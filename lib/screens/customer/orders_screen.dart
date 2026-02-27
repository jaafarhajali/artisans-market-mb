import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<OrderProvider>().loadCustomerOrders(uid);
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
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
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
              _buildOrderList(orderProv.customerOrders),
              _buildOrderList(
                orderProv.customerOrders.where((o) => o.isActive).toList(),
              ),
              _buildOrderList(
                orderProv.customerOrders.where((o) => o.isDelivered).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List orders) {
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
          await context.read<OrderProvider>().loadCustomerOrders(uid);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final order = orders[i];
          return OrderCard(
            order: order,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.orderDetail,
                arguments: order,
              );
            },
          );
        },
      ),
    );
  }
}
