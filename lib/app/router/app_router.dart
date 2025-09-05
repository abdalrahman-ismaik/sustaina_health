import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Placeholder imports for screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/auth/presentation/screens/onboarding_ai_screen.dart';
import '../../features/auth/presentation/screens/onboarding_sustainability_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/personal_info_setup_screen.dart';
import '../../features/profile/presentation/screens/profile_personal_info_screen.dart';
import '../../features/profile/presentation/screens/profile_health_goals_screen.dart';
import '../../features/profile/presentation/screens/profile_sustainability_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/exercise/presentation/screens/exercise_home_screen.dart';
import '../../features/exercise/presentation/screens/ai_workout_generator_screen.dart';
import '../../features/exercise/presentation/screens/workout_history_screen.dart';
import '../../features/exercise/presentation/screens/hybrid_workout_example.dart';
import '../../features/nutrition/presentation/screens/nutrition_home_screen.dart';
import '../../features/nutrition/presentation/screens/food_logging_screen.dart';
import '../../features/nutrition/presentation/screens/ai_food_recognition_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_insights_screen.dart';
import '../../features/nutrition/presentation/screens/ai_meal_plan_generator_screen.dart';
import '../../features/nutrition/presentation/screens/saved_meal_plans_screen.dart';
import '../../features/nutrition/presentation/screens/brand_recommendations_screen.dart';
import '../../features/sleep/presentation/screens/sleep_home_screen.dart';
import '../../features/sleep/presentation/screens/sleep_tracking_screen.dart';
import '../../features/sleep/presentation/screens/sleep_analysis_screen.dart';
import '../../features/sleep/presentation/screens/sleep_improvement_screen.dart';
import '../../features/profile/presentation/screens/profile_home_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_achievements_screen.dart';
import '../../features/profile/presentation/screens/profile_sustainability_dashboard_screen.dart';
import '../../features/profile/presentation/screens/privacy_security_screen.dart';
import '../../features/profile/presentation/screens/app_preferences_screen.dart';
import 'route_names.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/data/services/profile_setup_service.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import '../../core/widgets/main_navigation_wrapper.dart';

