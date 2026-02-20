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

  // Pagination
  static const int pageSize = 20;
}
