import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import 'package:ghiraas/widgets/interactive_loading.dart';
import '../../data/models/workout_models.dart';

class MyWorkoutsScreen extends ConsumerWidget {
  const MyWorkoutsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync =
        ref.watch(completedWorkoutsProvider);
    final AsyncValue<Map<String, dynamic>> workoutStatsAsync =
        ref.watch(workoutStatsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'My Workouts',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(completedWorkoutsProvider.notifier)
              .loadCompletedWorkouts();
          ref.invalidate(workoutStatsProvider);
        },
        child: CustomScrollView(
          slivers: <Widget>[
            // Stats Section
            SliverToBoxAdapter(
              child: workoutStatsAsync.when(
                data: (Map<String, dynamic> stats) => _buildStatsSection(context, stats),
                loading: () => _buildStatsLoading(context),
                error: (Object error, _) => _buildStatsError(context),
              ),
            ),

            // Workouts List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recent Workouts',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            completedWorkoutsAsync.when(
              data: (List<ActiveWorkoutSession> workouts) => workouts.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState(context))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) =>
                            _buildWorkoutCard(context, ref, workouts[index]),
                        childCount: workouts.length,
                      ),
                    ),
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: InteractiveLoading(
                      title: 'Loading your workouts',
                      subtitle: 'Fetching recent sessions…',
                      compact: true,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
              error: (Object error, StackTrace stackTrace) =>
                  SliverToBoxAdapter(
                child: _buildErrorState(context, ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, dynamic> stats) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            cs.primary.withValues(alpha: 0.2),
            cs.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Workout Statistics',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatItem(context,
                  'Total Workouts',
                  '${stats['totalWorkouts']}',
                  Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _buildStatItem(context,
                  'This Week',
                  '${stats['thisWeekWorkouts']}',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatItem(context,
                  'Total Time',
                  _formatDuration(stats['totalDuration'] as Duration),
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildStatItem(context,
                  'Avg Duration',
                  _formatDuration(stats['averageDuration'] as Duration),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: cs.onSurface, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(color: cs.primary),
      ),
    );
  }

  Widget _buildStatsError(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Failed to load statistics',
          style: TextStyle(color: cs.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workouts Yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first workout to see your progress here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start First Workout',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 80,
              color: cs.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Workouts',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(completedWorkoutsProvider.notifier)
                    .loadCompletedWorkouts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
      BuildContext context, WidgetRef ref, ActiveWorkoutSession workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetails(context, workout),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, workout);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: cs.error),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  _buildWorkoutStatChip(
                    Icons.timer,
                    _formatDuration(workout.totalDuration),
                    cs.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutStatChip(
                    Icons.fitness_center,
                    '${workout.exercises.length} exercises',
                    cs.secondary,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutStatChip(
                    Icons.repeat,
                    '${_getTotalSets(workout)} sets',
                    cs.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _formatDate(workout.startTime),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  if (workout.notes != null)
                    Icon(
                      Icons.note,
                      color: cs.onSurfaceVariant,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, ActiveWorkoutSession workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) =>
            Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Text(
                workout.workoutName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatDate(workout.startTime)} • ${_formatDuration(workout.totalDuration)}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),

              if (workout.notes != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.notes!,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Exercises list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: workout.exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CompletedExercise exercise = workout.exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('${exercise.sets.length} sets'),
                        children: exercise.sets
                            .asMap()
                            .entries
                            .map((MapEntry<int, ExerciseSet> entry) {
                          final int setIndex = entry.key;
                          final ExerciseSet set = entry.value;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: cs.primary,
                              child: Text(
                                '${setIndex + 1}',
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Row(
                              children: <Widget>[
                                Text('${set.reps} reps'),
                                if (set.weight != null) ...<Widget>[
                                  const SizedBox(width: 16),
                                  Text('${set.weight}kg'),
                                ],
                                if (set.duration != null) ...<Widget>[
                                  const SizedBox(width: 16),
                                  Text('${set.duration}s'),
                                ],
                              ],
                            ),
                            subtitle:
                                set.notes != null ? Text(set.notes!) : null,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ActiveWorkoutSession workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Workout',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${workout.workoutName}"? This action cannot be undone.',
            style: TextStyle(color: cs.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(completedWorkoutsProvider.notifier)
                      .deleteWorkout(workout.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Workout "${workout.workoutName}" deleted successfully'),
                      backgroundColor: cs.primary,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete workout: $e'),
                      backgroundColor: cs.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: cs.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int _getTotalSets(ActiveWorkoutSession workout) {
    return workout.exercises.fold(
        0,
        (int total, CompletedExercise exercise) =>
            total + exercise.sets.length);
  }
}
