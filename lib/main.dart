import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize Hive
  await Hive.initFlutter();
  // Initialize dependency injection
  await setupDependencyInjection();
  runApp(
    const ProviderScope(
      child: SustainaHealthApp(),
    ),
  );
} 