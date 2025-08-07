import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_models.dart';

class LocalWorkoutStorageService {
  static const String _savedWorkoutsKey = 'saved_workouts';

  /// Save a workout plan locally
  Future<String> saveWorkoutPlan({
    required String name,
    required WorkoutPlan workoutPlan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutId = DateTime.now().millisecondsSinceEpoch.toString();

      final savedWorkout = SavedWorkoutPlan(
        id: workoutId,
        userId: 'local_user', // For local storage, we'll use a fixed user ID
        name: name,
        workoutPlan: workoutPlan,
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      // Get existing workouts
      final existingWorkouts = await getSavedWorkoutPlans();

      // Add new workout
      existingWorkouts.add(savedWorkout);

      // Save back to shared preferences
      final workoutsJson = existingWorkouts.map((w) => w.toJson()).toList();
      await prefs.setString(_savedWorkoutsKey, json.encode(workoutsJson));

      return workoutId;
    } catch (e) {
      throw Exception('Failed to save workout locally: $e');
    }
  }

  /// Get all saved workout plans from local storage
  Future<List<SavedWorkoutPlan>> getSavedWorkoutPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsString = prefs.getString(_savedWorkoutsKey);

      if (workoutsString == null || workoutsString.isEmpty) {
        return [];
      }

      final workoutsJson = json.decode(workoutsString) as List<dynamic>;
      return workoutsJson
          .map(
              (json) => SavedWorkoutPlan.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) =>
            b.createdAt.compareTo(a.createdAt)); // Sort by newest first
    } catch (e) {
      print('Error loading local workouts: $e');
      return [];
    }
  }

  /// Get a specific saved workout plan by ID
  Future<SavedWorkoutPlan?> getSavedWorkoutPlan(String id) async {
    try {
      final workouts = await getSavedWorkoutPlans();
      return workouts.where((w) => w.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Update last used timestamp for a workout plan
  Future<void> updateLastUsed(String id) async {
    try {
      final workouts = await getSavedWorkoutPlans();
      final index = workouts.indexWhere((w) => w.id == id);

      if (index != -1) {
        workouts[index] = workouts[index].copyWith(lastUsed: DateTime.now());

        final prefs = await SharedPreferences.getInstance();
        final workoutsJson = workouts.map((w) => w.toJson()).toList();
        await prefs.setString(_savedWorkoutsKey, json.encode(workoutsJson));
      }
    } catch (e) {
      print('Failed to update last used: $e');
    }
  }

  /// Toggle favorite status of a workout plan
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      final workouts = await getSavedWorkoutPlans();
      final index = workouts.indexWhere((w) => w.id == id);

      if (index != -1) {
        workouts[index] = workouts[index].copyWith(isFavorite: isFavorite);

        final prefs = await SharedPreferences.getInstance();
        final workoutsJson = workouts.map((w) => w.toJson()).toList();
        await prefs.setString(_savedWorkoutsKey, json.encode(workoutsJson));
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Delete a saved workout plan
  Future<void> deleteWorkoutPlan(String id) async {
    try {
      final workouts = await getSavedWorkoutPlans();
      workouts.removeWhere((w) => w.id == id);

      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = workouts.map((w) => w.toJson()).toList();
      await prefs.setString(_savedWorkoutsKey, json.encode(workoutsJson));
    } catch (e) {
      throw Exception('Failed to delete workout plan: $e');
    }
  }

  /// Clear all saved workouts
  Future<void> clearAllWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedWorkoutsKey);
    } catch (e) {
      throw Exception('Failed to clear workouts: $e');
    }
  }
}

// Extension to add firstOrNull method if not available
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
