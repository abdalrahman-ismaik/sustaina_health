import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_models.dart';
import '../../data/services/notification_service.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Stream of all notifications
final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  
  // Initialize the service first
  try {
    await service.initialize();
    yield* service.notificationsStream;
  } catch (e) {
    // If initialization fails, yield empty list
    yield <AppNotification>[];
  }
});

// Provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider for filtered notifications by type
final notificationsByTypeProvider = Provider.family<List<AppNotification>, NotificationType>((ref, type) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => n.type == type).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for high priority notifications
final highPriorityNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) => n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for recent notifications (last 24 hours)
final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  final now = DateTime.now();
  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) => now.difference(n.createdAt).inHours <= 24)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Notification actions provider
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationActions(service);
});

class NotificationActions {
  final NotificationService _service;
  
  NotificationActions(this._service);
  
  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
  }
  
  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
  }
  
  Future<void> deleteNotification(String notificationId) async {
    await _service.deleteNotification(notificationId);
  }
  
  Future<void> clearAll() async {
    await _service.clearAllNotifications();
  }
  
  Future<void> createWorkoutNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createWorkoutNotification(
      title: title,
      message: message,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createAchievementNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createAchievementNotification(
      title: title,
      message: message,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createNutritionNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createNutritionNotification(
      title: title,
      message: message,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createSustainabilityNotification({
    required String title,
    required String message,
  }) async {
    await _service.createSustainabilityNotification(
      title: title,
      message: message,
    );
  }
}
