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
    final savedWorkoutsAsync = ref.watch(savedWorkoutPlansProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Workout Plans',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121714)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIWorkoutGeneratorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Color(0xFF121714)),
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
          data: (workouts) => workouts.isEmpty
              ? _buildEmptyState(context)
              : _buildWorkoutList(context, ref, workouts),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF94E0B2),
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(context, ref, error),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIWorkoutGeneratorScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF94E0B2),
        foregroundColor: const Color(0xFF121714),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF94E0B2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 80,
                color: Color(0xFF94E0B2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Workouts Yet',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Generate AI workouts and save your favorites here!\nYour saved plans will appear below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
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
                      builder: (context) => const AIWorkoutGeneratorScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF94E0B2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF121714),
                ),
                label: const Text(
                  'Generate Your First Workout',
                  style: TextStyle(
                    color: Color(0xFF121714),
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
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                        color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Pro Tip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF121714),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save generated workouts by tapping "Save Workout" after viewing the details. Saved plans can be started anytime!',
                    style: TextStyle(
                      color: Colors.grey,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    .read(savedWorkoutPlansProvider.notifier)
                    .loadSavedWorkouts();
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

  Widget _buildWorkoutList(
      BuildContext context, WidgetRef ref, List<SavedWorkoutPlan> workouts) {
    // Sort workouts: favorites first, then by last used, then by creation date
    final sortedWorkouts = List<SavedWorkoutPlan>.from(workouts);
    sortedWorkouts.sort((a, b) {
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
      children: [
        // Header with stats
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF94E0B2).withOpacity(0.8),
                const Color(0xFF94E0B2).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Workout Plans',
                      style: TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workouts.length} saved ${workouts.length == 1 ? 'plan' : 'plans'}',
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bookmark,
                  color: const Color(0xFF121714),
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
            itemBuilder: (context, index) {
              final workout = sortedWorkouts[index];
              return _buildWorkoutCard(context, ref, workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context, WidgetRef ref, List<SavedWorkoutPlan> workouts) {
    final favoriteCount = workouts.where((w) => w.isFavorite).length;
    final recentCount = workouts.where((w) => w.lastUsed != null).length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All (${workouts.length})', true),
          const SizedBox(width: 8),
          if (favoriteCount > 0)
            _buildFilterChip('Favorites ($favoriteCount)', false),
          const SizedBox(width: 8),
          if (recentCount > 0)
            _buildFilterChip('Recent ($recentCount)', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
          ? const Color(0xFF94E0B2) 
          : const Color(0xFF94E0B2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected 
            ? const Color(0xFF121714) 
            : const Color(0xFF121714).withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
      BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) {
    final totalExercises = workout.workoutPlan.workoutSessions
        .fold(0, (sum, session) => sum + session.exercises.length);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: workout.isFavorite 
          ? const BorderSide(color: Color(0xFF94E0B2), width: 1.5)
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
              builder: (context) => WorkoutDetailScreen(
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
            children: [
              Row(
                children: [
                  if (workout.isFavorite)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF94E0B2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      workout.name,
                      style: const TextStyle(
                        color: Color(0xFF121714),
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
                      color: workout.isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, workout);
                      } else if (value == 'duplicate') {
                        _duplicateWorkout(context, ref, workout);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Color(0xFF94E0B2)),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
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
              
              // Workout stats chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    Icons.calendar_today,
                    '${workout.workoutPlan.sessionsPerWeek}/week',
                    const Color(0xFF94E0B2),
                  ),
                  _buildStatChip(
                    Icons.fitness_center,
                    '$totalExercises exercises',
                    Colors.blue,
                  ),
                  _buildStatChip(
                    Icons.schedule,
                    '${workout.workoutPlan.workoutSessions.length} sessions',
                    Colors.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(workout.createdAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (workout.lastUsed != null)
                        Text(
                          'Last used: ${_formatDate(workout.lastUsed!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF94E0B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap to start',
                      style: TextStyle(
                        color: Color(0xFF94E0B2),
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

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

  void _duplicateWorkout(BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) async {
    try {
      final duplicatedName = "${workout.name} (Copy)";
      await ref
          .read(savedWorkoutPlansProvider.notifier)
          .saveWorkout(
            name: duplicatedName,
            workout: workout.workoutPlan,
          );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout duplicated as "$duplicatedName"'),
          backgroundColor: const Color(0xFF94E0B2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to duplicate workout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
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

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, SavedWorkoutPlan workout) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Workout Plan',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${workout.name}"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF121714)),
          ),
          actions: [
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
                      .read(savedWorkoutPlansProvider.notifier)
                      .deleteWorkout(workout.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Workout "${workout.name}" deleted successfully'),
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
}
