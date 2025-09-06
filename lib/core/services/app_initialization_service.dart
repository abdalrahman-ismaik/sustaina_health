import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/exercise/data/services/workout_storage_migration_service.dart';

class AppInitializationService {
  final WorkoutStorageMigrationService _migrationService;
  bool _isInitialized = false;
  
  AppInitializationService({
    WorkoutStorageMigrationService? migrationService,
  }) : _migrationService = migrationService ?? WorkoutStorageMigrationService();

  /// Initialize the app and run necessary migrations
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('Starting app initialization...');
    
    try {
      // Check if workout migration is needed
      final bool migrationNeeded = await _migrationService.isMigrationNeeded();
      
      if (migrationNeeded) {
        print('Workout migration needed. Starting migration...');
        
        final MigrationResult result = await _migrationService.performFullMigration();
        
        if (result.success) {
          print('Migration completed successfully: ${result.message}');
        } else {
          print('Migration failed: ${result.message}');
          // Don't throw error - let app continue with whatever data we have
        }
      } else {
        print('No workout migration needed.');
      }
      
      // Add other initialization tasks here as needed
      // await _initializeNotifications();
      // await _initializeAnalytics();
      // await _checkForAppUpdates();
      
      _isInitialized = true;
      print('App initialization completed successfully.');
      
    } catch (e) {
      print('App initialization failed: $e');
      // Don't throw error - let app continue
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Get migration status
  Future<MigrationStatus> getMigrationStatus() async {
    return await _migrationService.getMigrationStatus();
  }

  /// Force re-run migration (for testing or manual recovery)
  Future<MigrationResult> retryMigration() async {
    return await _migrationService.performFullMigration();
  }
}

// Provider for app initialization service
final Provider<AppInitializationService> appInitializationServiceProvider = Provider<AppInitializationService>((ProviderRef<AppInitializationService> ref) {
  return AppInitializationService();
});

// Provider to track initialization state
final FutureProvider<void> appInitializationProvider = FutureProvider<void>((FutureProviderRef<void> ref) async {
  final AppInitializationService service = ref.read(appInitializationServiceProvider);
  await service.initialize();
});

// Provider for migration status (refreshable)
final FutureProvider<MigrationStatus> migrationStatusProvider = FutureProvider<MigrationStatus>((FutureProviderRef<MigrationStatus> ref) async {
  final AppInitializationService service = ref.read(appInitializationServiceProvider);
  return await service.getMigrationStatus();
});
