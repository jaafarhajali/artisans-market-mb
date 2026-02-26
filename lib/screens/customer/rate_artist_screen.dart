import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../models/rating_model.dart';

class RateArtistScreen extends StatefulWidget {
  final String artistId;
  final String artistName;

  const RateArtistScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  State<RateArtistScreen> createState() => _RateArtistScreenState();
}

class _RateArtistScreenState extends State<RateArtistScreen> {
  final _feedbackController = TextEditingController();
  double _rating = 0;
  RatingModel? _existingRating;
  bool _loadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  Future<void> _loadExistingRating() async {
    final customerId = context.read<AuthProvider>().currentUser?.uid;
    if (customerId == null) return;

    final existing = await context
        .read<RatingProvider>()
        .getExistingRating(customerId, widget.artistId);

    if (mounted) {
      setState(() {
        _existingRating = existing;
        if (existing != null) {
          _rating = existing.stars.toDouble();
          _feedbackController.text = existing.feedback;
        }
        _loadingExisting = false;
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final customerId = context.read<AuthProvider>().currentUser!.uid;
    final success = await context.read<RatingProvider>().submitRating(
          artistId: widget.artistId,
          customerId: customerId,
          stars: _rating.toInt(),
          feedback: _feedbackController.text.trim(),
          existingRatingId: _existingRating?.id,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingRating != null
              ? 'Rating updated!'
              : 'Rating submitted!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.artistName}')),
      body: _loadingExisting
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_existingRating != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accent),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.accent),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You already rated this artist. Update your rating below.',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text(
                    'How would you rate this artist?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: RatingStars(
                      rating: _rating,
                      size: 40,
                      interactive: true,
                      onRatingUpdate: (val) {
                        setState(() => _rating = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _rating > 0
                          ? '${_rating.toInt()} / 5'
                          : 'Tap a star to rate',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _feedbackController,
                    label: 'Feedback (optional)',
                    hintText: 'Share your experience...',
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 24),

                  Consumer<RatingProvider>(
                    builder: (_, prov, __) => CustomButton(
                      label: _existingRating != null
                          ? 'Update Rating'
                          : 'Submit Rating',
                      onPressed: _submit,
                      isLoading: prov.isLoading,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
