import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../config/app_constants.dart';

class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  List<PostModel> _posts = [];
  List<PostModel> _myPosts = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  PostProvider(this._firestoreService, this._storageService);

  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;
  bool get isLoading => _isLoading;
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

  Future<bool> createPost({
    required String artistId,
    required String artistName,
    required String description,
    required String category,
    File? imageFile,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      String finalImageUrl = imageUrl ?? '';

      if (imageFile != null) {
        finalImageUrl =
            await _storageService.uploadPostImage(artistId, imageFile);
      }

      final data = {
        'artistId': artistId,
        'artistName': artistName,
        'description': description,
        'category': category,
        'status': AppConstants.postActive,
        'imageUrl': finalImageUrl,
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
    Map<String, dynamic> data, {
    File? newImageFile,
    String? artistId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (newImageFile != null && artistId != null) {
        final newUrl =
            await _storageService.uploadPostImage(artistId, newImageFile);
        data['imageUrl'] = newUrl;
      }

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
