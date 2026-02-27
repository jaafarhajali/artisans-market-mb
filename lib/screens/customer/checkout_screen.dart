import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/credit_card_form.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cardFormKey = GlobalKey<FormState>();
  CreditCardData? _cardData;

  Future<void> _placeOrder() async {
    if (!_cardFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    final userId = auth.currentUser!.uid;
    final userName = auth.currentUser!.name;

    final paymentMethod = _cardData?.cardType.toLowerCase() ?? 'credit_card';

    final orderIds = await orderProv.placeOrder(
      customerId: userId,
      customerName: userName,
      itemsByArtist: cartProv.itemsByArtist,
      paymentMethod: paymentMethod,
    );

    if (!mounted) return;

    if (orderIds != null) {
      await cartProv.clearCart(userId);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Payment Successful!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${orderIds.length} order${orderIds.length > 1 ? 's' : ''} placed successfully!',
              ),
              const SizedBox(height: 8),
              if (_cardData != null)
                Text(
                  'Charged to ${_cardData!.cardType} ending in ${_cardData!.maskedNumber.substring(_cardData!.maskedNumber.length - 4)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Track your orders in the Orders tab.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
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
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (_, cartProv, _) {
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
                        0.0,
                        (sum, item) => sum + item.subtotal,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEFEFEF)),
                        ),
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
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.title} x${item.quantity}',
                                        style: const TextStyle(fontSize: 14),
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
                              ),
                            ),
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
                      );
                    }),

                    const SizedBox(height: 8),

                    // Credit Card Payment
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.credit_card, size: 20,
                                  color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text(
                                'Payment Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CreditCardForm(
                            formKey: _cardFormKey,
                            onCardChanged: (data) {
                              setState(() => _cardData = data);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: Column(
                        children: [
                          _PriceRow(
                            label: 'Subtotal',
                            value: '\$${subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Service Fee (10%)',
                            value: '\$${fee.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 20),
                          _PriceRow(
                            label: 'Total',
                            value: '\$${total.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Pay button
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
                    builder: (_, orderProv, _) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: orderProv.isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: orderProv.isLoading
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
                                    'Pay \$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
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
