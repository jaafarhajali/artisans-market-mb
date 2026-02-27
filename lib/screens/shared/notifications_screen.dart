import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_item.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<NotificationProvider>().loadNotifications(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, notifProv, _) {
              if (notifProv.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final uid = context.read<AuthProvider>().currentUser?.uid;
                  if (uid != null) {
                    notifProv.markAllRead(uid);
                  }
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (_, notifProv, _) {
          if (notifProv.isLoading) {
            return const LoadingIndicator(message: 'Loading notifications...');
          }

          if (notifProv.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              message: 'No notifications yet.',
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              final uid = context.read<AuthProvider>().currentUser?.uid;
              if (uid != null) {
                await notifProv.loadNotifications(uid);
              }
            },
            child: ListView.builder(
              itemCount: notifProv.notifications.length,
              itemBuilder: (_, i) {
                final notification = notifProv.notifications[i];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    // Mark as read
                    if (!notification.isRead) {
                      notifProv.markAsRead(notification.id);
                    }

                    // Navigate to relevant screen
                    if (notification.referenceId.isNotEmpty) {
                      if (notification.type == 'order_placed' ||
                          notification.type == 'order_status') {
                        // Navigate to order detail
                        // We need to load the order first, so navigate to orders
                        final user = context.read<AuthProvider>().currentUser;
                        if (user?.role == 'customer') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.customerOrders,
                          );
                        } else {
                          Navigator.pushNamed(context, AppRoutes.artistOrders);
                        }
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
