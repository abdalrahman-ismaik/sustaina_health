import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'workout_history_screen.dart';
import 'ai_workout_generator_screen.dart';
import 'saved_workout_plans_screen.dart';
import 'my_workouts_screen.dart';
import 'completed_workout_detail_screen.dart';
import '../providers/workout_providers.dart';
import '../../../../app/theme/exercise_colors.dart';

class ExerciseHomeScreen extends ConsumerWidget {
  const ExerciseHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ExerciseColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.list, color: ExerciseColors.textPrimary, size: 32),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: Text(
                        'Your Fitness Journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ExerciseColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: ExerciseColors.textPrimary),
                    onPressed: () => _showExerciseGuide(context),
                  ),
                ],
              ),
            ),
            // Progress Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Weekly Workout Completion',
                      style: TextStyle(
                          color: ExerciseColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: ExerciseColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.75, // 75% completion
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: ExerciseColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('3/4 workouts completed',
                      style: TextStyle(
                          color: ExerciseColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const MyWorkoutsScreen()),
                      );
                    },
                    child: _StatCard(title: 'Current Streak', value: '5 days'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const WorkoutHistoryScreen()),
                      );
                    },
                    child: _StatCard(
                        title: 'Calories Burned Today', value: '350 kcal'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  _StatCard(title: 'Sustainability Score', value: '85/100'),
                  const SizedBox(width: 8),
                  _StatCard(title: 'Workout Duration', value: '45 min'),
                ],
              ),
            ),
            // Quick Start
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Quick Start',
                style: TextStyle(
                  color: ExerciseColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AIWorkoutGeneratorScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExerciseColors.buttonPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Start AI Workout',
                          style: TextStyle(
                            color: ExerciseColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.015,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SavedWorkoutPlansScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExerciseColors.buttonSecondary,
                          side: BorderSide(color: ExerciseColors.borderPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'My Plans',
                          style: TextStyle(
                            color: ExerciseColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.015,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recent Workouts & Outdoor Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const <Widget>[
                    _TagChip(label: 'Recent Workout: Yoga'),
                    SizedBox(width: 8),
                    _TagChip(label: 'Recent Workout: Running'),
                    SizedBox(width: 8),
                    _TagChip(label: 'Outdoor Activity: Hiking'),
                  ],
                ),
              ),
            ),
            // Saved Workout Plans Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Saved Plans',
                    style: TextStyle(
                      color: ExerciseColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.015,
                    ),
                  ),
                ],
              ),
            ),
            _buildSavedWorkoutPlansSection(context, ref),
            // Recent Completed Workouts Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Workouts',
                    style: TextStyle(
                      color: ExerciseColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.015,
                    ),
                  ),
                ],
              ),
            ),
            _buildRecentCompletedWorkoutsSection(context, ref),
            // Workout Categories
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Workout Categories',
                style: TextStyle(
                  color: ExerciseColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const <Widget>[
                  _CategoryCard(icon: Icons.favorite, label: 'Cardio'),
                  _CategoryCard(icon: Icons.fitness_center, label: 'Strength'),
                  _CategoryCard(
                      icon: Icons.self_improvement, label: 'Flexibility'),
                  _CategoryCard(icon: Icons.park, label: 'Outdoor'),
                  _CategoryCard(
                      icon: Icons.directions_bike, label: 'Eco-friendly'),
                ],
              ),
            ),
            const SizedBox(height: 80), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSavedWorkoutPlansSection(BuildContext context, WidgetRef ref) {
    final savedWorkoutsAsync = ref.watch(savedWorkoutPlansProvider);

    return savedWorkoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ExerciseColors.primaryGreenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ExerciseColors.primaryGreenMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_border,
                  color: ExerciseColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No saved workout plans yet',
                        style: TextStyle(
                          color: ExerciseColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate and save your first workout plan',
                        style: TextStyle(
                          color: ExerciseColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIWorkoutGeneratorScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Generate',
                    style: TextStyle(
                      color: ExerciseColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show recent saved workouts (max 3)
        final recentWorkouts = workouts.take(3).toList();

        return Column(
          children: [
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentWorkouts.length + 1, // +1 for "View All" card
                itemBuilder: (context, index) {
                  if (index == recentWorkouts.length) {
                    // "View All" card
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(left: 8),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SavedWorkoutPlansScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF94E0B2),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'View All\n(${workouts.length})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF94E0B2),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final workout = recentWorkouts[index];
                  return Container(
                    width: 180,
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SavedWorkoutPlansScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (workout.isFavorite)
                                    const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  if (workout.isFavorite)
                                    const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      workout.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF121714),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${workout.workoutPlan.sessionsPerWeek} sessions/week',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workout.workoutPlan.workoutSessions.length} workouts',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF94E0B2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(
                                    color: Color(0xFF94E0B2),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: CircularProgressIndicator(
            color: ExerciseColors.loadingIndicator,
          ),
        ),
      ),
      error: (error, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ExerciseColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Failed to load saved workouts',
          style: TextStyle(color: ExerciseColors.errorDark),
        ),
      ),
    );
  }

  Widget _buildRecentCompletedWorkoutsSection(
      BuildContext context, WidgetRef ref) {
    final completedWorkoutsAsync = ref.watch(completedWorkoutsProvider);

    return completedWorkoutsAsync.when(
      data: (completedWorkouts) {
        if (completedWorkouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No completed workouts yet',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Start a workout and complete it to see your progress',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedWorkoutPlansScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show recent completed workouts (max 3)
        // Sort by completion date (most recent first) and filter only completed ones
        final recentCompletedWorkouts = completedWorkouts
            .where((w) => w.isCompleted && w.endTime != null)
            .toList()
          ..sort((a, b) => b.endTime!.compareTo(a.endTime!));

        final displayWorkouts = recentCompletedWorkouts.take(3).toList();

        if (displayWorkouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workouts in progress',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have ${completedWorkouts.length} workout${completedWorkouts.length == 1 ? '' : 's'} started but not completed',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayWorkouts.length + 1, // +1 for "View All" card
                itemBuilder: (context, index) {
                  if (index == displayWorkouts.length) {
                    // "View All" card
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(left: 8),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkoutHistoryScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'View All\n(${completedWorkouts.where((w) => w.isCompleted).length})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final workout = displayWorkouts[index];
                  return Container(
                    width: 180,
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompletedWorkoutDetailScreen(
                                completedWorkout: workout,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.workoutName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF121714),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatWorkoutDate(workout.startTime),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: ${_formatDuration(workout.totalDuration)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workout.exercises.length} exercises',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
          child: CircularProgressIndicator(
            color: ExerciseColors.loadingIndicator,
          ),
        ),
      ),
      error: (error, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ExerciseColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Failed to load completed workouts',
          style: TextStyle(color: ExerciseColors.errorDark),
        ),
      ),
    );
  }

  String _formatWorkoutDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: ExerciseColors.borderLight),
          borderRadius: BorderRadius.circular(16),
          color: ExerciseColors.cardBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: TextStyle(
                    color: ExerciseColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: ExerciseColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ExerciseColors.chipBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ExerciseColors.chipText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ExerciseColors.cardBackground,
        border: Border.all(color: ExerciseColors.borderLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: ExerciseColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: ExerciseColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

void _showExerciseGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exercise Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to your fitness journey! Here\'s how to get started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('🏋️ AI Workout Generator'),
              Text('• Generate personalized workout plans based on your goals'),
              Text('• Choose from different workout types and difficulty levels'),
              Text('• Get AI-powered recommendations for your fitness journey'),
              SizedBox(height: 8),
              Text('📊 Workout History'),
              Text('• Track your completed workouts and progress'),
              Text('• View detailed statistics and performance metrics'),
              Text('• Monitor your fitness journey over time'),
              SizedBox(height: 8),
              Text('💪 My Workouts'),
              Text('• Access your saved and favorite workout plans'),
              Text('• Create custom workout routines'),
              Text('• Manage your personal fitness library'),
              SizedBox(height: 8),
              Text('🎯 Tips for Success'),
              Text('• Start with beginner-friendly workouts'),
              Text('• Gradually increase intensity and duration'),
              Text('• Stay consistent with your exercise routine'),
              Text('• Listen to your body and rest when needed'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      );
    },
  );
}
