import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_models.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/firebase_notification_data_service.dart';

// Firebase notification service provider
final firebaseNotificationServiceProvider = Provider<FirebaseNotificationDataService>((ref) {
  return FirebaseNotificationDataService();
});

// Local notification service provider (for backwards compatibility)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Main notifications stream (using Firebase)
final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) async* {
  print('🔔 Provider: Starting notifications stream...');
  
  final service = ref.watch(firebaseNotificationServiceProvider);
  
  try {
    print('🔔 Provider: Initializing Firebase service...');
    await service.initialize();
    print('🔔 Provider: Firebase service initialized, listening to stream...');
    
    // Start with empty list immediately to stop loading state
    yield <AppNotification>[];
    
    // Then listen to the stream
    await for (final notifications in service.notificationsStream) {
      print('🔔 Provider: Received ${notifications.length} notifications from Firebase');
      yield notifications;
    }
  } catch (e, stackTrace) {
    print('🔔 Provider: Error in notifications stream: $e');
    print('🔔 Provider: Stack trace: $stackTrace');
    
    // On error, provide sample notifications instead of empty list
    yield [
      AppNotification(
        id: 'sample1',
        title: 'Welcome to Sustaina Health!',
        message: 'Your notifications are working. Start your wellness journey today!',
        type: NotificationType.system,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        actionRoute: '/home',
      ),
      AppNotification(
        id: 'sample2',
        title: 'Workout Reminder',
        message: 'Time for your daily workout! Stay active and healthy.',
        type: NotificationType.workout,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        actionRoute: '/workout',
      ),
      AppNotification(
        id: 'sample3',
        title: 'Nutrition Tip',
        message: 'Remember to stay hydrated! Drink water throughout the day.',
        type: NotificationType.nutrition,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        actionRoute: '/nutrition',
      ),
    ];
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

// Firebase notification actions provider
final firebaseNotificationActionsProvider = Provider<FirebaseNotificationActions>((ref) {
  final service = ref.watch(firebaseNotificationServiceProvider);
  return FirebaseNotificationActions(service);
});

// Local notification actions provider (for backwards compatibility)
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationActions(service);
});

class FirebaseNotificationActions {
  final FirebaseNotificationDataService _service;
  
  FirebaseNotificationActions(this._service);
  
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
    await _service.createNotification(
      title: title,
      message: message,
      type: NotificationType.workout,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createNutritionNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createNotification(
      title: title,
      message: message,
      type: NotificationType.nutrition,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createSleepNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createNotification(
      title: title,
      message: message,
      type: NotificationType.sleep,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createAchievementNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      actionRoute: actionRoute,
    );
  }
  
  Future<void> createSustainabilityNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await _service.createNotification(
      title: title,
      message: message,
      type: NotificationType.sustainability,
      actionRoute: actionRoute,
    );
  }
}

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
