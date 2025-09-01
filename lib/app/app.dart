import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/providers/theme_provider.dart';

class GhiraasApp extends ConsumerWidget {
  const GhiraasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Ghiraas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use theme provider for dynamic theme switching
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
