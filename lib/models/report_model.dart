import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String postId;
  final String reporterId;
  final String reason;
  final String status;
  final DateTime? createdAt;

  ReportModel({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    this.status = 'pending',
    this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
