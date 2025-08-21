import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import 'completed_workout_detail_screen.dart';
import '../../../../app/theme/exercise_colors.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    // Load completed workouts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(completedWorkoutsProvider.notifier).loadCompletedWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync = ref.watch(completedWorkoutsProvider);

    return Scaffold(
      backgroundColor: ExerciseColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: ExerciseColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Workout History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ExerciseColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  _TabButton(
                    label: 'All',
                    selected: _selectedTab == 'All',
                    onTap: () => setState(() => _selectedTab = 'All'),
                  ),
                  _TabButton(
                    label: 'This Week',
                    selected: _selectedTab == 'This Week',
                    onTap: () => setState(() => _selectedTab = 'This Week'),
                  ),
                  _TabButton(
                    label: 'This Month',
                    selected: _selectedTab == 'This Month',
                    onTap: () => setState(() => _selectedTab = 'This Month'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: completedWorkoutsAsync.when(
                data: (List<ActiveWorkoutSession> completedWorkouts) {
                  if (completedWorkouts.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Filter workouts based on selected tab
                  final List<ActiveWorkoutSession> filteredWorkouts = _filterWorkouts(completedWorkouts);

                  if (filteredWorkouts.isEmpty) {
                    return _buildEmptyFilterState();
                  }

                  return _buildWorkoutsList(filteredWorkouts);
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: ExerciseColors.loadingIndicator,
                  ),
                ),
                error: (Object error, StackTrace stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ActiveWorkoutSession> _filterWorkouts(
      List<ActiveWorkoutSession> workouts) {
    final DateTime now = DateTime.now();

    switch (_selectedTab) {
      case 'This Week':
        // Calculate start of current week (Monday 00:00:00)
        final DateTime weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));

        print('DEBUG: Filtering for This Week');
        print('DEBUG: Current date: $now');
        print('DEBUG: Week start: $weekStart');
        print('DEBUG: Total workouts to filter: ${workouts.length}');

        final List<ActiveWorkoutSession> filteredWorkouts = workouts
            .where((ActiveWorkoutSession w) =>
                w.isCompleted &&
                w.endTime != null &&
                w.endTime!.isAfter(weekStart.subtract(Duration(seconds: 1))))
            .toList()
          ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) => b.endTime!.compareTo(a.endTime!));

        print(
            'DEBUG: Workouts after This Week filter: ${filteredWorkouts.length}');
        for (final ActiveWorkoutSession workout in filteredWorkouts) {
          print(
              'DEBUG: Workout: ${workout.workoutName} completed at ${workout.endTime}');
        }

        return filteredWorkouts;

      case 'This Month':
        final DateTime monthStart = DateTime(now.year, now.month, 1);

        print('DEBUG: Filtering for This Month');
        print('DEBUG: Month start: $monthStart');

        final List<ActiveWorkoutSession> filteredWorkouts = workouts
            .where((ActiveWorkoutSession w) =>
                w.isCompleted &&
                w.endTime != null &&
                w.endTime!.isAfter(monthStart.subtract(Duration(seconds: 1))))
            .toList()
          ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) => b.endTime!.compareTo(a.endTime!));

        print(
            'DEBUG: Workouts after This Month filter: ${filteredWorkouts.length}');

        return filteredWorkouts;

      default: // All
        print('DEBUG: Showing all workouts');
        final List<ActiveWorkoutSession> filteredWorkouts = workouts
            .where((ActiveWorkoutSession w) => w.isCompleted && w.endTime != null)
            .toList()
          ..sort((ActiveWorkoutSession a, ActiveWorkoutSession b) => b.endTime!.compareTo(a.endTime!));

        print('DEBUG: Total completed workouts: ${filteredWorkouts.length}');

        return filteredWorkouts;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.fitness_center,
            size: 64,
            color: ExerciseColors.emptyState['icon'],
          ),
          const SizedBox(height: 16),
          Text(
            'No completed workouts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ExerciseColors.emptyState['title'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start working out to see your progress here',
            style: TextStyle(
              fontSize: 14,
              color: ExerciseColors.emptyState['subtitle'],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ExerciseColors.emptyState['button'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start Your First Workout',
              style: TextStyle(
                color: ExerciseColors.emptyState['buttonText'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: ExerciseColors.emptyState['icon'],
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts in $_selectedTab',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ExerciseColors.emptyState['title'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different time period',
            style: TextStyle(
              fontSize: 14,
              color: ExerciseColors.emptyState['subtitle'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: ExerciseColors.errorDark,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ExerciseColors.errorDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: ExerciseColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(completedWorkoutsProvider.notifier)
                  .loadCompletedWorkouts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ExerciseColors.buttonPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: ExerciseColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(List<ActiveWorkoutSession> workouts) {
    return Column(
      children: <Widget>[
        // Stats Section
        _buildStatsSection(workouts),

        const SizedBox(height: 16),

        // Workouts List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workouts.length,
            itemBuilder: (BuildContext context, int index) {
              final ActiveWorkoutSession workout = workouts[index];
              return _buildWorkoutCard(workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(List<ActiveWorkoutSession> workouts) {
    final Duration totalDuration = workouts.fold<Duration>(
      Duration.zero,
      (Duration sum, ActiveWorkoutSession workout) => sum + workout.totalDuration,
    );

    final int totalSets = workouts.fold<int>(
      0,
      (int sum, ActiveWorkoutSession workout) =>
          sum +
          workout.exercises.fold<int>(
            0,
            (int exerciseSum, CompletedExercise exercise) => exerciseSum + exercise.sets.length,
          ),
    );

    final Duration avgDuration = workouts.isNotEmpty
        ? Duration(
            milliseconds: totalDuration.inMilliseconds ~/ workouts.length)
        : Duration.zero;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ExerciseColors.statsCard['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ExerciseColors.statsCard['border']!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Statistics',
            style: TextStyle(
              color: ExerciseColors.statsCard['text'],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  label: 'Total Workouts',
                  value: '${workouts.length}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Total Sets',
                  value: '$totalSets',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  label: 'Total Time',
                  value: _formatDuration(totalDuration),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Avg Duration',
                  value: _formatDuration(avgDuration),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(ActiveWorkoutSession workout) {
    final int totalSets = workout.exercises.fold<int>(
      0,
      (int sum, CompletedExercise exercise) => sum + exercise.sets.length,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: ExerciseColors.workoutCard['background'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => CompletedWorkoutDetailScreen(
                  completedWorkout: workout,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        workout.workoutName,
                        style: TextStyle(
                          color: ExerciseColors.workoutCard['text'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: ExerciseColors.buttonSuccess,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(workout.endTime!),
                  style: TextStyle(
                    color: ExerciseColors.workoutCard['subtitle'],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _InfoChip(
                      icon: Icons.timer,
                      label: _formatDuration(workout.totalDuration),
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: '${workout.exercises.length} exercises',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.repeat,
                      label: '$totalSets sets',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? ExerciseColors.borderPrimary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? ExerciseColors.textPrimary
                  : ExerciseColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: ExerciseColors.statsCard['value'],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: ExerciseColors.statsCard['label'],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ExerciseColors.workoutCard['chip'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: ExerciseColors.workoutCard['chipText'],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: ExerciseColors.workoutCard['chipText'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
