import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hybrid_workout_repository.dart';
import '../../data/services/local_workout_storage_service.dart';
import '../../data/services/firestore_workout_service.dart';
import '../../data/models/workout_models.dart';

// Providers for services
final Provider<LocalWorkoutStorageService> localWorkoutStorageProvider = Provider<LocalWorkoutStorageService>((ProviderRef<LocalWorkoutStorageService> ref) {
  return LocalWorkoutStorageService();
});

final Provider<FirestoreWorkoutService> firestoreWorkoutServiceProvider = Provider<FirestoreWorkoutService>((ProviderRef<FirestoreWorkoutService> ref) {
  return FirestoreWorkoutService();
});

// Main hybrid repository provider
final Provider<HybridWorkoutRepository> hybridWorkoutRepositoryProvider = Provider<HybridWorkoutRepository>((ProviderRef<HybridWorkoutRepository> ref) {
  return HybridWorkoutRepository(
    localService: ref.read(localWorkoutStorageProvider),
    firestoreService: ref.read(firestoreWorkoutServiceProvider),
  );
});

// Stream provider for workout plans
final StreamProvider<List<SavedWorkoutPlan>> workoutPlansStreamProvider = StreamProvider<List<SavedWorkoutPlan>>((StreamProviderRef<List<SavedWorkoutPlan>> ref) {
  final HybridWorkoutRepository repository = ref.read(hybridWorkoutRepositoryProvider);
  return repository.watchWorkoutPlans();
});

// Future provider for sync status
final FutureProvider<Map<String, int>> syncStatusProvider = FutureProvider<Map<String, int>>((FutureProviderRef<Map<String, int>> ref) {
  final HybridWorkoutRepository repository = ref.read(hybridWorkoutRepositoryProvider);
  return repository.getSyncStatus();
});

// State provider for sync state
final StateProvider<bool> isSyncingProvider = StateProvider<bool>((StateProviderRef<bool> ref) => false);

// Provider for manual sync action
final Provider<Future<void> Function()> syncActionProvider = Provider<Future<void> Function()>((ProviderRef<Future<void> Function()> ref) {
  return () async {
    final HybridWorkoutRepository repository = ref.read(hybridWorkoutRepositoryProvider);
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
final Provider<Future<String> Function(String p1, WorkoutPlan p2)> createWorkoutProvider = Provider<Future<String> Function(String, WorkoutPlan)>((ProviderRef<Future<String> Function(String p1, WorkoutPlan p2)> ref) {
  return (String name, WorkoutPlan workoutPlan) async {
    final HybridWorkoutRepository repository = ref.read(hybridWorkoutRepositoryProvider);
    return await repository.saveWorkoutPlan(
      name: name,
      workoutPlan: workoutPlan,
    );
  };
});

// Provider for workout actions
final Provider<WorkoutActions> workoutActionsProvider = Provider<WorkoutActions>((ProviderRef<WorkoutActions> ref) {
  final HybridWorkoutRepository repository = ref.read(hybridWorkoutRepositoryProvider);
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
