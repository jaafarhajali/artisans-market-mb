import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../config/app_constants.dart';

class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<PostModel> _posts = [];
  List<PostModel> _myPosts = [];
  List<PostModel> _artistProfilePosts = [];
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _error;
  String? _selectedCategory;

  PostProvider(this._firestoreService);

  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;
  List<PostModel> get artistProfilePosts => _artistProfilePosts;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadActivePosts({String? category}) async {
    _setLoading(true);
    _error = null;

    try {
      _posts = await _firestoreService.getActivePosts(category: category);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load posts.';
      _setLoading(false);
    }
  }

  Future<void> loadMyPosts(String artistId) async {
    _setLoading(true);
    _error = null;

    try {
      _myPosts = await _firestoreService.getArtistPosts(artistId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load your posts.';
      _setLoading(false);
    }
  }

  /// Load posts for an artist's profile (separate from myPosts to avoid conflicts).
  /// If [activeOnly] is true, only active posts are returned.
  Future<void> loadArtistProfilePosts(String artistId,
      {bool activeOnly = true}) async {
    _isLoadingProfile = true;
    notifyListeners();
    _error = null;

    try {
      final allPosts = await _firestoreService.getArtistPosts(artistId);
      _artistProfilePosts =
          activeOnly ? allPosts.where((p) => p.isActive).toList() : allPosts;
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load artist posts.';
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String artistId,
    required String artistName,
    required String description,
    required String category,
    required double price,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = {
        'artistId': artistId,
        'artistName': artistName,
        'description': description,
        'category': category,
        'price': price,
        'status': AppConstants.postActive,
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.createPost(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to create post.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePost(
    String postId,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.updatePost(postId, data);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update post.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.deletePost(postId);
      _myPosts.removeWhere((p) => p.id == postId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to delete post.';
      _setLoading(false);
      return false;
    }
  }

  Future<int> getActivePostCount(String artistId) async {
    return await _firestoreService.getArtistActivePostCount(artistId);
  }
}
