import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String artistId;
  final String artistName;
  final String artistEmail;
  final String plan;
  final double amount;
  final String status;
  final int postLimit;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? assignedBy;

  SubscriptionModel({
    required this.artistId,
    required this.artistName,
    required this.artistEmail,
    required this.plan,
    required this.amount,
    required this.status,
    required this.postLimit,
    this.startDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.assignedBy,
  });

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';
  bool get isUnlimited => postLimit == -1;

  String get planDisplayName {
    switch (plan) {
      case 'basic':
        return 'Basic';
      case 'premium':
        return 'Premium';
      default:
        return 'Free';
    }
  }

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      artistId: doc.id,
      artistName: data['artistName'] ?? '',
      artistEmail: data['artistEmail'] ?? '',
      plan: data['plan'] ?? 'free',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'active',
      postLimit: (data['postLimit'] as num?)?.toInt() ?? 5,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      assignedBy: data['assignedBy'],
    );
  }
}
