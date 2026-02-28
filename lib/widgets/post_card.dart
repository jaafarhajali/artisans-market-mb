import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onArtistTap;
  final bool showStatus;
  final Widget? trailing;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onArtistTap,
    this.showStatus = false,
    this.trailing,
  });

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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Artist Name + Category + Time ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Brand gradient-bordered avatar
                GestureDetector(
                  onTap: onArtistTap,
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
                        radius: 16,
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          post.artistName.isNotEmpty
                              ? post.artistName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onArtistTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.artistName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textDark,
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
                if (showStatus) ...[
                  _buildStatusBadge(post.status),
                  const SizedBox(width: 8),
                ],
                ?trailing,
              ],
            ),
          ),

          // ── Image ── full width, tappable
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
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
                            size: 48,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
              ),
            ),
          ),

          // ── Action Row: Appreciate / Rate / Bookmark + Price ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Appreciate (sparkle icon - admire the art)
                GestureDetector(
                  onTap: onTap,
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    size: 26,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(width: 16),
                // Rate (star icon - rate the artist)
                GestureDetector(
                  onTap: onTap,
                  child: const Icon(
                    Icons.star_outline_rounded,
                    size: 26,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(width: 16),
                // Bookmark / Collect (save the art)
                GestureDetector(
                  onTap: onTap,
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    size: 26,
                    color: Color(0xFF262626),
                  ),
                ),
                const Spacer(),
                if (post.price > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.brandGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\$${post.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF262626)),
                children: [
                  TextSpan(
                    text: post.artistName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: post.description,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),

          // ── Time ago ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
            child: Text(
              _timeAgo(post.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),

          // Thin divider
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFEFEFEF)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'active':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'reported':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'removed':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
