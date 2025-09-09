import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/achievement_service.dart';

class AchievementTestScreen extends ConsumerStatefulWidget {
  const AchievementTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementTestScreen> createState() => _AchievementTestScreenState();
}

class _AchievementTestScreenState extends ConsumerState<AchievementTestScreen> {
  final AchievementService _achievementService = AchievementService();
  String _status = 'Ready to test achievements';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement System Test'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                    Text(
                      'Test Achievement System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use these buttons to test different achievement triggers',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _testSustainableAction(),
              icon: const Icon(Icons.eco),
              label: const Text('Test Sustainable Action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _testWorkoutCompletion(),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Test Workout Completion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _testNutritionLogging(),
              icon: const Icon(Icons.restaurant),
              label: const Text('Test Nutrition Logging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _testSleepLogging(),
              icon: const Icon(Icons.bedtime),
              label: const Text('Test Sleep Logging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _testLocalSupport(),
              icon: const Icon(Icons.store),
              label: const Text('Test Local Business Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Status Display
            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Processing...'),
                        ],
                      )
                    else
                      Text(
                        _status,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Click any test button above\n'
                      '2. Watch for achievement popups\n'
                      '3. Check the Achievements screen to see progress\n'
                      '4. Tap multiple times to unlock higher achievements',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testSustainableAction() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing sustainable action...';
    });

    try {
      await _achievementService.trackSustainableAction(
        context,
        actionType: 'recycling',
        carbonSaved: 2.5,
      );
      
      setState(() {
        _status = 'Sustainable action tracked! Check for achievement popup.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error testing sustainable action: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testWorkoutCompletion() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing workout completion...';
    });

    try {
      await _achievementService.trackWorkout(
        context,
        workoutType: 'strength',
        duration: 45,
      );
      
      setState(() {
        _status = 'Workout completion tracked! Check for achievement popup.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error testing workout completion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNutritionLogging() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing nutrition logging...';
    });

    try {
      await _achievementService.trackNutritionLog(context);
      
      setState(() {
        _status = 'Nutrition logging tracked! Check for achievement popup.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error testing nutrition logging: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSleepLogging() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing sleep logging...';
    });

    try {
      await _achievementService.trackSleep(
        context,
        hours: 8.0,
      );
      
      setState(() {
        _status = 'Sleep logging tracked! Check for achievement popup.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error testing sleep logging: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLocalSupport() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing local business support...';
    });

    try {
      await _achievementService.trackSustainableAction(
        context,
        actionType: 'local_business',
        carbonSaved: 1.2,
      );
      
      setState(() {
        _status = 'Local business support tracked! Check for achievement popup.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error testing local business support: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
