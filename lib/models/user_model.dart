import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;
  final String? category;
  final double? averageRating;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'active',
    this.createdAt,
    this.category,
    this.averageRating,
    this.profileImageUrl,
  });

  bool get isArtist => role == 'artist';
  bool get isCustomer => role == 'customer';
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      category: data['category'],
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (role == 'artist') {
      map['category'] = category ?? '';
      map['averageRating'] = averageRating ?? 0.0;
    }
    if (profileImageUrl != null) {
      map['profileImageUrl'] = profileImageUrl;
    }
    return map;
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? status,
    String? category,
    double? averageRating,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      category: category ?? this.category,
      averageRating: averageRating ?? this.averageRating,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
