import '../models/workout_models.dart';
import '../services/local_workout_storage_service.dart';
import '../services/firestore_workout_service.dart';

class WorkoutStorageMigrationService {
  final LocalWorkoutStorageService _localService;
  final FirestoreWorkoutService _firestoreService;
  
  WorkoutStorageMigrationService({
    LocalWorkoutStorageService? localService,
    FirestoreWorkoutService? firestoreService,
  })  : _localService = localService ?? LocalWorkoutStorageService(),
        _firestoreService = firestoreService ?? FirestoreWorkoutService();

  /// Migrate existing local workouts to include sync fields
  Future<MigrationResult> migrateLocalWorkouts() async {
    try {
      print('Starting local workout migration...');
      
      // This method is now mainly for marking existing workouts as unsynced
      // since the new model requires all fields
      final List<SavedWorkoutPlan> existingWorkouts = await _localService.getSavedWorkoutPlans();
      int migratedCount = 0;
      int skippedCount = 0;
      
      for (final SavedWorkoutPlan workout in existingWorkouts) {
        // Check if workout needs migration (not synced and no firestoreId)
        if (!workout.isSynced && workout.firestoreId == null) {
          // This workout needs to be marked for sync
          final SavedWorkoutPlan migratedWorkout = workout.copyWith(
            isSynced: false, // Ensure it's marked as unsynced
            lastUpdated: DateTime.now(), // Update the timestamp
          );
          
          await _localService.updateWorkoutPlan(workout.id, migratedWorkout);
          migratedCount++;
        } else {
          skippedCount++;
        }
      }
      
      print('Local migration completed. Migrated: $migratedCount, Skipped: $skippedCount');
      
      return MigrationResult(
        success: true,
        migratedCount: migratedCount,
        skippedCount: skippedCount,
        totalCount: existingWorkouts.length,
        message: 'Local migration completed successfully',
      );
    } catch (e) {
      print('Local migration failed: $e');
      return MigrationResult(
        success: false,
        migratedCount: 0,
        skippedCount: 0,
        totalCount: 0,
        message: 'Local migration failed: $e',
      );
    }
  }

  /// Migrate all local workouts to Firestore (one-time sync)
  Future<MigrationResult> migrateToFirestore() async {
    if (!_firestoreService.isUserAuthenticated) {
      return MigrationResult(
        success: false,
        migratedCount: 0,
        skippedCount: 0,
        totalCount: 0,
        message: 'User not authenticated for Firestore migration',
      );
    }

    try {
      print('Starting Firestore migration...');
      
      final List<SavedWorkoutPlan> localWorkouts = await _localService.getSavedWorkoutPlans();
      final List<SavedWorkoutPlan> unsyncedWorkouts = localWorkouts.where((SavedWorkoutPlan w) => !w.isSynced).toList();
      
      int migratedCount = 0;
      int failedCount = 0;
      
      for (final SavedWorkoutPlan workout in unsyncedWorkouts) {
        try {
          // Upload to Firestore
          final String firestoreId = await _firestoreService.saveWorkoutPlan(workout);
          
          // Update local record with Firestore ID and mark as synced
          final SavedWorkoutPlan syncedWorkout = workout.copyWith(
            firestoreId: firestoreId,
            isSynced: true,
          );
          
          await _localService.updateWorkoutPlan(workout.id, syncedWorkout);
          migratedCount++;
          
          print('Migrated workout: ${workout.name} (${workout.id} -> $firestoreId)');
        } catch (e) {
          print('Failed to migrate workout ${workout.id}: $e');
          failedCount++;
        }
      }
      
      print('Firestore migration completed. Migrated: $migratedCount, Failed: $failedCount');
      
      return MigrationResult(
        success: failedCount == 0,
        migratedCount: migratedCount,
        skippedCount: localWorkouts.length - unsyncedWorkouts.length,
        totalCount: localWorkouts.length,
        message: failedCount == 0 
            ? 'Firestore migration completed successfully'
            : 'Firestore migration completed with $failedCount failures',
      );
    } catch (e) {
      print('Firestore migration failed: $e');
      return MigrationResult(
        success: false,
        migratedCount: 0,
        skippedCount: 0,
        totalCount: 0,
        message: 'Firestore migration failed: $e',
      );
    }
  }

