import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Placeholder imports for screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_ai_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/exercise/presentation/screens/exercise_home_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_home_screen.dart';
import '../../features/nutrition/presentation/screens/food_logging_screen.dart';
import '../../features/nutrition/presentation/screens/ai_food_recognition_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_insights_screen.dart';
import '../../features/sleep/presentation/screens/sleep_home_screen.dart';
import '../../features/sleep/presentation/screens/sleep_tracking_screen.dart';
import '../../features/sleep/presentation/screens/sleep_analysis_screen.dart';
import '../../features/sleep/presentation/screens/sleep_improvement_screen.dart';
import '../../features/profile/presentation/screens/profile_home_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // GoRoute(
      //   path: RouteNames.onboarding,
      //   builder: (context, state) => const OnboardingScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.login,
      //   builder: (context, state) => const LoginScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.register,
      //   builder: (context, state) => const RegisterScreen(),
      // ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.exercise,
            builder: (context, state) => const ExerciseHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.nutrition,
            builder: (context, state) => const NutritionHomeScreen(),
            routes: [
              GoRoute(
                path: 'log',
                builder: (context, state) => const FoodLoggingScreen(),
              ),
              GoRoute(
                path: 'ai-recognition',
                builder: (context, state) => const AIFoodRecognitionScreen(),
              ),
              GoRoute(
                path: 'insights',
                builder: (context, state) => const NutritionInsightsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.sleep,
            builder: (context, state) => const SleepHomeScreen(),
            routes: [
              GoRoute(
                path: 'tracking',
                builder: (context, state) => const SleepTrackingScreen(),
              ),
              GoRoute(
                path: 'analysis',
                builder: (context, state) => const SleepAnalysisScreen(),
              ),
              GoRoute(
                path: 'improvement',
                builder: (context, state) => const SleepImprovementScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileHomeScreen(),
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