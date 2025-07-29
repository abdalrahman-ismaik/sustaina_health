import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Placeholder imports for screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_ai_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/profile/presentation/screens/profile_personal_info_screen.dart';
import '../../features/profile/presentation/screens/profile_health_goals_screen.dart';
import '../../features/profile/presentation/screens/profile_sustainability_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/exercise/presentation/screens/exercise_home_screen.dart';
import '../../features/exercise/presentation/screens/ai_workout_generator_screen.dart';
import '../../features/exercise/presentation/screens/workout_detail_screen.dart';
import '../../features/exercise/presentation/screens/workout_history_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_home_screen.dart';
import '../../features/nutrition/presentation/screens/food_logging_screen.dart';
import '../../features/nutrition/presentation/screens/ai_food_recognition_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_insights_screen.dart';
import '../../features/sleep/presentation/screens/sleep_home_screen.dart';
import '../../features/sleep/presentation/screens/sleep_tracking_screen.dart';
import '../../features/sleep/presentation/screens/sleep_analysis_screen.dart';
import '../../features/sleep/presentation/screens/sleep_improvement_screen.dart';
import '../../features/profile/presentation/screens/profile_home_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_achievements_screen.dart';
import '../../features/profile/presentation/screens/profile_sustainability_dashboard_screen.dart';
import 'route_names.dart';
import '../providers/auth_state_provider.dart';


final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authState.hasValue && authState.value != null;
      final bool isOnAuthPage = <String>[
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
      ].contains(state.uri.path);

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return RouteNames.login;
      }
      // If logged in and on auth pages, redirect to home
      if (isLoggedIn && isOnAuthPage) {
        return RouteNames.home;
      }
      return null;
    },
    routes: <RouteBase>[
      // Authentication and onboarding
      GoRoute(
        path: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (BuildContext context, GoRouterState state) => const OnboardingAIScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (BuildContext context, GoRouterState state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (BuildContext context, GoRouterState state) => const PasswordRecoveryScreen(),
      ),

      // Profile setup
      GoRoute(
        path: RouteNames.personalInfo,
        builder: (BuildContext context, GoRouterState state) => ProfilePersonalInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.healthGoals,
        builder: (BuildContext context, GoRouterState state) => ProfileHealthGoalsScreen(),
      ),
      GoRoute(
        path: RouteNames.sustainabilityPrefs,
        builder: (BuildContext context, GoRouterState state) => ProfileSustainabilityScreen(),
      ),

      // Main app shell
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) => MainNavigationWrapper(child: child),
        routes: <RouteBase>[
          // Home
          GoRoute(
            path: RouteNames.home,
            builder: (BuildContext context, GoRouterState state) => HomeDashboardScreen(),
          ),
          // Exercise
          GoRoute(
            path: RouteNames.exercise,
            builder: (BuildContext context, GoRouterState state) => ExerciseHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'ai-generator',
                builder: (BuildContext context, GoRouterState state) => AIWorkoutGeneratorScreen(),
              ),
              GoRoute(
                path: 'workout/:workoutId',
                builder: (BuildContext context, GoRouterState state) {
                  final String workoutId = state.pathParameters['workoutId']!;
                  return WorkoutDetailScreen(workoutId: workoutId);
                },
              ),
              GoRoute(
                path: 'history',
                builder: (BuildContext context, GoRouterState state) => WorkoutHistoryScreen(),
              ),
            ],
          ),
          // Nutrition
          GoRoute(
            path: RouteNames.nutrition,
            builder: (BuildContext context, GoRouterState state) => NutritionHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'food-logging',
                builder: (BuildContext context, GoRouterState state) => FoodLoggingScreen(),
              ),
              GoRoute(
                path: 'ai-recognition',
                builder: (BuildContext context, GoRouterState state) => AIFoodRecognitionScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (BuildContext context, GoRouterState state) => NutritionInsightsScreen(),
              ),
            ],
          ),
          // Sleep
          GoRoute(
            path: RouteNames.sleep,
            builder: (BuildContext context, GoRouterState state) => SleepHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'tracking',
                builder: (BuildContext context, GoRouterState state) => SleepTrackingScreen(),
              ),
              GoRoute(
                path: 'analysis',
                builder: (BuildContext context, GoRouterState state) => SleepAnalysisScreen(),
              ),
              GoRoute(
                path: 'improvement',
                builder: (BuildContext context, GoRouterState state) => SleepImprovementScreen(),
              ),
            ],
          ),
          // Profile
          GoRoute(
            path: RouteNames.profile,
            builder: (BuildContext context, GoRouterState state) => ProfileHomeScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'settings',
                builder: (BuildContext context, GoRouterState state) => ProfileSettingsScreen(),
              ),
              GoRoute(
                path: 'achievements',
                builder: (BuildContext context, GoRouterState state) => ProfileAchievementsScreen(),
              ),
              GoRoute(
                path: 'sustainability',
                builder: (BuildContext context, GoRouterState state) => ProfileSustainabilityDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Placeholder for MainNavigationWrapper
class MainNavigationWrapper extends StatelessWidget {
  final Widget child;
  const MainNavigationWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
} 