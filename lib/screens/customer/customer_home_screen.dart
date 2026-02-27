import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../screens/shared/profile_screen.dart';
import '../../screens/customer/cart_screen.dart';
import '../../screens/customer/orders_screen.dart';
import '../../screens/shared/notifications_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      context.read<PostProvider>().loadActivePosts();
      if (uid != null) {
        context.read<CartProvider>().loadCart(uid);
        context.read<NotificationProvider>().startListening(uid);
      }
    });
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);
    context.read<PostProvider>().loadActivePosts(category: category);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildFeed(),
      const CartScreen(),
      const OrdersScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[_currentIndex],
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
                    ? Icons.storefront_rounded
                    : Icons.storefront_outlined,
                size: 26,
              ),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cartProv, child) {
                  final count = cartProv.itemCount;
                  final icon = Icon(
                    _currentIndex == 1
                        ? Icons.palette_rounded
                        : Icons.palette_outlined,
                    size: 26,
                  );
                  if (count == 0) return icon;
                  return Badge(
                    label: Text(
                      '$count',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: icon,
                  );
                },
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? Icons.local_shipping_rounded
                    : Icons.local_shipping_outlined,
                size: 26,
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Consumer<NotificationProvider>(
                builder: (_, notifProv, child) {
                  final count = notifProv.unreadCount;
                  final icon = Icon(
                    _currentIndex == 3
                        ? Icons.notifications_rounded
                        : Icons.notifications_outlined,
                    size: 26,
                  );
                  if (count == 0) return icon;
                  return Badge(
                    label: Text(
                      '$count',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: icon,
                  );
                },
              ),
              label: 'Alerts',
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

  Widget _buildFeed() {
    return SafeArea(
      child: Column(
        children: [
          // ── App Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Brand icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.brandGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Artisans Market',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF262626),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 3),
                  child: Consumer<NotificationProvider>(
                    builder: (_, notifProv, _) {
                      final count = notifProv.unreadCount;
                      return count > 0
                          ? Badge(
                              label: Text(
                                '$count',
                                style: const TextStyle(fontSize: 10),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                size: 26,
                                color: Color(0xFF262626),
                              ),
                            )
                          : const Icon(
                              Icons.notifications_outlined,
                              size: 26,
                              color: Color(0xFF262626),
                            );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Consumer<CartProvider>(
                    builder: (_, cartProv, _) {
                      final count = cartProv.itemCount;
                      return count > 0
                          ? Badge(
                              label: Text(
                                '$count',
                                style: const TextStyle(fontSize: 10),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 26,
                                color: Color(0xFF262626),
                              ),
                            )
                          : const Icon(
                              Icons.shopping_cart_outlined,
                              size: 26,
                              color: Color(0xFF262626),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Category Chips (circle style) ──
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildStoryChip(
                  'All',
                  Icons.apps_rounded,
                  _selectedCategory == null,
                  () => _onCategorySelected(null),
                ),
                ...AppConstants.categories.map(
                  (cat) => _buildStoryChip(
                    cat,
                    _getCategoryIcon(cat),
                    _selectedCategory == cat,
                    () => _onCategorySelected(cat),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFEFEFEF),
          ),

          // ── Posts Feed ──
          Expanded(
            child: Consumer<PostProvider>(
              builder: (_, postProv, _) {
                if (postProv.isLoading) {
                  return const LoadingIndicator(message: 'Loading posts...');
                }

                if (postProv.posts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.palette_outlined,
                    message: 'No artwork found.\nCheck back later!',
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () =>
                      postProv.loadActivePosts(category: _selectedCategory),
                  child: ListView.builder(
                    itemCount: postProv.posts.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, i) {
                      final post = postProv.posts[i];
                      return PostCard(
                        post: post,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.postDetail,
                            arguments: post,
                          );
                        },
                        onArtistTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.artistProfile,
                            arguments: {
                              'artistId': post.artistId,
                              'artistName': post.artistName,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: AppTheme.brandGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFDBDBDB), width: 2),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? AppTheme.primary
                        : const Color(0xFF8E8E8E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.length > 8 ? '${label.substring(0, 7)}.' : label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF262626)
                    : const Color(0xFF8E8E8E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Painting':
        return Icons.brush_rounded;
      case 'Sculpture':
        return Icons.architecture_rounded;
      case 'Photography':
        return Icons.camera_alt_rounded;
      case 'Digital Art':
        return Icons.desktop_mac_rounded;
      case 'Crafts':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
