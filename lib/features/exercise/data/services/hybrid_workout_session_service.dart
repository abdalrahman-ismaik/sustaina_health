import 'package:flutter/foundation.dart';
import '../models/workout_models.dart';
import 'workout_session_service.dart';
import 'firestore_workout_service.dart';

/// Hybrid service that manages both local and cloud storage for workout sessions
/// Provides smart fallback and synchronization between local SharedPreferences and Firestore
class HybridWorkoutSessionService {
  final WorkoutSessionService _localService = WorkoutSessionService();
  final FirestoreWorkoutService _cloudService = FirestoreWorkoutService();

  /// Save completed workout to both local and cloud storage
  Future<void> saveCompletedWorkout(ActiveWorkoutSession session) async {
    // Always save locally first for immediate availability
    await _localService.saveCompletedWorkout(session);
    
    // Try to save to cloud, but don't fail if cloud is unavailable
    try {
      if (_cloudService.isUserAuthenticated && await _cloudService.hasInternetConnection()) {
        await _cloudService.saveCompletedWorkout(session);
        debugPrint('Completed workout saved to cloud: ${session.workoutName}');
      } else {
        debugPrint('Cloud unavailable, workout saved locally only');
      }
    } catch (e) {
      debugPrint('Failed to save workout to cloud, keeping local copy: $e');
      // Local save already succeeded, so this is not a critical failure
    }
  }

  /// Get completed workouts with smart fallback (cloud first, then local)
  Future<List<ActiveWorkoutSession>> getCompletedWorkouts() async {
    try {
      // Try cloud first if available
      if (_cloudService.isUserAuthenticated && await _cloudService.hasInternetConnection()) {
        final List<ActiveWorkoutSession> cloudWorkouts = await _cloudService.getAllCompletedWorkouts();
        debugPrint('Loaded ${cloudWorkouts.length} completed workouts from cloud');
        
        // Also update local storage with cloud data for offline access
        _syncCloudToLocal(cloudWorkouts);
        
        return cloudWorkouts;
      }
    } catch (e) {
      debugPrint('Failed to load workouts from cloud, falling back to local: $e');
    }
    
    // Fallback to local storage
    final List<ActiveWorkoutSession> localWorkouts = await _localService.getCompletedWorkouts();
    debugPrint('Loaded ${localWorkouts.length} completed workouts from local storage');
    return localWorkouts;
  }

  /// Delete completed workout from both local and cloud storage
  Future<void> deleteCompletedWorkout(String workoutId) async {
    // Delete from local storage first
    final List<ActiveWorkoutSession> currentWorkouts = await _localService.getCompletedWorkouts();
    final List<ActiveWorkoutSession> updatedWorkouts = currentWorkouts
        .where((ActiveWorkoutSession w) => w.id != workoutId)
        .toList();
    
    // Save updated list to local storage
    await _saveWorkoutsListLocally(updatedWorkouts);
    
    // Try to delete from cloud
    try {
      if (_cloudService.isUserAuthenticated && await _cloudService.hasInternetConnection()) {
        await _cloudService.deleteCompletedWorkout(workoutId);
        debugPrint('Completed workout deleted from cloud: $workoutId');
      }
    } catch (e) {
      debugPrint('Failed to delete workout from cloud: $e');
      // Local deletion already succeeded
    }
  }

  /// Sync all local workouts to cloud
  Future<void> syncLocalToCloud() async {
    try {
      if (!_cloudService.isUserAuthenticated || !await _cloudService.hasInternetConnection()) {
        debugPrint('Cannot sync to cloud: not authenticated or no internet');
        return;
      }

      final List<ActiveWorkoutSession> localWorkouts = await _localService.getCompletedWorkouts();
      final List<ActiveWorkoutSession> cloudWorkouts = await _cloudService.getAllCompletedWorkouts();
      
      // Find workouts that exist locally but not in cloud
      final Set<String> cloudWorkoutIds = cloudWorkouts.map((w) => w.id).toSet();
      final List<ActiveWorkoutSession> workoutsToSync = localWorkouts
          .where((workout) => !cloudWorkoutIds.contains(workout.id))
          .toList();
      
      if (workoutsToSync.isNotEmpty) {
        await _cloudService.syncCompletedWorkoutsToFirestore(workoutsToSync);
        debugPrint('Synced ${workoutsToSync.length} local workouts to cloud');
      }
    } catch (e) {
      debugPrint('Failed to sync local workouts to cloud: $e');
    }
  }

  /// Sync cloud workouts to local storage (for offline access)
  Future<void> _syncCloudToLocal(List<ActiveWorkoutSession> cloudWorkouts) async {
    try {
      // Save cloud workouts to local storage
      await _saveWorkoutsListLocally(cloudWorkouts);
      debugPrint('Synced ${cloudWorkouts.length} cloud workouts to local storage');
    } catch (e) {
      debugPrint('Failed to sync cloud workouts to local: $e');
    }
  }

  /// Helper method to save a list of workouts to local storage
  Future<void> _saveWorkoutsListLocally(List<ActiveWorkoutSession> workouts) async {
    // Clear existing local workouts and save new list
    // Note: This is a simplified approach. In production, you might want more sophisticated merging
    try {
      // For now, we'll save each workout individually
      // A more efficient approach would be to directly manipulate SharedPreferences
      for (final ActiveWorkoutSession workout in workouts) {
        await _localService.saveCompletedWorkout(workout);
      }
    } catch (e) {
      debugPrint('Failed to save workouts list locally: $e');
    }
  }

  /// Get active workout (local only - active workouts don't need cloud sync)
  Future<ActiveWorkoutSession?> getActiveWorkout() async {
    return await _localService.getActiveWorkout();
  }

  /// Save active workout (local only - active workouts don't need cloud sync)
  Future<void> saveActiveWorkout(ActiveWorkoutSession session) async {
    await _localService.saveActiveWorkout(session);
  }

  /// Clear active workout (local only)
  Future<void> clearActiveWorkout() async {
    await _localService.clearActiveWorkout();
  }

  /// Check if cloud sync is available
  Future<bool> isCloudSyncAvailable() async {
    return _cloudService.isUserAuthenticated && await _cloudService.hasInternetConnection();
  }

  /// Get cloud sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final bool isAuthenticated = _cloudService.isUserAuthenticated;
      final bool hasInternet = await _cloudService.hasInternetConnection();
      final List<ActiveWorkoutSession> localWorkouts = await _localService.getCompletedWorkouts();
      
      int cloudWorkoutCount = 0;
      if (isAuthenticated && hasInternet) {
        try {
          final List<ActiveWorkoutSession> cloudWorkouts = await _cloudService.getAllCompletedWorkouts();
          cloudWorkoutCount = cloudWorkouts.length;
        } catch (e) {
          debugPrint('Failed to get cloud workout count: $e');
        }
      }
      
      return {
        'isAuthenticated': isAuthenticated,
        'hasInternet': hasInternet,
        'localWorkoutCount': localWorkouts.length,
        'cloudWorkoutCount': cloudWorkoutCount,
        'cloudSyncAvailable': isAuthenticated && hasInternet,
        'lastChecked': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isAuthenticated': false,
        'hasInternet': false,
        'localWorkoutCount': 0,
        'cloudWorkoutCount': 0,
        'cloudSyncAvailable': false,
        'error': e.toString(),
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }
}
