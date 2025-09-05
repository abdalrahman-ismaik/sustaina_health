import 'package:flutter/material.dart';
import '../features/exercise/data/services/firestore_workout_service.dart';
import '../features/nutrition/data/services/firestore_nutrition_service.dart';
import '../features/sleep/data/services/firestore_sleep_service.dart';
import '../features/profile/data/services/firestore_profile_service.dart';

/// Comprehensive debug panel to test the new modular Firestore architecture
/// Tests all four modules: Exercise, Nutrition, Sleep, Profile
class FirestoreModularDebugPanel extends StatefulWidget {
  const FirestoreModularDebugPanel({super.key});

  @override
  State<FirestoreModularDebugPanel> createState() => _FirestoreModularDebugPanelState();
}

class _FirestoreModularDebugPanelState extends State<FirestoreModularDebugPanel> {
  final FirestoreWorkoutService _exerciseService = FirestoreWorkoutService();
  final FirestoreNutritionService _nutritionService = FirestoreNutritionService();
  final FirestoreSleepService _sleepService = FirestoreSleepService();
  final FirestoreProfileService _profileService = FirestoreProfileService();

  String _status = 'Ready to test modular architecture';
  bool _isLoading = false;

  void _updateStatus(String message) {
    setState(() {
      _status = message;
      _isLoading = false;
    });
  }

  void _setLoading(String message) {
    setState(() {
      _status = message;
      _isLoading = true;
    });
  }

  Future<void> _testExerciseModule() async {
    _setLoading('Testing Exercise module...');
    try {
      // Test exercise module initialization
      await _exerciseService.ensureExerciseModuleExists();
      _updateStatus('✅ Exercise module: Successfully initialized!\n'
                   'Check Firebase Console: users/{userId}/exercise/data/');
    } catch (e) {
      _updateStatus('❌ Exercise module error: $e');
    }
  }

  Future<void> _testNutritionModule() async {
    _setLoading('Testing Nutrition module...');
    try {
      // Test nutrition module initialization
      await _nutritionService.ensureNutritionModuleExists();
      _updateStatus('✅ Nutrition module: Successfully initialized!\n'
                   'Check Firebase Console: users/{userId}/nutrition/data/');
    } catch (e) {
      _updateStatus('❌ Nutrition module error: $e');
    }
  }

  Future<void> _testSleepModule() async {
    _setLoading('Testing Sleep module...');
    try {
      // Test sleep module initialization
      await _sleepService.ensureSleepModuleExists();
      _updateStatus('✅ Sleep module: Successfully initialized!\n'
                   'Check Firebase Console: users/{userId}/sleep/data/');
    } catch (e) {
      _updateStatus('❌ Sleep module error: $e');
    }
  }

  Future<void> _testProfileModule() async {
    _setLoading('Testing Profile module...');
    try {
      // Test profile module initialization
      await _profileService.ensureProfileModuleExists();
      _updateStatus('✅ Profile module: Successfully initialized!\n'
                   'Check Firebase Console: users/{userId}/profile/data/');
    } catch (e) {
      _updateStatus('❌ Profile module error: $e');
    }
  }

  Future<void> _testAllModules() async {
    _setLoading('Testing all modules...');
    try {
      // Initialize all modules
      await Future.wait([
        _exerciseService.ensureExerciseModuleExists(),
        _nutritionService.ensureNutritionModuleExists(),
        _sleepService.ensureSleepModuleExists(),
        _profileService.ensureProfileModuleExists(),
      ]);

      _updateStatus('🎉 All modules initialized successfully!\n\n'
                   'New Firestore Architecture:\n'
                   'users/{userId}/\n'
                   '├── exercise/data/\n'
                   '│   ├── workout_plans/\n'
                   '│   └── ...\n'
                   '├── nutrition/data/\n'
                   '│   ├── food_log_entries/\n'
                   '│   ├── meal_plans/\n'
                   '│   └── ...\n'
                   '├── sleep/data/\n'
                   '│   ├── sleep_sessions/\n'
                   '│   ├── sleep_goals/\n'
                   '│   └── ...\n'
                   '└── profile/data/\n'
                   '    ├── personal_info/\n'
                   '    ├── health_goals/\n'
                   '    └── ...\n\n'
                   'Check Firebase Console to see the new structure!');
    } catch (e) {
      _updateStatus('❌ Error initializing modules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modular Architecture Debug'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Modular Architecture',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Data is now organized by modules:\n'
                      '• Exercise: workout plans, sessions\n'
                      '• Nutrition: food logs, meal plans\n'
                      '• Sleep: sessions, goals, reminders\n'
                      '• Profile: personal info, achievements',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testExerciseModule,
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Test Exercise'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testNutritionModule,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Test Nutrition'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testSleepModule,
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Test Sleep'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testProfileModule,
                    icon: const Icon(Icons.person),
                    label: const Text('Test Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAllModules,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Initialize All Modules'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_isLoading) ...[
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _status,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
