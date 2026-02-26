import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatings();
    });
  }

  void _loadRatings() {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<RatingProvider>().loadArtistRatings(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final avgRating = auth.currentUser?.averageRating ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: Column(
        children: [
          // Average rating header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 8),
                RatingStars(rating: avgRating, size: 28),
                const SizedBox(height: 8),
                Consumer<RatingProvider>(
                  builder: (_, prov, __) => Text(
                    '${prov.artistRatings.length} ${prov.artistRatings.length == 1 ? 'review' : 'reviews'}',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Individual ratings
          Expanded(
            child: Consumer<RatingProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return const LoadingIndicator(message: 'Loading ratings...');
                }

                if (prov.artistRatings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.star_border,
                    message: 'No ratings yet.\nKeep sharing your art!',
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => _loadRatings(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: prov.artistRatings.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (_, i) {
                      final rating = prov.artistRatings[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              RatingStars(
                                  rating: rating.stars.toDouble(), size: 18),
                              const Spacer(),
                              if (rating.createdAt != null)
                                Text(
                                  DateFormat.yMMMd()
                                      .format(rating.createdAt!),
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          if (rating.feedback.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              rating.feedback,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
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
