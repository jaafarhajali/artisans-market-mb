import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';

class PaymentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  PaymentProvider(this._firestoreService);

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadOrderPayments(String orderId) async {
    _setLoading(true);
    _error = null;

    try {
      _payments = await _firestoreService.getPaymentsByOrder(orderId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load payments.';
      _setLoading(false);
    }
  }

  /// Simulates payment processing — always succeeds instantly.
  Future<String?> processPayment({
    required String orderId,
    required String userId,
    required double amount,
    required String method,
    required String type,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final payment = PaymentModel(
        orderId: orderId,
        userId: userId,
        amount: amount,
        method: method,
        status: 'completed',
        type: type,
      );

      final paymentId = await _firestoreService.createPayment(payment);
      _setLoading(false);
      return paymentId;
    } catch (e) {
      _error = 'Payment failed.';
      _setLoading(false);
      return null;
    }
  }
}
