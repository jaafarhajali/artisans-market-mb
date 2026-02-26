import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;
  final double balance;
  final double totalEarnings;
  final double totalWithdrawn;
  final DateTime? lastUpdated;

  WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.totalEarnings = 0.0,
    this.totalWithdrawn = 0.0,
    this.lastUpdated,
  });

  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletModel(
      userId: doc.id,
      balance: (data['balance'] ?? 0.0).toDouble(),
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0.0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'totalEarnings': totalEarnings,
      'totalWithdrawn': totalWithdrawn,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
