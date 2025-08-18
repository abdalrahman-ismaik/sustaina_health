import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _sustainabilityChannelId = 'sustainability_tips';
  static const String _healthChannelId = 'health_reminders';

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Sustainability tips data
  static const List<String> _sustainabilityTips = [
    "🌱 Take the stairs instead of the elevator to reduce energy consumption and improve your health!",
    "💧 Turn off the tap while brushing your teeth to save up to 8 gallons of water per day.",
    "🚲 Consider walking or cycling for short trips - it's great for your health and the environment!",
    "🌿 Eat more plant-based meals to reduce your carbon footprint and improve your nutrition.",
    "♻️ Remember to recycle and properly sort your waste to help protect our planet.",
    "💡 Switch to LED bulbs - they use 75% less energy and last 25 times longer!",
    "🏡 Unplug electronics when not in use to prevent phantom energy consumption.",
    "🌍 Choose reusable bags, bottles, and containers to reduce single-use plastic waste.",
    "🚿 Take shorter showers to conserve water and energy - aim for 5 minutes or less!",
    "🌳 Support local and seasonal produce to reduce transportation emissions and eat fresher food.",
    "📱 Use your device's power-saving mode to extend battery life and reduce charging frequency.",
    "🚗 Combine errands into one trip to reduce fuel consumption and save time.",
    "🌱 Start a small herb garden - grow your own fresh herbs and reduce packaging waste!",
    "💨 Use natural ventilation instead of air conditioning when possible to save energy.",
    "🔋 Charge your devices during off-peak hours to reduce strain on the electrical grid."
  ];

  // Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  // Handle notification taps
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Schedule daily sustainability tips
  Future<void> scheduleDailySustainabilityTips({
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel existing scheduled notifications
      await _cancelNotificationsByChannel(_sustainabilityChannelId);

      // Schedule notifications for the next 30 days
      for (int i = 1; i <= 30; i++) {
        final tip = _sustainabilityTips[Random().nextInt(_sustainabilityTips.length)];
        final scheduledDate = DateTime.now().add(Duration(days: i));
        final scheduledDateTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          1000 + i, // Unique ID for each tip
          'Sustainability Tip 🌱',
          tip,
          tz.TZDateTime.from(scheduledDateTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sustainability_tips',
              'Sustainability Tips',
              channelDescription: 'Daily sustainability tips and advice',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFF94e0b2),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'sustainability_tip',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      debugPrint('Scheduled daily sustainability tips for 30 days');
    } catch (e) {
      debugPrint('Error scheduling sustainability tips: $e');
    }
  }

  // Send immediate test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final randomTip = _sustainabilityTips[Random().nextInt(_sustainabilityTips.length)];

      await _flutterLocalNotificationsPlugin.show(
        999, // Test notification ID
        'Test Notification 🧪',
        randomTip,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sustainability_tips',
            'Sustainability Tips',
            channelDescription: 'Daily sustainability tips and advice',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF94e0b2),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'test_notification',
      );

      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  // Schedule health reminders
  Future<void> scheduleHealthReminder({
    required String title,
    required String body,
    required int hour,
    required int minute,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7], // All days by default
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel existing health reminders
      await _cancelNotificationsByChannel(_healthChannelId);

      for (int weekday in weekdays) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          2000 + weekday, // Unique ID for each weekday
          title,
          body,
          _nextInstanceOfTime(hour, minute, weekday),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'health_reminders',
              'Health Reminders',
              channelDescription: 'Health and wellness reminders',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFF94e0b2),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'health_reminder',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      debugPrint('Scheduled health reminder for weekdays: $weekdays');
    } catch (e) {
      debugPrint('Error scheduling health reminder: $e');
    }
  }

  // Helper method to get next instance of a specific time and weekday
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int weekday) {
    tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local);
    scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  // Cancel notifications by channel (simulated)
  Future<void> _cancelNotificationsByChannel(String channelId) async {
    try {
      // Since flutter_local_notifications doesn't have channel-specific cancellation,
      // we'll cancel specific ID ranges
      if (channelId == _sustainabilityChannelId) {
        for (int i = 1001; i <= 1030; i++) {
          await _flutterLocalNotificationsPlugin.cancel(i);
        }
      } else if (channelId == _healthChannelId) {
        for (int i = 2001; i <= 2007; i++) {
          await _flutterLocalNotificationsPlugin.cancel(i);
        }
      }
      debugPrint('Notifications cancelled for channel: $channelId');
    } catch (e) {
      debugPrint('Error cancelling notifications for channel $channelId: $e');
    }
  }

  // Cancel notifications by channel
  Future<void> cancelNotificationsByChannel(String channelKey) async {
    await _cancelNotificationsByChannel(channelKey);
  }

  // Get scheduled notifications (simplified)
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting scheduled notifications: $e');
      return [];
    }
  }

  // Check if notifications are enabled (simplified)
  Future<bool> areNotificationsEnabled() async {
    try {
      // This is a simplified check - in a real app you might want more sophisticated logic
      return _isInitialized;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  // Open notification settings (platform specific)
  Future<void> openNotificationSettings() async {
    try {
      // This would need platform-specific implementation
      // For now, we'll just show a message
      debugPrint('Please enable notifications in your device settings');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }
}
