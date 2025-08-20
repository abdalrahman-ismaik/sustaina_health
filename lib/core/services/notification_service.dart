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
      tz.initializeTimeZones();
      final String timeZoneName = 'UTC';
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );

      if (initialized != null) {
        final permissionGranted = await requestPermissions();
        debugPrint(
            'Notification initialization: $initialized, Permissions: $permissionGranted');

        _isInitialized = true;
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

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidImplementation?.requestPermission();
    return granted ?? false;
  }

  Future<void> _autoStartNotifications() async {
    await scheduleDailySustainabilityTip();
    await scheduleHealthReminders();
  }

  Future<void> scheduleDailySustainabilityTip() async {
    final random = Random();
    final String tip = _sustainabilityTips[random.nextInt(_sustainabilityTips.length)];

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Sustainability Tip',
      tip,
      _nextInstanceOfTime(9, 0), // 9:00 AM
      NotificationDetails(
        android: AndroidNotificationDetails(
          _sustainabilityChannelId,
          'Sustainability Tips',
          channelDescription: 'Daily sustainable living tips',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleHealthReminders() async {
    // Schedule water reminder every 2 hours
    await _scheduleWaterReminder();
    
    // Schedule movement reminder every 3 hours
    await _scheduleMovementReminder();
  }

  Future<void> _scheduleWaterReminder() async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Stay Hydrated',
      '💧 Time to drink some water! Stay healthy and hydrated.',
      _nextInstanceOfTime(10, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _healthChannelId,
          'Health Reminders',
          channelDescription: 'Regular health and wellness reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleMovementReminder() async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'Time to Move',
      '🏃‍♂️ Take a break and stretch! A little movement goes a long way.',
      _nextInstanceOfTime(11, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _healthChannelId,
          'Health Reminders',
          channelDescription: 'Regular health and wellness reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
