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

  // Initialize the notification service and auto-start notifications
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone
      final String timeZoneName =
          'UTC'; // You can change this to your local timezone
      tz.setLocalLocation(tz.getLocation(timeZoneName));

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
      final initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      if (initialized == true) {
        // Request permissions explicitly
        final permissionGranted = await requestPermissions();
        debugPrint(
            'Notification initialization: $initialized, Permissions: $permissionGranted');

        _isInitialized = true;

        // Auto-start notifications when app initializes
        await _autoStartNotifications();

        return true;
      } else {
        debugPrint('Failed to initialize notifications');
        return false;
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  // Automatically start daily notifications
  Future<void> _autoStartNotifications() async {
    try {
      debugPrint('Auto-starting daily notifications...');

      // Start sustainability tips throughout the day
      await _startDailyNotifications();

      debugPrint('Daily notifications started automatically');
    } catch (e) {
      debugPrint('Error auto-starting notifications: $e');
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
      // Request permissions on Android
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');

        // We DON'T request exact alarm permission anymore to avoid strict scheduling
        debugPrint(
            'Skipping exact alarm permission to use flexible notifications');

        return granted == true;
      }

      // Request permissions on iOS
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
        return granted == true;
      }

      return true; // Default to true for other platforms
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Start daily notifications automatically throughout the day
  Future<void> _startDailyNotifications() async {
    try {
      debugPrint('Starting automatic daily notifications...');

      // Schedule sustainability tips throughout the day
      // Spread them across different times for better user experience
      final now = DateTime.now();

      // Schedule 8-10 tips throughout the day at random intervals
      for (int i = 0; i < 8; i++) {
        // Spread notifications throughout the day (1-12 hours from now)
        final baseHours =
            (i + 1) * 1.5; // 1.5, 3, 4.5, 6, 7.5, 9, 10.5, 12 hours
        final randomMinutes = Random().nextInt(60); // Add some randomness
        final randomHourOffset =
            Random().nextDouble() * 0.5; // ±30 minutes variance

        final delayHours = baseHours + randomHourOffset;
        final totalMinutes = (delayHours * 60).round() + randomMinutes;

        // Get a different tip for each notification
        final tipIndex = (i + now.day + now.hour) % _sustainabilityTips.length;
        final tip = _sustainabilityTips[tipIndex];

        debugPrint(
            'Scheduling tip ${i + 1} in ${totalMinutes ~/ 60}h ${totalMinutes % 60}m');

        await _scheduleFlexibleNotification(
          id: 1001 + i,
          title: 'Sustainability Tip 🌱',
          body: tip,
          delayDuration: Duration(minutes: totalMinutes),
          payload: 'sustainability_tip_auto',
        );
      }

      // Schedule a few health reminders throughout the day too
      await _scheduleHealthRemindersAuto();

      debugPrint('Scheduled notifications throughout the day');
    } catch (e) {
      debugPrint('Error starting daily notifications: $e');
    }
  }

  // Schedule automatic health reminders
  Future<void> _scheduleHealthRemindersAuto() async {
    try {
      // Schedule 2-3 health reminders at different times
      final healthReminders = [
        'Time to check in with your wellness goals! 💚',
        'Remember to stay hydrated and take care of yourself! 💧',
        'How are you feeling today? Take a moment for self-care! 🌿',
      ];

      for (int i = 0; i < healthReminders.length; i++) {
        // Schedule health reminders at 3, 7, and 11 hours from now
        final delayHours = 3 + (i * 4); // 3, 7, 11 hours
        final randomMinutes = Random().nextInt(60);

        await _scheduleFlexibleNotification(
          id: 2001 + i,
          title: 'Health Check-in 💚',
          body: healthReminders[i],
          delayDuration: Duration(hours: delayHours, minutes: randomMinutes),
          payload: 'health_reminder_auto',
        );
      }

      debugPrint('Scheduled automatic health reminders');
    } catch (e) {
      debugPrint('Error scheduling automatic health reminders: $e');
    }
  }

  // Helper method to schedule flexible notifications without exact alarms
  Future<void> _scheduleFlexibleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delayDuration,
    String? payload,
  }) async {
    // Instead of using zonedSchedule (which requires exact alarms),
    // we'll use a simple delayed show() with Future.delayed

    debugPrint(
        'Scheduling flexible notification $id with delay: ${delayDuration.inSeconds} seconds');

    // Use Future.delayed to show notification after a delay
    // This doesn't require any special permissions
    Future.delayed(delayDuration, () async {
      try {
        await _flutterLocalNotificationsPlugin.show(
          id,
          title,
          body,
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
          payload: payload,
        );
        debugPrint('Flexible notification $id shown successfully');
      } catch (e) {
        debugPrint('Error showing flexible notification $id: $e');
      }
    });

    debugPrint(
        'Flexible notification $id scheduled to show in ${delayDuration.inSeconds} seconds');
  }

  // Send immediate test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final randomTip =
          _sustainabilityTips[Random().nextInt(_sustainabilityTips.length)];

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

  // Keep this method for compatibility but make it redirect to auto-start
  Future<void> scheduleDailySustainabilityTips({
    int hour = 9,
    int minute = 0,
  }) async {
    // This method is kept for compatibility but notifications now start automatically
    debugPrint('Manual scheduling called - notifications are now automatic');
    if (!_isInitialized) {
      await initialize(); // This will auto-start notifications
    }
  }

  // Keep this method for compatibility but make it redirect to auto-start
  Future<void> scheduleHealthReminder({
    required String title,
    required String body,
    required int hour,
    required int minute,
    List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
  }) async {
    // This method is kept for compatibility but notifications now start automatically
    debugPrint(
        'Manual health reminder scheduling called - notifications are now automatic');
    if (!_isInitialized) {
      await initialize(); // This will auto-start notifications
    }
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
        for (int i = 1001; i <= 1005; i++) {
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

  // Get scheduled notifications (Note: flexible notifications won't show here)
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    try {
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint(
          'Found ${pending.length} traditionally scheduled notifications:');
      for (final notification in pending) {
        debugPrint(
            'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }

      // Note: Flexible notifications using Future.delayed won't appear here
      // because they're not "scheduled" in the traditional sense
      debugPrint(
          'Note: Flexible notifications (using Future.delayed) are not shown in pending requests');

      return pending;
    } catch (e) {
      debugPrint('Error getting scheduled notifications: $e');
      return [];
    }
  }

  // Check if notifications are enabled (simplified)
  Future<bool> areNotificationsEnabled() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Check Android permissions
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? notificationsEnabled =
            await androidImplementation.areNotificationsEnabled();
        debugPrint('Android notifications enabled: $notificationsEnabled');
        return notificationsEnabled == true;
      }

      // For iOS and other platforms, assume enabled if initialized
      return _isInitialized;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  // Comprehensive diagnostic method
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final diagnostics = <String, dynamic>{};

    try {
      diagnostics['isInitialized'] = _isInitialized;
      diagnostics['notificationsEnabled'] = await areNotificationsEnabled();

      final pending = await getScheduledNotifications();
      diagnostics['scheduledCount'] = pending.length;
      diagnostics['scheduledNotifications'] = pending
          .map((n) => {
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'payload': n.payload,
              })
          .toList();

      // Check timezone
      final now = tz.TZDateTime.now(tz.local);
      diagnostics['currentTime'] = now.toIso8601String();
      diagnostics['timezone'] = tz.local.name;

      debugPrint('Notification diagnostics: $diagnostics');
      return diagnostics;
    } catch (e) {
      diagnostics['error'] = e.toString();
      debugPrint('Error getting diagnostic info: $e');
      return diagnostics;
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
