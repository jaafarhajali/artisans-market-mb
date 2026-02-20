import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  UserModel? _viewedArtist;
  bool _isLoading = false;

  UserProvider(this._firestoreService);

  UserModel? get viewedArtist => _viewedArtist;
  bool get isLoading => _isLoading;

  Future<void> loadArtist(String artistId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _viewedArtist = await _firestoreService.getUserDocument(artistId);
    } catch (e) {
      _viewedArtist = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
