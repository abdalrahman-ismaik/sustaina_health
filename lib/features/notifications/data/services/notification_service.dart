import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_models.dart';

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static const String _lastNotificationIdKey = 'last_notification_id';
  
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();
  
  List<AppNotification> _notifications = [];
  
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await _loadNotifications();
    _generateSampleNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded
            .map((json) => AppNotification.fromJson(json))
            .toList();
        
        // Sort by creation time (newest first)
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _notificationsController.add(_notifications);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, encoded);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<String> _generateUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    final int lastId = prefs.getInt(_lastNotificationIdKey) ?? 0;
    final int newId = lastId + 1;
    await prefs.setInt(_lastNotificationIdKey, newId);
    return 'notification_$newId';
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }
    
    await _saveNotifications();
    _notificationsController.add(_notifications);
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionRoute,
    Map<String, dynamic>? metadata,
  }) async {
    final id = await _generateUniqueId();
    final notification = AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      priority: priority,
      createdAt: DateTime.now(),
      actionRoute: actionRoute,
      metadata: metadata,
    );
    
    await addNotification(notification);
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      _notificationsController.add(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    _notificationsController.add(_notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    _notificationsController.add(_notifications);
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    _notificationsController.add(_notifications);
  }

  void dispose() {
    _notificationsController.close();
  }

  // Generate some sample notifications for demo
  void _generateSampleNotifications() {
    if (_notifications.isNotEmpty) return;

    final List<AppNotification> sampleNotifications = [
      AppNotification(
        id: 'sample_1',
        title: '🎉 Achievement Unlocked!',
        message: 'You\'ve completed your first eco-friendly workout!',
        type: NotificationType.achievement,
        priority: NotificationPriority.high,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        actionRoute: '/profile',
      ),
      AppNotification(
        id: 'sample_2',
        title: '🥗 Meal Reminder',
        message: 'Time to log your lunch! Don\'t forget to choose sustainable options.',
        type: NotificationType.nutrition,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        actionRoute: '/nutrition',
      ),
      AppNotification(
        id: 'sample_3',
        title: '🌱 Daily Eco Tip',
        message: 'Walking instead of driving for short trips can save 2.6kg of CO₂!',
        type: NotificationType.sustainability,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'sample_4',
        title: '😴 Sleep Reminder',
        message: 'It\'s time to wind down. Good sleep helps both you and the planet!',
        type: NotificationType.sleep,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        actionRoute: '/sleep',
      ),
      AppNotification(
        id: 'sample_5',
        title: '💪 Workout Streak',
        message: 'You\'re on a 3-day workout streak! Keep it up!',
        type: NotificationType.workout,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        actionRoute: '/exercise',
      ),
    ];

    _notifications.addAll(sampleNotifications);
    _notificationsController.add(_notifications);
  }

  // Create workout-related notifications
  Future<void> createWorkoutNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.workout,
      actionRoute: actionRoute ?? '/exercise',
    );
  }

  // Create nutrition-related notifications
  Future<void> createNutritionNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.nutrition,
      actionRoute: actionRoute ?? '/nutrition',
    );
  }

  // Create achievement notifications
  Future<void> createAchievementNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      actionRoute: actionRoute ?? '/profile',
    );
  }

  // Create sustainability notifications
  Future<void> createSustainabilityNotification({
    required String title,
    required String message,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.sustainability,
    );
  }
}
