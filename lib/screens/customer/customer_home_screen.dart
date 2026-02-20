import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../screens/shared/profile_screen.dart';

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
      context.read<PostProvider>().loadActivePosts();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);
    context.read<PostProvider>().loadActivePosts(category: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildFeed() : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Artisans Market',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => Text(
                    'Hi, ${auth.currentUser?.name.split(' ').first ?? 'there'}!',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => _onCategorySelected(null),
                ),
                const SizedBox(width: 8),
                ...AppConstants.categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () => _onCategorySelected(cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Posts List
          Expanded(
            child: Consumer<PostProvider>(
              builder: (_, postProv, __) {
                if (postProv.isLoading) {
                  return const LoadingIndicator(message: 'Loading posts...');
                }

                if (postProv.posts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.art_track,
                    message: 'No posts found.\nCheck back later!',
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => postProv.loadActivePosts(
                    category: _selectedCategory,
                  ),
                  child: ListView.builder(
                    itemCount: postProv.posts.length,
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
}
