import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/firestore_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  SubscriptionModel? _subscription;
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider(this._firestoreService);

  SubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSubscription => _subscription != null;
  bool get isActive => _subscription?.isActive ?? false;
  int get postLimit => _subscription?.postLimit ?? 0;
  String get planName => _subscription?.planDisplayName ?? 'None';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadSubscription(String artistId) async {
    _setLoading(true);
    _error = null;

    try {
      _subscription = await _firestoreService.getSubscription(artistId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load subscription.';
      _setLoading(false);
    }
  }

  Future<bool> subscribeToPlan({
    required String artistId,
    required String artistName,
    required String artistEmail,
    required String planKey,
    required double amount,
    required int postLimit,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.subscribeToPlan(
        artistId: artistId,
        artistName: artistName,
        artistEmail: artistEmail,
        planKey: planKey,
        amount: amount,
        postLimit: postLimit,
      );
      await loadSubscription(artistId);
      return true;
    } catch (e) {
      _error = 'Failed to subscribe. Please try again.';
      _setLoading(false);
      return false;
    }
  }
}
