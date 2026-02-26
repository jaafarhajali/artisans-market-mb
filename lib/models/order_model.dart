import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String postId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.postId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      postId: data['postId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get subtotal => price * quantity;
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String artistId;
  final String artistName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double platformFee;
  final double artistEarnings;
  final String status;
  final String paymentMethod;
  final String paymentId;
  final String payoutStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.artistId,
    required this.artistName,
    required this.items,
    required this.totalAmount,
    required this.platformFee,
    required this.artistEarnings,
    this.status = 'pending',
    required this.paymentMethod,
    this.paymentId = '',
    this.payoutStatus = 'unpaid',
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';
  bool get isActive => !isCancelled && !isRefunded && !isDelivered;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      platformFee: (data['platformFee'] ?? 0.0).toDouble(),
      artistEarnings: (data['artistEarnings'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentId: data['paymentId'] ?? '',
      payoutStatus: data['payoutStatus'] ?? 'unpaid',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'artistId': artistId,
      'artistName': artistName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'artistEarnings': artistEarnings,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'payoutStatus': payoutStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
