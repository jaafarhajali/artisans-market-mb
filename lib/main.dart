import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'config/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/report_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/notification_provider.dart';
import 'models/post_model.dart';
import 'models/order_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/post_detail_screen.dart';
import 'screens/customer/rate_artist_screen.dart';
import 'screens/customer/report_post_screen.dart';
import 'screens/customer/artist_public_profile_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/orders_screen.dart';
import 'screens/customer/order_detail_screen.dart';
import 'screens/artist/artist_home_screen.dart';
import 'screens/artist/edit_post_screen.dart';
import 'screens/artist/artist_orders_screen.dart';
import 'screens/artist/wallet_screen.dart';
import 'screens/artist/subscription_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const ArtisansMarketApp());
}

class ArtisansMarketApp extends StatelessWidget {
  const ArtisansMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => RatingProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(firestoreService),
        ),
      ],
      child: MaterialApp(
        title: 'Artisans Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(
                  builder: (_) => const LoginScreen());
            case AppRoutes.register:
              return MaterialPageRoute(
                  builder: (_) => const RegisterScreen());
            case AppRoutes.forgotPassword:
              return MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen());
            case AppRoutes.customerHome:
              return MaterialPageRoute(
                  builder: (_) => const CustomerHomeScreen());
            case AppRoutes.artistHome:
              return MaterialPageRoute(
                  builder: (_) => const ArtistHomeScreen());
            case AppRoutes.postDetail:
              final post = settings.arguments as PostModel;
              return MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: post));
            case AppRoutes.rateArtist:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => RateArtistScreen(
                  artistId: args['artistId'] as String,
                  artistName: args['artistName'] as String,
                ),
              );
            case AppRoutes.reportPost:
              final postId = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => ReportPostScreen(postId: postId));
            case AppRoutes.editPost:
              final post = settings.arguments as PostModel;
              return MaterialPageRoute(
                  builder: (_) => EditPostScreen(post: post));
            case AppRoutes.profile:
              return MaterialPageRoute(
                  builder: (_) => const ProfileScreen());
            case AppRoutes.editProfile:
              return MaterialPageRoute(
                  builder: (_) => const EditProfileScreen());
            case AppRoutes.cart:
              return MaterialPageRoute(
                  builder: (_) => const CartScreen());
            case AppRoutes.checkout:
              return MaterialPageRoute(
                  builder: (_) => const CheckoutScreen());
            case AppRoutes.customerOrders:
              return MaterialPageRoute(
                  builder: (_) => const OrdersScreen());
            case AppRoutes.orderDetail:
              final order = settings.arguments as OrderModel;
              return MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: order));
            case AppRoutes.artistOrders:
              return MaterialPageRoute(
                  builder: (_) => const ArtistOrdersScreen());
            case AppRoutes.wallet:
              return MaterialPageRoute(
                  builder: (_) => const WalletScreen());
            case AppRoutes.subscription:
              return MaterialPageRoute(
                  builder: (_) => const SubscriptionScreen());
            case AppRoutes.notifications:
              return MaterialPageRoute(
                  builder: (_) => const NotificationsScreen());
            case AppRoutes.artistProfile:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ArtistPublicProfileScreen(
                  artistId: args['artistId'] as String,
                  artistName: args['artistName'] as String,
                ),
              );
            default:
              return MaterialPageRoute(
                  builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.refreshUser();

    if (mounted) {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    if (auth.isArtist) {
      return const ArtistHomeScreen();
    }

    return const CustomerHomeScreen();
  }
}
