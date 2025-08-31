export 'app/app.dart' show GhiraasApp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart';
import 'core/services/firebase_notification_service.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Ensure background handler symbol is available
// (firebaseMessagingBackgroundHandler is defined in firebase_notification_service.dart)
import 'core/services/firebase_notification_service.dart' as _notif_export;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler BEFORE creating service or runApp
  FirebaseMessaging.onBackgroundMessage(
      _notif_export.firebaseMessagingBackgroundHandler);

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase notifications
  final FirebaseNotificationService notificationService =
      FirebaseNotificationService();
  await notificationService.initialize();

  // Check if native Android started the app after device boot and request reschedule
  const MethodChannel platform =
      MethodChannel('com.example.sustaina_health/boot');
  try {
    final bool launchedFromBoot =
        await platform.invokeMethod<bool>('launchedFromBoot') ?? false;
    if (launchedFromBoot) {
      await notificationService.rescheduleAllReminders();
    }
  } catch (e) {
    // ignore - platform may not implement the method on iOS or other situations
  }

  runApp(
    const ProviderScope(
      child: GhiraasApp(),
    ),
  );
}
