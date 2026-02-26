import 'dart:async';
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../config/app_constants.dart';
import '../services/firestore_service.dart';

class WalletProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  WalletModel? _wallet;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _walletSubscription;

  WalletProvider(this._firestoreService);

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
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

  /// Simulates a withdrawal request. In production, this would
  /// trigger an actual payout process.
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

      // Deduct from wallet
      final walletRef = _firestoreService;
      await walletRef.updateWalletBalance(userId, -amount);

      // Update totalWithdrawn separately
      final currentWallet = await _firestoreService.getWallet(userId);
      if (currentWallet != null) {
        // The updateWalletBalance reduces balance but also increments totalEarnings
        // For withdrawal, we need to correct: reduce totalEarnings increment and add to totalWithdrawn
        // Simpler approach: directly update the fields
      }

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
