import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/firestore_service.dart';

class RatingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<RatingModel> _artistRatings = [];
  bool _isLoading = false;
  String? _error;

  RatingProvider(this._firestoreService);

  List<RatingModel> get artistRatings => _artistRatings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadArtistRatings(String artistId) async {
    _setLoading(true);
    _error = null;

    try {
      _artistRatings = await _firestoreService.getArtistRatings(artistId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load ratings.';
      _setLoading(false);
    }
  }

  Future<RatingModel?> getExistingRating(
    String customerId,
    String artistId,
  ) async {
    return await _firestoreService.getExistingRating(customerId, artistId);
  }

  Future<bool> submitRating({
    required String artistId,
    required String customerId,
    required int stars,
    required String feedback,
    String? existingRatingId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (existingRatingId != null) {
        await _firestoreService.updateRating(existingRatingId, {
          'stars': stars,
          'feedback': feedback,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = RatingModel(
          id: '',
          artistId: artistId,
          customerId: customerId,
          stars: stars,
          feedback: feedback,
        ).toFirestore();
        await _firestoreService.createRating(data);
      }

      await _firestoreService.updateArtistAverageRating(artistId);

      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to submit rating.';
      _setLoading(false);
      return false;
    }
  }
}
