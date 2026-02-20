import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  void _loadPosts() {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<PostProvider>().loadMyPosts(uid);
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<PostProvider>().deletePost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Post deleted' : 'Failed to delete post'),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
        if (success) _loadPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body: Consumer<PostProvider>(
        builder: (_, postProv, __) {
          if (postProv.isLoading) {
            return const LoadingIndicator(message: 'Loading your posts...');
          }

          if (postProv.myPosts.isEmpty) {
            return const EmptyState(
              icon: Icons.art_track,
              message: 'You haven\'t created any posts yet.\nTap Create to get started!',
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => _loadPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: postProv.myPosts.length,
              itemBuilder: (_, i) {
                final post = postProv.myPosts[i];
                return PostCard(
                  post: post,
                  showStatus: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editPost,
                          arguments: post,
                        ).then((_) => _loadPosts());
                      } else if (value == 'delete') {
                        _deletePost(post.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 18, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
