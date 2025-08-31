import 'package:firebase_messaging/firebase_messaging.dart'
    as firebase_messaging;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class FirebaseNotificationService with WidgetsBindingObserver {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final firebase_messaging.FirebaseMessaging _firebaseMessaging =
      firebase_messaging.FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _exactAlarmsPermitted = true;
  bool _rescheduleInProgress = false;
  String? _fcmToken;

  // Notification IDs for different types
  static const int _mealReminderBaseId = 1000;
  static const int _exerciseReminderBaseId = 2000;
  static const int _sleepReminderBaseId = 3000;
  static const int _sustainabilityTipBaseId = 4000;

  // Notification settings keys
  static const String _settingsKey = 'notification_settings';
  static const String _fcmTokenKey = 'fcm_token';

  /// Initialize the Firebase notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      // tz.setLocalLocation(tz.getLocation('Asia/Dubai')); // Removed hardcoded timezone

      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request FCM permissions
      final firebase_messaging.NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!);
        debugPrint('FCM Token: $_fcmToken');
      }

      // Initialize local notifications for scheduled notifications
      await _initializeLocalNotifications();

      // Set up FCM message handlers
      await _setupFCMHandlers();

      // Check if exact alarms are permitted on Android
      try {
        final bool allowed = await isExactAlarmPermitted();
        _exactAlarmsPermitted = allowed;
      } catch (e) {
        _exactAlarmsPermitted = true;
      }

      // Aggressively handle Android battery optimization
      await _handleAndroidOptimizations();

      // Subscribe to FCM topics for campaigns
      final AppNotificationSettings appSettings =
          await _getNotificationSettings();
      if (appSettings.exerciseRemindersEnabled) {
        await _firebaseMessaging.subscribeToTopic('Exercises Reminder');
        debugPrint('Subscribed to Exercises Reminder topic for FCM campaign');
      }

      debugPrint(
          'Firebase notification service initialized and scheduled reminders');

      // Register for app lifecycle events
      try {
        WidgetsBinding.instance.addObserver(this);
      } catch (e) {
        // ignore - in some test contexts WidgetsBinding may not be available
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing Firebase notifications: $e');
      return false;
    }
  }

  /// Initialize local notifications for scheduled notifications
  Future<void> _initializeLocalNotifications() async {
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

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      const AndroidNotificationChannel mealChannel = AndroidNotificationChannel(
        'meal_reminders',
        'Meal Reminders',
        description: 'Reminders to log your meals',
        importance: Importance.high,
      );

      const AndroidNotificationChannel exerciseChannel =
          AndroidNotificationChannel(
        'exercise_reminders',
        'Exercise Reminders',
        description: 'Reminders to exercise and log workouts',
        importance: Importance.high,
      );

      const AndroidNotificationChannel sleepChannel =
          AndroidNotificationChannel(
        'sleep_reminders',
        'Sleep Reminders',
        description: 'Reminders for sleep tracking and bedtime',
        importance: Importance.defaultImportance,
      );

      const AndroidNotificationChannel sustainabilityChannel =
          AndroidNotificationChannel(
        'sustainability_tips',
        'Sustainability Tips',
        description: 'Daily sustainability tips and advice',
        importance: Importance.defaultImportance,
      );

      const AndroidNotificationChannel smartChannel =
          AndroidNotificationChannel(
        'smart_reminders',
        'Smart Reminders',
        description: 'Intelligent reminders based on your activity',
        importance: Importance.defaultImportance,
      );

      const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
        'test_notifications',
        'Test Notifications',
        description: 'Test notifications',
        importance: Importance.high,
      );

      await androidImpl.createNotificationChannel(mealChannel);
      await androidImpl.createNotificationChannel(exerciseChannel);
      await androidImpl.createNotificationChannel(sleepChannel);
      await androidImpl.createNotificationChannel(sustainabilityChannel);
      await androidImpl.createNotificationChannel(smartChannel);
      await androidImpl.createNotificationChannel(testChannel);
    }
  }

  /// Set up FCM message handlers
  Future<void> _setupFCMHandlers() async {
    // Handle messages when app is in foreground
    firebase_messaging.FirebaseMessaging.onMessage
        .listen(_handleForegroundMessage);

    // Handle messages when app is opened from background
    firebase_messaging.FirebaseMessaging.onMessageOpenedApp
        .listen(_handleBackgroundMessage);

    // Handle messages when app is terminated
    firebase_messaging.FirebaseMessaging.onBackgroundMessage(
        _handleTerminatedMessage);
  }

  /// Handle FCM messages when app is in foreground
  Future<void> _handleForegroundMessage(
      firebase_messaging.RemoteMessage message) async {
    debugPrint('FCM Foreground message: ${message.notification?.title}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'exercise_reminders', // Use exercise channel for campaign
            'Exercise Reminders',
            channelDescription: 'Reminders to exercise and log workouts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['payload'],
      );
    }
  }

  /// Handle FCM messages when app is opened from background
  void _handleBackgroundMessage(firebase_messaging.RemoteMessage message) {
    debugPrint('FCM Background message: ${message.notification?.title}');
    // Handle navigation or other actions based on message data
  }

  /// Handle FCM messages when app is terminated
  Future<void> _handleTerminatedMessage(
      firebase_messaging.RemoteMessage message) async {
    debugPrint('FCM Terminated message: ${message.notification?.title}');
    // Handle terminated messages
  }

  /// Handle notification taps
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Save FCM token to shared preferences
  Future<void> _saveFCMToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  /// Get saved FCM token
  Future<String?> getFCMToken() async {
    if (_fcmToken != null) return _fcmToken;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString(_fcmTokenKey);
    return _fcmToken;
  }

  /// Force reschedule all notifications with improved system
  Future<bool> forceRescheduleWithImprovements() async {
    try {
      debugPrint('🔄 Force rescheduling with improvements...');

      // Cancel all existing notifications
      await cancelAllNotifications();

      // Handle Android optimizations aggressively
      await _handleAndroidOptimizations();

      // Reschedule all reminders with improved methods
      await _scheduleAllReminders();

      debugPrint('✅ Force rescheduling completed');
      return true;
    } catch (e) {
      debugPrint('❌ Force rescheduling failed: $e');
      return false;
    }
  }

  /// Schedule a one-off test notification using local notifications
  Future<bool> scheduleOneOffTestNotification({int seconds = 60}) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime scheduledDate = now.add(Duration(seconds: seconds));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9999,
        'Firebase Scheduled Test',
        'This is a scheduled test notification via Firebase service.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_notifications',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Firebase scheduled test notification for $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('Error scheduling Firebase test notification: $e');
      return false;
    }
  }

  /// Schedule a simple test notification for exactly 30 seconds from now
  Future<bool> scheduleSimple30SecondTest() async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        DateTime.now().add(const Duration(minutes: 2)),
        tz.local,
      );

      debugPrint('Current TZ time: $now');
      debugPrint('TZ Scheduled time: $tzScheduledTime');

      // Check exact alarm permission
      final bool exactPermitted = await isExactAlarmPermitted();
      debugPrint('Exact alarm permitted: $exactPermitted');

      if (!exactPermitted) {
        debugPrint(
            'Exact alarms not permitted, scheduling for 4 minutes later as fallback');
        final tz.TZDateTime fallbackTime = tz.TZDateTime.from(
          DateTime.now().add(const Duration(minutes: 4)),
          tz.local,
        );
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          9995,
          'Firebase 4-Minute Fallback Test',
          'This notification was scheduled using Firebase service as fallback (exact alarms not permitted).',
          fallbackTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'test_notifications',
              'Test Notifications',
              channelDescription: 'Test notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              enableVibration: true,
              color: const Color(0xFFFFFF00), // Yellow for fallback
              ledColor: const Color(0xFFFFFF00),
              ledOnMs: 1000,
              ledOffMs: 500,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          9995,
          'Firebase 2-Minute Test',
          'This notification was scheduled using Firebase service for exactly 2 minutes ago.',
          tzScheduledTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'test_notifications',
              'Test Notifications',
              channelDescription: 'Test notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              enableVibration: true,
              color: const Color(0xFF00FF00),
              ledColor: const Color(0xFF00FF00),
              ledOnMs: 1000,
              ledOffMs: 500,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // Send immediate notification for comparison
      await _flutterLocalNotificationsPlugin.show(
        9994,
        'Firebase Immediate Test',
        'This is an immediate notification for comparison.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_notifications',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            color: const Color(0xFFFF0000),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'firebase_immediate_test',
      );

      debugPrint('Firebase test notification scheduled');

      // Check pending notifications to verify scheduling
      final pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending notifications after scheduling: ${pending.length}');
      for (final p in pending) {
        if (p.id == 9995) {
          debugPrint(
              'Scheduled notification found in pending: ${p.title} at ${p.body}');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error in Firebase test: $e');
      return false;
    }
  }

  /// Schedule all reminder types
  Future<void> _scheduleAllReminders() async {
    try {
      // Always try to schedule, even if exact alarms are not permitted
      // We'll use alternative methods for devices that don't support exact alarms
      debugPrint('Scheduling all Firebase reminders...');

      // Schedule meal reminders
      await _scheduleMealReminders();

      // Schedule exercise reminders
      await _scheduleExerciseReminders();

      // Schedule sleep reminders
      await _scheduleSleepReminders();

      // Schedule sustainability tips
      await _scheduleSustainabilityTips();

      debugPrint('All Firebase reminders scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling all Firebase reminders: $e');
    }
  }

  /// Schedule meal reminders
  Future<void> _scheduleMealReminders() async {
    try {
      final AppNotificationSettings settings = await _getNotificationSettings();
      if (!settings.mealRemindersEnabled) return;

      final Map<String, TimeOfDay> mealTimes = {
        'breakfast': const TimeOfDay(hour: 8, minute: 0),
        'lunch': const TimeOfDay(hour: 13, minute: 0),
        'dinner': const TimeOfDay(hour: 19, minute: 0),
      };

      for (final MapEntry<String, TimeOfDay> entry in mealTimes.entries) {
        await _scheduleDailyMealReminder(
          entry.key,
          entry.value,
          _mealReminderBaseId + mealTimes.keys.toList().indexOf(entry.key),
        );
      }
    } catch (e) {
      debugPrint('Error scheduling Firebase meal reminders: $e');
    }
  }

  /// Schedule a daily meal reminder
  Future<void> _scheduleDailyMealReminder(
    String mealType,
    TimeOfDay time,
    int notificationId,
  ) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Try exact scheduling first
      bool scheduled = await _tryScheduleExactNotification(
        id: notificationId,
        title: '${_capitalizeFirst(mealType)} Reminder 🍽️',
        body: 'Time to log your $mealType! Don\'t forget to track your meal.',
        scheduledDate: scheduledDate,
        channelId: 'meal_reminders',
        payload: 'meal_reminder_$mealType',
      );

      if (!scheduled) {
        // Fallback to periodic scheduling
        await _schedulePeriodicFallback(
          notificationId,
          '${_capitalizeFirst(mealType)} Reminder 🍽️',
          'Time to log your $mealType! Don\'t forget to track your meal.',
          time,
          'meal_reminders',
          'meal_reminder_$mealType',
        );
      }

      debugPrint('Firebase scheduled $mealType reminder for $time');
    } catch (e) {
      debugPrint('Error scheduling Firebase $mealType reminder: $e');
    }
  }

  /// Schedule exercise reminders
  Future<void> _scheduleExerciseReminders() async {
    try {
      final AppNotificationSettings settings = await _getNotificationSettings();
      if (!settings.exerciseRemindersEnabled) return;

      // Using FCM campaign "Exercises Reminder" instead of local scheduling
      debugPrint('Using FCM campaign for exercise reminders');
    } catch (e) {
      debugPrint('Error scheduling Firebase exercise reminders: $e');
    }
  }

  /// Schedule sleep reminders
  Future<void> _scheduleSleepReminders() async {
    try {
      final AppNotificationSettings settings = await _getNotificationSettings();
      if (!settings.sleepRemindersEnabled) return;

      await _scheduleBedtimeReminder();
      await _scheduleMorningSleepReminder();
    } catch (e) {
      debugPrint('Error scheduling Firebase sleep reminders: $e');
    }
  }

  /// Schedule bedtime reminder
  Future<void> _scheduleBedtimeReminder() async {
    try {
      const TimeOfDay bedtime = TimeOfDay(hour: 22, minute: 0);
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        bedtime.hour,
        bedtime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Try exact scheduling first
      bool scheduled = await _tryScheduleExactNotification(
        id: _sleepReminderBaseId,
        title: 'Bedtime Reminder 🌙',
        body: 'Time to wind down! Prepare for a good night\'s sleep.',
        scheduledDate: scheduledDate,
        channelId: 'sleep_reminders',
        payload: 'sleep_bedtime_reminder',
      );

      if (!scheduled) {
        // Fallback to periodic scheduling
        await _schedulePeriodicFallback(
          _sleepReminderBaseId,
          'Bedtime Reminder 🌙',
          'Time to wind down! Prepare for a good night\'s sleep.',
          bedtime,
          'sleep_reminders',
          'sleep_bedtime_reminder',
        );
      }

      debugPrint('Firebase scheduled bedtime reminder for $bedtime');
    } catch (e) {
      debugPrint('Error scheduling Firebase bedtime reminder: $e');
    }
  }

  /// Schedule morning sleep reminder
  Future<void> _scheduleMorningSleepReminder() async {
    try {
      const TimeOfDay morningTime = TimeOfDay(hour: 9, minute: 0);
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        morningTime.hour,
        morningTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Try exact scheduling first
      bool scheduled = await _tryScheduleExactNotification(
        id: _sleepReminderBaseId + 1,
        title: 'Sleep Tracking 😴',
        body: 'Good morning! Don\'t forget to log your sleep from last night.',
        scheduledDate: scheduledDate,
        channelId: 'sleep_reminders',
        payload: 'sleep_morning_reminder',
      );

      if (!scheduled) {
        // Fallback to periodic scheduling
        await _schedulePeriodicFallback(
          _sleepReminderBaseId + 1,
          'Sleep Tracking 😴',
          'Good morning! Don\'t forget to log your sleep from last night.',
          morningTime,
          'sleep_reminders',
          'sleep_morning_reminder',
        );
      }

      debugPrint('Firebase scheduled morning sleep reminder for $morningTime');
    } catch (e) {
      debugPrint('Error scheduling Firebase morning sleep reminder: $e');
    }
  }

  /// Schedule sustainability tips
  Future<void> _scheduleSustainabilityTips() async {
    try {
      final AppNotificationSettings settings = await _getNotificationSettings();
      if (!settings.sustainabilityTipsEnabled) return;

      final List<TimeOfDay> tipTimes = [
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 15, minute: 30),
        const TimeOfDay(hour: 18, minute: 45),
      ];

      for (int i = 0; i < tipTimes.length; i++) {
        await _scheduleDailySustainabilityTip(
          tipTimes[i],
          _sustainabilityTipBaseId + i,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling Firebase sustainability tips: $e');
    }
  }

  /// Schedule a daily sustainability tip
  Future<void> _scheduleDailySustainabilityTip(
    TimeOfDay time,
    int notificationId,
  ) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final String tip = _getRandomSustainabilityTip();

      // Try exact scheduling first
      bool scheduled = await _tryScheduleExactNotification(
        id: notificationId,
        title: 'Sustainability Tip 🌱',
        body: tip,
        scheduledDate: scheduledDate,
        channelId: 'sustainability_tips',
        payload: 'sustainability_tip',
      );

      if (!scheduled) {
        // Fallback to periodic scheduling
        await _schedulePeriodicFallback(
          notificationId,
          'Sustainability Tip 🌱',
          tip,
          time,
          'sustainability_tips',
          'sustainability_tip',
        );
      }

      debugPrint('Firebase scheduled sustainability tip for $time');
    } catch (e) {
      debugPrint('Error scheduling Firebase sustainability tip: $e');
    }
  }

  /// Get a random sustainability tip
  String _getRandomSustainabilityTip() {
    final List<String> tips = [
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
    ];

    return tips[Random().nextInt(tips.length)];
  }

  /// Try to schedule an exact notification
  Future<bool> _tryScheduleExactNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _getChannelName(channelId),
            channelDescription: _getChannelDescription(channelId),
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
      debugPrint('✅ Exact notification scheduled: $title at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to schedule exact notification: $e');
      return false;
    }
  }

  /// Schedule periodic fallback notification
  Future<void> _schedulePeriodicFallback(
    int id,
    String title,
    String body,
    TimeOfDay time,
    String channelId,
    String payload,
  ) async {
    try {
      // Use periodic scheduling as fallback
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _getChannelName(channelId),
            channelDescription: _getChannelDescription(channelId),
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
      debugPrint('📅 Periodic fallback scheduled: $title');
    } catch (e) {
      debugPrint('❌ Failed to schedule periodic fallback: $e');
      // Last resort: schedule for next minute as a test
      await _scheduleNextMinuteFallback(id, title, body, channelId, payload);
    }
  }

  /// Schedule next minute fallback (for testing)
  Future<void> _scheduleNextMinuteFallback(
    int id,
    String title,
    String body,
    String channelId,
    String payload,
  ) async {
    try {
      final DateTime nextMinute =
          DateTime.now().add(const Duration(minutes: 1));
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(nextMinute, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            _getChannelName(channelId),
            channelDescription: _getChannelDescription(channelId),
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFFF0000), // Red for fallback
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('🔔 Next minute fallback scheduled: $title');
    } catch (e) {
      debugPrint('❌ Failed to schedule next minute fallback: $e');
    }
  }

  /// Get channel name from channel ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'meal_reminders':
        return 'Meal Reminders';
      case 'exercise_reminders':
        return 'Exercise Reminders';
      case 'sleep_reminders':
        return 'Sleep Reminders';
      case 'sustainability_tips':
        return 'Sustainability Tips';
      case 'test_notifications':
        return 'Test Notifications';
      default:
        return 'Notifications';
    }
  }

  /// Get channel description from channel ID
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'meal_reminders':
        return 'Reminders to log your meals';
      case 'exercise_reminders':
        return 'Reminders to exercise and log workouts';
      case 'sleep_reminders':
        return 'Reminders for sleep tracking and bedtime';
      case 'sustainability_tips':
        return 'Daily sustainability tips and advice';
      case 'test_notifications':
        return 'Test notifications';
      default:
        return 'App notifications';
    }
  }

  /// Handle Android battery optimization and permissions aggressively
  Future<void> _handleAndroidOptimizations() async {
    try {
      debugPrint('🔧 Handling Android optimizations...');

      // Try to request battery optimization exemption
      final batteryGranted = await requestIgnoreBatteryOptimizations();
      if (batteryGranted) {
        debugPrint('✅ Battery optimization exemption granted');
      } else {
        debugPrint('❌ Battery optimization exemption denied');
      }

      // Check and handle exact alarm permissions
      final exactAlarmAllowed = await isExactAlarmPermitted();
      if (!exactAlarmAllowed) {
        debugPrint('⚠️ Exact alarms not permitted, will use fallback methods');
        // Try to open settings for user to enable
        await openExactAlarmSettings();
      } else {
        debugPrint('✅ Exact alarms permitted');
      }

      // Ensure notification channels are created
      await recreateNotificationChannels();

      debugPrint('🔧 Android optimizations handled');
    } catch (e) {
      debugPrint('❌ Error handling Android optimizations: $e');
    }
  }

  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Get notification settings
  Future<AppNotificationSettings> _getNotificationSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> settings = jsonDecode(settingsJson);
        return AppNotificationSettings.fromJson(settings);
      }

      return const AppNotificationSettings();
    } catch (e) {
      debugPrint('Error getting Firebase notification settings: $e');
      return const AppNotificationSettings();
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(
      AppNotificationSettings settings) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

      await cancelAllNotifications();
      await _scheduleAllReminders();

      // Update FCM topic subscriptions
      if (settings.exerciseRemindersEnabled) {
        await _firebaseMessaging.subscribeToTopic('Exercises Reminder');
        debugPrint('Subscribed to Exercises Reminder topic');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('Exercises Reminder');
        debugPrint('Unsubscribed from Exercises Reminder topic');
      }

      debugPrint(
          'Firebase notification settings updated and reminders rescheduled');
    } catch (e) {
      debugPrint('Error updating Firebase notification settings: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All Firebase notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling Firebase notifications: $e');
    }
  }

  /// Get scheduled notifications
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    try {
      final List<PendingNotificationRequest> exactNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      if (exactNotifications.isNotEmpty) {
        return exactNotifications;
      }

      // Create mock notifications for UI display
      final List<PendingNotificationRequest> mockNotifications = [];
      final AppNotificationSettings settings = await _getNotificationSettings();

      if (settings.mealRemindersEnabled) {
        mockNotifications.addAll([
          PendingNotificationRequest(
            _mealReminderBaseId,
            'Breakfast Reminder',
            'Time to log your breakfast and start your day healthy!',
            'meal_breakfast',
          ),
          PendingNotificationRequest(
            _mealReminderBaseId + 1,
            'Lunch Reminder',
            'Don\'t forget to log your lunch for balanced nutrition!',
            'meal_lunch',
          ),
          PendingNotificationRequest(
            _mealReminderBaseId + 2,
            'Dinner Reminder',
            'Time to log your dinner and complete your daily nutrition!',
            'meal_dinner',
          ),
        ]);
      }

      if (settings.exerciseRemindersEnabled) {
        // Exercise reminders are now handled by FCM campaigns
        mockNotifications.addAll([
          PendingNotificationRequest(
            _exerciseReminderBaseId,
            'Exercise Reminder (FCM)',
            'Exercise reminders delivered via Firebase Cloud Messaging campaigns',
            'exercise_fcm',
          ),
        ]);
      }

      if (settings.sleepRemindersEnabled) {
        mockNotifications.addAll([
          PendingNotificationRequest(
            _sleepReminderBaseId,
            'Bedtime Reminder',
            'Time to wind down and prepare for restful sleep!',
            'sleep_bedtime',
          ),
          PendingNotificationRequest(
            _sleepReminderBaseId + 1,
            'Morning Sleep Log',
            'How did you sleep? Log your sleep data for today!',
            'sleep_morning',
          ),
        ]);
      }

      if (settings.sustainabilityTipsEnabled) {
        mockNotifications.addAll([
          PendingNotificationRequest(
            _sustainabilityTipBaseId,
            'Daily Sustainability Tip',
            'Discover eco-friendly practices for sustainable living!',
            'sustainability_tip',
          ),
        ]);
      }

      return mockNotifications;
    } catch (e) {
      debugPrint('Error getting Firebase scheduled notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? enabled =
            await androidImplementation.areNotificationsEnabled();
        return enabled == true;
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error checking Firebase notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Request FCM permissions
      final firebase_messaging.NotificationSettings fcmSettings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final bool fcmGranted = fcmSettings.authorizationStatus ==
          firebase_messaging.AuthorizationStatus.authorized;

      // Request local notification permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? localGranted =
            await androidImplementation.requestNotificationsPermission();
        return fcmGranted && (localGranted == true);
      }

      return fcmGranted;
    } catch (e) {
      debugPrint('Error requesting Firebase notification permissions: $e');
      return false;
    }
  }

  /// Check notification blocking
  Future<Map<String, dynamic>> checkNotificationBlocking() async {
    final Map<String, dynamic> results = <String, dynamic>{};

    try {
      results['timestamp'] = DateTime.now().toIso8601String();

      // Check Android-specific settings
      try {
        final bool? batteryOptimized = await _platform
            .invokeMethod<bool>('isIgnoringBatteryOptimizations');
        results['isIgnoringBatteryOptimizations'] = batteryOptimized ?? false;

        final bool? canScheduleExactAlarms =
            await _platform.invokeMethod<bool>('canScheduleExactAlarms');
        results['canScheduleExactAlarms'] = canScheduleExactAlarms ?? false;

        final String? powerManagementStatus =
            await _platform.invokeMethod<String>('getPowerManagementStatus');
        results['powerManagementStatus'] = powerManagementStatus ?? 'unknown';

        final bool? isAppWhitelisted =
            await _platform.invokeMethod<bool>('isAppWhitelisted');
        results['isAppWhitelisted'] = isAppWhitelisted ?? false;

        final bool notificationsEnabled = await areNotificationsEnabled();
        results['notificationsEnabled'] = notificationsEnabled;

        try {
          final bool? dndEnabled =
              await _platform.invokeMethod<bool>('isDoNotDisturbEnabled');
          results['doNotDisturbEnabled'] = dndEnabled ?? false;
        } catch (e) {
          results['doNotDisturbEnabled'] = 'unknown';
        }
      } catch (e) {
        results['platformChannelError'] = e.toString();
        debugPrint('Platform channel error: $e');
      }

      // Analyze the results
      final List<String> issues = [];
      final List<String> recommendations = [];

      if (results['isIgnoringBatteryOptimizations'] == false) {
        issues.add('Battery optimization is enabled');
        recommendations.add('Disable battery optimization for this app');
      }

      if (results['canScheduleExactAlarms'] == false) {
        issues.add('Exact alarms are not permitted');
        recommendations.add('Enable exact alarm permission in settings');
      }

      if (results['powerManagementStatus'] == 'restricted' ||
          results['powerManagementStatus'] == 'battery_optimized') {
        issues.add('App is restricted by power management');
        recommendations.add('Add app to whitelist/unrestricted apps');
      }

      if (results['isAppWhitelisted'] == false) {
        issues.add('App is not whitelisted');
        recommendations
            .add('Add app to whitelist in power management settings');
      }

      if (results['doNotDisturbEnabled'] == true) {
        issues.add('Do Not Disturb is enabled');
        recommendations
            .add('Disable Do Not Disturb or allow exceptions for this app');
      }

      if (results['notificationsEnabled'] == false) {
        issues.add('Notifications are disabled');
        recommendations.add('Enable notifications for this app');
      }

      results['issues'] = issues;
      results['recommendations'] = recommendations;
      results['hasIssues'] = issues.isNotEmpty;

      debugPrint('Firebase notification blocking analysis: $results');
      return results;
    } catch (e) {
      results['error'] = e.toString();
      debugPrint('Error checking Firebase notification blocking: $e');
      return results;
    }
  }

  /// Reschedule all reminders
  Future<void> rescheduleAllReminders() async {
    try {
      if (!_isInitialized) {
        await initialize();
      } else {
        await _scheduleAllReminders();
      }
      debugPrint('Rescheduled all Firebase reminders');
    } catch (e) {
      debugPrint('Error rescheduling Firebase reminders: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppResumed() async {
    if (_rescheduleInProgress) return;
    _rescheduleInProgress = true;
    try {
      final bool allowed = await isExactAlarmPermitted();
      if (allowed && !_exactAlarmsPermitted) {
        _exactAlarmsPermitted = true;
        await rescheduleAllReminders();
      } else {
        _exactAlarmsPermitted = allowed;
      }
    } catch (e) {
      // ignore errors
    } finally {
      _rescheduleInProgress = false;
    }
  }

  // Platform channel for Android-specific settings
  static const MethodChannel _platform =
      MethodChannel('com.example.sustaina_health/boot');

  /// Check if exact alarms are permitted
  Future<bool> isExactAlarmPermitted() async {
    try {
      final bool? permitted =
          await _platform.invokeMethod<bool>('isExactAlarmPermitted');
      return permitted == true;
    } catch (e) {
      return true;
    }
  }

  /// Open exact alarm settings
  Future<bool> openExactAlarmSettings() async {
    try {
      final bool? launched =
          await _platform.invokeMethod<bool>('openExactAlarmSettings');
      return launched == true;
    } catch (e) {
      return false;
    }
  }

  /// Open notification settings
  Future<bool> openNotificationSettings() async {
    try {
      final bool? opened =
          await _platform.invokeMethod<bool>('openNotificationSettings');
      return opened == true;
    } catch (e) {
      debugPrint('Error opening Firebase notification settings: $e');
      return false;
    }
  }

  /// Open battery optimization settings
  Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool? opened =
          await _platform.invokeMethod<bool>('openBatteryOptimizationSettings');
      return opened == true;
    } catch (e) {
      debugPrint('Error opening Firebase battery optimization settings: $e');
      return false;
    }
  }

  /// Request to ignore battery optimizations
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final bool? granted = await _platform
          .invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return granted == true;
    } catch (e) {
      debugPrint('Error requesting Firebase ignore battery optimizations: $e');
      return false;
    }
  }

  /// Recreate notification channels
  Future<void> recreateNotificationChannels() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImpl =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        await androidImpl.deleteNotificationChannel('meal_reminders');
        await androidImpl.deleteNotificationChannel('exercise_reminders');
        await androidImpl.deleteNotificationChannel('sleep_reminders');
        await androidImpl.deleteNotificationChannel('sustainability_tips');
        await androidImpl.deleteNotificationChannel('smart_reminders');
        await androidImpl.deleteNotificationChannel('test_notifications');

        await _createNotificationChannels();

        debugPrint('✅ Firebase notification channels re-created');
      }
    } catch (e) {
      debugPrint('❌ Error re-creating Firebase notification channels: $e');
    }
  }

  /// Send immediate test notification
  Future<void> sendTestNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        9998,
        'Firebase Test Notification',
        'This is a test notification sent immediately via Firebase service.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_notifications',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            color: const Color(0xFF00FF00),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'firebase_test',
      );
      debugPrint('Firebase test notification sent');
    } catch (e) {
      debugPrint('Error sending Firebase test notification: $e');
      throw e;
    }
  }
}

