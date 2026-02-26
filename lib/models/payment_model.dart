import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String method;
  final String status;
  final String type;
  final DateTime? createdAt;

  PaymentModel({
    this.id = '',
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    this.status = 'completed',
    required this.type,
    this.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      method: data['method'] ?? '',
      status: data['status'] ?? 'completed',
      type: data['type'] ?? 'order_payment',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
