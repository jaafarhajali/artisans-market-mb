import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _cartSubscription;

  CartProvider(this._firestoreService);

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  Map<String, List<CartItemModel>> get itemsByArtist {
    final map = <String, List<CartItemModel>>{};
    for (final item in _cartItems) {
      map.putIfAbsent(item.artistId, () => []).add(item);
    }
    return map;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void loadCart(String userId) {
    _cartSubscription?.cancel();
    _cartSubscription = _firestoreService.getCartItems(userId).listen(
      (items) {
        _cartItems = items;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load cart.';
        notifyListeners();
      },
    );
  }

  Future<bool> addToCart(String userId, CartItemModel item) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.addToCart(userId, item);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to add item to cart.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    _error = null;

    try {
      if (quantity <= 0) {
        await _firestoreService.removeFromCart(userId, cartItemId);
      } else {
        await _firestoreService.updateCartQuantity(
            userId, cartItemId, quantity);
      }
      return true;
    } catch (e) {
      _error = 'Failed to update quantity.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String userId, String cartItemId) async {
    _error = null;

    try {
      await _firestoreService.removeFromCart(userId, cartItemId);
      return true;
    } catch (e) {
      _error = 'Failed to remove item.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    _error = null;

    try {
      await _firestoreService.clearCart(userId);
      return true;
    } catch (e) {
      _error = 'Failed to clear cart.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
