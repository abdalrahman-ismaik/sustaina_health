import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../../features/exercise/data/services/workout_session_service.dart';
import '../../features/sleep/data/services/sleep_service.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = 
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final WorkoutSessionService _workoutService = WorkoutSessionService();
  final SleepService _sleepService = SleepService();

  bool _isInitialized = false;

  // Notification IDs for different types
  static const int _mealReminderBaseId = 1000;
  static const int _exerciseReminderBaseId = 2000;
  static const int _sleepReminderBaseId = 3000;
  static const int _sustainabilityTipBaseId = 4000;

  // Notification settings keys
  static const String _settingsKey = 'notification_settings';
  static const String _lastCheckKey = 'last_activity_check';
  static const String _flexibleNotificationsKey = 'flexible_notifications';

  // Track flexible notifications internally
  List<Map<String, dynamic>> _flexibleNotifications = <Map<String, dynamic>>[];

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Set local timezone (you can customize this)
      tz.setLocalLocation(tz.getLocation('UTC'));

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
      final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      if (initialized == true) {
        // Request permissions
        final bool permissionGranted = await requestPermissions();
        
        if (permissionGranted) {
          _isInitialized = true;
          
          // Start automatic reminder scheduling
          await _scheduleAllReminders();
          
          debugPrint('Enhanced notification service initialized successfully');
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
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
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

  /// Schedule all reminder types
  Future<void> _scheduleAllReminders() async {
    try {
      debugPrint('Scheduling all reminders...');
      
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
      final Map<String, TimeOfDay> mealTimes = <String, TimeOfDay>{
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
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
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

  /// Schedule exercise reminders
  Future<void> _scheduleExerciseReminders() async {
    try {
      final NotificationSettings settings = await _getNotificationSettings();
      if (!settings.exerciseRemindersEnabled) return;

      // Schedule daily exercise reminder
      await _scheduleDailyExerciseReminder();
      
      // Schedule evening check-in if no workout logged
      await _scheduleEveningExerciseCheckIn();
    } catch (e) {
      debugPrint('Error scheduling exercise reminders: $e');
    }
  }

  /// Schedule daily exercise reminder
  Future<void> _scheduleDailyExerciseReminder() async {
    try {
      const TimeOfDay exerciseTime = TimeOfDay(hour: 17, minute: 0); // 5 PM
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        exerciseTime.hour,
        exerciseTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _exerciseReminderBaseId,
        'Exercise Time! 💪',
        'Ready for your workout? Let\'s get moving and track your progress!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'exercise_reminders',
            'Exercise Reminders',
            channelDescription: 'Reminders to exercise and log workouts',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'exercise_reminder_daily',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled daily exercise reminder for $exerciseTime');
    } catch (e) {
      debugPrint('Error scheduling daily exercise reminder: $e');
    }
  }

  /// Schedule evening exercise check-in
  Future<void> _scheduleEveningExerciseCheckIn() async {
    try {
      const TimeOfDay checkInTime = TimeOfDay(hour: 20, minute: 0); // 8 PM
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        checkInTime.hour,
        checkInTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _exerciseReminderBaseId + 1,
        'Daily Check-in 📊',
        'Did you exercise today? Don\'t forget to log your workout!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'exercise_reminders',
            'Exercise Reminders',
            channelDescription: 'Reminders to exercise and log workouts',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: const Color(0xFF94e0b2),
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'exercise_checkin_evening',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled evening exercise check-in for $checkInTime');
    } catch (e) {
      debugPrint('Error scheduling evening exercise check-in: $e');
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
      final List<TimeOfDay> tipTimes = <TimeOfDay>[
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
    final List<String> tips = <String>[
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
      final DateTime lastCheckDate = lastCheck != null 
          ? DateTime.parse(lastCheck) 
          : DateTime(2000);
      
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
              channelDescription: 'Intelligent reminders based on your activity',
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
      final List<dynamic> todayWorkouts = await _workoutService.getCompletedWorkouts();
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
              channelDescription: 'Intelligent reminders based on your activity',
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
      final List<dynamic> sleepSessions = await _sleepService.getSleepSessions();
      
      final bool hasLoggedSleep = sleepSessions.any((session) {
        final DateTime sessionDate = DateTime.parse(session['startTime']);
        final DateTime sessionDateOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
        final DateTime yesterdayOnly = DateTime(yesterday.year, yesterday.month, yesterday.day);
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
              channelDescription: 'Intelligent reminders based on your activity',
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
      final List<PendingNotificationRequest> mockNotifications = <PendingNotificationRequest>[];
      
      // Add mock notifications for known scheduled types
      final NotificationSettings settings = await _getNotificationSettings();
      
      if (settings.mealRemindersEnabled) {
        mockNotifications.addAll(<PendingNotificationRequest>[
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
        mockNotifications.addAll(<PendingNotificationRequest>[
          PendingNotificationRequest(
            _exerciseReminderBaseId,
            'Daily Exercise Reminder',
            'Time for some physical activity! Let\'s get moving!',
            'exercise_daily',
          ),
          PendingNotificationRequest(
            _exerciseReminderBaseId + 1,
            'Workout Check-in',
            'Did you exercise today? Log your workout progress!',
            'exercise_checkin',
          ),
        ]);
      }
      
      if (settings.sleepRemindersEnabled) {
        mockNotifications.addAll(<PendingNotificationRequest>[
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
        mockNotifications.addAll(<PendingNotificationRequest>[
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
      return <PendingNotificationRequest>[];
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
        final bool? enabled = await androidImplementation.areNotificationsEnabled();
        return enabled == true;
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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
    return <String, dynamic>{
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
      exerciseRemindersEnabled: exerciseRemindersEnabled ?? this.exerciseRemindersEnabled,
      sleepRemindersEnabled: sleepRemindersEnabled ?? this.sleepRemindersEnabled,
      sustainabilityTipsEnabled: sustainabilityTipsEnabled ?? this.sustainabilityTipsEnabled,
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
    );
  }
}
