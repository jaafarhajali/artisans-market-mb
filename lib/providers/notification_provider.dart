import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _unreadSubscription;

  NotificationProvider(this._firestoreService);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void startListening(String userId) {
    _unreadSubscription?.cancel();
    _unreadSubscription =
        _firestoreService.getUnreadNotificationCount(userId).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (e) {
        // Silently handle errors for badge count
      },
    );
  }

  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _notifications = await _firestoreService.getNotifications(userId);
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load notifications.';
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          referenceId: _notifications[index].referenceId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      // Silently handle
    }
  }

  Future<void> markAllRead(String userId) async {
    try {
      await _firestoreService.markAllNotificationsRead(userId);
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                message: n.message,
                type: n.type,
                referenceId: n.referenceId,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all as read.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _unreadSubscription?.cancel();
    super.dispose();
  }
}
