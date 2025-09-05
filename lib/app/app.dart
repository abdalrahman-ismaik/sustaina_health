import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/app_initialization_service.dart';
import '../widgets/auto_sync_widget.dart';

class GhiraasApp extends ConsumerWidget {
  const GhiraasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    final appInitialization = ref.watch(appInitializationProvider);
    
    return MaterialApp.router(
      title: 'Ghiraas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use theme provider for dynamic theme switching
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Show a loading screen while app is initializing
      builder: (context, child) {
        return appInitialization.when(
          data: (_) => AutoSyncWidget(
            showProgressIndicator: true,
            child: child ?? const SizedBox(),
          ),
          loading: () => const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Ghiraas...'),
                  ],
                ),
              ),
            ),
          ),
          error: (error, stack) {
            // Still show the app even if initialization fails
            print('App initialization error: $error');
            return AutoSyncWidget(
              showProgressIndicator: false,
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
