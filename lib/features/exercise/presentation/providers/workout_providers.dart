import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/workout_api_service.dart';
import '../../data/services/local_workout_storage_service.dart';
import '../../data/services/workout_session_service.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../data/models/workout_models.dart';
import '../../../profile/data/models/user_profile_model.dart';
import 'package:uuid/uuid.dart';

// API Service Provider
final workoutApiServiceProvider = Provider<WorkoutApiService>((ref) {
  return WorkoutApiService();
});

// Local Workout Storage Service Provider
final localWorkoutStorageServiceProvider =
    Provider<LocalWorkoutStorageService>((ref) {
  return LocalWorkoutStorageService();
});

// Workout Session Service Provider
final workoutSessionServiceProvider = Provider<WorkoutSessionService>((ref) {
  return WorkoutSessionService();
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
final savedWorkoutPlansProvider = StateNotifierProvider<
    SavedWorkoutPlansNotifier, AsyncValue<List<SavedWorkoutPlan>>>((ref) {
  return SavedWorkoutPlansNotifier(
      ref.watch(localWorkoutStorageServiceProvider));
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

// Active Workout Session Provider
final activeWorkoutSessionProvider =
    StateNotifierProvider<ActiveWorkoutSessionNotifier, ActiveWorkoutSession?>(
        (ref) {
  return ActiveWorkoutSessionNotifier(ref.watch(workoutSessionServiceProvider));
});

class ActiveWorkoutSessionNotifier
    extends StateNotifier<ActiveWorkoutSession?> {
  final WorkoutSessionService _sessionService;
  final Uuid _uuid = const Uuid();

  ActiveWorkoutSessionNotifier(this._sessionService) : super(null) {
    _loadActiveWorkout();
  }

  Future<void> _loadActiveWorkout() async {
    try {
      print('Loading active workout from storage...');
      final activeWorkout = await _sessionService.getActiveWorkout();

      if (activeWorkout != null) {
        print('Found active workout: ${activeWorkout.summary}');

        // Validate the loaded workout
        if (activeWorkout.isValid) {
          state = activeWorkout;
          print('Active workout loaded successfully');
        } else {
          print('Active workout is invalid, clearing...');
          await _sessionService.clearActiveWorkout();
        }
      } else {
        print('No active workout found');
      }
    } catch (e) {
      print('Error loading active workout: $e');
      // Clear corrupted data
      try {
        await _sessionService.clearActiveWorkout();
      } catch (clearError) {
        print('Error clearing corrupted active workout: $clearError');
      }
    }
  }

  Future<void> startWorkout({
    required String workoutName,
    required WorkoutSession workoutSession,
  }) async {
    try {
      print(
          'Starting workout: $workoutName with ${workoutSession.exercises.length} exercises');

      // Validate input
      if (workoutName.trim().isEmpty) {
        throw Exception('Workout name cannot be empty');
      }

      if (workoutSession.exercises.isEmpty) {
        throw Exception('Cannot start workout with no exercises');
      }

      final session = ActiveWorkoutSession.fromWorkoutSession(
        id: _uuid.v4(),
        workoutName: workoutName.trim(),
        workoutSession: workoutSession,
      );

      print(
          'Created session with ID: ${session.id} and ${session.exercises.length} exercises');

      // Save the session first
      await _sessionService.saveActiveWorkout(session);

      // Then update the state
      state = session;

      print('Workout started and saved successfully');
    } catch (e) {
      print('Error in startWorkout: $e');
      // Reset state on error
      state = null;
      throw Exception('Failed to start workout: $e');
    }
  }

  void setActiveSession(ActiveWorkoutSession session) async {
    try {
      print('Setting active session: ${session.workoutName}');

      // Save to storage first
      await _sessionService.saveActiveWorkout(session);

      // Then update state
      state = session;

      print('Active session updated and saved successfully');
    } catch (e) {
      print('Error setting active session: $e');
      // Don't throw here to avoid breaking the UI, just log the error
      print('Failed to save active session, keeping in memory only');
      state = session;
    }
  }

  Future<void> addSet({
    required int exerciseIndex,
    required int reps,
    double? weight,
    int? duration,
    String? notes,
  }) async {
    if (state == null) return;

    try {
      final newSet = ExerciseSet(
        reps: reps,
        weight: weight,
        duration: duration,
        completedAt: DateTime.now(),
        notes: notes,
      );

      final updatedExercises = List<CompletedExercise>.from(state!.exercises);
      final exercise = updatedExercises[exerciseIndex];

      updatedExercises[exerciseIndex] = exercise.copyWith(
        sets: [...exercise.sets, newSet],
      );

      final updatedSession = state!.copyWith(exercises: updatedExercises);
      await _sessionService.saveActiveWorkout(updatedSession);
      state = updatedSession;
    } catch (e) {
      throw Exception('Failed to add set: $e');
    }
  }

  Future<void> markExerciseComplete(int exerciseIndex) async {
    if (state == null) return;

    try {
      final updatedExercises = List<CompletedExercise>.from(state!.exercises);
      updatedExercises[exerciseIndex] =
          updatedExercises[exerciseIndex].copyWith(
        isCompleted: true,
      );

      final updatedSession = state!.copyWith(exercises: updatedExercises);
      await _sessionService.saveActiveWorkout(updatedSession);
      state = updatedSession;
    } catch (e) {
      throw Exception('Failed to mark exercise complete: $e');
    }
  }

  Future<void> updateWorkoutTimer() async {
    if (state == null) return;

    try {
      final now = DateTime.now();
      final duration = now.difference(state!.startTime);

      final updatedSession = state!.copyWith(totalDuration: duration);
      await _sessionService.saveActiveWorkout(updatedSession);
      state = updatedSession;
    } catch (e) {
      // Don't throw error for timer updates
      print('Failed to update timer: $e');
    }
  }

  Future<void> completeWorkout({String? notes}) async {
    if (state == null) {
      throw Exception('No active workout to complete');
    }

    try {
      print('Completing workout: ${state!.workoutName}');

      final now = DateTime.now();
      final totalDuration = now.difference(state!.startTime);

      final completedSession = state!.copyWith(
        endTime: now,
        totalDuration: totalDuration,
        isCompleted: true,
        notes: notes,
      );

      // Validate completed session
      if (completedSession.exercises.isEmpty) {
        throw Exception('Cannot complete workout with no exercises');
      }

      // Save to completed workouts first
      await _sessionService.saveCompletedWorkout(completedSession);

      // Then clear active workout
      await _sessionService.clearActiveWorkout();

      // Finally clear state
      state = null;

      print('Workout completed and saved successfully');
    } catch (e) {
      print('Error in completeWorkout: $e');
      throw Exception('Failed to complete workout: $e');
    }
  }

  Future<void> cancelWorkout() async {
    try {
      await _sessionService.clearActiveWorkout();
      state = null;
    } catch (e) {
      throw Exception('Failed to cancel workout: $e');
    }
  }
}

// Completed Workouts Provider
final completedWorkoutsProvider = StateNotifierProvider<
    CompletedWorkoutsNotifier, AsyncValue<List<ActiveWorkoutSession>>>((ref) {
  return CompletedWorkoutsNotifier(ref.watch(workoutSessionServiceProvider));
});

class CompletedWorkoutsNotifier
    extends StateNotifier<AsyncValue<List<ActiveWorkoutSession>>> {
  final WorkoutSessionService _sessionService;

  CompletedWorkoutsNotifier(this._sessionService)
      : super(const AsyncValue.loading()) {
    loadCompletedWorkouts();
  }

  Future<void> loadCompletedWorkouts() async {
    state = const AsyncValue.loading();
    try {
      final workouts = await _sessionService.getCompletedWorkouts();
      state = AsyncValue.data(workouts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _sessionService.deleteCompletedWorkout(workoutId);
      await loadCompletedWorkouts(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Workout Stats Provider
final workoutStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final sessionService = ref.watch(workoutSessionServiceProvider);
  return await sessionService.getWorkoutStats();
});
