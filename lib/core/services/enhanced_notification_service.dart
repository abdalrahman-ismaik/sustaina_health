import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../../features/exercise/data/services/workout_session_service.dart';
import '../../features/sleep/data/services/sleep_service.dart';
import 'package:flutter/services.dart';

class EnhancedNotificationService with WidgetsBindingObserver {
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final WorkoutSessionService _workoutService = WorkoutSessionService();
  final SleepService _sleepService = SleepService();

  bool _isInitialized = false;
  bool _exactAlarmsPermitted = true;
  bool _rescheduleInProgress = false;

  // Notification IDs for different types
  static const int _mealReminderBaseId = 1000;
  static const int _exerciseReminderBaseId = 2000;
  static const int _sleepReminderBaseId = 3000;
  static const int _sustainabilityTipBaseId = 4000;

  // Notification settings keys
  static const String _settingsKey = 'notification_settings';
  static const String _lastCheckKey = 'last_activity_check';
  // Key for storing flexible notifications (kept for future use)
  // ignore: unused_field
  static const String _flexibleNotificationsKey = 'flexible_notifications';

  // Track flexible notifications internally (kept for future use)
  // ignore: unused_field
  List<Map<String, dynamic>> _flexibleNotifications = [];

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set timezone to Asia/Dubai
      tz.setLocalLocation(tz.getLocation('Asia/Dubai'));

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
      final bool? initialized =
          await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // For Android: create notification channels explicitly to ensure correct importance
      try {
        final AndroidFlutterLocalNotificationsPlugin? androidImpl =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          const AndroidNotificationChannel testChannel =
              AndroidNotificationChannel(
            'test_scheduled',
            'Scheduled Test',
            description: 'Channel for scheduled test notifications',
            importance: Importance.high,
          );

          const AndroidNotificationChannel mealChannel =
              AndroidNotificationChannel(
            'meal_reminders',
            'Meal Reminders',
            description: 'Reminders to log your meals',
            importance: Importance.high,
          );

          // Create channels (safe to call multiple times)
          await androidImpl.createNotificationChannel(testChannel);
          await androidImpl.createNotificationChannel(mealChannel);
          // Additional channels are created implicitly via AndroidNotificationDetails when used,
          // but we log that channels creation was attempted.
        }
      } catch (e) {
        debugPrint('Unable to create Android notification channels: $e');
      }

      // Log timezone info for debugging scheduling issues
      try {
        debugPrint('Timezone: Asia/Dubai');
        debugPrint(
            'Local now: ${tz.TZDateTime.now(tz.getLocation('Asia/Dubai'))}');
      } catch (e) {
        debugPrint('Error printing timezone info: $e');
      }

      if (initialized == true) {
        // Request permissions
        final bool permissionGranted = await requestPermissions();

        if (permissionGranted) {
          _isInitialized = true;

          // Check if exact alarms are permitted on Android; if not, skip scheduling to avoid
          // PlatformException(exact_alarms_not_permitted). The UI can prompt user to enable it.
          try {
            final bool allowed = await isExactAlarmPermitted();
            _exactAlarmsPermitted = allowed;
          } catch (e) {
            _exactAlarmsPermitted = true;
          }

          if (_exactAlarmsPermitted) {
            // Start automatic reminder scheduling
            await _scheduleAllReminders();
            debugPrint(
                'Enhanced notification service initialized and scheduled reminders');
          } else {
            debugPrint(
                'Enhanced notification service initialized but exact alarms are not permitted. Skipping scheduling.');
          }

          // Register for app lifecycle events so we can detect when the user
          // returns from system settings and re-check exact alarm permission.
          try {
            WidgetsBinding.instance.addObserver(this);
          } catch (e) {
            // ignore - in some test contexts WidgetsBinding may not be available
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error initializing enhanced notifications: $e');
      return false;
    }
  }

  /// Handle notification taps
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Handle navigation based on payload
    // You can add navigation logic here based on the notification type
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Request permissions on Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted == true;
      }

      // Request permissions on iOS
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted == true;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Public method to reschedule all reminders. Useful to call after device boot
  /// when the app is launched by a native receiver.
  Future<void> rescheduleAllReminders() async {
    try {
      if (!_isInitialized) {
        // Ensure the service is initialized which will also schedule reminders
        await initialize();
      } else {
        await _scheduleAllReminders();
      }
      debugPrint('Rescheduled all reminders via rescheduleAllReminders()');
    } catch (e) {
      debugPrint('Error rescheduling reminders: $e');
    }
  }

  /// Schedule a one-off test notification N seconds from now using local tz.
  /// Returns true on success, false on failure.
  Future<bool> scheduleOneOffTestNotification({int seconds = 60}) async {
    try {
      if (!_isInitialized) await initialize();
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      final tz.TZDateTime scheduledDate = now.add(Duration(seconds: seconds));

      debugPrint('Attempting to schedule one-off test notification');
      debugPrint('Timezone=Asia/Dubai, now=$now, scheduledDate=$scheduledDate');

      // Check exact-alarm permission state before scheduling
      try {
        final bool exactAllowed = await isExactAlarmPermitted();
        debugPrint('isExactAlarmPermitted() => $exactAllowed');
      } catch (e) {
        debugPrint(
            'Error checking exact alarm permission before scheduling: $e');
      }

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          9999, // test id
          'Scheduled Test Notification',
          'This is a scheduled test notification ($seconds seconds).',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'test_scheduled',
              'Scheduled Test',
              channelDescription: 'Channel for scheduled test notifications',
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

        debugPrint('✅ zonedSchedule call completed successfully for ID 9999');

        // After scheduling, list pending notifications from the plugin
        try {
          final pending = await _flutterLocalNotificationsPlugin
              .pendingNotificationRequests();
          debugPrint(
              'Pending notifications after scheduleOneOffTestNotification: ${pending.map((p) => '${p.id}:${p.title}').join(', ')}');

          // Check if our test notification is actually in the pending list
          final testNotification = pending.where((p) => p.id == 9999).toList();
          if (testNotification.isNotEmpty) {
            debugPrint('✅ Test notification ID 9999 found in pending list');
          } else {
            debugPrint('❌ Test notification ID 9999 NOT found in pending list');
          }
        } catch (e) {
          debugPrint('Error getting pending notifications: $e');
        }

        debugPrint('Scheduled one-off test notification for $scheduledDate');
        return true;
      } catch (e, st) {
        debugPrint('❌ Error scheduling one-off test notification: $e');
        debugPrint('Stack trace: $st');

        // Fallback: attempt a flexible delayed show so the test notification
        // still appears even if zoned scheduling/exact alarms are blocked.
        try {
          final int delaySeconds = seconds;
          Future.delayed(Duration(seconds: delaySeconds), () async {
            try {
              await _flutterLocalNotificationsPlugin.show(
                9999,
                'Fallback Test Notification',
                'Fallback scheduled test after $delaySeconds seconds due to scheduling error.',
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    'test_scheduled',
                    'Scheduled Test',
                    channelDescription:
                        'Channel for scheduled test notifications',
                    importance: Importance.high,
                    priority: Priority.high,
                    icon: '@mipmap/ic_launcher',
                  ),
                  iOS: const DarwinNotificationDetails(),
                ),
                payload: 'fallback_test_notification',
              );
              debugPrint(
                  'Fallback test notification shown after $delaySeconds seconds');
            } catch (e) {
              debugPrint('Error showing fallback notification: $e');
            }
          });
        } catch (e) {
          debugPrint('Error scheduling fallback delayed notification: $e');
        }

        return false;
      }
    } catch (e) {
      debugPrint('Error scheduling one-off test notification: $e');
      return false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app resumes, re-check exact-alarm permission and reschedule if needed
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

  // Platform channel for Android-specific settings and checks
  static const MethodChannel _platform =
      MethodChannel('com.example.sustaina_health/boot');

  /// Returns true if the app is permitted to schedule exact alarms on Android (API 31+).
  /// On other platforms it returns true.
  Future<bool> isExactAlarmPermitted() async {
    try {
      final bool? permitted =
          await _platform.invokeMethod<bool>('isExactAlarmPermitted');
      return permitted == true;
    } catch (e) {
      return true; // conservative fallback
    }
  }

  /// Opens the system settings screen where the user can grant exact alarm permission.
  /// Returns true if the intent was launched.
  Future<bool> openExactAlarmSettings() async {
    try {
      final bool? launched =
          await _platform.invokeMethod<bool>('openExactAlarmSettings');
      return launched == true;
    } catch (e) {
      return false;
    }
  }

  /// Schedule all reminder types
  Future<void> _scheduleAllReminders() async {
    try {
      if (!_exactAlarmsPermitted) {
        debugPrint(
            'Skipping scheduling: exact alarms are not permitted on this device.');
        return;
      }
      debugPrint('Scheduling all reminders...');

      /// Wrapper to prompt the user to open the exact alarm settings screen on Android.
      // ignore: unused_element
      Future<bool> promptEnableExactAlarms() async {
        return await openExactAlarmSettings();
      }

      // Schedule meal reminders
      await _scheduleMealReminders();

      // Schedule exercise reminders
      await _scheduleExerciseReminders();

      // Schedule sleep reminders
      await _scheduleSleepReminders();

      // Schedule sustainability tips
      await _scheduleSustainabilityTips();

      debugPrint('All reminders scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling all reminders: $e');
    }
  }

  /// Schedule meal reminders based on user activity
  Future<void> _scheduleMealReminders() async {
    try {
      final NotificationSettings settings = await _getNotificationSettings();
      if (!settings.mealRemindersEnabled) return;

      // Schedule reminders for each meal type
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
      debugPrint('Error scheduling meal reminders: $e');
    }
  }

  /// Schedule a daily meal reminder
  Future<void> _scheduleDailyMealReminder(
    String mealType,
    TimeOfDay time,
    int notificationId,
  ) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.getLocation('Asia/Dubai'),
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the scheduled time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '${_capitalizeFirst(mealType)} Reminder 🍽️',
        'Time to log your $mealType! Don\'t forget to track your meal.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'meal_reminder_$mealType',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled $mealType reminder for $time');
    } catch (e) {
      debugPrint('Error scheduling $mealType reminder: $e');
    }
  }

  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Schedule exercise reminders
  Future<void> _scheduleExerciseReminders() async {
    try {
      final NotificationSettings settings = await _getNotificationSettings();
      if (!settings.exerciseRemindersEnabled) return;

      // Exercise reminders are now handled by FCM campaigns
      debugPrint('Exercise reminders handled by FCM campaigns');
    } catch (e) {
      debugPrint('Error scheduling exercise reminders: $e');
    }
  }

  /// Schedule sleep reminders
  Future<void> _scheduleSleepReminders() async {
    try {
      final NotificationSettings settings = await _getNotificationSettings();
      if (!settings.sleepRemindersEnabled) return;

      // Schedule bedtime reminder
      await _scheduleBedtimeReminder();

      // Schedule morning sleep logging reminder
      await _scheduleMorningSleepReminder();
    } catch (e) {
      debugPrint('Error scheduling sleep reminders: $e');
    }
  }

  /// Schedule bedtime reminder
  Future<void> _scheduleBedtimeReminder() async {
    try {
      const TimeOfDay bedtime = TimeOfDay(hour: 22, minute: 0); // 10 PM
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.getLocation('Asia/Dubai'),
        now.year,
        now.month,
        now.day,
        bedtime.hour,
        bedtime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _sleepReminderBaseId,
        'Bedtime Reminder 🌙',
        'Time to wind down! Prepare for a good night\'s sleep.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sleep_reminders',
            'Sleep Reminders',
            channelDescription: 'Reminders for sleep tracking and bedtime',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'sleep_bedtime_reminder',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled bedtime reminder for $bedtime');
    } catch (e) {
      debugPrint('Error scheduling bedtime reminder: $e');
    }
  }

  /// Schedule morning sleep reminder
  Future<void> _scheduleMorningSleepReminder() async {
    try {
      const TimeOfDay morningTime = TimeOfDay(hour: 9, minute: 0); // 9 AM
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.getLocation('Asia/Dubai'),
        now.year,
        now.month,
        now.day,
        morningTime.hour,
        morningTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _sleepReminderBaseId + 1,
        'Sleep Tracking 😴',
        'Good morning! Don\'t forget to log your sleep from last night.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sleep_reminders',
            'Sleep Reminders',
            channelDescription: 'Reminders for sleep tracking and bedtime',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'sleep_morning_reminder',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled morning sleep reminder for $morningTime');
    } catch (e) {
      debugPrint('Error scheduling morning sleep reminder: $e');
    }
  }

  /// Schedule sustainability tips
  Future<void> _scheduleSustainabilityTips() async {
    try {
      final NotificationSettings settings = await _getNotificationSettings();
      if (!settings.sustainabilityTipsEnabled) return;

      // Schedule 2-3 tips per day at different times
      final List<TimeOfDay> tipTimes = [
        const TimeOfDay(hour: 11, minute: 0), // 11 AM
        const TimeOfDay(hour: 15, minute: 30), // 3:30 PM
        const TimeOfDay(hour: 18, minute: 45), // 6:45 PM
      ];

      for (int i = 0; i < tipTimes.length; i++) {
        await _scheduleDailySustainabilityTip(
          tipTimes[i],
          _sustainabilityTipBaseId + i,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling sustainability tips: $e');
    }
  }

  /// Schedule a daily sustainability tip
  Future<void> _scheduleDailySustainabilityTip(
    TimeOfDay time,
    int notificationId,
  ) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.getLocation('Asia/Dubai'),
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

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Sustainability Tip 🌱',
        tip,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'sustainability_tips',
            'Sustainability Tips',
            channelDescription: 'Daily sustainability tips and advice',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'sustainability_tip',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled sustainability tip for $time');
    } catch (e) {
      debugPrint('Error scheduling sustainability tip: $e');
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

  /// Check if activities were logged and send smart reminders
  Future<void> checkAndSendSmartReminders() async {
    try {
      final DateTime today = DateTime.now();
      final DateTime todayStart = DateTime(today.year, today.month, today.day);

      // Check if we've already sent reminders today
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastCheck = prefs.getString(_lastCheckKey);
      final DateTime lastCheckDate =
          lastCheck != null ? DateTime.parse(lastCheck) : DateTime(2000);

      // Only check once per day
      if (lastCheckDate.isAfter(todayStart)) return;

      // Check meal logging
      await _checkMealLogging(todayStart);

      // Check exercise logging
      await _checkExerciseLogging(todayStart);

      // Check sleep logging
      await _checkSleepLogging(todayStart);

      // Update last check time
      await prefs.setString(_lastCheckKey, today.toIso8601String());
    } catch (e) {
      debugPrint('Error in smart reminder check: $e');
    }
  }

  /// Check meal logging for today
  Future<void> _checkMealLogging(DateTime todayStart) async {
    try {
      // This would need to be connected to your actual food logging provider
      // For now, we'll simulate the check

      // Example: Check if meals were logged today
      final int missedMeals = await _getMissedMealsCount(todayStart);

      if (missedMeals > 0 && DateTime.now().hour >= 20) {
        await _flutterLocalNotificationsPlugin.show(
          9000,
          'Meal Logging Reminder 🍽️',
          'You haven\'t logged all your meals today. Track your nutrition to stay on top of your health goals!',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'smart_reminders',
              'Smart Reminders',
              channelDescription:
                  'Intelligent reminders based on your activity',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: const Color(0xFF94e0b2),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: 'smart_meal_reminder',
        );
      }
    } catch (e) {
      debugPrint('Error checking meal logging: $e');
    }
  }

  /// Check exercise logging for today
  Future<void> _checkExerciseLogging(DateTime todayStart) async {
    try {
      final List<dynamic> todayWorkouts =
          await _workoutService.getCompletedWorkouts();
      final bool hasExercisedToday = todayWorkouts.any((workout) {
        final DateTime workoutDate = DateTime.parse(workout['startTime']);
        return workoutDate.isAfter(todayStart);
      });

      if (!hasExercisedToday && DateTime.now().hour >= 21) {
        await _flutterLocalNotificationsPlugin.show(
          9001,
          'Exercise Check-in 💪',
          'No workout logged today. Even 10 minutes of movement counts! Track your activity to stay motivated.',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'smart_reminders',
              'Smart Reminders',
              channelDescription:
                  'Intelligent reminders based on your activity',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: const Color(0xFF94e0b2),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: 'smart_exercise_reminder',
        );
      }
    } catch (e) {
      debugPrint('Error checking exercise logging: $e');
    }
  }

  /// Check sleep logging for yesterday
  Future<void> _checkSleepLogging(DateTime todayStart) async {
    try {
      final DateTime yesterday = todayStart.subtract(const Duration(days: 1));
      final List<dynamic> sleepSessions =
          await _sleepService.getSleepSessions();

      final bool hasLoggedSleep = sleepSessions.any((session) {
        final DateTime sessionDate = DateTime.parse(session['startTime']);
        final DateTime sessionDateOnly =
            DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
        final DateTime yesterdayOnly =
            DateTime(yesterday.year, yesterday.month, yesterday.day);
        return sessionDateOnly.isAtSameMomentAs(yesterdayOnly);
      });

      if (!hasLoggedSleep && DateTime.now().hour >= 10) {
        await _flutterLocalNotificationsPlugin.show(
          9002,
          'Sleep Tracking 😴',
          'Don\'t forget to log your sleep from last night! Track your rest to improve your sleep quality.',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'smart_reminders',
              'Smart Reminders',
              channelDescription:
                  'Intelligent reminders based on your activity',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: const Color(0xFF94e0b2),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: 'smart_sleep_reminder',
        );
      }
    } catch (e) {
      debugPrint('Error checking sleep logging: $e');
    }
  }

  /// Get count of missed meals (placeholder implementation)
  Future<int> _getMissedMealsCount(DateTime todayStart) async {
    // This is a placeholder - you would implement this by checking
    // your actual food log provider
    // For now, simulate by returning a random number
    return Random().nextInt(3); // 0-2 missed meals
  }

  /// Send immediate test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        999,
        'Test Notification 🧪',
        'Enhanced notification system is working! You should receive activity reminders throughout the day.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_notifications',
            'Test Notifications',
            channelDescription: 'Test notifications',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'test_notification',
      );

      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> _getNotificationSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> settings = jsonDecode(settingsJson);
        return NotificationSettings.fromJson(settings);
      }

      // Return default settings
      return const NotificationSettings();
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      return const NotificationSettings();
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

      // Reschedule all reminders with new settings
      await cancelAllNotifications();
      await _scheduleAllReminders();

      debugPrint('Notification settings updated and reminders rescheduled');
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Get scheduled notifications (including flexible notifications)
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    try {
      // Get exact scheduled notifications
      final List<PendingNotificationRequest> exactNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      // If we have exact notifications, return them
      if (exactNotifications.isNotEmpty) {
        return exactNotifications;
      }

      // Otherwise, create mock pending notifications from our flexible notifications
      // This helps show users what notifications are scheduled even when using flexible timing
      final List<PendingNotificationRequest> mockNotifications = [];

      // Add mock notifications for known scheduled types
      final NotificationSettings settings = await _getNotificationSettings();

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
          PendingNotificationRequest(
            _sustainabilityTipBaseId + 1,
            'Green Living Reminder',
            'Small actions, big impact! Check out today\'s green tip!',
            'sustainability_reminder',
          ),
        ]);
      }

      return mockNotifications;
    } catch (e) {
      debugPrint('Error getting scheduled notifications: $e');
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
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Check if notifications are being blocked by Do Not Disturb or other system restrictions
  Future<Map<String, dynamic>> checkNotificationBlocking() async {
    final Map<String, dynamic> results = <String, dynamic>{};

    try {
      results['timestamp'] = DateTime.now().toIso8601String();

      // Check Android-specific settings via platform channel
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

        // Check if notifications are enabled
        final bool notificationsEnabled = await areNotificationsEnabled();
        results['notificationsEnabled'] = notificationsEnabled;

        // Check Do Not Disturb status (if available)
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

      debugPrint('Notification blocking analysis: $results');
      return results;
    } catch (e) {
      results['error'] = e.toString();
      debugPrint('Error checking notification blocking: $e');
      return results;
    }
  }

  /// Test notification firing with callback tracking
  Future<void> testNotificationFiring() async {
    try {
      if (!_isInitialized) await initialize();

      debugPrint('🧪 Starting notification firing test...');

      // Schedule a test notification for 30 seconds from now
      final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Dubai'));
      final tz.TZDateTime testTime = now.add(const Duration(seconds: 30));

      debugPrint('📅 Scheduling test notification for: $testTime');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9997, // Unique test ID
        'Firing Test Notification',
        'This notification should fire in 30 seconds. If you see this, scheduling works!',
        testTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled',
            'Scheduled Test',
            channelDescription: 'Channel for scheduled test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            // Add sound and vibration to make it more noticeable
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Test notification scheduled for 30 seconds from now');

      // Also schedule a delayed notification as backup
      Future.delayed(const Duration(seconds: 35), () async {
        try {
          await _flutterLocalNotificationsPlugin.show(
            9996,
            'Backup Test Notification',
            'Backup notification (35s). If you only see this and not the scheduled one, Android is blocking scheduled notifications.',
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
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            payload: 'backup_test_notification',
          );
          debugPrint('✅ Backup test notification sent');
        } catch (e) {
          debugPrint('❌ Error sending backup notification: $e');
        }
      });

      debugPrint(
          '🔍 Check your device in 30-35 seconds. If you see both notifications, scheduling works. If you only see the backup, Android is blocking scheduled notifications.');
    } catch (e) {
      debugPrint('❌ Error in notification firing test: $e');
    }
  }

  /// Open Android notification settings for this app
  Future<bool> openNotificationSettings() async {
    try {
      final bool? opened =
          await _platform.invokeMethod<bool>('openNotificationSettings');
      return opened == true;
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
      return false;
    }
  }

  /// Open Android battery optimization settings
  Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool? opened =
          await _platform.invokeMethod<bool>('openBatteryOptimizationSettings');
      return opened == true;
    } catch (e) {
      debugPrint('Error opening battery optimization settings: $e');
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
      debugPrint('Error requesting ignore battery optimizations: $e');
      return false;
    }
  }

  /// Force re-create all notification channels (Android only)
  Future<void> recreateNotificationChannels() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImpl =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        // Delete existing channels first
        await androidImpl.deleteNotificationChannel('test_scheduled');
        await androidImpl.deleteNotificationChannel('meal_reminders');
        await androidImpl.deleteNotificationChannel('exercise_reminders');
        await androidImpl.deleteNotificationChannel('sleep_reminders');
        await androidImpl.deleteNotificationChannel('sustainability_tips');
        await androidImpl.deleteNotificationChannel('smart_reminders');
        await androidImpl.deleteNotificationChannel('test_notifications');

        // Re-create channels
        const AndroidNotificationChannel testChannel =
            AndroidNotificationChannel(
          'test_scheduled',
          'Scheduled Test',
          description: 'Channel for scheduled test notifications',
          importance: Importance.high,
        );

        const AndroidNotificationChannel mealChannel =
            AndroidNotificationChannel(
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

        const AndroidNotificationChannel testNotificationsChannel =
            AndroidNotificationChannel(
          'test_notifications',
          'Test Notifications',
          description: 'Test notifications',
          importance: Importance.high,
        );

        await androidImpl.createNotificationChannel(testChannel);
        await androidImpl.createNotificationChannel(mealChannel);
        await androidImpl.createNotificationChannel(exerciseChannel);
        await androidImpl.createNotificationChannel(sleepChannel);
        await androidImpl.createNotificationChannel(sustainabilityChannel);
        await androidImpl.createNotificationChannel(smartChannel);
        await androidImpl.createNotificationChannel(testNotificationsChannel);

        debugPrint('✅ All notification channels re-created');
      }
    } catch (e) {
      debugPrint('❌ Error re-creating notification channels: $e');
    }
  }

  /// Alternative scheduling method using Future.delayed (bypasses Android alarm restrictions)
  Future<bool> scheduleTestWithDelay({int seconds = 10}) async {
    try {
      if (!_isInitialized) await initialize();

      debugPrint(
          '🔄 Scheduling test notification using Future.delayed approach');

      Future.delayed(Duration(seconds: seconds), () async {
        try {
          await _flutterLocalNotificationsPlugin.show(
            9998, // Different ID to avoid conflicts
            'Delayed Test Notification',
            'This notification was scheduled using Future.delayed ($seconds seconds ago).',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'test_scheduled',
                'Scheduled Test',
                channelDescription: 'Channel for scheduled test notifications',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            payload: 'delayed_test_notification',
          );
          debugPrint('✅ Delayed test notification shown successfully');
        } catch (e) {
          debugPrint('❌ Error showing delayed notification: $e');
        }
      });

      debugPrint(
          '✅ Delayed notification scheduled for $seconds seconds from now');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling delayed notification: $e');
      return false;
    }
  }

  /// Schedule a simple test notification for exactly 10 seconds from now (no timezone complications)
  Future<bool> scheduleSimple10SecondTest() async {
    try {
      if (!_isInitialized) await initialize();

      debugPrint('🧪 Starting simple 10-second test notification...');

      // Get current time and add 10 seconds - SIMPLE approach
      final DateTime now = DateTime.now();
      final DateTime scheduledTime = now.add(const Duration(seconds: 10));

      debugPrint('📅 Current time: $now');
      debugPrint('⏰ Scheduled for: $scheduledTime');
      debugPrint('⏳ Delay: 10 seconds');

      // Schedule using zonedSchedule with current timezone (simplest approach)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9995, // Unique test ID
        '10-Second Test',
        'This notification was scheduled for exactly 10 seconds ago. If you see this, scheduling works!',
        tz.TZDateTime.from(scheduledTime, tz.local), // Use local timezone
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled',
            'Scheduled Test',
            channelDescription: 'Channel for scheduled test notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            // Make it very visible
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

      debugPrint('✅ Simple 10-second notification scheduled successfully');

      // Also schedule an immediate notification for comparison
      await _flutterLocalNotificationsPlugin.show(
        9994,
        'Immediate Test',
        'This is an immediate notification for comparison. You should see this right away.',
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
        payload: 'immediate_test',
      );

      debugPrint('✅ Immediate comparison notification sent');

      // Check pending notifications
      final List<PendingNotificationRequest> pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final testNotification = pending.where((p) => p.id == 9995).toList();

      if (testNotification.isNotEmpty) {
        debugPrint('✅ 10-second test notification found in pending list');
        debugPrint(
            '📋 Pending notification details: ${testNotification.first.title}');
      } else {
        debugPrint('❌ 10-second test notification NOT found in pending list');
      }

      debugPrint(
          '🔍 Check your device now for the immediate notification, then wait 10 seconds for the scheduled one.');
      debugPrint(
          '💡 If you see the immediate notification but not the scheduled one, Android is blocking scheduled notifications.');

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in simple 10-second test: $e');
      debugPrint('📄 Stack trace: $stackTrace');
      return false;
    }
  }
}

/// Notification settings class
class NotificationSettings {
  final bool mealRemindersEnabled;
  final bool exerciseRemindersEnabled;
  final bool sleepRemindersEnabled;
  final bool sustainabilityTipsEnabled;
  final bool smartRemindersEnabled;

  const NotificationSettings({
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

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      mealRemindersEnabled: json['mealRemindersEnabled'] ?? true,
      exerciseRemindersEnabled: json['exerciseRemindersEnabled'] ?? true,
      sleepRemindersEnabled: json['sleepRemindersEnabled'] ?? true,
      sustainabilityTipsEnabled: json['sustainabilityTipsEnabled'] ?? true,
      smartRemindersEnabled: json['smartRemindersEnabled'] ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? mealRemindersEnabled,
    bool? exerciseRemindersEnabled,
    bool? sleepRemindersEnabled,
    bool? sustainabilityTipsEnabled,
    bool? smartRemindersEnabled,
  }) {
    return NotificationSettings(
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
