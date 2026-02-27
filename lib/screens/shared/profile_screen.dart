import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/rating_stars.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.role == AppConstants.roleArtist) {
        context
            .read<PostProvider>()
            .loadArtistProfilePosts(user.uid, activeOnly: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF262626),
        elevation: 0,
        title: Consumer<AuthProvider>(
          builder: (_, auth, _) => Text(
            auth.currentUser?.name ?? 'Profile',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF262626),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 26),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, _) {
          final user = auth.currentUser;
          if (user == null) return const SizedBox.shrink();

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              await auth.refreshUser();
              if (user.role == AppConstants.roleArtist) {
                await context
                    .read<PostProvider>()
                    .loadArtistProfilePosts(user.uid, activeOnly: false);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Profile Header (Instagram-style) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Avatar
                        _buildAvatar(user.profileImageUrl, user.name),
                        const SizedBox(width: 24),

                        // Stats
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (user.role == AppConstants.roleArtist)
                                Consumer<PostProvider>(
                                  builder: (_, postProv, _) => _buildStat(
                                    postProv.artistProfilePosts.length
                                        .toString(),
                                    'Posts',
                                  ),
                                ),
                              if (user.role == AppConstants.roleArtist &&
                                  user.averageRating != null)
                                _buildStat(
                                  user.averageRating!.toStringAsFixed(1),
                                  'Rating',
                                ),
                              _buildStat(
                                user.role == AppConstants.roleArtist
                                    ? 'Artist'
                                    : 'Customer',
                                'Role',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Name + Bio ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF262626),
                          ),
                        ),
                        if (user.role == AppConstants.roleArtist &&
                            user.category != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.category!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        if (user.role == AppConstants.roleArtist &&
                            user.averageRating != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingStars(
                                  rating: user.averageRating!, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '(${user.averageRating!.toStringAsFixed(1)})',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Edit Profile Button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                      context, AppRoutes.editProfile)
                                  .then((_) {
                                context.read<AuthProvider>().refreshUser();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF262626),
                              side: const BorderSide(
                                  color: Color(0xFFDBDBDB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (user.role == AppConstants.roleArtist) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.subscription);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF262626),
                                side: const BorderSide(
                                    color: Color(0xFFDBDBDB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                'Subscription',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Posts Grid (Artists only) ──
                  if (user.role == AppConstants.roleArtist) ...[
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xFFEFEFEF),
                    ),

                    // Grid/List tab indicator
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF262626),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard_rounded,
                              size: 24,
                              color: Color(0xFF262626),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Posts Grid
                    Consumer<PostProvider>(
                      builder: (_, postProv, _) {
                        if (postProv.isLoadingProfile) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final posts = postProv.artistProfilePosts;

                        if (posts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
                                    size: 48,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No posts yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF262626),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Share your art with the world',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8E8E8E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return _buildPostsGrid(posts);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, String name) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppTheme.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                    errorWidget: (_, _, _) => Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid(List<PostModel> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.postDetail,
              arguments: post,
            );
          },
          child: post.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                )
              : Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.editProfile).then((_) {
                  context.read<AuthProvider>().refreshUser();
                });
              },
            ),
            Consumer<AuthProvider>(
              builder: (_, auth, _) {
                if (auth.currentUser?.role == AppConstants.roleArtist) {
                  return ListTile(
                    leading: const Icon(Icons.card_membership_outlined),
                    title: const Text('My Subscription'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, AppRoutes.subscription);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFED4956)),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFED4956)),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dlgCtx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dlgCtx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dlgCtx, true),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Color(0xFFED4956)),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (_) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
