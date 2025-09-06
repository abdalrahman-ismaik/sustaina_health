import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import 'completed_workout_detail_screen.dart';

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
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
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
                        color: cs.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Workout History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onSurface,
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
                    context: context,
                    label: 'All',
                    selected: _selectedTab == 'All',
                    onTap: () => setState(() => _selectedTab = 'All'),
                  ),
                  _TabButton(
                    context: context,
                    label: 'This Week',
                    selected: _selectedTab == 'This Week',
                    onTap: () => setState(() => _selectedTab = 'This Week'),
                  ),
                  _TabButton(
                    context: context,
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
                    return _buildEmptyState(context);
                  }

                  // Filter workouts based on selected tab
                  final List<ActiveWorkoutSession> filteredWorkouts = _filterWorkouts(completedWorkouts);

                  if (filteredWorkouts.isEmpty) {
                    return _buildEmptyFilterState(context);
                  }

                  return _buildWorkoutsList(context, filteredWorkouts);
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: cs.primary,
                  ),
                ),
                error: (Object error, StackTrace stack) => _buildErrorState(context, error),
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

  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.fitness_center,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No completed workouts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start working out to see your progress here',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start Your First Workout',
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts in $_selectedTab',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different time period',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: cs.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
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
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, List<ActiveWorkoutSession> workouts) {
    return Column(
      children: <Widget>[
        // Stats Section
        _buildStatsSection(context, workouts),

        const SizedBox(height: 16),

        // Workouts List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: workouts.length,
            itemBuilder: (BuildContext context, int index) {
              final ActiveWorkoutSession workout = workouts[index];
              return _buildWorkoutCard(context, workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, List<ActiveWorkoutSession> workouts) {
    final ColorScheme cs = Theme.of(context).colorScheme;
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
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Statistics',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  context: context,
                  label: 'Total Workouts',
                  value: '${workouts.length}',
                ),
              ),
              Expanded(
                child: _StatItem(
                  context: context,
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
                  context: context,
                  label: 'Total Time',
                  value: _formatDuration(totalDuration),
                ),
              ),
              Expanded(
                child: _StatItem(
                  context: context,
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

  Widget _buildWorkoutCard(BuildContext context, ActiveWorkoutSession workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final int totalSets = workout.exercises.fold<int>(
      0,
      (int sum, CompletedExercise exercise) => sum + exercise.sets.length,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            color: cs.surfaceContainerLow,
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
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: cs.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(workout.endTime!),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        _InfoChip(
                          context: context,
                          icon: Icons.timer,
                          label: _formatDuration(workout.totalDuration),
                        ),
                        const SizedBox(width: 12),
                        _InfoChip(
                          context: context,
                          icon: Icons.fitness_center,
                          label: '${workout.exercises.length} exercises',
                        ),
                        const SizedBox(width: 12),
                        _InfoChip(
                          context: context,
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
          // Delete button positioned at top-right
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteWorkoutDialog(context, workout),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _showDeleteWorkoutDialog(BuildContext context, ActiveWorkoutSession workout) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Are you sure you want to delete this workout session?'),
                const SizedBox(height: 8),
                Text(
                  workout.workoutName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (workout.endTime != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Completed on ${workout.endTime!.day}/${workout.endTime!.month}/${workout.endTime!.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                // Delete the workout using the provider
                final CompletedWorkoutsNotifier notifier = ref.read(completedWorkoutsProvider.notifier);
                await notifier.deleteWorkout(workout.id);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final BuildContext context;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.context,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? cs.primary
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
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
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
  final BuildContext context;
  final String label;
  final String value;

  const _StatItem({
    required this.context,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.context,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
