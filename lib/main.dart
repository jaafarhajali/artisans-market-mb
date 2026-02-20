import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/report_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/user_provider.dart';
import 'models/post_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/post_detail_screen.dart';
import 'screens/customer/rate_artist_screen.dart';
import 'screens/customer/report_post_screen.dart';
import 'screens/artist/artist_home_screen.dart';
import 'screens/artist/edit_post_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ArtisansMarketApp());
}

class ArtisansMarketApp extends StatelessWidget {
  const ArtisansMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(firestoreService, storageService),
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
