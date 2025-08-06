import '../../data/models/workout_models.dart';

abstract class WorkoutRepository {
  Future<WorkoutPlan> generateWorkout(WorkoutGenerationRequest request);
  Future<bool> checkApiAvailability();
  Future<void> saveWorkout(WorkoutPlan workout);
  Future<List<WorkoutPlan>> getSavedWorkouts();
  Future<void> deleteWorkout(String workoutId);
}