  /// Complete migration process (local + Firestore)
  Future<MigrationResult> performFullMigration() async {
    print('Starting full migration process...');
    
    // Step 1: Migrate local workouts to add sync fields
    final MigrationResult localResult = await migrateLocalWorkouts();
    if (!localResult.success) {
      return localResult;
    }
    
    // Step 2: Migrate to Firestore if user is authenticated
    if (_firestoreService.isUserAuthenticated) {
      final MigrationResult firestoreResult = await migrateToFirestore();
      
      return MigrationResult(
        success: localResult.success && firestoreResult.success,
        migratedCount: localResult.migratedCount + firestoreResult.migratedCount,
        skippedCount: localResult.skippedCount + firestoreResult.skippedCount,
        totalCount: localResult.totalCount,
        message: '${localResult.message}. ${firestoreResult.message}',
      );
    } else {
      return MigrationResult(
        success: localResult.success,
        migratedCount: localResult.migratedCount,
        skippedCount: localResult.skippedCount,
        totalCount: localResult.totalCount,
        message: '${localResult.message}. Firestore migration skipped (user not authenticated)',
      );
    }
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      final List<SavedWorkoutPlan> workouts = await _localService.getSavedWorkoutPlans();
      
      // Check if any workout is missing sync fields by checking if they're not synced
      // and don't have a firestoreId (indicates old data model)
      for (final SavedWorkoutPlan workout in workouts) {
        if (!workout.isSynced && workout.firestoreId == null) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking migration status: $e');
      // If there's an error (like parsing old format), migration is probably needed
      return true;
    }
  }

  /// Get migration status
  Future<MigrationStatus> getMigrationStatus() async {
    try {
      final List<SavedWorkoutPlan> workouts = await _localService.getSavedWorkoutPlans();
      
      final int totalCount = workouts.length;
      final int syncedCount = workouts.where((SavedWorkoutPlan w) => w.isSynced).length;
      final int unsyncedCount = totalCount - syncedCount;
      // Legacy workouts are those that are unsynced and don't have a firestoreId
      final int legacyCount = workouts.where((SavedWorkoutPlan w) => !w.isSynced && w.firestoreId == null).length;
      
      return MigrationStatus(
        totalWorkouts: totalCount,
        syncedWorkouts: syncedCount,
        unsyncedWorkouts: unsyncedCount,
        legacyWorkouts: legacyCount,
        isFullyMigrated: legacyCount == 0,
        isFullySynced: unsyncedCount == 0,
      );
    } catch (e) {
      print('Error getting migration status: $e');
      return MigrationStatus(
        totalWorkouts: 0,
        syncedWorkouts: 0,
        unsyncedWorkouts: 0,
        legacyWorkouts: 0,
        isFullyMigrated: false,
        isFullySynced: false,
      );
    }
  }
}

class MigrationResult {
  final bool success;
  final int migratedCount;
  final int skippedCount;
  final int totalCount;
  final String message;
  
  const MigrationResult({
    required this.success,
    required this.migratedCount,
    required this.skippedCount,
    required this.totalCount,
    required this.message,
  });
  
  @override
  String toString() {
    return 'MigrationResult(success: $success, migrated: $migratedCount, skipped: $skippedCount, total: $totalCount, message: $message)';
  }
}

class MigrationStatus {
  final int totalWorkouts;
  final int syncedWorkouts;
  final int unsyncedWorkouts;
  final int legacyWorkouts;
  final bool isFullyMigrated;
  final bool isFullySynced;
  
  const MigrationStatus({
    required this.totalWorkouts,
    required this.syncedWorkouts,
    required this.unsyncedWorkouts,
    required this.legacyWorkouts,
    required this.isFullyMigrated,
    required this.isFullySynced,
  });
  
  @override
  String toString() {
    return 'MigrationStatus(total: $totalWorkouts, synced: $syncedWorkouts, unsynced: $unsyncedWorkouts, legacy: $legacyWorkouts, fullyMigrated: $isFullyMigrated, fullySynced: $isFullySynced)';
  }
}
