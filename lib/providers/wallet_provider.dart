import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../models/notification_model.dart';
import '../config/app_constants.dart';
import '../services/firestore_service.dart';

class WalletProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  WalletModel? _wallet;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _error;
  StreamSubscription? _walletSubscription;

  WalletProvider(this._firestoreService);

  WalletModel? get wallet => _wallet;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void loadWallet(String userId) {
    _walletSubscription?.cancel();
    _walletSubscription = _firestoreService.getWalletStream(userId).listen(
      (wallet) {
        _wallet = wallet;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load wallet.';
        notifyListeners();
      },
    );
  }

  Future<void> ensureWalletExists(String userId) async {
    final existing = await _firestoreService.getWallet(userId);
    if (existing == null) {
      await _firestoreService.createWallet(userId);
    }
  }

  /// Loads transaction history (earnings from orders + withdrawals from payouts).
  Future<void> loadTransactions(String userId) async {
    _isLoadingTransactions = true;
    notifyListeners();

    try {
      final results = <Map<String, dynamic>>[];

      // Load delivered orders (earnings)
      final orders = await _firestoreService.getArtistOrders(userId);
      for (final order in orders) {
        if (order.isDelivered || order.status == AppConstants.orderPaid ||
            order.isProcessing || order.isShipped) {
          results.add({
            'type': 'earning',
            'amount': order.artistEarnings,
            'description': 'Order from ${order.customerName}',
            'status': order.isDelivered ? 'completed' : 'pending',
            'date': order.createdAt ?? DateTime.now(),
            'orderId': order.id,
          });
        }
        if (order.isRefunded) {
          results.add({
            'type': 'refund',
            'amount': -order.artistEarnings,
            'description': 'Refund - ${order.customerName}',
            'status': 'completed',
            'date': order.updatedAt ?? DateTime.now(),
            'orderId': order.id,
          });
        }
      }

      // Load payouts (withdrawals)
      final payouts = await _firestoreService.getArtistPayouts(userId);
      for (final payout in payouts) {
        results.add({
          'type': 'withdrawal',
          'amount': -(payout['amount'] as num).toDouble(),
          'description': 'Withdrawal',
          'status': payout['status'] ?? 'completed',
          'date': (payout['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'payoutId': payout['id'],
        });
      }

      // Sort by date descending
      results.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      _transactions = results;
      _isLoadingTransactions = false;
      notifyListeners();
    } catch (e) {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  /// Requests a withdrawal from the wallet. Creates a payout record
  /// and properly debits the wallet.
  Future<bool> requestWithdrawal(String userId, double amount) async {
    _setLoading(true);
    _error = null;

    try {
      if (_wallet == null || _wallet!.balance < amount) {
        _error = 'Insufficient balance.';
        _setLoading(false);
        return false;
      }

      if (amount < AppConstants.minWithdrawal) {
        _error =
            'Minimum withdrawal is \$${AppConstants.minWithdrawal.toStringAsFixed(2)}.';
        _setLoading(false);
        return false;
      }

      // Debit wallet (balance down, totalWithdrawn up)
      await _firestoreService.debitWallet(userId, amount);

      // Create a payout record
      await _firestoreService.createPayout({
        'artistId': userId,
        'artistName': '',
        'amount': amount,
        'currency': AppConstants.currency,
        'orderIds': [],
        'paymentMethod': 'wallet_withdrawal',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify artist
      await _firestoreService.createNotification(NotificationModel(
        userId: userId,
        title: 'Withdrawal Processed',
        message:
            'Your withdrawal of \$${amount.toStringAsFixed(2)} has been processed.',
        type: AppConstants.notifPayout,
      ));

      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Withdrawal failed.';
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }
}
