import 'package:flutter_test/flutter_test.dart';
import 'package:ghiraas/features/exercise/data/services/workout_storage_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/core/services/app_initialization_service.dart';

void main() {
  group('App Initialization Migration Tests', () {
    late AppInitializationService service;
    
    setUp(() {
      service = AppInitializationService();
    });

    test('should complete initialization without errors', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});
      
      // Act & Assert - should not throw
      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    test('should handle initialization state correctly', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});
      
      // Act
      await service.initialize();
      final bool isInitialized = service.isInitialized;
      
      // Assert
      expect(isInitialized, isTrue);
    });

    test('should provide migration status', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});
      
      // Act
      final MigrationStatus status = await service.getMigrationStatus();
      
      // Assert
      expect(status, isNotNull);
    });
  });
}
