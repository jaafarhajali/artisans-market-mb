import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  bool _isLoading = false;
  String? _error;

  ReportProvider(this._firestoreService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> submitReport({
    required String postId,
    required String reporterId,
    required String reason,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = ReportModel(
        id: '',
        postId: postId,
        reporterId: reporterId,
        reason: reason,
      ).toFirestore();

      await _firestoreService.createReport(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to submit report.';
      _setLoading(false);
      return false;
    }
  }
}
