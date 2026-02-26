import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rating_stars.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.currentUser;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                if (user.profileImageUrl != null &&
                    user.profileImageUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.15),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.profileImageUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const CircularProgressIndicator(
                                color: AppTheme.primary),
                        errorWidget: (_, __, ___) => Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Role chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role == AppConstants.roleArtist
                        ? 'Artist'
                        : 'Customer',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Artist-specific info
                if (user.role == AppConstants.roleArtist) ...[
                  const SizedBox(height: 16),
                  if (user.category != null)
                    Text(
                      user.category!,
                      style: const TextStyle(
                        color: AppTheme.accentBrown,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (user.averageRating != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingStars(
                            rating: user.averageRating!, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '(${user.averageRating!.toStringAsFixed(1)})',
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 8),

                // Edit Profile
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primary),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.textLight),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile)
                        .then((_) {
                      context.read<AuthProvider>().refreshUser();
                    });
                  },
                ),

                // Subscription (artists only)
                if (user.role == AppConstants.roleArtist)
                  ListTile(
                    leading: const Icon(Icons.card_membership,
                        color: AppTheme.primary),
                    title: const Text('My Subscription'),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppTheme.textLight),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.subscription);
                    },
                  ),

                // Sign Out
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text('Sign Out',
                      style: TextStyle(color: AppTheme.errorColor)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                            'Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sign Out',
                                style: TextStyle(
                                    color: AppTheme.errorColor)),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
