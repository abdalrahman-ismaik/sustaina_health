import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import 'workout_detail_screen.dart';
import 'ai_workout_generator_screen.dart';

class SavedWorkoutPlansScreen extends ConsumerWidget {
  const SavedWorkoutPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SavedWorkoutPlan>> savedWorkoutsAsync = ref.watch(savedWorkoutPlansProvider);
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'My Workout Plans',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const AIWorkoutGeneratorScreen(),
                ),
              );
            },
            icon: Icon(Icons.add, color: cs.onSurface),
            tooltip: 'Generate New Workout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(savedWorkoutPlansProvider.notifier)
              .loadSavedWorkouts();
        },
        child: savedWorkoutsAsync.when(
          data: (List<SavedWorkoutPlan> workouts) => workouts.isEmpty
              ? _buildEmptyState(context)
              : _buildWorkoutList(context, ref, workouts),
          loading: () => Center(
            child: CircularProgressIndicator(
              color: cs.primary,
            ),
          ),
          error: (Object error, StackTrace stackTrace) => _buildErrorState(context, ref, error),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const AIWorkoutGeneratorScreen(),
            ),
          );
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        label: const Text(
          'Generate Workout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 80,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Workouts Yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Generate AI workouts and save your favorites here!\nYour saved plans will appear below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Primary action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const AIWorkoutGeneratorScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.auto_awesome,
                  color: cs.onPrimary,
                ),
                label: Text(
                  'Generate Your First Workout',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.info_outline,
                          color: cs.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pro Tip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save generated workouts by tapping "Save Workout" after viewing the details. Saved plans can be started anytime!',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    .read(savedWorkoutPlansProvider.notifier)
                    .loadSavedWorkouts();
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

  Widget _buildWorkoutList(
      BuildContext context, WidgetRef ref, List<SavedWorkoutPlan> workouts) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    // Sort workouts: favorites first, then by last used, then by creation date
    final List<SavedWorkoutPlan> sortedWorkouts = List<SavedWorkoutPlan>.from(workouts);
    sortedWorkouts.sort((SavedWorkoutPlan a, SavedWorkoutPlan b) {
      // First priority: favorites
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      // Second priority: last used (most recent first)
      if (a.lastUsed != null && b.lastUsed != null) {
        return b.lastUsed!.compareTo(a.lastUsed!);
      }
      if (a.lastUsed != null && b.lastUsed == null) return -1;
      if (a.lastUsed == null && b.lastUsed != null) return 1;

      // Third priority: creation date (most recent first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header with stats
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                cs.primary.withValues(alpha: 0.8),
                cs.primary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your Workout Plans',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workouts.length} saved ${workouts.length == 1 ? 'plan' : 'plans'}',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bookmark,
                  color: cs.onPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),

        // Filter tabs
        if (workouts.length > 3) _buildFilterTabs(context, ref, workouts),

        // Workout list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedWorkouts.length,
            itemBuilder: (BuildContext context, int index) {
              final SavedWorkoutPlan workout = sortedWorkouts[index];
              return _buildWorkoutCard(context, ref, workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(
      BuildContext context, WidgetRef ref, List<SavedWorkoutPlan> workouts) {
    final int favoriteCount = workouts.where((SavedWorkoutPlan w) => w.isFavorite).length;
    final int recentCount = workouts.where((SavedWorkoutPlan w) => w.lastUsed != null).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          _buildFilterChip(context, 'All (${workouts.length})', true),
          const SizedBox(width: 8),
          if (favoriteCount > 0)
            _buildFilterChip(context, 'Favorites ($favoriteCount)', false),
          const SizedBox(width: 8),
          if (recentCount > 0) _buildFilterChip(context, 'Recent ($recentCount)', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary
            : cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? cs.onPrimary
              : cs.onSurface.withValues(alpha: 0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
      BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final int totalExercises = workout.workoutPlan.workoutSessions
        .fold(0, (int sum, WorkoutSession session) => sum + session.exercises.length);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: workout.isFavorite
            ? BorderSide(color: cs.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // Update last used timestamp
          ref
              .read(savedWorkoutPlansProvider.notifier)
              .updateLastUsed(workout.id);

          // Navigate to workout detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => WorkoutDetailScreen(
                workout: workout.workoutPlan,
                savedWorkout: workout,
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
                  if (workout.isFavorite)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: cs.onPrimary,
                        size: 12,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      workout.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(savedWorkoutPlansProvider.notifier)
                          .toggleFavorite(workout.id, !workout.isFavorite);
                    },
                    icon: Icon(
                      workout.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: workout.isFavorite ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, workout);
                      } else if (value == 'duplicate') {
                        _duplicateWorkout(context, ref, workout);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.copy, color: cs.primary),
                            const SizedBox(width: 8),
                            const Text('Duplicate'),
                          ],
                        ),
                      ),
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

              // Workout stats chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _buildStatChip(
                    context,
                    Icons.calendar_today,
                    '${workout.workoutPlan.sessionsPerWeek}/week',
                    cs.primary,
                  ),
                  _buildStatChip(
                    context,
                    Icons.fitness_center,
                    '$totalExercises exercises',
                    cs.secondary,
                  ),
                  _buildStatChip(
                    context,
                    Icons.schedule,
                    '${workout.workoutPlan.workoutSessions.length} sessions',
                    cs.tertiary,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Created: ${_formatDate(workout.createdAt)}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      if (workout.lastUsed != null)
                        Text(
                          'Last used: ${_formatDate(workout.lastUsed!)}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap to start',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text, Color color) {
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

  void _duplicateWorkout(
      BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) async {
    final ColorScheme cs = Theme.of(context).colorScheme;
    try {
      final String duplicatedName = "${workout.name} (Copy)";
      await ref.read(savedWorkoutPlansProvider.notifier).saveWorkout(
            name: duplicatedName,
            workout: workout.workoutPlan,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout duplicated as "$duplicatedName"'),
          backgroundColor: cs.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to duplicate workout: $e'),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
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

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cs.surfaceContainerHigh,
          title: Text(
            'Delete Workout Plan',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${workout.name}"? This action cannot be undone.',
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
                      .read(savedWorkoutPlansProvider.notifier)
                      .deleteWorkout(workout.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Workout "${workout.name}" deleted successfully'),
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
}
