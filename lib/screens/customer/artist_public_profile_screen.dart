import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/post_model.dart';
import '../../widgets/rating_stars.dart';

class ArtistPublicProfileScreen extends StatefulWidget {
  final String artistId;
  final String artistName;

  const ArtistPublicProfileScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  State<ArtistPublicProfileScreen> createState() =>
      _ArtistPublicProfileScreenState();
}

class _ArtistPublicProfileScreenState extends State<ArtistPublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadArtist(widget.artistId);
      context
          .read<PostProvider>()
          .loadArtistProfilePosts(widget.artistId, activeOnly: true);
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
        title: Text(
          widget.artistName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF262626),
          ),
        ),
      ),
      body: Consumer2<UserProvider, PostProvider>(
        builder: (_, userProv, postProv, _) {
          if (userProv.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            );
          }

          final artist = userProv.viewedArtist;
          final posts = postProv.artistProfilePosts;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              await userProv.loadArtist(widget.artistId);
              await postProv.loadArtistProfilePosts(widget.artistId,
                  activeOnly: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Profile Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Avatar
                        _buildAvatar(
                          artist?.profileImageUrl,
                          artist?.name ?? widget.artistName,
                        ),
                        const SizedBox(width: 24),

                        // Stats
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(
                                posts.length.toString(),
                                'Posts',
                              ),
                              if (artist?.averageRating != null)
                                _buildStat(
                                  artist!.averageRating!.toStringAsFixed(1),
                                  'Rating',
                                ),
                              _buildStat('Artist', 'Role'),
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
                          artist?.name ?? widget.artistName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF262626),
                          ),
                        ),
                        if (artist?.category != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            artist!.category!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (artist?.averageRating != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingStars(
                                  rating: artist!.averageRating!, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '(${artist.averageRating!.toStringAsFixed(1)})',
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

                  // ── Action Buttons ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.rateArtist,
                                arguments: {
                                  'artistId': widget.artistId,
                                  'artistName': widget.artistName,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Rate Artist',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Posts Section ──
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFEFEFEF),
                  ),

                  // Grid tab indicator
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
                  if (postProv.isLoadingProfile)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.palette_outlined,
                              size: 48,
                              color: Color(0xFFBDBDBD),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF262626),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This artist hasn\'t shared anything yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildPostsGrid(posts),
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
}
