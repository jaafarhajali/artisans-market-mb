import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double fontSize;
  final Color? color;

  const PriceTag({
    super.key,
    required this.price,
    this.fontSize = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppTheme.primary,
      ),
    );
  }
}
