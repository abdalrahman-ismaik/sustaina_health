import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'workout_history_screen.dart';
import 'ai_workout_generator_screen.dart';
import 'saved_workout_plans_screen.dart';
import 'my_workouts_screen.dart';
import 'completed_workout_detail_screen.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import '../../../../core/widgets/app_background.dart';

class ExerciseHomeScreen extends ConsumerWidget {
  const ExerciseHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync =
        ref.watch(completedWorkoutsProvider);

    return AppBackground(
      type: BackgroundType.exercise,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.fitness_center, color: cs.primary, size: 28),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Your Fitness Journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.help_outline, color: cs.primary),
                        onPressed: () => _showExerciseGuide(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress Overview
              completedWorkoutsAsync.when(
                loading: () => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        cs.primaryContainer,
                        cs.primaryContainer.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: cs.onPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Weekly Progress',
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CircularProgressIndicator(
                        color: cs.primary,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                ),
                error: (Object error, StackTrace stack) => _buildWeeklyProgressCard(cs, 0, 0, 0),
                data: (List<ActiveWorkoutSession> completedWorkouts) {
                  final Map<String, int> weeklyProgress = _calculateWeeklyProgress(completedWorkouts);
                  final int completedThisWeek = weeklyProgress['completed'] ?? 0;
                  final int targetWorkouts = weeklyProgress['target'] ?? 4; // Default target of 4 workouts per week
                  final double progressPercentage = targetWorkouts > 0 
                      ? (completedThisWeek / targetWorkouts).clamp(0.0, 1.0)
                      : 0.0;
                  
                  return _buildWeeklyProgressCard(cs, completedThisWeek, targetWorkouts, progressPercentage);
                },
              ),
              // Dynamic Stats from completed workouts
              completedWorkoutsAsync.when(
                loading: () => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(flex: 3, child: _LoadingStatCard()),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: _LoadingStatCard()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(flex: 2, child: _LoadingStatCard()),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: _LoadingStatCard()),
                        ],
                      ),
                    ],
                  ),
                ),
                error: (Object error, StackTrace stack) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MyWorkoutsScreen()),
                                );
                              },
                              child: _StatCard(
                                  title: 'Current Streak', 
                                  value: '0 days',
                                  color: cs.primary,
                                  neonIntensity: 0.15),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const WorkoutHistoryScreen()),
                                );
                              },
                              child: _StatCard(
                                  title: 'Calories', 
                                  value: '0',
                                  color: Colors.deepOrange,
                                  neonIntensity: 0.1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: _StatCard(
                                title: 'Total', 
                                value: '0',
                                color: Colors.teal,
                                neonIntensity: 0.1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _StatCard(
                                title: 'Avg Duration', 
                                value: '0 min',
                                color: Colors.purple,
                                neonIntensity: 0.1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                data: (List<ActiveWorkoutSession> completedWorkouts) => Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3, // Slightly wider for longer text
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const MyWorkoutsScreen()),
                                );
                              },
                              child: _StatCard(
                                  title: 'Current Streak',
                                  value: _calculateCurrentStreak(completedWorkouts),
                                  color: cs.primary,
                                  neonIntensity: 0.15),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2, // Narrower
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const WorkoutHistoryScreen()),
                                );
                              },
                              child: _StatCard(
                                  title: 'Calories',
                                  value: '${_calculateCaloriesToday(completedWorkouts)}',
                                  color: Colors.deepOrange,
                                  neonIntensity: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2, // Narrower
                            child: _StatCard(
                                title: 'Total',
                                value: '${_calculateTotalWorkouts(completedWorkouts)}',
                                color: Colors.teal,
                                neonIntensity: 0.1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3, // Wider for duration text
                            child: _StatCard(
                                title: 'Avg Duration',
                                value: _calculateAverageWorkoutDuration(completedWorkouts),
                                color: Colors.purple,
                                neonIntensity: 0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Start
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flash_on,
                        color: cs.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Start',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: <Widget>[
                    // AI Workout Button - Left box
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.primary,
                              cs.primary.withValues(alpha: 0.8),
                              cs.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const AIWorkoutGeneratorScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: cs.onPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'AI Workout',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              Text(
                                'Generate',
                                style: TextStyle(
                                  color: cs.onPrimary.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // My Plans Button - Right box
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.surfaceContainerHigh,
                              cs.surfaceContainer,
                            ],
                          ),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const SavedWorkoutPlansScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.library_books,
                                  color: cs.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'My Plans',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              Text(
                                'Saved workouts',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Saved Workout Plans Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 5, 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        color: cs.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Saved Plans',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSavedWorkoutPlansSection(context, ref),
              // Recent Completed Workouts Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history,
                        color: cs.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Workouts',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRecentCompletedWorkoutsSection(context, ref),
              // Eco Tips for Exercise - Moved to end
              _buildEcoTipsWidget(cs),
              const SizedBox(height: 80), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEcoTipsWidget(ColorScheme cs) {
    final List<Map<String, dynamic>> ecoTips = [
      {
        'tip': 'Choose outdoor workouts to reduce gym energy consumption',
        'icon': Icons.park_outlined,
        'color': Colors.green,
      },
      {
        'tip': 'Walk or bike to your workout location',
        'icon': Icons.directions_bike,
        'color': Colors.blue,
      },
      {
        'tip': 'Use bodyweight exercises - no equipment needed!',
        'icon': Icons.self_improvement,
        'color': Colors.orange,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.eco,
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Eco-Friendly Exercise Tips',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ecoTips.map((tip) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tip['color'].withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  tip['icon'],
                  color: tip['color'],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip['tip'],
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSavedWorkoutPlansSection(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<List<SavedWorkoutPlan>> savedWorkoutsAsync =
        ref.watch(savedWorkoutPlansProvider);

    return savedWorkoutsAsync.when(
      data: (List<SavedWorkoutPlan> workouts) {
        if (workouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.bookmark_border,
                  color: cs.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'No saved workout plans yet',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate and save your first workout plan',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
                        builder: (BuildContext context) =>
                            const AIWorkoutGeneratorScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Generate',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show recent saved workouts (max 3)
        final List<SavedWorkoutPlan> recentWorkouts = workouts.take(3).toList();

        return Column(
          children: <Widget>[
            Container(
              // increased height for taller cards
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recentWorkouts.length + 1, // +1 for "View All" card
                itemBuilder: (BuildContext context, int index) {
                  if (index == recentWorkouts.length) {
                    // "View All" card
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(left: 8, right: 8),
                      child: Card(
                        elevation: 4,
                        shadowColor: cs.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                cs.primaryContainer,
                                cs.primaryContainer.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SavedWorkoutPlansScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: cs.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: cs.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '(${workouts.length})',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final SavedWorkoutPlan workout = recentWorkouts[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    child: Card(
                      elevation: 4,
                      shadowColor: cs.secondary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.surfaceContainerHigh,
                              cs.surfaceContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.secondary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const SavedWorkoutPlansScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    if (workout.isFavorite)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 14,
                                        ),
                                      ),
                                    if (workout.isFavorite)
                                      const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        workout.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: cs.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${workout.workoutPlan.sessionsPerWeek}/week',
                                    style: TextStyle(
                                      color: cs.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${workout.workoutPlan.workoutSessions.length} exercises',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        cs.primary,
                                        cs.primary.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Start Workout',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cs.onPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Center(
          child: CircularProgressIndicator(
            color: cs.primary,
          ),
        ),
      ),
      error: (Object error, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Failed to load saved workouts',
          style: TextStyle(color: cs.error),
        ),
      ),
    );
  }

  Widget _buildRecentCompletedWorkoutsSection(
      BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync =
        ref.watch(completedWorkoutsProvider);

    return completedWorkoutsAsync.when(
      data: (List<ActiveWorkoutSession> completedWorkouts) {
        if (completedWorkouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.fitness_center,
                  color: cs.secondary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'No completed workouts yet',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start a workout and complete it to see your progress',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
                        builder: (BuildContext context) =>
                            const SavedWorkoutPlansScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Start',
                    style: TextStyle(
                      color: cs.secondary,
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
        final List<ActiveWorkoutSession> recentCompletedWorkouts =
            completedWorkouts
                .where((ActiveWorkoutSession w) =>
                    w.isCompleted && w.endTime != null)
                .toList()
              ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) =>
                  b.endTime!.compareTo(a.endTime!));

        final List<ActiveWorkoutSession> displayWorkouts =
            recentCompletedWorkouts.take(3).toList();

        if (displayWorkouts.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.pending_actions,
                  color: cs.tertiary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Workouts in progress',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have ${completedWorkouts.length} workout${completedWorkouts.length == 1 ? '' : 's'} started but not completed',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
          children: <Widget>[
            Container(
              // increased height for taller cards
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: displayWorkouts.length + 1, // +1 for "View All" card
                itemBuilder: (BuildContext context, int index) {
                  if (index == displayWorkouts.length) {
                    // "View All" card
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(left: 4, right: 4),
                      child: Card(
                        elevation: 4,
                        shadowColor: cs.tertiary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                cs.tertiaryContainer,
                                cs.tertiaryContainer.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.tertiary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const WorkoutHistoryScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cs.tertiary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: cs.tertiary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.history,
                                      color: cs.onTertiary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: cs.onTertiaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '(${completedWorkouts.where((ActiveWorkoutSession w) => w.isCompleted).length})',
                                    style: TextStyle(
                                      color: cs.onTertiaryContainer.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final ActiveWorkoutSession workout = displayWorkouts[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(left: 4, right: 4),
                    child: Card(
                      elevation: 4,
                      shadowColor: cs.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              cs.surfaceContainerHigh,
                              cs.surfaceContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CompletedWorkoutDetailScreen(
                                  completedWorkout: workout,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  workout.workoutName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.tertiary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatWorkoutDate(workout.startTime),
                                    style: TextStyle(
                                      color: cs.tertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      color: cs.onSurfaceVariant,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(workout.totalDuration),
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.fitness_center,
                                      color: cs.onSurfaceVariant,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${workout.exercises.length} exercises',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Colors.green,
                                        Colors.green.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.green.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Center(
          child: CircularProgressIndicator(
            color: cs.primary,
          ),
        ),
      ),
      error: (Object error, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Failed to load completed workouts',
          style: TextStyle(color: cs.error),
        ),
      ),
    );
  }

  String _formatWorkoutDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

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
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;

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
  final Color color;
  final double neonIntensity;
  
  const _StatCard({
    required this.title, 
    required this.value,
    required this.color,
    this.neonIntensity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cs.surfaceContainerHigh,
            cs.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.6 : 0.3),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          // Regular shadow
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          // Neon glow effect
          if (isDark) BoxShadow(
            color: color.withValues(alpha: neonIntensity * 0.4),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: 2,
          ),
          if (isDark) BoxShadow(
            color: color.withValues(alpha: neonIntensity * 0.2),
            blurRadius: 30,
            offset: const Offset(0, 0),
            spreadRadius: 4,
          ),
          // Light mode subtle glow
          if (!isDark) BoxShadow(
            color: color.withValues(alpha: neonIntensity * 0.15),
            blurRadius: 15,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              shadows: isDark ? <Shadow>[
                Shadow(
                  color: color.withValues(alpha: neonIntensity * 0.8),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ] : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Helper methods to calculate dynamic stats from completed workouts
String _calculateCurrentStreak(List<ActiveWorkoutSession> completedWorkouts) {
  if (completedWorkouts.isEmpty) return '0 days';

  // Sort workouts by date (most recent first)
  final List<ActiveWorkoutSession> sortedWorkouts = completedWorkouts
      .where((ActiveWorkoutSession w) => w.isCompleted && w.endTime != null)
      .toList()
    ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) =>
        b.endTime!.compareTo(a.endTime!));

  if (sortedWorkouts.isEmpty) return '0 days';

  int streak = 0;
  DateTime currentDate = DateTime.now();

  for (final ActiveWorkoutSession workout in sortedWorkouts) {
    final DateTime workoutDate = workout.endTime!;
    final int daysDifference = currentDate.difference(workoutDate).inDays;

    if (daysDifference <= 1) {
      // Workout was today or yesterday
      streak++;
      currentDate = workoutDate;
    } else {
      // Gap in workouts, streak is broken
      break;
    }
  }

  return '$streak day${streak != 1 ? 's' : ''}';
}

int _calculateCaloriesToday(List<ActiveWorkoutSession> completedWorkouts) {
  final DateTime today = DateTime.now();
  final Iterable<ActiveWorkoutSession> todayWorkouts = completedWorkouts.where(
      (ActiveWorkoutSession w) =>
          w.isCompleted &&
          w.endTime != null &&
          w.endTime!.day == today.day &&
          w.endTime!.month == today.month &&
          w.endTime!.year == today.year);

  // Estimate calories based on workout duration
  // Rough estimate: 4-10 calories per minute of workout
  int totalCalories = 0;
  for (final ActiveWorkoutSession workout in todayWorkouts) {
    final int durationMinutes = workout.totalDuration.inMinutes;
    totalCalories +=
        (durationMinutes * 6).round(); // 6 calories per minute average
  }

  return totalCalories;
}

String _calculateAverageWorkoutDuration(
    List<ActiveWorkoutSession> completedWorkouts) {
  final List<ActiveWorkoutSession> recentWorkouts = completedWorkouts
      .where((ActiveWorkoutSession w) =>
          w.isCompleted && w.totalDuration.inMinutes > 0)
      .take(10) // Last 10 workouts
      .toList();

  if (recentWorkouts.isEmpty) return '0 min';

  final int totalMinutes = recentWorkouts
      .map((ActiveWorkoutSession w) => w.totalDuration.inMinutes)
      .reduce((int a, int b) => a + b);

  final int averageMinutes = totalMinutes ~/ recentWorkouts.length;
  return '$averageMinutes min';
}

int _calculateTotalWorkouts(List<ActiveWorkoutSession> completedWorkouts) {
  return completedWorkouts
      .where((ActiveWorkoutSession w) => w.isCompleted)
      .length;
}

class _LoadingStatCard extends StatelessWidget {
  const _LoadingStatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: 40,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, int> _calculateWeeklyProgress(List<ActiveWorkoutSession> completedWorkouts) {
  final DateTime now = DateTime.now();
  final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
  
  final int completedThisWeek = completedWorkouts.where((ActiveWorkoutSession session) {
    return session.startTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           session.startTime.isBefore(endOfWeek.add(const Duration(days: 1))) &&
           session.isCompleted;
  }).length;
  
  return <String, int>{
    'completed': completedThisWeek,
    'target': 4, // Default weekly target
  };
}

Widget _buildWeeklyProgressCard(ColorScheme cs, int completed, int target, double percentage) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          cs.surfaceContainerHigh,
          cs.surfaceContainer,
          cs.surfaceContainerLow,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: cs.primary.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: cs.shadow.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.trending_up,
                color: cs.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Your fitness journey this week',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[cs.primary, cs.primary.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$completed of $target workouts completed',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(percentage * 100).round()}%',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
            children: <Widget>[
              Text(
                'Welcome to your fitness journey! Here\'s how to get started:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('🏋️ AI Workout Generator'),
              Text('• Generate personalized workout plans based on your goals'),
              Text(
                  '• Choose from different workout types and difficulty levels'),
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
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      );
    },
  );
}


