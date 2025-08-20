import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GhiraasApp extends ConsumerWidget {
  const GhiraasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Ghiraas',
      theme:
          AppTheme.lightTheme, // This is actually our dark sustainability theme
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Force use our custom dark theme
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
