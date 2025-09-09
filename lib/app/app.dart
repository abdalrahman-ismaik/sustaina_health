import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/providers/theme_provider.dart';
import '../core/providers/locale_provider.dart';
import '../core/services/app_initialization_service.dart';
import '../widgets/auto_sync_widget.dart';
import '../l10n/app_localizations.dart';

class GhiraasApp extends ConsumerWidget {
  const GhiraasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    final Locale locale = ref.watch(localeProvider);
    final AsyncValue<void> appInitialization = ref.watch(appInitializationProvider);
    
    return MaterialApp.router(
      title: 'Ghiraas',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use theme provider for dynamic theme switching
      locale: locale, // Use locale provider for dynamic language switching
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleNotifier.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Show a loading screen while app is initializing
      builder: (BuildContext context, Widget? child) {
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
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Ghiraas...'),
                  ],
                ),
              ),
            ),
          ),
          error: (Object error, StackTrace stack) {
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
