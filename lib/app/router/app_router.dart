import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Placeholder imports for screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_ai_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
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


final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // Authentication and onboarding
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingAIScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),

      // Profile setup
      GoRoute(
        path: RouteNames.personalInfo,
        builder: (context, state) => ProfilePersonalInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.healthGoals,
        builder: (context, state) => ProfileHealthGoalsScreen(),
      ),
      GoRoute(
        path: RouteNames.sustainabilityPrefs,
        builder: (context, state) => ProfileSustainabilityScreen(),
      ),

      // Main app shell
      ShellRoute(
        builder: (context, state, child) => MainNavigationWrapper(child: child),
        routes: [
          // Home
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => HomeDashboardScreen(),
          ),
          // Exercise
          GoRoute(
            path: RouteNames.exercise,
            builder: (context, state) => ExerciseHomeScreen(),
            routes: [
              GoRoute(
                path: 'ai-generator',
                builder: (context, state) => AIWorkoutGeneratorScreen(),
              ),
              GoRoute(
                path: 'workout/:workoutId',
                builder: (context, state) {
                  final workoutId = state.pathParameters['workoutId']!;
                  return WorkoutDetailScreen(workoutId: workoutId);
                },
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => WorkoutHistoryScreen(),
              ),
            ],
          ),
          // Nutrition
          GoRoute(
            path: RouteNames.nutrition,
            builder: (context, state) => NutritionHomeScreen(),
            routes: [
              GoRoute(
                path: 'food-logging',
                builder: (context, state) => FoodLoggingScreen(),
              ),
              GoRoute(
                path: 'ai-recognition',
                builder: (context, state) => AIFoodRecognitionScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (context, state) => NutritionInsightsScreen(),
              ),
            ],
          ),
          // Sleep
          GoRoute(
            path: RouteNames.sleep,
            builder: (context, state) => SleepHomeScreen(),
            routes: [
              GoRoute(
                path: 'tracking',
                builder: (context, state) => SleepTrackingScreen(),
              ),
              GoRoute(
                path: 'analysis',
                builder: (context, state) => SleepAnalysisScreen(),
              ),
              GoRoute(
                path: 'improvement',
                builder: (context, state) => SleepImprovementScreen(),
              ),
            ],
          ),
          // Profile
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => ProfileHomeScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => ProfileSettingsScreen(),
              ),
              GoRoute(
                path: 'achievements',
                builder: (context, state) => ProfileAchievementsScreen(),
              ),
              GoRoute(
                path: 'sustainability',
                builder: (context, state) => ProfileSustainabilityDashboardScreen(),
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