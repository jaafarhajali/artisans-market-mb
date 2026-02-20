import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String artistId;
  final String customerId;
  final int stars;
  final String feedback;
  final DateTime? createdAt;

  RatingModel({
    required this.id,
    required this.artistId,
    required this.customerId,
    required this.stars,
    required this.feedback,
    this.createdAt,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      artistId: data['artistId'] ?? '',
      customerId: data['customerId'] ?? '',
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      feedback: data['feedback'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'artistId': artistId,
      'customerId': customerId,
      'stars': stars,
      'feedback': feedback,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