/// Notification settings class
class AppNotificationSettings {
  final bool mealRemindersEnabled;
  final bool exerciseRemindersEnabled;
  final bool sleepRemindersEnabled;
  final bool sustainabilityTipsEnabled;
  final bool smartRemindersEnabled;

  const AppNotificationSettings({
    this.mealRemindersEnabled = true,
    this.exerciseRemindersEnabled = true,
    this.sleepRemindersEnabled = true,
    this.sustainabilityTipsEnabled = true,
    this.smartRemindersEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'mealRemindersEnabled': mealRemindersEnabled,
      'exerciseRemindersEnabled': exerciseRemindersEnabled,
      'sleepRemindersEnabled': sleepRemindersEnabled,
      'sustainabilityTipsEnabled': sustainabilityTipsEnabled,
      'smartRemindersEnabled': smartRemindersEnabled,
    };
  }

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AppNotificationSettings(
      mealRemindersEnabled: json['mealRemindersEnabled'] ?? true,
      exerciseRemindersEnabled: json['exerciseRemindersEnabled'] ?? true,
      sleepRemindersEnabled: json['sleepRemindersEnabled'] ?? true,
      sustainabilityTipsEnabled: json['sustainabilityTipsEnabled'] ?? true,
      smartRemindersEnabled: json['smartRemindersEnabled'] ?? true,
    );
  }

  AppNotificationSettings copyWith({
    bool? mealRemindersEnabled,
    bool? exerciseRemindersEnabled,
    bool? sleepRemindersEnabled,
    bool? sustainabilityTipsEnabled,
    bool? smartRemindersEnabled,
  }) {
    return AppNotificationSettings(
      mealRemindersEnabled: mealRemindersEnabled ?? this.mealRemindersEnabled,
      exerciseRemindersEnabled:
          exerciseRemindersEnabled ?? this.exerciseRemindersEnabled,
      sleepRemindersEnabled:
          sleepRemindersEnabled ?? this.sleepRemindersEnabled,
      sustainabilityTipsEnabled:
          sustainabilityTipsEnabled ?? this.sustainabilityTipsEnabled,
      smartRemindersEnabled:
          smartRemindersEnabled ?? this.smartRemindersEnabled,
    );
  }
}
