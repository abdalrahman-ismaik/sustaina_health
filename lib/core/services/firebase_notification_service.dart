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

/// Top-level background message handler required by firebase_messaging.
/// This must be a top-level or static function (not an instance or closure)
/// so it can be invoked by the background isolate.
Future<void> firebaseMessagingBackgroundHandler(
    firebase_messaging.RemoteMessage message) async {
  try {
    // Ensure Firebase is initialized in the background isolate.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    debugPrint('FCM background handler received a message: '
        '\${message.messageId} | \\${message.notification?.title}');

    // NOTE: Avoid using plugin instances that aren't safe from background isolate.
    // Keep processing light here (logging, analytics, or scheduling work).
  } catch (e) {
    debugPrint('Error in background message handler: $e');
  }
}

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

  // Local notification IDs removed; app relies on FCM topics

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

      // Subscribe to FCM topics for campaigns (topics are the single source of truth)
      final AppNotificationSettings appSettings =
          await _getNotificationSettings();
      if (appSettings.exerciseRemindersEnabled) {
        await _firebaseMessaging.subscribeToTopic('exercises_reminder');
        debugPrint('Subscribed to exercises_reminder topic for FCM campaign');
      }

      debugPrint(
          'Firebase notification service initialized (topics-only model)');

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

    // Background message handler registration is performed in `main.dart`
    // (before runApp) to ensure the handler is registered from the main isolate.
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

  /// Force reschedule (topics-only): cancel local notifications and reapply optimizations
  Future<bool> forceRescheduleWithImprovements() async {
    try {
      debugPrint('🔄 Force rescheduling (topics-only)...');

      // Cancel any local notifications
      await cancelAllNotifications();

      // Re-check Android optimizations
      await _handleAndroidOptimizations();

      debugPrint('✅ Force rescheduling (topics-only) completed');
      return true;
    } catch (e) {
      debugPrint('❌ Force rescheduling failed: $e');
      return false;
    }
  }

  /// Scheduling helpers removed: App uses FCM topics and server-side campaigns.

  // Removed scheduled test helpers: app now relies on FCM topics and server campaigns

  // Scheduling removed: rely on FCM topics and server-side campaigns instead

  // Meal scheduling removed (topics-only)

  // Daily meal reminders removed

  /// Exercise reminders handled by FCM topics (no local scheduling)

  // Sleep scheduling removed (topics-only)

  // Bedtime reminder removed

  // Morning sleep reminder removed

  // Sustainability tips scheduling removed (use server/FCM topics)

  // Daily sustainability tips removed

  // Sustainability tips helper removed

  // Exact scheduling helpers removed

  // Periodic fallback removed

  // Next-minute fallback removed

  /// Handle Android battery optimization and permissions aggressively
  Future<void> _handleAndroidOptimizations() async {
    try {
      debugPrint('🔧 Handling Android optimizations...');

      // Try to request battery optimization exemption
      final bool batteryGranted = await requestIgnoreBatteryOptimizations();
      if (batteryGranted) {
        debugPrint('✅ Battery optimization exemption granted');
      } else {
        debugPrint('❌ Battery optimization exemption denied');
      }

      // Check and handle exact alarm permissions
      final bool exactAlarmAllowed = await isExactAlarmPermitted();
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

  // Helper methods for local scheduling removed in topics-only model

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

      // Cancel local notifications; scheduling is handled server-side via FCM topics
      await cancelAllNotifications();

      // Update FCM topic subscriptions (topics-only)
      if (settings.exerciseRemindersEnabled) {
        await _firebaseMessaging.subscribeToTopic('exercises_reminder');
        debugPrint('Subscribed to exercises_reminder topic');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('exercises_reminder');
        debugPrint('Unsubscribed from exercises_reminder topic');
      }

      // Cancel any local notifications as we now rely on FCM topics
      await cancelAllNotifications();

      debugPrint('Firebase notification settings updated (topics-only)');
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

  /// Get scheduled notifications: since reminders are topics-only, return local pending requests (likely empty)
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    try {
      final List<PendingNotificationRequest> exactNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return exactNotifications;
    } catch (e) {
      debugPrint('Error getting Firebase scheduled notifications: $e');
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
      final List<String> issues = <String>[];
      final List<String> recommendations = <String>[];

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
        // No local rescheduling in topics-only model
        await cancelAllNotifications();
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
    return <String, dynamic>{
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
