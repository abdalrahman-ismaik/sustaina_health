import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../../../../app/theme/exercise_colors.dart';

class CompletedWorkoutDetailScreen extends ConsumerWidget {
  final ActiveWorkoutSession completedWorkout;

  const CompletedWorkoutDetailScreen({
    Key? key,
    required this.completedWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ExerciseColors.backgroundLight,
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
                        color: ExerciseColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Workout Summary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ExerciseColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: ExerciseColors.textPrimary),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
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
                    ExerciseColors.primaryGreen,
                    ExerciseColors.primaryGreen.withOpacity(0.8),
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
                              ExerciseColors.backgroundLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: ExerciseColors.textOnDark,
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
                                color: ExerciseColors.textOnDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              completedWorkout.workoutName,
                              style: TextStyle(
                                color: ExerciseColors.textOnDark,
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
                        'Duration',
                        _formatDuration(completedWorkout.totalDuration),
                        Icons.timer,
                      ),
                      _buildStatColumn(
                        'Exercises',
                        '${completedWorkout.exercises.length}',
                        Icons.fitness_center,
                      ),
                      _buildStatColumn(
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
                color: ExerciseColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ExerciseColors.borderLight),
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
                          color: ExerciseColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateTime(completedWorkout.startTime),
                        style: TextStyle(
                          color: ExerciseColors.textPrimary,
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
                            color: ExerciseColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDateTime(completedWorkout.endTime!),
                          style: TextStyle(
                            color: ExerciseColors.textPrimary,
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
                      color: ExerciseColors.textPrimary,
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
                  return _buildExerciseCard(exercise, index + 1);
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
                  color: ExerciseColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ExerciseColors.buttonInfo),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.note,
                            color: ExerciseColors.buttonInfo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Workout Notes',
                          style: TextStyle(
                            color: ExerciseColors.infoDark,
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
                        color: ExerciseColors.infoDark,
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

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ExerciseColors.backgroundLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: ExerciseColors.textOnDark,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: ExerciseColors.textOnDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: ExerciseColors.textOnDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(CompletedExercise exercise, int exerciseNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ExerciseColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: exercise.isCompleted
              ? ExerciseColors.buttonSuccess
              : ExerciseColors.borderLight,
          width: exercise.isCompleted ? 2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ExerciseColors.cardShadow,
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
                  ? ExerciseColors.successLight
                  : ExerciseColors.surfaceLight,
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
                        ? ExerciseColors.buttonSuccess
                        : ExerciseColors.textMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: exercise.isCompleted
                        ? Icon(Icons.check,
                            color: ExerciseColors.textOnDark, size: 18)
                        : Text(
                            '$exerciseNumber',
                            style: TextStyle(
                              color: ExerciseColors.textOnDark,
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
                          color: ExerciseColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (exercise.sets.isNotEmpty)
                        Text(
                          '${exercise.sets.length} set${exercise.sets.length == 1 ? '' : 's'} completed',
                          style: TextStyle(
                            color: ExerciseColors.textSecondary,
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
                      color: ExerciseColors.buttonSuccess,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: ExerciseColors.textOnDark,
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
                                  color: ExerciseColors.textSecondary))),
                      Expanded(
                          child: Text('Reps',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: ExerciseColors.textSecondary))),
                      Expanded(
                          child: Text('Weight',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: ExerciseColors.textSecondary))),
                      Expanded(
                          child: Text('Duration',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: ExerciseColors.textSecondary))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: ExerciseColors.divider),
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
                                  color: ExerciseColors.textPrimary),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${set.reps}',
                              style: TextStyle(
                                fontSize: 14,
                                color: ExerciseColors.textPrimary,
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
                                color: ExerciseColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              set.duration != null ? '${set.duration}s' : '-',
                              style: TextStyle(
                                fontSize: 14,
                                color: ExerciseColors.textPrimary,
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
                  color: ExerciseColors.textMuted,
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
}
