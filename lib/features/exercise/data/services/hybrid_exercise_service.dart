import '../models/workout_models.dart';
import 'workout_session_service.dart';
import 'firestore_exercise_service.dart';

/// Hybrid service that combines local storage with cloud storage for workout data
/// Provides automatic fallback and synchronization between local and cloud storage
class HybridExerciseService {
  final WorkoutSessionService _localService = WorkoutSessionService();
  final FirestoreExerciseService _cloudService = FirestoreExerciseService();

  /// Save completed workout to both local and cloud storage
  Future<void> saveCompletedWorkout(ActiveWorkoutSession session) async {
    try {
      // Save to local storage first (faster, more reliable)
      await _localService.saveCompletedWorkout(session);
      print('Workout saved locally: ${session.workoutName}');

      // Try to save to cloud storage
      try {
        final String cloudId = await _cloudService.saveCompletedWorkout(session);
        print('Workout saved to cloud with ID: $cloudId');
      } catch (e) {
        print('Failed to save workout to cloud (local copy preserved): $e');
        // Don't throw error - local save was successful
      }
    } catch (e) {
      print('Error saving workout: $e');
      throw Exception('Failed to save workout: $e');
    }
  }

  /// Get completed workouts with cloud sync
  Future<List<ActiveWorkoutSession>> getCompletedWorkouts() async {
    try {
      // First, try to get from cloud storage
      List<ActiveWorkoutSession> cloudWorkouts = <ActiveWorkoutSession>[];
      try {
        cloudWorkouts = await _cloudService.getCompletedWorkouts();
        print('Loaded ${cloudWorkouts.length} workouts from cloud');
      } catch (e) {
        print('Failed to load from cloud, using local storage: $e');
      }

      // Get local workouts as fallback
      final List<ActiveWorkoutSession> localWorkouts = await _localService.getCompletedWorkouts();
      print('Loaded ${localWorkouts.length} workouts from local storage');

      // If we have cloud data, use it and sync local storage
      if (cloudWorkouts.isNotEmpty) {
        await _syncLocalFromCloud(cloudWorkouts);
        return cloudWorkouts;
      }

      // If no cloud data but we have local data, try to sync to cloud
      if (localWorkouts.isNotEmpty) {
        try {
          await _cloudService.syncCompletedWorkoutsFromLocal(localWorkouts);
          print('Synced local workouts to cloud');
        } catch (e) {
          print('Failed to sync local workouts to cloud: $e');
        }
      }

      return localWorkouts;
    } catch (e) {
      print('Error loading workouts: $e');
      // Return empty list instead of throwing to prevent app crashes
      return <ActiveWorkoutSession>[];
    }
  }

  /// Delete workout from both local and cloud storage
  Future<void> deleteCompletedWorkout(String workoutId) async {
    bool localDeleted = false;
    bool cloudDeleted = false;

    try {
      // Try to delete from local storage
      await _localService.deleteCompletedWorkout(workoutId);
      localDeleted = true;
      print('Workout deleted from local storage: $workoutId');
    } catch (e) {
      print('Failed to delete workout from local storage: $e');
    }

    try {
      // Try to delete from cloud storage
      await _cloudService.deleteCompletedWorkout(workoutId);
      cloudDeleted = true;
      print('Workout deleted from cloud: $workoutId');
    } catch (e) {
      print('Failed to delete workout from cloud: $e');
    }

    // If neither deletion succeeded, throw an error
    if (!localDeleted && !cloudDeleted) {
      throw Exception('Failed to delete workout from both local and cloud storage');
    }

    // If only one succeeded, log it but don't throw error
    if (!localDeleted) {
      print('Warning: Workout deleted from cloud but not from local storage');
    }
    if (!cloudDeleted) {
      print('Warning: Workout deleted from local but not from cloud storage');
    }
  }

  /// Save active workout to both local and cloud storage
  Future<void> saveActiveWorkout(ActiveWorkoutSession session) async {
    try {
      // Save to local storage first
      await _localService.saveActiveWorkout(session);
      print('Active workout saved locally: ${session.workoutName}');

      // Try to save to cloud storage
      try {
        await _cloudService.saveActiveWorkout(session);
        print('Active workout saved to cloud: ${session.id}');
      } catch (e) {
        print('Failed to save active workout to cloud (local copy preserved): $e');
      }
    } catch (e) {
      print('Error saving active workout: $e');
      throw Exception('Failed to save active workout: $e');
    }
  }

