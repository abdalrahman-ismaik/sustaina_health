import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_models.dart';

class WorkoutSessionService {
  static const String _completedWorkoutsKey = 'completed_workouts';
  static const String _activeWorkoutKey = 'active_workout';

  /// Save a completed workout session
  Future<void> saveCompletedWorkout(ActiveWorkoutSession session) async {
    try {
      print('Saving completed workout: ${session.summary}');

      // Validate session before saving
      if (!session.isValid) {
        throw Exception('Invalid session data: ${session.summary}');
      }

      if (!session.isCompleted) {
        throw Exception('Cannot save incomplete workout as completed');
      }

      final prefs = await SharedPreferences.getInstance();
      final completedWorkouts = await getCompletedWorkouts();

      // Check for duplicates
      final existingIndex =
          completedWorkouts.indexWhere((w) => w.id == session.id);
      if (existingIndex != -1) {
        // Update existing workout instead of duplicating
        completedWorkouts[existingIndex] = session;
        print('Updated existing workout: ${session.id}');
      } else {
        // Add the new completed workout
        completedWorkouts.add(session);
        print('Added new workout: ${session.id}');
      }

      // Keep only the last 100 workouts to avoid storage issues
      if (completedWorkouts.length > 100) {
        completedWorkouts.removeRange(0, completedWorkouts.length - 100);
      }

      // Save to local storage
      final workoutsJson = completedWorkouts.map((w) => w.toJson()).toList();
      final jsonString = jsonEncode(workoutsJson);

      final success = await prefs.setString(_completedWorkoutsKey, jsonString);

      if (!success) {
        throw Exception('Failed to write to SharedPreferences');
      }

      print('Workout saved successfully: ${session.workoutName}');
    } catch (e) {
      print('Error in saveCompletedWorkout: $e');
      throw Exception('Failed to save completed workout: $e');
    }
  }

  /// Get all completed workout sessions
  Future<List<ActiveWorkoutSession>> getCompletedWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getString(_completedWorkoutsKey);

      if (workoutsJson == null) {
        return [];
      }

      final workoutsList = jsonDecode(workoutsJson) as List<dynamic>;
      return workoutsList
          .map((json) =>
              ActiveWorkoutSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading completed workouts: $e');
      return [];
    }
  }

  /// Save the current active workout session
  Future<void> saveActiveWorkout(ActiveWorkoutSession session) async {
    try {
      print('Saving active workout: ${session.summary}');

      // Validate session before saving
      if (!session.isValid) {
        throw Exception('Invalid session data: ${session.summary}');
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(session.toJson());

      final success = await prefs.setString(_activeWorkoutKey, jsonString);

      if (!success) {
        throw Exception('Failed to write to SharedPreferences');
      }

      print('Active workout saved successfully: ${session.workoutName}');
    } catch (e) {
      print('Error in saveActiveWorkout: $e');
      throw Exception('Failed to save active workout: $e');
    }
  }

  /// Get the current active workout session
  Future<ActiveWorkoutSession?> getActiveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutJson = prefs.getString(_activeWorkoutKey);

      if (workoutJson == null) {
        print('No active workout found in storage');
        return null;
      }

      print('Loading active workout from storage...');
      final jsonData = jsonDecode(workoutJson) as Map<String, dynamic>;
      final session = ActiveWorkoutSession.fromJson(jsonData);

      // Validate the loaded session
      if (!session.isValid) {
        print('Invalid active workout found, clearing...');
        await clearActiveWorkout();
        return null;
      }

      print('Active workout loaded: ${session.summary}');
      return session;
    } catch (e) {
      print('Error loading active workout: $e');
      // Clear corrupted data
      try {
        await clearActiveWorkout();
      } catch (clearError) {
        print('Error clearing corrupted active workout: $clearError');
      }
      return null;
    }
  }

  /// Clear the current active workout
  Future<void> clearActiveWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeWorkoutKey);
    } catch (e) {
      throw Exception('Failed to clear active workout: $e');
    }
  }

  /// Delete a completed workout
  Future<void> deleteCompletedWorkout(String workoutId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedWorkouts = await getCompletedWorkouts();

      completedWorkouts.removeWhere((workout) => workout.id == workoutId);

      final workoutsJson = completedWorkouts.map((w) => w.toJson()).toList();
      await prefs.setString(_completedWorkoutsKey, jsonEncode(workoutsJson));
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      final completedWorkouts = await getCompletedWorkouts();

      if (completedWorkouts.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalDuration': Duration.zero,
          'averageDuration': Duration.zero,
          'thisWeekWorkouts': 0,
          'thisMonthWorkouts': 0,
        };
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      final thisWeekWorkouts =
          completedWorkouts.where((w) => w.startTime.isAfter(weekStart)).length;

      final thisMonthWorkouts = completedWorkouts
          .where((w) => w.startTime.isAfter(monthStart))
          .length;

      final totalDuration = completedWorkouts.fold<Duration>(
          Duration.zero, (sum, workout) => sum + workout.totalDuration);

      final averageDuration = Duration(
          milliseconds:
              totalDuration.inMilliseconds ~/ completedWorkouts.length);

      return {
        'totalWorkouts': completedWorkouts.length,
        'totalDuration': totalDuration,
        'averageDuration': averageDuration,
        'thisWeekWorkouts': thisWeekWorkouts,
        'thisMonthWorkouts': thisMonthWorkouts,
      };
    } catch (e) {
      print('Error calculating workout stats: $e');
      return {
        'totalWorkouts': 0,
        'totalDuration': Duration.zero,
        'averageDuration': Duration.zero,
        'thisWeekWorkouts': 0,
        'thisMonthWorkouts': 0,
      };
    }
  }
}
