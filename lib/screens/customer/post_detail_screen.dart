import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/post_model.dart';
import '../../models/cart_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/post_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  void _addToCart(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();
    final userId = auth.currentUser?.uid;

    if (userId == null) return;

    final item = CartItemModel(
      postId: post.id,
      artistId: post.artistId,
      artistName: post.artistName,
      title: post.description.length > 50
          ? '${post.description.substring(0, 50)}...'
          : post.description,
      imageUrl: post.imageUrl,
      price: post.price,
    );

    final success = await cartProv.addToCart(userId, item);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Added to cart!' : 'Failed to add to cart'),
        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF262626),
        elevation: 0,
        title: const Text(
          'Post',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current Post (Instagram-style detail) ──
            _buildPostDetail(context),

            const Divider(
              height: 1,
              thickness: 0.5,
              color: Color(0xFFEFEFEF),
            ),

            // ── More Posts Section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
              child: Row(
                children: [
                  Icon(Icons.dashboard_rounded, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'More Artwork',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            // ── All Posts Grid ──
            Consumer<PostProvider>(
              builder: (_, postProv, _) {
                final otherPosts =
                    postProv.posts.where((p) => p.id != post.id).toList();

                if (otherPosts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No more posts',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: otherPosts.length,
                  itemBuilder: (_, index) {
                    final otherPost = otherPosts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.postDetail,
                          arguments: otherPost,
                        );
                      },
                      child: otherPost.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: otherPost.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: const Color(0xFFF5F5F5),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Color(0xFFBDBDBD),
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(
                                Icons.image_outlined,
                                color: Color(0xFFBDBDBD),
                                size: 24,
                              ),
                            ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDetail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Avatar + Artist Name + Category ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.artistProfile,
                    arguments: {
                      'artistId': post.artistId,
                      'artistName': post.artistName,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AppTheme.brandGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        post.artistName.isNotEmpty
                            ? post.artistName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.artistProfile,
                      arguments: {
                        'artistId': post.artistId,
                        'artistName': post.artistName,
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.artistName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF262626),
                        ),
                      ),
                      Text(
                        post.category,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, size: 24),
                onPressed: () => _showOptions(context),
              ),
            ],
          ),
        ),

        // ── Image ──
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 1,
            child: post.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
          ),
        ),

        // ── Action Row: Appreciate / Rate / Bookmark + Cart ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Appreciate (admire the art)
              const Icon(
                Icons.auto_awesome_outlined,
                size: 28,
                color: Color(0xFF262626),
              ),
              const SizedBox(width: 16),
              // Rate the artist
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.rateArtist,
                    arguments: {
                      'artistId': post.artistId,
                      'artistName': post.artistName,
                    },
                  );
                },
                child: const Icon(
                  Icons.star_outline_rounded,
                  size: 28,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(width: 16),
              // Bookmark / collect
              const Icon(
                Icons.bookmark_border_rounded,
                size: 26,
                color: Color(0xFF262626),
              ),
              const Spacer(),
              if (post.price > 0)
                GestureDetector(
                  onTap: () => _addToCart(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.brandGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '\$${post.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Description ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF262626),
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: post.artistName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '  '),
                TextSpan(text: post.description),
              ],
            ),
          ),
        ),

        // ── Time + Category ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(
            children: [
              Text(
                _timeAgo(post.createdAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.category,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  void _showOptions(BuildContext context) {
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
              leading: const Icon(Icons.star_rate_outlined, color: AppTheme.accent),
              title: const Text('Rate this Artist'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.rateArtist,
                  arguments: {
                    'artistId': post.artistId,
                    'artistName': post.artistName,
                  },
                );
              },
            ),
            if (post.price > 0)
              ListTile(
                leading: const Icon(Icons.add_shopping_cart_rounded,
                    color: AppTheme.primary),
                title: const Text('Add to Cart'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addToCart(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('View Artist Profile'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.artistProfile,
                  arguments: {
                    'artistId': post.artistId,
                    'artistName': post.artistName,
                  },
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.report_gmailerrorred_outlined, color: Color(0xFFED4956)),
              title: const Text(
                'Report this Post',
                style: TextStyle(color: Color(0xFFED4956)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.reportPost,
                  arguments: post.id,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
