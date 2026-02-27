import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/common/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Consumer<CartProvider>(
        builder: (_, cartProv, _) {
          if (cartProv.cartItems.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: 'Your cart is empty.\nBrowse artworks to add items!',
            );
          }

          final itemsByArtist = cartProv.itemsByArtist;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: itemsByArtist.entries.map((entry) {
                    final artistName = entry.value.first.artistName;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            artistName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (item) => CartItemCard(
                            item: item,
                            onRemove: () {
                              if (userId != null) {
                                cartProv.removeItem(userId, item.id);
                              }
                            },
                            onQuantityChanged: (qty) {
                              if (userId != null) {
                                cartProv.updateQuantity(userId, item.id, qty);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              // Bottom bar
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
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '\$${cartProv.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.checkout);
                          },
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
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
