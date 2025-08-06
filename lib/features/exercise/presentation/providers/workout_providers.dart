import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/workout_api_service.dart';
import '../../data/services/local_workout_storage_service.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../data/models/workout_models.dart';
import '../../../profile/data/models/user_profile_model.dart';

// API Service Provider
final workoutApiServiceProvider = Provider<WorkoutApiService>((ref) {
  return WorkoutApiService();
});

// Local Workout Storage Service Provider
final localWorkoutStorageServiceProvider = Provider<LocalWorkoutStorageService>((ref) {
  return LocalWorkoutStorageService();
});

// Repository Provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(
    apiService: ref.watch(workoutApiServiceProvider),
  );
});

// User Profile Provider (mock for now - you can integrate with actual user data)
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile());

  void updateProfile(UserProfile profile) {
    state = profile;
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void updateHeight(int height) {
    state = state.copyWith(height: height);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void updateSex(String sex) {
    state = state.copyWith(sex: sex);
  }

  void updateFitnessGoal(String goal) {
    state = state.copyWith(fitnessGoal: goal);
  }

  void updateWorkoutsPerWeek(int workouts) {
    state = state.copyWith(workoutsPerWeek: workouts);
  }

  void updateEquipment(List<String> equipment) {
    state = state.copyWith(availableEquipment: equipment);
  }

  void updateActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }
}

// Workout Generation Provider
final workoutGenerationProvider =
    StateNotifierProvider<WorkoutGenerationNotifier, AsyncValue<WorkoutPlan?>>(
        (ref) {
  return WorkoutGenerationNotifier(ref.watch(workoutRepositoryProvider));
});

class WorkoutGenerationNotifier
    extends StateNotifier<AsyncValue<WorkoutPlan?>> {
  final WorkoutRepository _repository;

  WorkoutGenerationNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> generateWorkout(UserProfile userProfile) async {
    if (!userProfile.isComplete) {
      state = AsyncValue.error(
          'Please complete your profile first', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final request = WorkoutGenerationRequest(
        weight: userProfile.weight!,
        height: userProfile.height!,
        age: userProfile.age!,
        sex: userProfile.apiSex,
        goal: userProfile.apiGoal,
        workoutsPerWeek: userProfile.workoutsPerWeek!,
        equipment: userProfile.availableEquipment,
      );

      final workout = await _repository.generateWorkout(request);
      state = AsyncValue.data(workout);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearWorkout() {
    state = const AsyncValue.data(null);
  }
}

// API Health Check Provider
final apiHealthProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.checkApiAvailability();
});

// Saved Workouts Provider (Local Storage)
final savedWorkoutPlansProvider =
    StateNotifierProvider<SavedWorkoutPlansNotifier, AsyncValue<List<SavedWorkoutPlan>>>(
        (ref) {
  return SavedWorkoutPlansNotifier(ref.watch(localWorkoutStorageServiceProvider));
});

class SavedWorkoutPlansNotifier
    extends StateNotifier<AsyncValue<List<SavedWorkoutPlan>>> {
  final LocalWorkoutStorageService _localStorageService;

  SavedWorkoutPlansNotifier(this._localStorageService) 
      : super(const AsyncValue.loading()) {
    loadSavedWorkouts();
  }

  Future<void> loadSavedWorkouts() async {
    state = const AsyncValue.loading();
    try {
      final workouts = await _localStorageService.getSavedWorkoutPlans();
      state = AsyncValue.data(workouts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String?> saveWorkout({
    required String name,
    required WorkoutPlan workout,
  }) async {
    try {
      final workoutId = await _localStorageService.saveWorkoutPlan(
        name: name,
        workoutPlan: workout,
      );
      await loadSavedWorkouts(); // Refresh the list
      return workoutId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _localStorageService.deleteWorkoutPlan(workoutId);
      await loadSavedWorkouts(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(String workoutId, bool isFavorite) async {
    try {
      await _localStorageService.toggleFavorite(workoutId, isFavorite);
      await loadSavedWorkouts(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateLastUsed(String workoutId) async {
    try {
      await _localStorageService.updateLastUsed(workoutId);
    } catch (e) {
      // Don't update state for this minor operation
      print('Failed to update last used: $e');
    }
  }
}

// Saved Workouts Provider (Old - using repository)
final savedWorkoutsProvider =
    StateNotifierProvider<SavedWorkoutsNotifier, AsyncValue<List<WorkoutPlan>>>(
        (ref) {
  return SavedWorkoutsNotifier(ref.watch(workoutRepositoryProvider));
});

class SavedWorkoutsNotifier
    extends StateNotifier<AsyncValue<List<WorkoutPlan>>> {
  final WorkoutRepository _repository;

  SavedWorkoutsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSavedWorkouts();
  }

  Future<void> loadSavedWorkouts() async {
    try {
      final workouts = await _repository.getSavedWorkouts();
      state = AsyncValue.data(workouts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> saveWorkout(WorkoutPlan workout) async {
    try {
      await _repository.saveWorkout(workout);
      await loadSavedWorkouts(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _repository.deleteWorkout(workoutId);
      await loadSavedWorkouts(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
