import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../providers/workout_providers.dart';
import '../../../../app/theme/exercise_colors.dart';

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
      _exercises = [];
    } else {
      _exercises = List.from(widget.workoutSession.exercises);
      print('Exercises loaded: ${_exercises.length}');

      // Debug each exercise
      for (int i = 0; i < _exercises.length; i++) {
        final exercise = _exercises[i];
        print(
            'Exercise $i: ${exercise.name}, rest: ${exercise.restTime}, sets: ${exercise.sets.length}');
      }
    }
  }

  void _addSet(int exerciseIndex, int reps, double? weight) async {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) {
      print('ERROR: Invalid exercise index: $exerciseIndex');
      return;
    }

    try {
      setState(() {
        final exercise = _exercises[exerciseIndex];
        final newSet = ExerciseSet(
          reps: reps,
          weight: weight,
          completedAt: DateTime.now(),
        );

        _exercises[exerciseIndex] = exercise.copyWith(
          sets: [...exercise.sets, newSet],
        );
      });

      // Update the provider with the new set data
      final updatedSession = widget.workoutSession.copyWith(
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
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _finishWorkout() async {
    // Check if user has completed at least one set
    final hasCompletedSets =
        _exercises.any((exercise) => exercise.sets.isNotEmpty);

    if (!hasCompletedSets) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please complete at least one set before finishing the workout'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Finish Workout',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to finish this workout?',
                style: TextStyle(color: Color(0xFF121714)),
              ),
              SizedBox(height: 8),
              Text(
                'Your progress will be saved to your workout history.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Continue Workout',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94E0B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  color: Color(0xFF121714),
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
              color: ExerciseColors.loadingIndicator,
            ),
          );
        },
      );

      // First update the current session with latest exercise data
      final now = DateTime.now();
      final totalDuration = now.difference(widget.workoutSession.startTime);

      final updatedSession = widget.workoutSession.copyWith(
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

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout completed and saved successfully! 🎉'),
            backgroundColor: Color(0xFF94E0B2),
          ),
        );

        // Navigate back to previous screen
        Navigator.of(context).pop();
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
            backgroundColor: Colors.red,
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

    final TextEditingController repsController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Set for ${_exercises[exerciseIndex].name}',
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF94E0B2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    borderSide: const BorderSide(color: Color(0xFF94E0B2)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reps = int.tryParse(repsController.text);
                if (reps == null || reps <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid reps'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final weight = weightController.text.isNotEmpty
                    ? double.tryParse(weightController.text)
                    : null;

                _addSet(exerciseIndex, reps, weight);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Set added: $reps reps${weight != null ? " @ ${weight}kg" : ""}'),
                    backgroundColor: const Color(0xFF94E0B2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94E0B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Set',
                style: TextStyle(
                  color: Color(0xFF121714),
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
        backgroundColor: ExerciseColors.backgroundLight,
        foregroundColor: ExerciseColors.textPrimary,
      ),
      backgroundColor: ExerciseColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ExerciseColors.primaryGreenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ExerciseColors.borderPrimary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workoutSession.workoutName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ExerciseColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Started: ${_formatTime(widget.workoutSession.startTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ExerciseColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 14,
                        color: ExerciseColors.textPrimary,
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
                  color: ExerciseColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _exercises.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No exercises found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ExerciseColors.cardBackground,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: ExerciseColors.cardShadow,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ExerciseColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rest time: ${exercise.restTime} seconds',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ExerciseColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sets completed: ${exercise.sets.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ExerciseColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showAddSetDialog(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ExerciseColors.buttonPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: Text(
                                      'Add Set',
                                      style: TextStyle(
                                        color: ExerciseColors.textOnPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (exercise.sets.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Completed Sets:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF121714),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...exercise.sets.asMap().entries.map((entry) {
                                    final setIndex = entry.key + 1;
                                    final set = entry.value;
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF94E0B2)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Set $setIndex: ${set.reps} reps${set.weight != null ? " @ ${set.weight}kg" : ""}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF121714),
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
                    backgroundColor: ExerciseColors.buttonPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Finish Workout',
                    style: TextStyle(
                      color: ExerciseColors.textOnPrimary,
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
