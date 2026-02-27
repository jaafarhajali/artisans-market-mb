import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../widgets/order_status_timeline.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Info',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          order.createdAt != null
                              ? DateFormat(
                                  'MMM d, yyyy h:mm a',
                                ).format(order.createdAt!)
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artist: ${order.artistName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Customer: ${order.customerName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OrderStatusTimeline(currentStatus: order.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 56,
                                  height: 56,
                                  color: AppTheme.borderColor,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 56,
                                  height: 56,
                                  color: AppTheme.borderColor,
                                  child: const Icon(
                                    Icons.image,
                                    size: 24,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Payment Method',
                      value: order.paymentMethod == 'virtual_card'
                          ? 'Virtual Card'
                          : 'Virtual Visa',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Subtotal',
                      value: '\$${order.totalAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Platform Fee',
                      value: '\$${order.platformFee.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: 'Total Paid',
                      value:
                          '\$${(order.totalAmount + order.platformFee).toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
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
            fontSize: 14,
            color: isBold ? AppTheme.textDark : AppTheme.textLight,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppTheme.primary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
