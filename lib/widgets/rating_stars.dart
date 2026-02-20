import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final void Function(double)? onRatingUpdate;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.interactive = false,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: size,
        itemBuilder: (_, __) => const Icon(
          Icons.star,
          color: AppTheme.accentGold,
        ),
        unratedColor: AppTheme.borderColor,
        onRatingUpdate: onRatingUpdate ?? (_) {},
      );
    }

    return RatingBarIndicator(
      rating: rating,
      itemCount: 5,
      itemSize: size,
      itemBuilder: (_, __) => const Icon(
        Icons.star,
        color: AppTheme.accentGold,
      ),
      unratedColor: AppTheme.borderColor,
    );
  }
}
