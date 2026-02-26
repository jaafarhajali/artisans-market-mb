import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String postId;
  final String artistId;
  final String artistName;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final DateTime? addedAt;

  CartItemModel({
    this.id = '',
    required this.postId,
    required this.artistId,
    required this.artistName,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.addedAt,
  });

  double get subtotal => price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      postId: postId,
      artistId: artistId,
      artistName: artistName,
      title: title,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
    );
  }

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'artistId': artistId,
      'artistName': artistName,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
