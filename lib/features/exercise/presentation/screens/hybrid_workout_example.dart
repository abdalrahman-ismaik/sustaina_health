import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/workout_repository_providers.dart';
import '../../data/services/workout_storage_migration_service.dart';
import '../../data/models/workout_models.dart';
import '../widgets/firestore_debug_panel.dart';

class HybridWorkoutExample extends ConsumerStatefulWidget {
  const HybridWorkoutExample({super.key});

  @override
  ConsumerState<HybridWorkoutExample> createState() => _HybridWorkoutExampleState();
}

class _HybridWorkoutExampleState extends ConsumerState<HybridWorkoutExample> {
  final WorkoutStorageMigrationService _migrationService = WorkoutStorageMigrationService();
  bool _isMigrating = false;
  String _migrationStatus = 'Not checked';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDemo();
  }

  Future<void> _initializeDemo() async {
    setState(() => _isLoading = true);
    
    try {
      await _checkMigrationStatus();
      // Add some delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error initializing demo: $e');
      setState(() => _migrationStatus = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkMigrationStatus() async {
    try {
      final MigrationStatus status = await _migrationService.getMigrationStatus();
      setState(() {
        _migrationStatus = status.toString();
      });
    } catch (e) {
      setState(() {
        _migrationStatus = 'Error checking status: $e';
      });
    }
  }

  Future<void> _performMigration() async {
    setState(() {
      _isMigrating = true;
    });

    try {
      final MigrationResult result = await _migrationService.performFullMigration();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );

      if (result.success) {
        _checkMigrationStatus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Migration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isMigrating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutPlansAsync = ref.watch(workoutPlansStreamProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final isSyncing = ref.watch(isSyncingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hybrid Workout Storage Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use GoRouter to navigate back
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/exercise'); // Fallback to exercise screen
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSyncing ? Icons.sync : Icons.refresh,
              color: isSyncing ? Colors.blue : null,
            ),
            onPressed: isSyncing ? null : () async {
              try {
                await ref.read(syncActionProvider)();
                await _checkMigrationStatus();
                // Refresh the providers
                ref.invalidate(workoutPlansStreamProvider);
                ref.invalidate(syncStatusProvider);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data refreshed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Refresh failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading demo...'),
              ],
            ),
          )
        : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firestore Debug Panel - First for easy access
            const FirestoreDebugPanel(),
            
            const SizedBox(height: 16),
            
            // Migration Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migration Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_migrationStatus),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isMigrating ? null : _performMigration,
                          child: _isMigrating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Migrate Data'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            await _checkMigrationStatus();
                            // Also refresh other providers
                            ref.invalidate(workoutPlansStreamProvider);
                            ref.invalidate(syncStatusProvider);
                          },
                          child: const Text('Refresh Status'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sync Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    syncStatus.when(
                      data: (status) {
                        if (status.isEmpty) {
                          return const Text('No sync data available');
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${status['total'] ?? 0}'),
                            Text('Synced: ${status['synced'] ?? 0}'),
                            Text('Pending: ${status['pending'] ?? 0}'),
                          ],
                        );
                      },
                      loading: () => const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading sync status...'),
                        ],
                      ),
                      error: (error, _) => Text(
                        'Error loading sync status: $error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    if (isSyncing) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                      const Text('Syncing...'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Workout Plans List
            Text(
              'Workout Plans',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: workoutPlansAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No workout plans found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create a sample workout',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(workout.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Created: ${workout.createdAt.toString().split('.')[0]}'),
                              Text('Last Updated: ${workout.lastUpdated.toString().split('.')[0]}'),
                              Row(
                                children: [
                                  Icon(
                                    workout.isSynced ? Icons.cloud_done : Icons.cloud_off,
                                    size: 16,
                                    color: workout.isSynced ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    workout.isSynced ? 'Synced' : 'Pending sync',
                                    style: TextStyle(
                                      color: workout.isSynced ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  workout.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: workout.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  ref.read(workoutActionsProvider).toggleFavorite(
                                        workout.id,
                                        !workout.isFavorite,
                                      );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmation(context, workout);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading workouts...'),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading workouts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(workoutPlansStreamProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _createSampleWorkout(),
        icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
        label: Text(_isLoading ? 'Loading...' : 'Add Sample Workout'),
        backgroundColor: _isLoading ? Colors.grey : null,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedWorkoutPlan workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "${workout.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(workoutActionsProvider).deleteWorkout(workout.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createSampleWorkout() async {
    try {
      final workoutPlan = WorkoutPlan(
        warmup: const WorkoutComponent(
          description: 'Light cardio and dynamic stretching',
          duration: 10,
        ),
        cardio: const WorkoutComponent(
          description: 'Moderate intensity cardio',
          duration: 15,
        ),
        sessionsPerWeek: 3,
        workoutSessions: [
          WorkoutSession(
            exercises: [
              const Exercise(name: 'Push-ups', sets: 3, reps: '10-15', rest: 60),
              const Exercise(name: 'Pull-ups', sets: 3, reps: '5-10', rest: 90),
              const Exercise(name: 'Squats', sets: 3, reps: '15-20', rest: 60),
            ],
          ),
        ],
        cooldown: const WorkoutComponent(
          description: 'Static stretching and relaxation',
          duration: 5,
        ),
      );

      final String workoutId = await ref.read(createWorkoutProvider)(
        'Sample Workout ${DateTime.now().millisecondsSinceEpoch}',
        workoutPlan,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sample workout created with ID: $workoutId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
