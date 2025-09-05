import 'package:flutter_test/flutter_test.dart';
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
      SharedPreferences.setMockInitialValues({});
      
      // Act & Assert - should not throw
      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    test('should handle initialization state correctly', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      
      // Act
      await service.initialize();
      final isInitialized = service.isInitialized;
      
      // Assert
      expect(isInitialized, isTrue);
    });

    test('should provide migration status', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      
      // Act
      final status = await service.getMigrationStatus();
      
      // Assert
      expect(status, isNotNull);
    });
  });
}
