import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = AppConstants.paymentVirtualCard;

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    final userId = auth.currentUser!.uid;
    final userName = auth.currentUser!.name;

    final orderIds = await orderProv.placeOrder(
      customerId: userId,
      customerName: userName,
      itemsByArtist: cartProv.itemsByArtist,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;

    if (orderIds != null) {
      await cartProv.clearCart(userId);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
              SizedBox(width: 8),
              Text('Order Placed!'),
            ],
          ),
          content: Text(
            '${orderIds.length} order${orderIds.length > 1 ? 's' : ''} placed successfully!\nYou can track your orders in the Orders tab.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back from checkout
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProv.error ?? 'Failed to place order'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (_, cartProv, __) {
          final itemsByArtist = cartProv.itemsByArtist;
          final subtotal = cartProv.totalAmount;
          final fee = subtotal * AppConstants.platformFeePercent;
          final total = subtotal + fee;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Order summary by artist
                    ...itemsByArtist.entries.map((entry) {
                      final items = entry.value;
                      final artistName = items.first.artistName;
                      final artistSubtotal = items.fold(
                          0.0, (sum, item) => sum + item.subtotal);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artistName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const Divider(),
                              ...items.map((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.title} x${item.quantity}',
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                        ),
                                        Text(
                                          '\$${item.subtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Subtotal: \$${artistSubtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Payment method
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<String>(
                              title: const Text('Virtual Card'),
                              subtitle:
                                  const Text('Simulated card payment'),
                              value: AppConstants.paymentVirtualCard,
                              groupValue: _selectedMethod,
                              activeColor: AppTheme.primary,
                              onChanged: (v) =>
                                  setState(() => _selectedMethod = v!),
                            ),
                            RadioListTile<String>(
                              title: const Text('Virtual Visa'),
                              subtitle:
                                  const Text('Simulated Visa payment'),
                              value: AppConstants.paymentVirtualVisa,
                              groupValue: _selectedMethod,
                              activeColor: AppTheme.primary,
                              onChanged: (v) =>
                                  setState(() => _selectedMethod = v!),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Price breakdown
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _PriceRow(
                                label: 'Subtotal',
                                value:
                                    '\$${subtotal.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            _PriceRow(
                                label: 'Service Fee (10%)',
                                value:
                                    '\$${fee.toStringAsFixed(2)}'),
                            const Divider(height: 20),
                            _PriceRow(
                              label: 'Total',
                              value: '\$${total.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Place order button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Consumer<OrderProvider>(
                    builder: (_, orderProv, __) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            orderProv.isLoading ? null : _placeOrder,
                        child: orderProv.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Place Order — \$${total.toStringAsFixed(2)}'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isBold ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isBold ? AppTheme.primary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
