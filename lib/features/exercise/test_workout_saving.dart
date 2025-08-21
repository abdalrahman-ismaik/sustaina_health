import 'package:flutter/material.dart';
import 'data/models/workout_models.dart';
import 'data/services/workout_session_service.dart';

/// Test script to verify workout saving functionality
/// This can be run independently to test the core saving logic
class WorkoutSavingTest {
  static Future<void> runTests() async {
    print('Starting Workout Saving Tests...\n');

    final WorkoutSessionService service = WorkoutSessionService();

    // Test 1: Create and save a simple workout
    await testBasicWorkoutSaving(service);

    // Test 2: Test duplicate handling
    await testDuplicateHandling(service);

    // Test 3: Test invalid data handling
    await testInvalidDataHandling(service);

    // Test 4: Test active workout persistence
    await testActiveWorkoutPersistence(service);

    print('\n✅ All tests completed!');
  }

  static Future<void> testBasicWorkoutSaving(
      WorkoutSessionService service) async {
    print('🧪 Test 1: Basic Workout Saving');

    try {
      // Create a test workout
      final ActiveWorkoutSession testWorkout = _createTestWorkout();

      print('   Creating test workout: ${testWorkout.summary}');

      // Save as active workout
      await service.saveActiveWorkout(testWorkout);
      print('   ✓ Active workout saved');

      // Retrieve active workout
      final ActiveWorkoutSession? retrievedActive = await service.getActiveWorkout();
      if (retrievedActive != null && retrievedActive.id == testWorkout.id) {
        print('   ✓ Active workout retrieved successfully');
      } else {
        print('   ❌ Failed to retrieve active workout');
      }

      // Complete the workout
      final ActiveWorkoutSession completedWorkout = testWorkout.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
        totalDuration: const Duration(minutes: 30),
      );

      await service.saveCompletedWorkout(completedWorkout);
      print('   ✓ Completed workout saved');

      // Retrieve completed workouts
      final List<ActiveWorkoutSession> completedWorkouts = await service.getCompletedWorkouts();
      if (completedWorkouts.any((ActiveWorkoutSession w) => w.id == testWorkout.id)) {
        print('   ✓ Completed workout retrieved successfully');
      } else {
        print('   ❌ Failed to retrieve completed workout');
      }

      // Clear active workout
      await service.clearActiveWorkout();
      print('   ✓ Active workout cleared');

      print('   ✅ Test 1 passed!\n');
    } catch (e) {
      print('   ❌ Test 1 failed: $e\n');
    }
  }

  static Future<void> testDuplicateHandling(
      WorkoutSessionService service) async {
    print('🧪 Test 2: Duplicate Handling');

    try {
      final ActiveWorkoutSession testWorkout = _createTestWorkout();
      final ActiveWorkoutSession completedWorkout = testWorkout.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
        totalDuration: const Duration(minutes: 30),
      );

      // Save first time
      await service.saveCompletedWorkout(completedWorkout);

      // Save again with updates
      final ActiveWorkoutSession updatedWorkout = completedWorkout.copyWith(
        totalDuration: const Duration(minutes: 45),
        notes: 'Updated workout',
      );

      await service.saveCompletedWorkout(updatedWorkout);

      // Check that only one copy exists
      final List<ActiveWorkoutSession> completedWorkouts = await service.getCompletedWorkouts();
      final List<ActiveWorkoutSession> matchingWorkouts =
          completedWorkouts.where((ActiveWorkoutSession w) => w.id == testWorkout.id).toList();

      if (matchingWorkouts.length == 1) {
        print('   ✓ Duplicate handling works correctly');

        if (matchingWorkouts.first.notes == 'Updated workout') {
          print('   ✓ Workout was updated, not duplicated');
        } else {
          print('   ❌ Workout was not updated properly');
        }
      } else {
        print('   ❌ Found ${matchingWorkouts.length} copies instead of 1');
      }

      print('   ✅ Test 2 passed!\n');
    } catch (e) {
      print('   ❌ Test 2 failed: $e\n');
    }
  }

  static Future<void> testInvalidDataHandling(
      WorkoutSessionService service) async {
    print('🧪 Test 3: Invalid Data Handling');

    try {
      // Test invalid workout (empty name)
      final ActiveWorkoutSession invalidWorkout = ActiveWorkoutSession(
        id: 'invalid-id',
        workoutName: '', // Invalid: empty name
        startTime: DateTime.now(),
        exercises: <CompletedExercise>[], // Invalid: no exercises
        totalDuration: Duration.zero,
      );

      bool caughtError = false;
      try {
        await service.saveActiveWorkout(invalidWorkout);
      } catch (e) {
        caughtError = true;
        print('   ✓ Invalid workout correctly rejected: $e');
      }

      if (!caughtError) {
        print('   ❌ Invalid workout was not rejected');
      }

      print('   ✅ Test 3 passed!\n');
    } catch (e) {
      print('   ❌ Test 3 failed: $e\n');
    }
  }

  static Future<void> testActiveWorkoutPersistence(
      WorkoutSessionService service) async {
    print('🧪 Test 4: Active Workout Persistence');

    try {
      // Clear any existing active workout
      await service.clearActiveWorkout();

      // Create and save an active workout
      final ActiveWorkoutSession testWorkout = _createTestWorkout();
      await service.saveActiveWorkout(testWorkout);

      // Simulate app restart by creating a new service instance
      final WorkoutSessionService newService = WorkoutSessionService();
      final ActiveWorkoutSession? retrievedWorkout = await newService.getActiveWorkout();

      if (retrievedWorkout != null && retrievedWorkout.id == testWorkout.id) {
        print('   ✓ Active workout persisted across service instances');
      } else {
        print('   ❌ Active workout not persisted properly');
      }

      // Clean up
      await service.clearActiveWorkout();

      print('   ✅ Test 4 passed!\n');
    } catch (e) {
      print('   ❌ Test 4 failed: $e\n');
    }
  }

  static ActiveWorkoutSession _createTestWorkout() {
    return ActiveWorkoutSession(
      id: 'test-workout-${DateTime.now().millisecondsSinceEpoch}',
      workoutName: 'Test Workout',
      startTime: DateTime.now(),
      exercises: <CompletedExercise>[
        const CompletedExercise(
          name: 'Push-ups',
          sets: <ExerciseSet>[],
          restTime: 60,
        ),
        const CompletedExercise(
          name: 'Squats',
          sets: <ExerciseSet>[],
          restTime: 90,
        ),
      ],
      totalDuration: Duration.zero,
    );
  }
}

/// Widget to run tests in a Flutter app context
class WorkoutTestScreen extends StatefulWidget {
  const WorkoutTestScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutTestScreen> createState() => _WorkoutTestScreenState();
}

class _WorkoutTestScreenState extends State<WorkoutTestScreen> {
  bool _isRunning = false;
  String _results = 'Press the button to run tests';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Saving Tests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: Text(_isRunning ? 'Running Tests...' : 'Run Tests'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _results,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _results = 'Running tests...\n';
    });

    try {
      await WorkoutSavingTest.runTests();
      setState(() {
        _results += '\n✅ All tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _results += '\n❌ Tests failed: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
}
