import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/post_model.dart';
import '../../widgets/common/custom_button.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: post.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.background,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.background,
                        child: const Icon(Icons.image_not_supported,
                            size: 64, color: AppTheme.textLight),
                      ),
                    )
                  : Container(
                      color: AppTheme.background,
                      child: const Icon(Icons.image,
                          size: 64, color: AppTheme.textLight),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist Name + Category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.artistName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              post.category,
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.category,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.description,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        post.createdAt != null
                            ? DateFormat.yMMMMd().format(post.createdAt!)
                            : 'N/A',
                        style: const TextStyle(
                            color: AppTheme.textLight, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  CustomButton(
                    label: 'Rate this Artist',
                    icon: Icons.star,
                    color: AppTheme.accentGold,
                    onPressed: () {
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
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'Report this Post',
                    icon: Icons.flag,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.reportPost,
                        arguments: post.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
