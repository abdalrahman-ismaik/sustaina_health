import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../providers/workout_providers.dart';

class CompletedWorkoutDetailScreen extends ConsumerWidget {
  final ActiveWorkoutSession completedWorkout;

  const CompletedWorkoutDetailScreen({
    Key? key,
    required this.completedWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Workout Summary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                    onSelected: (String value) {
                      if (value == 'share') {
                        // TODO: Implement share functionality
                      } else if (value == 'delete') {
                        _showDeleteWorkoutDialog(context, ref);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Workout Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Workout Completed!',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              completedWorkout.workoutName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildStatColumn(
                        context,
                        'Duration',
                        _formatDuration(completedWorkout.totalDuration),
                        Icons.timer,
                      ),
                      _buildStatColumn(
                        context,
                        'Exercises',
                        '${completedWorkout.exercises.length}',
                        Icons.fitness_center,
                      ),
                      _buildStatColumn(
                        context,
                        'Total Sets',
                        '${_getTotalSets()}',
                        Icons.repeat,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Workout Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Started',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateTime(completedWorkout.startTime),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (completedWorkout.endTime != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Finished',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDateTime(completedWorkout.endTime!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Exercise List
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: <Widget>[
                  Text(
                    'Exercise Details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.015,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: completedWorkout.exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  final CompletedExercise exercise = completedWorkout.exercises[index];
                  return _buildExerciseCard(context, exercise, index + 1);
                },
              ),
            ),

            // Notes section (if any)
            if (completedWorkout.notes != null &&
                completedWorkout.notes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.note,
                            color: Theme.of(context).colorScheme.tertiary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Workout Notes',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedWorkout.notes!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, CompletedExercise exercise, int exerciseNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: exercise.isCompleted
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.outline,
          width: exercise.isCompleted ? 2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: exercise.isCompleted
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: exercise.isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: exercise.isCompleted
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary, size: 18)
                        : Text(
                            '$exerciseNumber',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exercise.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (exercise.sets.isNotEmpty)
                        Text(
                          '${exercise.sets.length} set${exercise.sets.length == 1 ? '' : 's'} completed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (exercise.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Sets Details
          if (exercise.sets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  // Sets Header
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text('Set',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant))),
                      Expanded(
                          child: Text('Reps',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant))),
                      Expanded(
                          child: Text('Weight',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant))),
                      Expanded(
                          child: Text('Duration',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 8),

                  // Sets Data
                  ...exercise.sets.asMap().entries.map((MapEntry<int, ExerciseSet> entry) {
                    final int setIndex = entry.key;
                    final ExerciseSet set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${setIndex + 1}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${set.reps}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              set.weight != null
                                  ? '${set.weight!.toStringAsFixed(1)} kg'
                                  : '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              set.duration != null ? '${set.duration}s' : '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Set Notes
                  ...exercise.sets
                      .where(
                          (ExerciseSet set) => set.notes != null && set.notes!.isNotEmpty)
                      .map((ExerciseSet set) {
                    final int setIndex = exercise.sets.indexOf(set);
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow.shade200),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.note,
                              size: 16, color: Colors.yellow.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Set ${setIndex + 1}: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade800,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              set.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.yellow.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No sets recorded for this exercise',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final int hour = dateTime.hour;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String amPm = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $amPm';
  }

  int _getTotalSets() {
    return completedWorkout.exercises
        .fold(0, (int total, CompletedExercise exercise) => total + exercise.sets.length);
  }

  Future<void> _showDeleteWorkoutDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Are you sure you want to delete this workout session?'),
                const SizedBox(height: 8),
                Text(
                  completedWorkout.workoutName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (completedWorkout.endTime != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Completed on ${completedWorkout.endTime!.day}/${completedWorkout.endTime!.month}/${completedWorkout.endTime!.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
                
                // Delete the workout using the provider
                final CompletedWorkoutsNotifier notifier = ref.read(completedWorkoutsProvider.notifier);
                await notifier.deleteWorkout(completedWorkout.id);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
