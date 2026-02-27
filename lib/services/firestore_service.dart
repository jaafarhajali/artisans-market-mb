import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/rating_model.dart';
import '../models/subscription_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../models/wallet_model.dart';
import '../models/notification_model.dart';

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

  Future<void> subscribeToPlan({
    required String artistId,
    required String artistName,
    required String artistEmail,
    required String planKey,
    required double amount,
    required int postLimit,
  }) async {
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 30));

    await _db
        .collection(AppConstants.subscriptionsCollection)
        .doc(artistId)
        .set({
      'artistName': artistName,
      'artistEmail': artistEmail,
      'plan': planKey,
      'amount': amount,
      'postLimit': postLimit,
      'status': 'active',
      'startDate': Timestamp.fromDate(now),
      'expiryDate': Timestamp.fromDate(expiry),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // CART
  // ==========================================

  Stream<List<CartItemModel>> getCartItems(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartSubcollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItemModel.fromFirestore(doc)).toList());
  }

  Future<void> addToCart(String userId, CartItemModel item) async {
    // Check if item already exists in cart
    final existing = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartSubcollection)
        .where('postId', isEqualTo: item.postId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update quantity
      final currentQty = existing.docs.first.data()['quantity'] ?? 1;
      await existing.docs.first.reference
          .update({'quantity': currentQty + item.quantity});
    } else {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.cartSubcollection)
          .add(item.toFirestore());
    }
  }

  Future<void> updateCartQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartSubcollection)
        .doc(cartItemId)
        .update({'quantity': quantity});
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartSubcollection)
        .doc(cartItemId)
        .delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartSubcollection)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ==========================================
  // ORDERS
  // ==========================================

  Future<String> createOrder(OrderModel order) async {
    final docRef = await _db
        .collection(AppConstants.ordersCollection)
        .add(order.toFirestore());
    return docRef.id;
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final snapshot = await _db
        .collection(AppConstants.ordersCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  Future<List<OrderModel>> getArtistOrders(String artistId) async {
    final snapshot = await _db
        .collection(AppConstants.ordersCollection)
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .get();

    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection(AppConstants.ordersCollection).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // PAYMENTS
  // ==========================================

  Future<String> createPayment(PaymentModel payment) async {
    final docRef = await _db
        .collection(AppConstants.paymentsCollection)
        .add(payment.toFirestore());
    return docRef.id;
  }

  Future<List<PaymentModel>> getPaymentsByOrder(String orderId) async {
    final snapshot = await _db
        .collection(AppConstants.paymentsCollection)
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
  }

  // ==========================================
  // WALLETS
  // ==========================================

  Future<WalletModel?> getWallet(String userId) async {
    final doc = await _db
        .collection(AppConstants.walletsCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return WalletModel.fromFirestore(doc);
  }

  Stream<WalletModel?> getWalletStream(String userId) {
    return _db
        .collection(AppConstants.walletsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return WalletModel.fromFirestore(doc);
    });
  }

  Future<void> createWallet(String userId) async {
    await _db.collection(AppConstants.walletsCollection).doc(userId).set({
      'balance': 0.0,
      'totalEarnings': 0.0,
      'totalWithdrawn': 0.0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Credits earnings to an artist's wallet (balance + totalEarnings go up).
  Future<void> creditWallet(String userId, double amount) async {
    final walletRef =
        _db.collection(AppConstants.walletsCollection).doc(userId);
    final doc = await walletRef.get();

    if (!doc.exists) {
      await walletRef.set({
        'balance': amount,
        'totalEarnings': amount,
        'totalWithdrawn': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await walletRef.update({
        'balance': FieldValue.increment(amount),
        'totalEarnings': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Debits from wallet for withdrawals (balance goes down, totalWithdrawn goes up).
  Future<void> debitWallet(String userId, double amount) async {
    final walletRef =
        _db.collection(AppConstants.walletsCollection).doc(userId);
    final doc = await walletRef.get();

    if (!doc.exists) return;

    await walletRef.update({
      'balance': FieldValue.increment(-amount),
      'totalWithdrawn': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Reverses earnings on refund (balance + totalEarnings go down).
  Future<void> reverseWalletEarnings(String userId, double amount) async {
    final walletRef =
        _db.collection(AppConstants.walletsCollection).doc(userId);
    final doc = await walletRef.get();

    if (!doc.exists) return;

    await walletRef.update({
      'balance': FieldValue.increment(-amount),
      'totalEarnings': FieldValue.increment(-amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // PAYOUTS
  // ==========================================

  Future<String> createPayout(Map<String, dynamic> data) async {
    final docRef = await _db.collection('payouts').add(data);
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getArtistPayouts(String artistId) async {
    final snapshot = await _db
        .collection('payouts')
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateOrderPayoutStatus(
    String orderId,
    String payoutStatus, {
    String? payoutId,
  }) async {
    final updates = <String, dynamic>{
      'payoutStatus': payoutStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (payoutId != null) {
      updates['payoutId'] = payoutId;
    }
    await _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update(updates);
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .add(notification.toFirestore());
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Stream<int> getUnreadNotificationCount(String userId) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