  /// Get active workout with cloud sync
  Future<ActiveWorkoutSession?> getActiveWorkout() async {
    try {
      // Try cloud first
      try {
        final ActiveWorkoutSession? cloudWorkout = await _cloudService.getActiveWorkout();
        if (cloudWorkout != null) {
          print('Loaded active workout from cloud: ${cloudWorkout.id}');
          // Sync to local storage
          try {
            await _localService.saveActiveWorkout(cloudWorkout);
          } catch (e) {
            print('Failed to sync active workout to local: $e');
          }
          return cloudWorkout;
        }
      } catch (e) {
        print('Failed to load active workout from cloud: $e');
      }

      // Fallback to local storage
      final ActiveWorkoutSession? localWorkout = await _localService.getActiveWorkout();
      if (localWorkout != null) {
        print('Loaded active workout from local storage: ${localWorkout.id}');
        // Try to sync to cloud
        try {
          await _cloudService.saveActiveWorkout(localWorkout);
        } catch (e) {
          print('Failed to sync active workout to cloud: $e');
        }
      }
      
      return localWorkout;
    } catch (e) {
      print('Error loading active workout: $e');
      return null;
    }
  }

  /// Clear active workout from both storages
  Future<void> clearActiveWorkout() async {
    // Get the current active workout to get its ID for cloud deletion
    final ActiveWorkoutSession? activeWorkout = await _localService.getActiveWorkout();
    
    try {
      await _localService.clearActiveWorkout();
      print('Active workout cleared from local storage');
    } catch (e) {
      print('Failed to clear active workout from local storage: $e');
    }

    if (activeWorkout != null) {
      try {
        await _cloudService.clearActiveWorkout(activeWorkout.id);
        print('Active workout cleared from cloud: ${activeWorkout.id}');
      } catch (e) {
        print('Failed to clear active workout from cloud: $e');
      }
    }
  }

  /// Get workout statistics (prefer cloud data)
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      // Get workouts using the hybrid approach
      final List<ActiveWorkoutSession> workouts = await getCompletedWorkouts();
      
      if (workouts.isEmpty) {
        return <String, dynamic>{
          'totalWorkouts': 0,
          'totalDuration': Duration.zero,
          'averageDuration': Duration.zero,
          'thisWeekWorkouts': 0,
          'thisMonthWorkouts': 0,
        };
      }

      final DateTime now = DateTime.now();
      final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
      final DateTime monthStart = DateTime(now.year, now.month, 1);

      final int thisWeekWorkouts =
          workouts.where((ActiveWorkoutSession w) => w.startTime.isAfter(weekStart)).length;

      final int thisMonthWorkouts = workouts
          .where((ActiveWorkoutSession w) => w.startTime.isAfter(monthStart))
          .length;

      final Duration totalDuration = workouts.fold<Duration>(
          Duration.zero, (Duration sum, ActiveWorkoutSession workout) => sum + workout.totalDuration);

      final Duration averageDuration = Duration(
          milliseconds: totalDuration.inMilliseconds ~/ workouts.length);

      return <String, dynamic>{
        'totalWorkouts': workouts.length,
        'totalDuration': totalDuration,
        'averageDuration': averageDuration,
        'thisWeekWorkouts': thisWeekWorkouts,
        'thisMonthWorkouts': thisMonthWorkouts,
      };
    } catch (e) {
      print('Error calculating workout stats: $e');
      return <String, dynamic>{
        'totalWorkouts': 0,
        'totalDuration': Duration.zero,
        'averageDuration': Duration.zero,
        'thisWeekWorkouts': 0,
        'thisMonthWorkouts': 0,
      };
    }
  }

  /// Sync local storage from cloud data
  Future<void> _syncLocalFromCloud(List<ActiveWorkoutSession> cloudWorkouts) async {
    try {
      // This is a simple approach - we could make it more sophisticated
      // by comparing timestamps and only syncing newer data
      print('Syncing ${cloudWorkouts.length} cloud workouts to local storage...');
      
      // Note: For now, we trust cloud data over local data
      // In a more advanced implementation, we would merge based on timestamps
      
      // We don't directly overwrite local storage since the local service
      // manages its own deduplication logic
      for (final ActiveWorkoutSession workout in cloudWorkouts) {
        try {
          await _localService.saveCompletedWorkout(workout);
        } catch (e) {
          print('Failed to sync individual workout to local: $e');
        }
      }
      
      print('Local sync completed');
    } catch (e) {
      print('Error syncing local from cloud: $e');
    }
  }

  /// Force sync all local workouts to cloud
  Future<void> syncLocalToCloud() async {
    try {
      final List<ActiveWorkoutSession> localWorkouts = await _localService.getCompletedWorkouts();
      await _cloudService.syncCompletedWorkoutsFromLocal(localWorkouts);
      print('Manual sync to cloud completed');
    } catch (e) {
      print('Error during manual sync to cloud: $e');
      throw Exception('Failed to sync local workouts to cloud: $e');
    }
  }

  /// Force sync all cloud workouts to local
  Future<void> syncCloudToLocal() async {
    try {
      final List<ActiveWorkoutSession> cloudWorkouts = await _cloudService.getCompletedWorkouts();
      await _syncLocalFromCloud(cloudWorkouts);
      print('Manual sync from cloud completed');
    } catch (e) {
      print('Error during manual sync from cloud: $e');
      throw Exception('Failed to sync cloud workouts to local: $e');
    }
  }
}
