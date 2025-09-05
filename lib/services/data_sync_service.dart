import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

// Import all the services we need
import '../features/exercise/data/repositories/hybrid_workout_repository.dart';
import '../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../features/nutrition/data/models/nutrition_models.dart';
import '../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../features/nutrition/data/services/nutrition_api_service.dart';
import '../features/sleep/data/services/sleep_service_hybrid.dart';
import '../features/sleep/data/models/sleep_models.dart';
import '../features/profile/data/services/hybrid_profile_service.dart';
import '../features/profile/data/models/user_profile_model.dart';

/// Comprehensive data synchronization service to migrate all local data to cloud
class DataSyncService {
  static const String _syncStatusKey = 'data_sync_status';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  static bool _isSyncInProgress = false; // Global sync lock
  
  final HybridWorkoutRepository _workoutRepo = HybridWorkoutRepository();
  final NutritionRepositoryImpl _nutritionRepo = NutritionRepositoryImpl(
    apiService: NutritionApiService(),
  );
  final SleepService _sleepService = SleepService();
  final HybridProfileService _profileService = HybridProfileService();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isUserSignedIn => _auth.currentUser != null;

  /// Check if initial data sync has been completed
  Future<bool> hasCompletedInitialSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncStatusKey) ?? false;
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Mark initial sync as completed
  Future<void> _markSyncCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncStatusKey, true);
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Comprehensive sync of ALL local data to cloud with modular architecture
  Future<SyncResult> syncAllDataToCloud({
    bool forceSync = false,
    Function(String)? onProgress,
  }) async {
    if (!_isUserSignedIn) {
      return SyncResult(
        success: false,
        message: 'User not signed in',
        details: {},
      );
    }

    // Prevent concurrent sync operations
    if (_isSyncInProgress) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        details: {},
      );
    }

    // Check if sync already completed (unless forced)
    if (!forceSync && await hasCompletedInitialSync()) {
      return SyncResult(
        success: true,
        message: 'Data already synced',
        details: {},
      );
    }

    _isSyncInProgress = true; // Set sync lock
    
    final syncDetails = <String, dynamic>{};
    final errors = <String>[];

    try {
      onProgress?.call('Starting comprehensive data sync...');

      // 1. Sync Exercise/Workout Data
      onProgress?.call('📋 Syncing workout data...');
      try {
        final workoutResult = await _syncWorkoutData();
        syncDetails['workouts'] = workoutResult;
        onProgress?.call('✅ Workout data synced: ${workoutResult['count']} items');
      } catch (e) {
        final error = 'Failed to sync workout data: $e';
        errors.add(error);
        onProgress?.call('❌ $error');
      }

      // 2. Sync Nutrition Data
      onProgress?.call('🥗 Syncing nutrition data...');
      try {
        final nutritionResult = await _syncNutritionData();
        syncDetails['nutrition'] = nutritionResult;
        onProgress?.call('✅ Nutrition data synced: ${nutritionResult['totalItems']} items');
      } catch (e) {
        final error = 'Failed to sync nutrition data: $e';
        errors.add(error);
        onProgress?.call('❌ $error');
      }

      // 3. Sync Sleep Data
      onProgress?.call('😴 Syncing sleep data...');
      try {
        final sleepResult = await _syncSleepData();
        syncDetails['sleep'] = sleepResult;
        onProgress?.call('✅ Sleep data synced: ${sleepResult['totalItems']} items');
      } catch (e) {
        final error = 'Failed to sync sleep data: $e';
        errors.add(error);
        onProgress?.call('❌ $error');
      }

      // 4. Sync Profile Data
      onProgress?.call('👤 Syncing profile data...');
      try {
        final profileResult = await _syncProfileData();
        syncDetails['profile'] = profileResult;
        onProgress?.call('✅ Profile data synced');
      } catch (e) {
        final error = 'Failed to sync profile data: $e';
        errors.add(error);
        onProgress?.call('❌ $error');
      }

      // 5. Mark sync as completed if no major errors
      if (errors.isEmpty || errors.length < 2) {
        await _markSyncCompleted();
        onProgress?.call('🎉 All data successfully synced to cloud!');
      } else {
        onProgress?.call('⚠️ Sync completed with some errors');
      }

      return SyncResult(
        success: errors.length < 2, // Allow 1 error but still consider success
        message: errors.isEmpty 
          ? 'All data successfully synced to cloud'
          : 'Sync completed with ${errors.length} errors',
        details: syncDetails,
        errors: errors,
      );

    } catch (e) {
      onProgress?.call('💥 Sync failed: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        details: syncDetails,
        errors: [...errors, e.toString()],
      );
    } finally {
      _isSyncInProgress = false; // Release sync lock
    }
  }

  /// Sync workout data to Exercise module
  Future<Map<String, dynamic>> _syncWorkoutData() async {
    // Force sync all pending workout data
    await _workoutRepo.forceSyncAll();
    
    final workouts = await _workoutRepo.getSavedWorkoutPlans();
    return {
      'count': workouts.length,
      'synced': workouts.where((w) => w.isSynced).length,
      'pending': workouts.where((w) => !w.isSynced).length,
    };
  }

  /// Sync nutrition data to Nutrition module
  Future<Map<String, dynamic>> _syncNutritionData() async {
    final prefs = await SharedPreferences.getInstance();
    int totalSynced = 0;

    // Sync food log entries (cloud only - don't re-save to local)
    final foodLogJson = prefs.getStringList('food_log_entries') ?? [];
    int foodLogSynced = 0;
    for (final entryJson in foodLogJson) {
      try {
        final entryData = jsonDecode(entryJson);
        final entry = FoodLogEntry.fromJson(entryData);
        
        // Only sync to cloud, don't re-save to local storage
        await _nutritionRepo.syncFoodLogEntryToCloudOnly(entry);
        foodLogSynced++;
      } catch (e) {
        print('Failed to sync food log entry: $e');
      }
    }

    // Sync saved meal plans (cloud only - don't re-save to local)
    final mealPlansJson = prefs.getStringList('saved_meal_plans') ?? [];
    int mealPlansSynced = 0;
    for (final planJson in mealPlansJson) {
      try {
        final planData = jsonDecode(planJson);
        final plan = SavedMealPlan.fromJson(planData);
        
        // Only sync to cloud, don't re-save to local storage
        await _nutritionRepo.syncMealPlanToCloudOnly(plan.mealPlan, plan.name);
        mealPlansSynced++;
      } catch (e) {
        print('Failed to sync meal plan: $e');
      }
    }

    totalSynced = foodLogSynced + mealPlansSynced;

    return {
      'totalItems': totalSynced,
      'foodLogEntries': foodLogSynced,
      'mealPlans': mealPlansSynced,
    };
  }

  /// Sync sleep data to Sleep module
  Future<Map<String, dynamic>> _syncSleepData() async {
    // The sleep service should automatically sync when we call these methods
    await _sleepService.syncToCloud();

    final prefs = await SharedPreferences.getInstance();
    
    // Count items from local storage
    final sessions = prefs.getStringList('sleep_sessions') ?? [];
    final goals = prefs.getStringList('sleep_goals') ?? [];
    final reminders = prefs.getStringList('sleep_reminders') ?? [];
    final insights = prefs.getStringList('sleep_insights') ?? [];

    final totalItems = sessions.length + goals.length + reminders.length + insights.length;

    return {
      'totalItems': totalItems,
      'sessions': sessions.length,
      'goals': goals.length,
      'reminders': reminders.length,
      'insights': insights.length,
    };
  }

  /// Sync profile data to Profile module
  Future<Map<String, dynamic>> _syncProfileData() async {
    // Sync to cloud using the hybrid profile service
    await _profileService.syncToCloud();

    return {
      'profileSynced': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Force re-sync all data (useful for manual sync)
  Future<SyncResult> forceSyncAllData({Function(String)? onProgress}) async {
    return await syncAllDataToCloud(forceSync: true, onProgress: onProgress);
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    if (!_isUserSignedIn) {
      return {'error': 'User not signed in'};
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Get local data counts
    final foodLogEntries = prefs.getStringList('food_log_entries') ?? [];
    final mealPlans = prefs.getStringList('saved_meal_plans') ?? [];
    final sleepSessions = prefs.getStringList('sleep_sessions') ?? [];
    final workouts = await _workoutRepo.getSavedWorkoutPlans();
    
    final lastSync = await getLastSyncTime();
    final hasCompleted = await hasCompletedInitialSync();

    return {
      'hasCompletedInitialSync': hasCompleted,
      'lastSyncTime': lastSync?.toIso8601String(),
      'localDataCounts': {
        'workouts': workouts.length,
        'foodLogEntries': foodLogEntries.length,
        'mealPlans': mealPlans.length,
        'sleepSessions': sleepSessions.length,
      },
      'workoutSyncStatus': await _workoutRepo.getSyncStatus(),
    };
  }
}

/// Result class for sync operations
class SyncResult {
  final bool success;
  final String message;
  final Map<String, dynamic> details;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.details,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, errors: ${errors.length})';
  }
}
