import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/subscription_badge.dart';
import '../../widgets/credit_card_form.dart';
import '../../widgets/common/loading_indicator.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _activePostCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<SubscriptionProvider>().loadSubscription(uid);
      final count = await context.read<PostProvider>().getActivePostCount(uid);
      if (mounted) setState(() => _activePostCount = count);
    }
  }

  Future<void> _subscribeToPlan(
    String planKey,
    Map<String, dynamic> plan,
  ) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final planName = plan['name'] as String;
    final amount = plan['amount'] as double;

    // Free plan: just confirm
    if (amount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Switch to $planName'),
          content: const Text('Switch to the Free plan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      final success =
          await context.read<SubscriptionProvider>().subscribeToPlan(
                artistId: user.uid,
                artistName: user.name,
                artistEmail: user.email,
                planKey: planKey,
                amount: amount,
                postLimit: plan['postLimit'] as int,
              );

      if (!mounted) return;
      _showResult(success, planName);
      return;
    }

    // Paid plan: show card payment bottom sheet
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PaymentSheet(
        planName: planName,
        amount: amount,
      ),
    );

    if (result != true || !mounted) return;

    final success =
        await context.read<SubscriptionProvider>().subscribeToPlan(
              artistId: user.uid,
              artistName: user.name,
              artistEmail: user.email,
              planKey: planKey,
              amount: amount,
              postLimit: plan['postLimit'] as int,
            );

    if (!mounted) return;
    _showResult(success, planName);
  }

  void _showResult(bool success, String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Subscribed to $planName!'
              : 'Failed to subscribe. Please try again.',
        ),
        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
          'My Subscription',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (_, subProv, _) {
          if (subProv.isLoading) {
            return const LoadingIndicator(message: 'Loading subscription...');
          }

          final sub = subProv.subscription;
          final planName = sub?.planDisplayName ?? 'Free';
          final limit = sub?.postLimit ?? 5;
          final isUnlimited = sub?.isUnlimited ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Plan Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Current Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          SubscriptionBadge(plan: planName),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Post usage
                      Row(
                        children: [
                          const Icon(
                            Icons.article,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isUnlimited
                                ? 'Posts: $_activePostCount (Unlimited)'
                                : 'Posts: $_activePostCount / $limit',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      if (!isUnlimited) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: limit > 0
                                ? (_activePostCount / limit).clamp(0.0, 1.0)
                                : 0,
                            backgroundColor: AppTheme.borderColor,
                            color: _activePostCount >= limit
                                ? AppTheme.errorColor
                                : AppTheme.primary,
                            minHeight: 8,
                          ),
                        ),
                      ],

                      if (sub != null) ...[
                        const SizedBox(height: 16),
                        if (sub.expiryDate != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppTheme.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expires: ${DateFormat.yMMMd().format(sub.expiryDate!)}',
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              sub.isActive ? Icons.check_circle : Icons.cancel,
                              color: sub.isActive
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${sub.status[0].toUpperCase()}${sub.status.substring(1)}',
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Plan Comparison
                const Text(
                  'Available Plans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a plan that suits your needs.',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
                const SizedBox(height: 16),

                ...AppConstants.plans.entries.map((entry) {
                  final key = entry.key;
                  final plan = entry.value;
                  final isCurrent = key == (sub?.plan ?? 'free');
                  final isPaid = (plan['amount'] as double) > 0;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary.withValues(alpha: 0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primary
                            : AppTheme.borderColor,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        plan['name'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isCurrent
                                              ? AppTheme.primary
                                              : AppTheme.textDark,
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Current',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (plan['postLimit'] as int) == -1
                                        ? 'Unlimited posts'
                                        : 'Up to ${plan['postLimit']} posts',
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              !isPaid
                                  ? 'Free'
                                  : '\$${(plan['amount'] as double).toStringAsFixed(2)}/mo',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isCurrent
                                    ? AppTheme.primary
                                    : AppTheme.accent,
                              ),
                            ),
                          ],
                        ),
                        if (!isCurrent) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: subProv.isLoading
                                  ? null
                                  : () => _subscribeToPlan(key, plan),
                              icon: isPaid
                                  ? const Icon(Icons.credit_card, size: 18)
                                  : const Icon(Icons.swap_horiz, size: 18),
                              label: Text(
                                isPaid ? 'Subscribe & Pay' : 'Switch to Free',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bottom sheet with card form for paid subscription
class _PaymentSheet extends StatefulWidget {
  final String planName;
  final double amount;

  const _PaymentSheet({required this.planName, required this.amount});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _cardFormKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    const Icon(Icons.credit_card, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subscribe to ${widget.planName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '\$${widget.amount.toStringAsFixed(2)}/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card form
                CreditCardForm(
                  formKey: _cardFormKey,
                  onCardChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Pay button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (!_cardFormKey.currentState!.validate()) return;

                            setState(() => _isProcessing = true);

                            // Simulate payment processing
                            await Future.delayed(
                                const Duration(milliseconds: 800));

                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Pay \$${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your card will be charged \$${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
