import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../providers/workout_providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final ActiveWorkoutSession workoutSession;

  const ActiveWorkoutScreen({
    Key? key,
    required this.workoutSession,
  }) : super(key: key);

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late List<CompletedExercise> _exercises;

  @override
  void initState() {
    super.initState();

    // Debug the workoutSession data
    print('ActiveWorkoutScreen initialized');
    print('Workout name: ${widget.workoutSession.workoutName}');
    print('Number of exercises: ${widget.workoutSession.exercises.length}');

    // Add null safety check
    if (widget.workoutSession.exercises.isEmpty) {
      print('WARNING: No exercises found in workout session');
      _exercises = <CompletedExercise>[];
    } else {
      _exercises = List.from(widget.workoutSession.exercises);
      print('Exercises loaded: ${_exercises.length}');

      // Debug each exercise
      for (int i = 0; i < _exercises.length; i++) {
        final CompletedExercise exercise = _exercises[i];
        print(
            'Exercise $i: ${exercise.name}, rest: ${exercise.restTime}, sets: ${exercise.sets.length}');
      }
    }
  }

  // Helper method to determine if an exercise is duration-based
  bool _isDurationBasedExercise(String exerciseName, String reps) {
    // Check if exercise name contains duration-based keywords
    final List<String> durationKeywords = <String>[
      'plank',
      'hold',
      'run',
      'walk',
      'jog',
      'cycle',
      'swim',
      'cardio',
      'bridge',
      'wall sit',
      'mountain climber',
      'burpee',
      'jumping jack'
    ];

    final String nameLower = exerciseName.toLowerCase();
    final String repsLower = reps.toLowerCase();

    // Check if the exercise name contains duration keywords
    if (durationKeywords.any((String keyword) => nameLower.contains(keyword))) {
      return true;
    }

    // Check if reps field contains time indicators
    if (repsLower.contains('sec') ||
        repsLower.contains('min') ||
        repsLower.contains('time') ||
        repsLower.contains('hold') ||
        repsLower.contains('duration')) {
      return true;
    }

    return false;
  }

  // Helper method to determine if an exercise is typically bodyweight-only
  bool _isBodyweightExercise(String exerciseName) {
    final List<String> bodyweightKeywords = <String>[
      'push up',
      'pull up',
      'pushup',
      'pullup',
      'sit up',
      'situp',
      'plank',
      'burpee',
      'jumping jack',
      'mountain climber',
      'bodyweight',
      'calisthenic',
      'air squat',
      'lunge',
      'dip',
      'chin up',
      'chinup',
      'crunch',
      'leg raise',
      'pike',
      'bridge'
    ];

    final String nameLower = exerciseName.toLowerCase();
    return bodyweightKeywords.any((String keyword) => nameLower.contains(keyword));
  }

  void _addSet(int exerciseIndex, int reps, double? weight) async {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) {
      print('ERROR: Invalid exercise index: $exerciseIndex');
      return;
    }

    try {
      setState(() {
        final CompletedExercise exercise = _exercises[exerciseIndex];
        final ExerciseSet newSet = ExerciseSet(
          reps: reps,
          weight: weight,
          completedAt: DateTime.now(),
        );

        _exercises[exerciseIndex] = exercise.copyWith(
          sets: <ExerciseSet>[...exercise.sets, newSet],
        );
      });

      // Update the provider with the new set data
      final ActiveWorkoutSession updatedSession = widget.workoutSession.copyWith(
        exercises: _exercises,
      );

      // Update the provider's state
      ref
          .read(activeWorkoutSessionProvider.notifier)
          .setActiveSession(updatedSession);

      print('Set added and saved successfully');
    } catch (e) {
      print('Error adding set: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save set: $e'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  // Overloaded method for duration-based exercises
  void _addSetWithDuration(
      int exerciseIndex, int duration, double? weight) async {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) {
      print('ERROR: Invalid exercise index: $exerciseIndex');
      return;
    }

    try {
      setState(() {
        final CompletedExercise exercise = _exercises[exerciseIndex];
        final ExerciseSet newSet = ExerciseSet(
          reps: 1, // For duration exercises, reps is typically 1
          weight: weight,
          duration: duration, // Duration in seconds
          completedAt: DateTime.now(),
        );

        _exercises[exerciseIndex] = exercise.copyWith(
          sets: <ExerciseSet>[...exercise.sets, newSet],
        );
      });

      // Update the provider with the new set data
      final ActiveWorkoutSession updatedSession = widget.workoutSession.copyWith(
        exercises: _exercises,
      );

      // Update the provider's state
      ref
          .read(activeWorkoutSessionProvider.notifier)
          .setActiveSession(updatedSession);

      print('Duration set added and saved successfully');
    } catch (e) {
      print('Error adding duration set: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save duration set: $e'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  Future<void> _finishWorkout() async {
    // Check if user has completed at least one set
    final bool hasCompletedSets =
        _exercises.any((CompletedExercise exercise) => exercise.sets.isNotEmpty);

    if (!hasCompletedSets) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please complete at least one set before finishing the workout'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final bool? shouldFinish = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Finish Workout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Are you sure you want to finish this workout?',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(height: 8),
              Text(
                'Your progress will be saved to your workout history.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue Workout',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Finish',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldFinish != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      );

      // First update the current session with latest exercise data
      final DateTime now = DateTime.now();
      final Duration totalDuration = now.difference(widget.workoutSession.startTime);

      final ActiveWorkoutSession updatedSession = widget.workoutSession.copyWith(
        exercises: _exercises,
        endTime: now,
        totalDuration: totalDuration,
        isCompleted: true,
      );

      // Update the provider's state with the latest exercise data
      ref
          .read(activeWorkoutSessionProvider.notifier)
          .setActiveSession(updatedSession);

      // Complete workout through the provider (this handles saving and clearing)
      await ref.read(activeWorkoutSessionProvider.notifier).completeWorkout();

      // Refresh the completed workouts list to show in recent workouts
      await ref
          .read(completedWorkoutsProvider.notifier)
          .loadCompletedWorkouts();

      // Dismiss loading dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      // Navigate back to previous screen with completion result
      if (mounted) {
        print('ActiveWorkoutScreen: Navigating back with completion result: true');
        Navigator.of(context).pop(true); // true indicates successful completion
      } else {
        print('ActiveWorkoutScreen: Not mounted, cannot navigate back');
      }
    } catch (e) {
      print('Error finishing workout: $e');

      // Dismiss loading dialog if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddSetDialog(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) {
      print('ERROR: Invalid exercise index in dialog: $exerciseIndex');
      return;
    }

    final CompletedExercise exercise = _exercises[exerciseIndex];

    // Try to get original exercise data to determine if it's duration-based
    // For now, we'll use the exercise name to detect duration-based exercises
    final bool isDurationBased = _isDurationBasedExercise(exercise.name, '');

    final TextEditingController primaryController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Set for ${exercise.name}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: primaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isDurationBased ? 'Duration (seconds)' : 'Reps',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Only show weight field for exercises that typically use weights
              if (!_isBodyweightExercise(exercise.name))
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Weight (kg) - Optional',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final int? primaryValue = int.tryParse(primaryController.text);
                if (primaryValue == null || primaryValue <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please enter valid ${isDurationBased ? 'duration' : 'reps'}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }

                final double? weight = weightController.text.isNotEmpty
                    ? double.tryParse(weightController.text)
                    : null;

                if (isDurationBased) {
                  _addSetWithDuration(exerciseIndex, primaryValue, weight);
                } else {
                  _addSet(exerciseIndex, primaryValue, weight);
                }

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isDurationBased
                        ? 'Set added: ${primaryValue}s${weight != null ? " @ ${weight}kg" : ""}'
                        : 'Set added: $primaryValue reps${weight != null ? " @ ${weight}kg" : ""}'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Set',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutSession.workoutName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Workout header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.workoutSession.workoutName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Started: ${_formatTime(widget.workoutSession.startTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Exercises list
              Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No exercises found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CompletedExercise exercise = _exercises[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rest time: ${exercise.restTime} seconds',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sets completed: ${exercise.sets.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showAddSetDialog(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: Text(
                                      'Add Set',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (exercise.sets.isNotEmpty) ...<Widget>[
                                  SizedBox(height: 16),
                                  Text(
                                    'Completed Sets:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...exercise.sets.asMap().entries.map((MapEntry<int, ExerciseSet> entry) {
                                    final int setIndex = entry.key + 1;
                                    final ExerciseSet set = entry.value;
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        set.duration != null
                                            ? 'Set $setIndex: ${set.duration}s${set.weight != null ? " @ ${set.weight}kg" : ""}'
                                            : 'Set $setIndex: ${set.reps} reps${set.weight != null ? " @ ${set.weight}kg" : ""}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Finish Workout Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Finish Workout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
