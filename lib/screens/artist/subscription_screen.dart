import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/subscription_badge.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: Consumer<SubscriptionProvider>(
        builder: (_, subProv, __) {
          if (subProv.isLoading) {
            return const LoadingIndicator(
                message: 'Loading subscription...');
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
                          const Icon(Icons.article,
                              color: AppTheme.primary, size: 20),
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
                              const Icon(Icons.calendar_today,
                                  color: AppTheme.textLight, size: 16),
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
                              sub.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
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
                  'Contact admin to upgrade your plan.',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
                const SizedBox(height: 16),

                ...AppConstants.plans.entries.map((entry) {
                  final key = entry.key;
                  final plan = entry.value;
                  final isCurrent =
                      key == (sub?.plan ?? 'free');

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
                    child: Row(
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
                                          horizontal: 8, vertical: 2),
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
                          (plan['amount'] as double) == 0
                              ? 'Free'
                              : '\$${(plan['amount'] as double).toStringAsFixed(2)}/mo',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isCurrent
                                ? AppTheme.primary
                                : AppTheme.accentGold,
                          ),
                        ),
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
