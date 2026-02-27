import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class ArtistOrdersScreen extends StatefulWidget {
  const ArtistOrdersScreen({super.key});

  @override
  State<ArtistOrdersScreen> createState() => _ArtistOrdersScreenState();
}

class _ArtistOrdersScreenState extends State<ArtistOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<OrderProvider>().loadArtistOrders(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'New'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (_, orderProv, _) {
          if (orderProv.isLoading) {
            return const LoadingIndicator(message: 'Loading orders...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProv.artistOrders, orderProv),
              _buildOrderList(
                orderProv.artistOrders.where((o) => o.isPaid).toList(),
                orderProv,
              ),
              _buildOrderList(
                orderProv.artistOrders.where((o) => o.isProcessing).toList(),
                orderProv,
              ),
              _buildOrderList(
                orderProv.artistOrders.where((o) => o.isShipped).toList(),
                orderProv,
              ),
              _buildOrderList(
                orderProv.artistOrders.where((o) => o.isDelivered).toList(),
                orderProv,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, OrderProvider orderProv) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No orders found.',
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {
        final uid = context.read<AuthProvider>().currentUser?.uid;
        if (uid != null) {
          await context.read<OrderProvider>().loadArtistOrders(uid);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final order = orders[i];
          return Column(
            children: [
              OrderCard(
                order: order,
                showArtistName: false,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderDetail,
                    arguments: order,
                  );
                },
              ),
              // Status update buttons
              if (order.isActive && !order.isPending)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order.isPaid)
                        _StatusButton(
                          label: 'Start Processing',
                          onPressed: () => orderProv.updateOrderStatus(
                            order.id,
                            AppConstants.orderProcessing,
                          ),
                        ),
                      if (order.isProcessing)
                        _StatusButton(
                          label: 'Mark Shipped',
                          onPressed: () => orderProv.updateOrderStatus(
                            order.id,
                            AppConstants.orderShipped,
                          ),
                        ),
                      if (order.isShipped)
                        _StatusButton(
                          label: 'Mark Delivered',
                          onPressed: () => orderProv.updateOrderStatus(
                            order.id,
                            AppConstants.orderDelivered,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _StatusButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
