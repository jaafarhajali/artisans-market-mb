import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

              final success = await context
                  .read<WalletProvider>()
                  .requestWithdrawal(uid, amount);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Withdrawal request submitted!'
                      : context.read<WalletProvider>().error ??
                          'Withdrawal failed'),
                  backgroundColor:
                      success ? AppTheme.successColor : AppTheme.errorColor,
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
      appBar: AppBar(
        title: const Text('Wallet'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<WalletProvider>(
        builder: (_, walletProv, __) {
          if (walletProv.wallet == null && walletProv.isLoading) {
            return const LoadingIndicator(message: 'Loading wallet...');
          }

          final wallet = walletProv.wallet ??
              WalletModel(userId: '', balance: 0, totalEarnings: 0, totalWithdrawn: 0);

          return Column(
            children: [
              WalletCard(wallet: wallet),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: wallet.balance >= AppConstants.minWithdrawal
                        ? _showWithdrawDialog
                        : null,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Request Withdrawal'),
                  ),
                ),
              ),
              if (wallet.balance < AppConstants.minWithdrawal)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Minimum balance of \$${AppConstants.minWithdrawal.toStringAsFixed(2)} required for withdrawal.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How it works',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _InfoTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Earn from sales',
                subtitle:
                    'You receive ${((1 - AppConstants.platformFeePercent) * 100).toInt()}% of each order.',
              ),
              _InfoTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Balance updates',
                subtitle: 'Earnings are added to your wallet instantly.',
              ),
              _InfoTile(
                icon: Icons.payments_outlined,
                title: 'Withdrawals',
                subtitle:
                    'Request a payout once you reach \$${AppConstants.minWithdrawal.toStringAsFixed(0)} minimum.',
              ),
            ],
          );
        },
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
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
    );
  }
}
