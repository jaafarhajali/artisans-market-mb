import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<OrderModel> _customerOrders = [];
  List<OrderModel> _artistOrders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider(this._firestoreService);

  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get artistOrders => _artistOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Places orders from cart items grouped by artist.
  /// Returns list of order IDs on success, null on failure.
  Future<List<String>?> placeOrder({
    required String customerId,
    required String customerName,
    required Map<String, List<CartItemModel>> itemsByArtist,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final orderIds = <String>[];

      for (final entry in itemsByArtist.entries) {
        final artistId = entry.key;
        final items = entry.value;
        final artistName = items.first.artistName;

        // Calculate totals
        final subtotal =
            items.fold(0.0, (sum, item) => sum + item.subtotal);
        final platformFee = subtotal * AppConstants.platformFeePercent;
        final artistEarnings = subtotal - platformFee;

        // Create order items
        final orderItems = items
            .map((item) => OrderItemModel(
                  postId: item.postId,
                  title: item.title,
                  imageUrl: item.imageUrl,
                  price: item.price,
                  quantity: item.quantity,
                ))
            .toList();

        // Create order
        final order = OrderModel(
          id: '',
          customerId: customerId,
          customerName: customerName,
          artistId: artistId,
          artistName: artistName,
          items: orderItems,
          totalAmount: subtotal,
          platformFee: platformFee,
          artistEarnings: artistEarnings,
          status: AppConstants.orderPaid,
          paymentMethod: paymentMethod,
          payoutStatus: AppConstants.payoutUnpaid,
        );

        final orderId = await _firestoreService.createOrder(order);
        orderIds.add(orderId);

        // Create payment record
        final payment = PaymentModel(
          orderId: orderId,
          userId: customerId,
          amount: subtotal,
          method: paymentMethod,
          status: 'completed',
          type: AppConstants.paymentTypeOrder,
        );
        await _firestoreService.createPayment(payment);

        // Update artist wallet
        await _firestoreService.updateWalletBalance(artistId, artistEarnings);

        // Notify artist
        await _firestoreService.createNotification(NotificationModel(
          userId: artistId,
          title: 'New Order Received',
          message:
              'You have a new order from $customerName for \$${subtotal.toStringAsFixed(2)}',
          type: AppConstants.notifOrderPlaced,
          referenceId: orderId,
        ));

        // Notify customer
        await _firestoreService.createNotification(NotificationModel(
          userId: customerId,
          title: 'Order Placed',
          message:
              'Your order with $artistName has been placed successfully.',
          type: AppConstants.notifOrderPlaced,
          referenceId: orderId,
        ));
      }

      _setLoading(false);
      return orderIds;
    } catch (e) {
      _error = 'Failed to place order.';
      _setLoading(false);
      return null;
    }
  }

  Future<void> loadCustomerOrders(String customerId) async {
    _setLoading(true);
    _error = null;

    try {
      _customerOrders = await _firestoreService.getCustomerOrders(customerId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load orders.';
      _setLoading(false);
    }
  }

  Future<void> loadArtistOrders(String artistId) async {
    _setLoading(true);
    _error = null;

    try {
      _artistOrders = await _firestoreService.getArtistOrders(artistId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load orders.';
      _setLoading(false);
    }
  }

  Future<void> loadOrderDetail(String orderId) async {
    _setLoading(true);
    _error = null;

    try {
      _selectedOrder = await _firestoreService.getOrderById(orderId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load order details.';
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    _error = null;

    try {
      await _firestoreService.updateOrderStatus(orderId, status);

      // Update local lists
      _artistOrders = _artistOrders.map((o) {
        if (o.id == orderId) {
          return OrderModel(
            id: o.id,
            customerId: o.customerId,
            customerName: o.customerName,
            artistId: o.artistId,
            artistName: o.artistName,
            items: o.items,
            totalAmount: o.totalAmount,
            platformFee: o.platformFee,
            artistEarnings: o.artistEarnings,
            status: status,
            paymentMethod: o.paymentMethod,
            paymentId: o.paymentId,
            payoutStatus: o.payoutStatus,
            createdAt: o.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return o;
      }).toList();

      // Notify customer about status change
      final order = _artistOrders.firstWhere((o) => o.id == orderId,
          orElse: () => _customerOrders.firstWhere((o) => o.id == orderId));
      await _firestoreService.createNotification(NotificationModel(
        userId: order.customerId,
        title: 'Order Updated',
        message: 'Your order from ${order.artistName} is now ${order.statusDisplay}.',
        type: AppConstants.notifOrderStatus,
        referenceId: orderId,
      ));

      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update order status.';
      _setLoading(false);
      return false;
    }
  }
}
