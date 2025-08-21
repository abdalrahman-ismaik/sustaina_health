import '../models/workout_models.dart';
import '../services/workout_api_service.dart';
import '../../domain/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutApiService _apiService;

  const WorkoutRepositoryImpl({
    required WorkoutApiService apiService,
  }) : _apiService = apiService;

  @override
  Future<WorkoutPlan> generateWorkout(WorkoutGenerationRequest request) async {
    return await _apiService.generateWorkout(request);
  }

  @override
  Future<bool> checkApiAvailability() async {
    return await _apiService.checkApiHealth();
  }

  @override
  Future<void> saveWorkout(WorkoutPlan workout) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<WorkoutPlan> workouts = await getSavedWorkouts();

      // Add timestamp and ID to the workout
      final Map<String, Object> workoutWithMeta = <String, Object>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'created_at': DateTime.now().toIso8601String(),
        'workout': workout.toJson(),
      };

      workouts.add(WorkoutPlan.fromJson(
          workoutWithMeta['workout'] as Map<String, dynamic>));

      // Save to shared preferences
      final List<String> savedWorkouts = await prefs.getStringList('saved_workouts') ?? <String>[];
      savedWorkouts.add(jsonEncode(workoutWithMeta));
      await prefs.setStringList('saved_workouts', savedWorkouts);
    } catch (e) {
      throw Exception('Failed to save workout: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkoutPlan>> getSavedWorkouts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> savedWorkouts = prefs.getStringList('saved_workouts') ?? <String>[];

      return savedWorkouts.map((String workoutString) {
        final Map<String, dynamic> workoutData = jsonDecode(workoutString) as Map<String, dynamic>;
        return WorkoutPlan.fromJson(
            workoutData['workout'] as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return <WorkoutPlan>[];
    }
  }

  @override
  Future<void> deleteWorkout(String workoutId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> savedWorkouts = prefs.getStringList('saved_workouts') ?? <String>[];

      savedWorkouts.removeWhere((String workoutString) {
        final Map<String, dynamic> workoutData = jsonDecode(workoutString) as Map<String, dynamic>;
        return workoutData['id'] == workoutId;
      });

      await prefs.setStringList('saved_workouts', savedWorkouts);
    } catch (e) {
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }
}
