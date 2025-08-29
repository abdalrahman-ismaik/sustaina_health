import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'package:ghiraas/features/exercise/presentation/providers/workout_providers.dart';
import 'package:ghiraas/features/exercise/data/models/workout_models.dart';
import 'package:ghiraas/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:ghiraas/features/sleep/presentation/providers/sleep_providers.dart';
import 'package:ghiraas/features/nutrition/data/models/nutrition_models.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserEntity?> userAsyncValue =
        ref.watch(currentUserProvider);
    final UserEntity? user = userAsyncValue.value;

    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync =
        ref.watch(completedWorkoutsProvider);
    final List<ActiveWorkoutSession>? completedWorkouts =
        completedWorkoutsAsync.value;
    final int streak =
        completedWorkouts != null ? _calculateStreak(completedWorkouts) : 0;
    // Nutrition & Sleep stats
    final AsyncValue<DailyNutritionSummary> dailySummaryAsync =
        ref.watch(dailyNutritionSummaryProvider);
    final int caloriesEaten = dailySummaryAsync.maybeWhen(
        data: (DailyNutritionSummary s) => s.totalNutrition.calories,
        orElse: () => 0);

    final AsyncValue<Duration> sleepDurationAsync =
        ref.watch(sleepDurationProvider);
    final Duration avgSleepDuration = sleepDurationAsync.maybeWhen(
        data: (Duration d) => d, orElse: () => Duration.zero);
    final String avgSleepStr = avgSleepDuration == Duration.zero
        ? '--'
        : '${avgSleepDuration.inHours}h ${avgSleepDuration.inMinutes % 60}m';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle Lottie background for green/particle aesthetic
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.08,
                  child: Lottie.asset(
                    'assets/lottie/particles_green.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Main scrollable content
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Enhanced Header with Stats
                  _buildEnhancedHeader(
                      context, user, streak, caloriesEaten, avgSleepStr),
                  const SizedBox(height: 32),

                  // Quick Actions
                  _buildSectionHeader(
                      context, 'Quick Actions', Icons.dashboard_outlined),
                  const SizedBox(height: 16),
                  _buildEnhancedQuickAccessGrid(context),
                  const SizedBox(height: 32),

                  // Today's Focus with better design
                  _buildSectionHeader(
                      context, 'Today\'s Focus', Icons.eco_outlined),
                  const SizedBox(height: 16),
                  _buildEnhancedTodaysFocusCard(context),
                  const SizedBox(height: 24),

                  // Sustainability Tips
                  _buildSustainabilityTips(context),
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, UserEntity? user,
      int streak, int caloriesEaten, String avgSleepStr) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFF4CAF50), // Sustainable green
            const Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.eco,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Good ${_getGreeting()},',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.displayName?.split(' ').first ?? 'Eco Warrior',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Let\'s make today count! 🌱',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(streak.toString(), 'Day Streak',
                    Icons.local_fire_department),
                _buildStatDivider(),
                _buildStatItem('$caloriesEaten kcal', 'Calories Today',
                    Icons.restaurant_outlined),
                _buildStatDivider(),
                _buildStatItem(
                    avgSleepStr, 'Avg Sleep', Icons.bedtime_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildEnhancedQuickAccessGrid(BuildContext context) {
    final List<Map<String, Object>> quickActions = <Map<String, Object>>[
      <String, Object>{
        'title': 'Exercise',
        'subtitle': 'AI Workouts',
        'icon': Icons.fitness_center_outlined,
        'route': '/exercise',
        'color': const Color(0xFF2196F3),
        'implemented': true,
      },
      <String, Object>{
        'title': 'Nutrition',
        'subtitle': 'Meal Tracking',
        'icon': Icons.restaurant_outlined,
        'route': '/nutrition',
        'color': const Color(0xFF4CAF50),
        'implemented': true,
      },
      <String, Object>{
        'title': 'Sleep',
        'subtitle': 'Sleep Tracking',
        'icon': Icons.bedtime_outlined,
        'route': '/sleep',
        'color': const Color(0xFF9C27B0),
        'implemented': true,
      },
      <String, Object>{
        'title': 'Profile',
        'subtitle': 'Your Progress',
        'icon': Icons.person_outline,
        'route': '/profile',
        'color': const Color(0xFFFF9800),
        'implemented': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Slightly reduce height per item to avoid small bottom overflow on some devices
        childAspectRatio: 0.95,
      ),
      itemCount: quickActions.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, Object> action = quickActions[index];
        return _buildEnhancedQuickActionCard(context, action);
      },
    );
  }

  Widget _buildEnhancedQuickActionCard(
      BuildContext context, Map<String, dynamic> action) {
    final Color actionColor = action['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: actionColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: actionColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go(action['route'] as String),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        actionColor.withValues(alpha: 0.15),
                        actionColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    size: 28,
                    color: actionColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  action['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  action['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTodaysFocusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F8E9),
            Color(0xFFE8F5E8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sustainability Mission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Every small action creates a ripple effect. Start your sustainable journey today and watch your positive impact grow with each healthy choice you make.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/exercise'),
                  icon: const Icon(Icons.fitness_center, size: 18),
                  label: const Text('Start Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/nutrition'),
                  icon: const Icon(Icons.restaurant, size: 18),
                  label: const Text('Log Meal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFF9800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Eco Tip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Did you know? Walking or cycling for just 30 minutes instead of driving can save up to 2.6 kg of CO₂ emissions! 🚴‍♀️',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  // Calculate numeric streak (days) from completed workouts list
  int _calculateStreak(List<ActiveWorkoutSession> completedWorkouts) {
    if (completedWorkouts.isEmpty) return 0;

    final List<ActiveWorkoutSession> sortedWorkouts = completedWorkouts
        .where((ActiveWorkoutSession w) => w.isCompleted && w.endTime != null)
        .toList()
      ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) =>
          b.endTime!.compareTo(a.endTime!));

    if (sortedWorkouts.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final ActiveWorkoutSession workout in sortedWorkouts) {
      final DateTime workoutDate = workout.endTime!;
      final int daysDifference = currentDate.difference(workoutDate).inDays;

      if (daysDifference <= 1) {
        streak++;
        currentDate = workoutDate;
      } else {
        break;
      }
    }

    return streak;
  }
}