final Provider<GoRouter> appRouterProvider =
    Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  final AsyncValue<UserEntity?> authState = ref.watch(authStateProvider);
  final AsyncValue<bool> profileSetupCompleted = ref.watch(profileSetupCompletedProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authState.hasValue && authState.value != null;
      final bool isOnAuthPage = <String>[
        RouteNames.splash,
        RouteNames.onboardingWelcome,
        RouteNames.onboardingAIFeatures,
        RouteNames.onboardingSustainability,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
      ].contains(state.uri.path);
      
      final bool isOnProfileSetupPage = state.uri.path == RouteNames.personalInfoSetup;

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnAuthPage && !isOnProfileSetupPage) {
        return RouteNames.login;
      }
      
      // If logged in, check profile setup status
      if (isLoggedIn) {
        // Skip redirect if already on personal info setup page
        if (isOnProfileSetupPage) {
          return null;
        }
        
        // Check if profile setup is completed
        if (profileSetupCompleted.hasValue) {
          final bool hasCompletedSetup = profileSetupCompleted.value ?? false;
          
          // If profile not completed, redirect to profile setup (skip onboarding)
          if (!hasCompletedSetup) {
            return RouteNames.personalInfoSetup;
          }
          
          // If profile completed and on auth pages (except splash), redirect to home
          if (hasCompletedSetup && isOnAuthPage && state.uri.path != RouteNames.splash) {
            return RouteNames.home;
          }
        } else {
          // If profile setup status is still loading, wait for it
          // Don't redirect yet, let the provider load
          if (profileSetupCompleted.isLoading && state.uri.path != RouteNames.splash) {
            return null; // Stay on current page while loading
          }
        }
      }
      
      return null;
    },
    routes: <RouteBase>[
      // Authentication and onboarding
      GoRoute(
        path: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingWelcome,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingWelcomeScreen(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.onboardingAIFeatures,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingAIScreen(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.onboardingSustainability,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingSustainabilityScreen(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const PasswordRecoveryScreen(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),

      // Personal Info Setup (after authentication)
      GoRoute(
        path: RouteNames.personalInfoSetup,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: const PersonalInfoSetupScreen(isFirstTime: true),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      ),

      // Profile setup
      GoRoute(
        path: RouteNames.personalInfo,
        builder: (BuildContext context, GoRouterState state) =>
            ProfilePersonalInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.healthGoals,
        builder: (BuildContext context, GoRouterState state) =>
            ProfileHealthGoalsScreen(),
      ),
      GoRoute(
        path: RouteNames.sustainabilityPrefs,
        builder: (BuildContext context, GoRouterState state) =>
            ProfileSustainabilityScreen(),
      ),

      // Main app shell
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            MainNavigationWrapper(child: child),
        routes: <RouteBase>[
          // Home
          GoRoute(
            path: RouteNames.home,
            builder: (BuildContext context, GoRouterState state) =>
                HomeDashboardScreen(),
          ),
          // Exercise
          GoRoute(
            path: RouteNames.exercise,
            builder: (BuildContext context, GoRouterState state) =>
                ExerciseHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'ai-generator',
                builder: (BuildContext context, GoRouterState state) =>
                    AIWorkoutGeneratorScreen(),
              ),
              GoRoute(
                path: 'history',
                builder: (BuildContext context, GoRouterState state) =>
                    WorkoutHistoryScreen(),
              ),
              GoRoute(
                path: 'storage-demo',
                builder: (BuildContext context, GoRouterState state) =>
                    HybridWorkoutExample(),
              ),
            ],
          ),
          // Nutrition
          GoRoute(
            path: RouteNames.nutrition,
            builder: (BuildContext context, GoRouterState state) =>
                NutritionHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'food-logging',
                builder: (BuildContext context, GoRouterState state) =>
                    FoodLoggingScreen(),
              ),
              GoRoute(
                path: 'ai-recognition',
                builder: (BuildContext context, GoRouterState state) =>
                    AIFoodRecognitionScreen(
                  mealType: state.uri.queryParameters['mealType'],
                ),
              ),
              GoRoute(
                path: 'insights',
                builder: (BuildContext context, GoRouterState state) =>
                    NutritionInsightsScreen(),
              ),
              GoRoute(
                path: 'ai-meal-plan',
                builder: (BuildContext context, GoRouterState state) =>
                    AIMealPlanGeneratorScreen(),
              ),
              GoRoute(
                path: 'saved-plans',
                builder: (BuildContext context, GoRouterState state) =>
                    const SavedMealPlansScreen(),
              ),
              GoRoute(
                path: 'brand-recommendations',
                builder: (BuildContext context, GoRouterState state) =>
                    const BrandRecommendationsScreen(),
              ),
            ],
          ),
          // Sleep
          GoRoute(
            path: RouteNames.sleep,
            builder: (BuildContext context, GoRouterState state) =>
                SleepHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'tracking',
                builder: (BuildContext context, GoRouterState state) =>
                    SleepTrackingScreen(),
              ),
              GoRoute(
                path: 'analysis',
                builder: (BuildContext context, GoRouterState state) =>
                    SleepAnalysisScreen(),
              ),
              GoRoute(
                path: 'improvement',
                builder: (BuildContext context, GoRouterState state) =>
                    SleepImprovementScreen(),
              ),
            ],
          ),
          // Profile
          GoRoute(
            path: RouteNames.profile,
            builder: (BuildContext context, GoRouterState state) =>
                ProfileHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'settings',
                builder: (BuildContext context, GoRouterState state) =>
                    ProfileSettingsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'privacy',
                    builder: (BuildContext context, GoRouterState state) =>
                        const PrivacySecurityScreen(),
                  ),
                  GoRoute(
                    path: 'app',
                    builder: (BuildContext context, GoRouterState state) =>
                        const AppPreferencesScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'achievements',
                builder: (BuildContext context, GoRouterState state) =>
                    ProfileAchievementsScreen(),
              ),
              GoRoute(
                path: 'sustainability',
                builder: (BuildContext context, GoRouterState state) =>
                    ProfileSustainabilityDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Global routes
      GoRoute(
        path: RouteNames.privacy,
        builder: (BuildContext context, GoRouterState state) =>
            const PrivacySecurityScreen(),
      ),
    ],
  );
});
