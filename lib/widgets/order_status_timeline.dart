import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderStatusTimeline({super.key, required this.currentStatus});

  static const _statuses = ['paid', 'processing', 'shipped', 'delivered'];
  static const _labels = ['Paid', 'Processing', 'Shipped', 'Delivered'];

  int get _currentIndex {
    if (currentStatus == 'cancelled' || currentStatus == 'refunded') return -1;
    return _statuses.indexOf(currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == 'cancelled') {
      return _buildSpecialStatus('Cancelled', AppTheme.errorColor);
    }
    if (currentStatus == 'refunded') {
      return _buildSpecialStatus('Refunded', AppTheme.errorColor);
    }

    return Column(
      children: List.generate(_statuses.length, (index) {
        final isCompleted = index <= _currentIndex;
        final isLast = index == _statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.borderColor,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.borderColor,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Label
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? AppTheme.textDark : AppTheme.textLight,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSpecialStatus(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
