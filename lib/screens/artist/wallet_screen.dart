import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        final walletProv = context.read<WalletProvider>();
        walletProv.ensureWalletExists(uid);
        walletProv.loadWallet(uid);
        walletProv.loadTransactions(uid);
      }
    });
  }

  void _showWithdrawDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum withdrawal: \$${AppConstants.minWithdrawal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;

              Navigator.pop(ctx);

              final uid = context.read<AuthProvider>().currentUser?.uid;
              if (uid == null) return;

              final walletProv = context.read<WalletProvider>();
              final success = await walletProv.requestWithdrawal(uid, amount);

              if (!mounted) return;

              if (success) {
                // Reload transactions after withdrawal
                walletProv.loadTransactions(uid);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Withdrawal of \$${amount.toStringAsFixed(2)} processed!'
                        : walletProv.error ?? 'Withdrawal failed',
                  ),
                  backgroundColor: success
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('Withdraw'),
          ),
        ],
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
          'Earnings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF262626),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<WalletProvider>(
        builder: (_, walletProv, _) {
          if (walletProv.wallet == null && walletProv.isLoading) {
            return const LoadingIndicator(message: 'Loading wallet...');
          }

          final wallet =
              walletProv.wallet ??
              WalletModel(
                userId: '',
                balance: 0,
                totalEarnings: 0,
                totalWithdrawn: 0,
              );

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              final uid = context.read<AuthProvider>().currentUser?.uid;
              if (uid != null) {
                walletProv.loadWallet(uid);
                await walletProv.loadTransactions(uid);
              }
            },
            child: ListView(
              children: [
                WalletCard(wallet: wallet),
                const SizedBox(height: 8),

                // Withdraw button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: wallet.balance >= AppConstants.minWithdrawal
                          ? _showWithdrawDialog
                          : null,
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Request Withdrawal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (wallet.balance < AppConstants.minWithdrawal)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Minimum \$${AppConstants.minWithdrawal.toStringAsFixed(0)} balance required.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // Transaction History Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: Color(0xFF262626),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF262626),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${walletProv.transactions.length} transactions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Transaction List
                if (walletProv.isLoadingTransactions)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (walletProv.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your earnings and withdrawals will appear here',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...walletProv.transactions.map(
                    (tx) => _TransactionTile(transaction: tx),
                  ),

                const SizedBox(height: 20),

                // How it works
                const Divider(height: 1, color: Color(0xFFEFEFEF)),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'How it works',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Earn from sales',
                  subtitle:
                      'You receive ${((1 - AppConstants.platformFeePercent) * 100).toInt()}% of each delivered order.',
                ),
                _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Delivered orders',
                  subtitle: 'Earnings are added to your wallet once the order is delivered.',
                ),
                _InfoTile(
                  icon: Icons.payments_outlined,
                  title: 'Withdrawals',
                  subtitle:
                      'Request a payout once you reach \$${AppConstants.minWithdrawal.toStringAsFixed(0)} minimum.',
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final type = transaction['type'] as String;
    final amount = (transaction['amount'] as num).toDouble();
    final description = transaction['description'] as String;
    final status = transaction['status'] as String;
    final date = transaction['date'] as DateTime;

    final isPositive = amount >= 0;

    IconData icon;
    Color iconBgColor;
    Color iconColor;

    switch (type) {
      case 'earning':
        icon = Icons.arrow_downward_rounded;
        iconBgColor = AppTheme.successColor.withValues(alpha: 0.1);
        iconColor = AppTheme.successColor;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward_rounded;
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        break;
      case 'refund':
        icon = Icons.replay_rounded;
        iconBgColor = AppTheme.errorColor.withValues(alpha: 0.1);
        iconColor = AppTheme.errorColor;
        break;
      default:
        icon = Icons.swap_horiz;
        iconBgColor = Colors.grey.withValues(alpha: 0.1);
        iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF262626),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (status == 'pending') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
    );
  }
}
