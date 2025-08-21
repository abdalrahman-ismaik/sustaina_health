import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';

class MyWorkoutsScreen extends ConsumerWidget {
  const MyWorkoutsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ActiveWorkoutSession>> completedWorkoutsAsync = ref.watch(completedWorkoutsProvider);
    final AsyncValue<Map<String, dynamic>> workoutStatsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Workouts',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121714)),
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
                data: (Map<String, dynamic> stats) => _buildStatsSection(stats),
                loading: () => _buildStatsLoading(),
                error: (Object error, _) => _buildStatsError(),
              ),
            ),

            // Workouts List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recent Workouts',
                  style: const TextStyle(
                    color: Color(0xFF121714),
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
                    child: CircularProgressIndicator(
                      color: Color(0xFF94E0B2),
                    ),
                  ),
                ),
              ),
              error: (Object error, StackTrace stackTrace) => SliverToBoxAdapter(
                child: _buildErrorState(context, ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xFF94E0B2).withOpacity(0.8),
            const Color(0xFF94E0B2).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Workout Statistics',
            style: TextStyle(
              color: Color(0xFF121714),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatItem(
                  'Total Workouts',
                  '${stats['totalWorkouts']}',
                  Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _buildStatItem(
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
                child: _buildStatItem(
                  'Total Time',
                  _formatDuration(stats['totalDuration'] as Duration),
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildStatItem(
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF121714), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF94E0B2)),
      ),
    );
  }

  Widget _buildStatsError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Failed to load statistics',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF94E0B2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 80,
                color: Color(0xFF94E0B2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Workouts Yet',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start your first workout to see your progress here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94E0B2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start First Workout',
                style: TextStyle(
                  color: Color(0xFF121714),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Workouts',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
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
                backgroundColor: const Color(0xFF94E0B2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFF121714),
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
                      style: const TextStyle(
                        color: Color(0xFF121714),
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
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
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
                    const Color(0xFF94E0B2),
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutStatChip(
                    Icons.fitness_center,
                    '${workout.exercises.length} exercises',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutStatChip(
                    Icons.repeat,
                    '${_getTotalSets(workout)} sets',
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _formatDate(workout.startTime),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  if (workout.notes != null)
                    Icon(
                      Icons.note,
                      color: Colors.grey.shade600,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
        builder: (BuildContext context, ScrollController scrollController) => Padding(
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Text(
                workout.workoutName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatDate(workout.startTime)} • ${_formatDuration(workout.totalDuration)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              if (workout.notes != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121714),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.notes!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
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
                        children: exercise.sets.asMap().entries.map((MapEntry<int, ExerciseSet> entry) {
                          final int setIndex = entry.key;
                          final ExerciseSet set = entry.value;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF94E0B2),
                              child: Text(
                                '${setIndex + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF121714),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Workout',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${workout.workoutName}"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF121714)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
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
                      backgroundColor: const Color(0xFF94E0B2),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete workout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
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
    return workout.exercises
        .fold(0, (int total, CompletedExercise exercise) => total + exercise.sets.length);
  }
}
