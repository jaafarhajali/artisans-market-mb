class AppConstants {
  // Categories (must match admin panel exactly)
  static const List<String> categories = [
    'Painting',
    'Sculpture',
    'Photography',
    'Digital Art',
    'Crafts',
  ];

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleArtist = 'artist';

  // User status
  static const String statusActive = 'active';
  static const String statusSuspended = 'suspended';

  // Post status
  static const String postActive = 'active';
  static const String postReported = 'reported';
  static const String postRemoved = 'removed';

  // Report status
  static const String reportPending = 'pending';
  static const String reportReviewed = 'reviewed';

  // Order statuses
  static const String orderPending = 'pending';
  static const String orderPaid = 'paid';
  static const String orderProcessing = 'processing';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderRefunded = 'refunded';

  // Payout status
  static const String payoutUnpaid = 'unpaid';
  static const String payoutPaid = 'paid_out';

  // Payment constants
  static const double platformFeePercent = 0.10;
  static const double minWithdrawal = 20.0;
  static const int refundDays = 7;
  static const String currency = 'USD';

  // Payment methods
  static const String paymentVirtualCard = 'virtual_card';
  static const String paymentVirtualVisa = 'virtual_visa';

  // Payment types
  static const String paymentTypeOrder = 'order_payment';
  static const String paymentTypeRefund = 'refund';
  static const String paymentTypePayout = 'payout';

  // Notification types
  static const String notifOrderPlaced = 'order_placed';
  static const String notifOrderStatus = 'order_status';
  static const String notifPaymentReceived = 'payment_received';
  static const String notifPayout = 'payout';

  // Subscription plans
  static const Map<String, Map<String, dynamic>> plans = {
    'free': {'name': 'Free', 'amount': 0.0, 'postLimit': 5},
    'basic': {'name': 'Basic', 'amount': 9.99, 'postLimit': 25},
    'premium': {'name': 'Premium', 'amount': 24.99, 'postLimit': -1},
  };

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String reportsCollection = 'reports';
  static const String ratingsCollection = 'ratings';
  static const String subscriptionsCollection = 'subscriptions';
  static const String adminsCollection = 'admins';
  static const String ordersCollection = 'orders';
  static const String paymentsCollection = 'payments';
  static const String walletsCollection = 'wallets';
  static const String notificationsCollection = 'notifications';
  static const String cartSubcollection = 'cart';

  // Pagination
  static const int pageSize = 20;
}
