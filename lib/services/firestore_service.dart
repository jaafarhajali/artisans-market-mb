import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/rating_model.dart';
import '../models/subscription_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // USERS
  // ==========================================

  Future<void> createUserDocument(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).set(data);
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserDocument(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  Future<String> getUserStatus(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return 'active';
    return (doc.data() as Map<String, dynamic>)['status'] ?? 'active';
  }

  // ==========================================
  // POSTS
  // ==========================================

  Future<List<PostModel>> getActivePosts({String? category}) async {
    Query query = _db
        .collection(AppConstants.postsCollection)
        .where('status', isEqualTo: AppConstants.postActive);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<List<PostModel>> getArtistPosts(String artistId) async {
    final snapshot = await _db
        .collection(AppConstants.postsCollection)
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<int> getArtistActivePostCount(String artistId) async {
    final snapshot = await _db
        .collection(AppConstants.postsCollection)
        .where('artistId', isEqualTo: artistId)
        .where('status', isEqualTo: AppConstants.postActive)
        .get();

    return snapshot.size;
  }

  Future<DocumentReference> createPost(Map<String, dynamic> data) async {
    return await _db.collection(AppConstants.postsCollection).add(data);
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.postsCollection).doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection(AppConstants.postsCollection).doc(postId).delete();
  }

  // ==========================================
  // REPORTS
  // ==========================================

  Future<void> createReport(Map<String, dynamic> data) async {
    await _db.collection(AppConstants.reportsCollection).add(data);
  }

  // ==========================================
  // RATINGS
  // ==========================================

  Future<void> createRating(Map<String, dynamic> data) async {
    await _db.collection(AppConstants.ratingsCollection).add(data);
  }

  Future<void> updateRating(
    String ratingId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection(AppConstants.ratingsCollection)
        .doc(ratingId)
        .update(data);
  }

  Future<List<RatingModel>> getArtistRatings(String artistId) async {
    final snapshot = await _db
        .collection(AppConstants.ratingsCollection)
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
  }

  Future<RatingModel?> getExistingRating(
    String customerId,
    String artistId,
  ) async {
    final snapshot = await _db
        .collection(AppConstants.ratingsCollection)
        .where('customerId', isEqualTo: customerId)
        .where('artistId', isEqualTo: artistId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return RatingModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> updateArtistAverageRating(String artistId) async {
    final ratingsSnap = await _db
        .collection(AppConstants.ratingsCollection)
        .where('artistId', isEqualTo: artistId)
        .get();

    if (ratingsSnap.docs.isEmpty) {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(artistId)
          .update({'averageRating': 0.0});
      return;
    }

    double total = 0;
    for (final doc in ratingsSnap.docs) {
      total += ((doc.data())['stars'] as num?)?.toDouble() ?? 0;
    }
    final average = total / ratingsSnap.docs.length;

    await _db
        .collection(AppConstants.usersCollection)
        .doc(artistId)
        .update({'averageRating': average});
  }

  // ==========================================
  // SUBSCRIPTIONS
  // ==========================================

  Future<SubscriptionModel?> getSubscription(String artistId) async {
    final doc = await _db
        .collection(AppConstants.subscriptionsCollection)
        .doc(artistId)
        .get();

    if (!doc.exists) return null;
    return SubscriptionModel.fromFirestore(doc);
  }
}
