import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'my_posts_screen.dart';
import 'create_post_screen.dart';
import 'artist_orders_screen.dart';
import 'wallet_screen.dart';
import '../shared/profile_screen.dart';

class ArtistHomeScreen extends StatefulWidget {
  const ArtistHomeScreen({super.key});

  @override
  State<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends State<ArtistHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MyPostsScreen(),
    CreatePostScreen(),
    ArtistOrdersScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<NotificationProvider>().startListening(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFEFEFEF), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: const Color(0xFF8E8E8E),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0
                    ? Icons.photo_library_rounded
                    : Icons.photo_library_outlined,
                size: 26,
              ),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.brush_rounded
                    : Icons.brush_outlined,
                size: 26,
              ),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? Icons.inventory_2_rounded
                    : Icons.inventory_2_outlined,
                size: 26,
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3
                    ? Icons.account_balance_wallet_rounded
                    : Icons.account_balance_wallet_outlined,
                size: 26,
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 4
                    ? Icons.account_circle_rounded
                    : Icons.account_circle_outlined,
                size: 26,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
