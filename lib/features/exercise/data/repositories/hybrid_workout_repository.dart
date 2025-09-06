import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_models.dart';
import '../services/local_workout_storage_service.dart';
import '../services/firestore_workout_service.dart';

class HybridWorkoutRepository {
  final LocalWorkoutStorageService _localService;
  final FirestoreWorkoutService _firestoreService;
  
  // Stream controller for real-time updates
  final StreamController<List<SavedWorkoutPlan>> _workoutStreamController = 
      StreamController<List<SavedWorkoutPlan>>.broadcast();
  
  StreamSubscription? _firestoreSubscription;
  
  HybridWorkoutRepository({
    LocalWorkoutStorageService? localService,
    FirestoreWorkoutService? firestoreService,
  })  : _localService = localService ?? LocalWorkoutStorageService(),
        _firestoreService = firestoreService ?? FirestoreWorkoutService() {
    _initializeRepository();
  }

  /// Initialize the repository and set up real-time sync
  void _initializeRepository() {
    // Listen to Firestore changes if user is authenticated
    if (_firestoreService.isUserAuthenticated) {
      _setupFirestoreListener();
      _initializeModularArchitecture(); // Initialize modular structure
    }
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupFirestoreListener();
        _initializeModularArchitecture(); // Initialize modular structure
        _syncPendingChanges(); // Sync any pending local changes
      } else {
        _firestoreSubscription?.cancel();
      }
    });
  }

  /// Initialize the modular architecture in Firestore automatically
  Future<void> _initializeModularArchitecture() async {
    try {
      await _firestoreService.ensureExerciseModuleExists();
    } catch (e) {
      print('Warning: Could not initialize exercise module: $e');
      // Continue execution - local storage will still work
    }
  }

  /// Set up real-time listener to Firestore
  void _setupFirestoreListener() {
    _firestoreSubscription?.cancel();
    
    _firestoreSubscription = _firestoreService.watchWorkoutPlans().listen(
      (List<SavedWorkoutPlan> firestoreWorkouts) async {
        await _mergeFirestoreWithLocal(firestoreWorkouts);
        await _emitUpdatedWorkouts();
      },
      onError: (error) {
        print('Firestore listen error: $error');
      },
    );
  }

  /// Merge Firestore data with local data
  Future<void> _mergeFirestoreWithLocal(List<SavedWorkoutPlan> firestoreWorkouts) async {
    final List<SavedWorkoutPlan> localWorkouts = await _localService.getSavedWorkoutPlans();
    
    for (final SavedWorkoutPlan firestoreWorkout in firestoreWorkouts) {
      // Find corresponding local workout
      final SavedWorkoutPlan? localWorkout = localWorkouts
          .where((SavedWorkoutPlan w) => w.firestoreId == firestoreWorkout.firestoreId || w.id == firestoreWorkout.id)
          .firstOrNull;
      
      if (localWorkout == null) {
        // New workout from Firestore - add to local
        await _localService.saveWorkoutPlan(
          name: firestoreWorkout.name,
          workoutPlan: firestoreWorkout.workoutPlan,
          savedWorkout: firestoreWorkout.copyWith(isSynced: true),
        );
      } else {
        // Workout exists locally - check which is newer
        if (firestoreWorkout.lastUpdated.isAfter(localWorkout.lastUpdated)) {
          // Firestore is newer - update local
          await _localService.updateWorkoutPlan(
            localWorkout.id,
            firestoreWorkout.copyWith(
              id: localWorkout.id, // Keep local ID
              isSynced: true,
            ),
          );
        } else if (localWorkout.lastUpdated.isAfter(firestoreWorkout.lastUpdated) && !localWorkout.isSynced) {
          // Local is newer and not synced - sync to Firestore
          await _syncWorkoutToFirestore(localWorkout);
        }
      }
    }
  }

  /// Emit updated workout list to stream
  Future<void> _emitUpdatedWorkouts() async {
    final List<SavedWorkoutPlan> workouts = await _localService.getSavedWorkoutPlans();
    _workoutStreamController.add(workouts);
  }

  /// Stream of workout plans (real-time updates)
  Stream<List<SavedWorkoutPlan>> watchWorkoutPlans() {
    // Emit initial data
    _emitUpdatedWorkouts();
    return _workoutStreamController.stream;
  }

  /// Save a new workout plan
  Future<String> saveWorkoutPlan({
    required String name,
    required WorkoutPlan workoutPlan,
  }) async {
    final DateTime now = DateTime.now();
    final String localId = now.millisecondsSinceEpoch.toString();
    
    final SavedWorkoutPlan savedWorkout = SavedWorkoutPlan(
      id: localId,
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'local_user',
      name: name,
      workoutPlan: workoutPlan,
      createdAt: now,
      isFavorite: false,
      isSynced: false, // Mark as not synced initially
      lastUpdated: now,
    );

    // Save to local storage immediately
    await _localService.saveWorkoutPlan(
      name: name,
      workoutPlan: workoutPlan,
      savedWorkout: savedWorkout,
    );

    // Sync to Firestore in background if authenticated
    if (_firestoreService.isUserAuthenticated) {
      _syncWorkoutToFirestore(savedWorkout);
    }

    _emitUpdatedWorkouts();
    return localId;
  }

  /// Get all saved workout plans (from local cache)
  Future<List<SavedWorkoutPlan>> getSavedWorkoutPlans() async {
    return await _localService.getSavedWorkoutPlans();
  }

  /// Get a specific workout plan by ID
  Future<SavedWorkoutPlan?> getSavedWorkoutPlan(String id) async {
    return await _localService.getSavedWorkoutPlan(id);
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String id) async {
    final SavedWorkoutPlan? workout = await _localService.getSavedWorkoutPlan(id);
    if (workout != null) {
      final SavedWorkoutPlan updatedWorkout = workout.copyWith(
        lastUsed: DateTime.now(),
        lastUpdated: DateTime.now(),
        isSynced: false, // Mark as needing sync
      );
      
      await _localService.updateWorkoutPlan(id, updatedWorkout);
      
      // Sync to Firestore if authenticated
      if (_firestoreService.isUserAuthenticated) {
        _syncWorkoutToFirestore(updatedWorkout);
      }
      
      _emitUpdatedWorkouts();
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final SavedWorkoutPlan? workout = await _localService.getSavedWorkoutPlan(id);
    if (workout != null) {
      final SavedWorkoutPlan updatedWorkout = workout.copyWith(
        isFavorite: isFavorite,
        lastUpdated: DateTime.now(),
        isSynced: false, // Mark as needing sync
      );
      
      await _localService.updateWorkoutPlan(id, updatedWorkout);
      
      // Sync to Firestore if authenticated
      if (_firestoreService.isUserAuthenticated) {
        _syncWorkoutToFirestore(updatedWorkout);
      }
      
      _emitUpdatedWorkouts();
    }
  }

  /// Delete workout plan
  Future<void> deleteWorkoutPlan(String id) async {
    final SavedWorkoutPlan? workout = await _localService.getSavedWorkoutPlan(id);
    
    // Delete from local storage
    await _localService.deleteWorkoutPlan(id);
    
    // Delete from Firestore if it exists there
    if (workout?.firestoreId != null && _firestoreService.isUserAuthenticated) {
      try {
        await _firestoreService.deleteWorkoutPlan(workout!.firestoreId!);
      } catch (e) {
        print('Failed to delete from Firestore: $e');
      }
    }
    
    _emitUpdatedWorkouts();
  }

  /// Sync a specific workout to Firestore
  Future<void> _syncWorkoutToFirestore(SavedWorkoutPlan workout) async {
    try {
      // Ensure modular architecture is initialized before saving
      await _firestoreService.ensureExerciseModuleExists();
      
      final String firestoreId = await _firestoreService.saveWorkoutPlan(workout);
      
      // Update local record with Firestore ID and mark as synced
      final SavedWorkoutPlan syncedWorkout = workout.copyWith(
        firestoreId: firestoreId,
        isSynced: true,
      );
      
      await _localService.updateWorkoutPlan(workout.id, syncedWorkout);
    } catch (e) {
      print('Failed to sync workout to Firestore: $e');
    }
  }

  /// Sync all pending local changes to Firestore
  Future<void> _syncPendingChanges() async {
    if (!_firestoreService.isUserAuthenticated) return;
    
    try {
      final List<SavedWorkoutPlan> workouts = await _localService.getSavedWorkoutPlans();
      final List<SavedWorkoutPlan> unsyncedWorkouts = workouts.where((SavedWorkoutPlan w) => !w.isSynced).toList();
      
      for (final SavedWorkoutPlan workout in unsyncedWorkouts) {
        await _syncWorkoutToFirestore(workout);
      }
      
      if (unsyncedWorkouts.isNotEmpty) {
        _emitUpdatedWorkouts();
      }
    } catch (e) {
      print('Failed to sync pending changes: $e');
    }
  }

  /// Force sync all data (useful for manual sync)
  Future<void> forceSyncAll() async {
    if (!_firestoreService.isUserAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    await _syncPendingChanges();
    
    // Also fetch latest from Firestore
    final List<SavedWorkoutPlan> firestoreWorkouts = await _firestoreService.getAllWorkoutPlans();
    await _mergeFirestoreWithLocal(firestoreWorkouts);
    await _emitUpdatedWorkouts();
  }

  /// Clear all local data (useful for logout)
  Future<void> clearLocalData() async {
    await _localService.clearAllWorkouts();
    _emitUpdatedWorkouts();
  }

  /// Get sync status
  Future<Map<String, int>> getSyncStatus() async {
    final List<SavedWorkoutPlan> workouts = await _localService.getSavedWorkoutPlans();
    final int total = workouts.length;
    final int synced = workouts.where((SavedWorkoutPlan w) => w.isSynced).length;
    final int pending = total - synced;
    
    return <String, int>{
      'total': total,
      'synced': synced,
      'pending': pending,
    };
  }

  /// Dispose resources
  void dispose() {
    _firestoreSubscription?.cancel();
    _workoutStreamController.close();
  }
}
