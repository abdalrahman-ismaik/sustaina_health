import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hybrid_workout_repository.dart';
import '../../data/services/local_workout_storage_service.dart';
import '../../data/services/firestore_workout_service.dart';
import '../../data/models/workout_models.dart';

// Providers for services
final localWorkoutStorageProvider = Provider<LocalWorkoutStorageService>((ref) {
  return LocalWorkoutStorageService();
});

final firestoreWorkoutServiceProvider = Provider<FirestoreWorkoutService>((ref) {
  return FirestoreWorkoutService();
});

// Main hybrid repository provider
final hybridWorkoutRepositoryProvider = Provider<HybridWorkoutRepository>((ref) {
  return HybridWorkoutRepository(
    localService: ref.read(localWorkoutStorageProvider),
    firestoreService: ref.read(firestoreWorkoutServiceProvider),
  );
});

// Stream provider for workout plans
final workoutPlansStreamProvider = StreamProvider<List<SavedWorkoutPlan>>((ref) {
  final repository = ref.read(hybridWorkoutRepositoryProvider);
  return repository.watchWorkoutPlans();
});

// Future provider for sync status
final syncStatusProvider = FutureProvider<Map<String, int>>((ref) {
  final repository = ref.read(hybridWorkoutRepositoryProvider);
  return repository.getSyncStatus();
});

// State provider for sync state
final isSyncingProvider = StateProvider<bool>((ref) => false);

// Provider for manual sync action
final syncActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(hybridWorkoutRepositoryProvider);
    ref.read(isSyncingProvider.notifier).state = true;
    
    try {
      await repository.forceSyncAll();
    } catch (e) {
      // Handle error - could show a snackbar or error state
      print('Sync failed: $e');
      rethrow;
    } finally {
      ref.read(isSyncingProvider.notifier).state = false;
    }
  };
});

// Provider for creating a new workout
final createWorkoutProvider = Provider<Future<String> Function(String, WorkoutPlan)>((ref) {
  return (String name, WorkoutPlan workoutPlan) async {
    final repository = ref.read(hybridWorkoutRepositoryProvider);
    return await repository.saveWorkoutPlan(
      name: name,
      workoutPlan: workoutPlan,
    );
  };
});

// Provider for workout actions
final workoutActionsProvider = Provider<WorkoutActions>((ref) {
  final repository = ref.read(hybridWorkoutRepositoryProvider);
  return WorkoutActions(repository);
});

class WorkoutActions {
  final HybridWorkoutRepository _repository;
  
  WorkoutActions(this._repository);
  
  Future<void> updateLastUsed(String id) => _repository.updateLastUsed(id);
  
  Future<void> toggleFavorite(String id, bool isFavorite) => 
      _repository.toggleFavorite(id, isFavorite);
  
  Future<void> deleteWorkout(String id) => _repository.deleteWorkoutPlan(id);
  
  Future<SavedWorkoutPlan?> getWorkout(String id) => 
      _repository.getSavedWorkoutPlan(id);
  
  Future<void> forceSyncAll() => _repository.forceSyncAll();
  
  Future<Map<String, int>> getSyncStatus() => _repository.getSyncStatus();
}
