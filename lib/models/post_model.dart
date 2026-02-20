import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String artistId;
  final String artistName;
  final String description;
  final String category;
  final String status;
  final String imageUrl;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.description,
    required this.category,
    this.status = 'active',
    required this.imageUrl,
    this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isRemoved => status == 'removed';
  bool get isReported => status == 'reported';

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'active',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'artistId': artistId,
      'artistName': artistName,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
