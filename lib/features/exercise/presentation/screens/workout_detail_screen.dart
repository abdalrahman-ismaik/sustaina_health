import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout_models.dart';
import '../providers/workout_providers.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final WorkoutPlan workout;
  final SavedWorkoutPlan? savedWorkout;

  const WorkoutDetailScreen({
    Key? key,
    required this.workout,
    this.savedWorkout,
  }) : super(key: key);

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.workout.workoutSessions.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Header
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Workout Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
            ),

            // Workout Overview
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Plan Overview',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildInfoCard(
                          'Sessions/Week', '${widget.workout.sessionsPerWeek}'),
                      _buildInfoCard('Total Sessions',
                          '${widget.workout.workoutSessions.length}'),
                    ],
                  ),
                ],
              ),
            ),

            // Warmup & Cooldown Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildComponentCard(
                      'Warmup',
                      '${widget.workout.warmup.duration} min',
                      widget.workout.warmup.description,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildComponentCard(
                      'Cooldown',
                      '${widget.workout.cooldown.duration} min',
                      widget.workout.cooldown.description,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Cardio Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.error),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.favorite, color: Theme.of(context).colorScheme.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Cardio - ${widget.workout.cardio.duration} min',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.workout.cardio.description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Workout Sessions Tabs
            if (widget.workout.workoutSessions.isNotEmpty) ...<Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: widget.workout.workoutSessions
                      .asMap()
                      .entries
                      .map((MapEntry<int, WorkoutSession> entry) {
                    return Tab(text: 'Session ${entry.key + 1}');
                  }).toList(),
                ),
              ),
              Container(
                height: 400, // Fixed height for the TabBarView in scrollable layout
                child: TabBarView(
                  controller: _tabController,
                  children: widget.workout.workoutSessions.map((WorkoutSession session) {
                    return _buildWorkoutSession(session);
                  }).toList(),
                ),
              ),
            ],

            // Start Workout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _startWorkout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

  Widget _buildInfoCard(String label, String value) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentCard(
      String title, String duration, String description, Color color) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    // Restore the original better colors for warmup and cooldown
    final Color containerColor = title == 'Warmup' 
        ? Colors.orange.withValues(alpha: 0.1) 
        : Colors.blue.withValues(alpha: 0.1);
    final Color textColor = title == 'Warmup' ? Colors.orange.shade700 : Colors.blue.shade700;
    final Color borderColor = title == 'Warmup' ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                title == 'Warmup' ? Icons.whatshot : Icons.self_improvement,
                color: textColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSession(WorkoutSession session) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: session.exercises.length,
      itemBuilder: (BuildContext context, int index) {
        final Exercise exercise = session.exercises[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20), // Increased padding for height
          constraints: const BoxConstraints(minHeight: 100), // Minimum height constraint
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Exercise number
              Container(
                width: 45, // Increased width
                height: 45, // Increased height
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 18), // Increased spacing

              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      exercise.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 17, // Slightly larger text
                      ),
                    ),
                    const SizedBox(height: 8), // Increased spacing
                    Wrap( // Changed from Row to Wrap for better responsiveness
                      spacing: 16,
                      runSpacing: 4,
                      children: <Widget>[
                        _buildExerciseDetail(
                            Icons.fitness_center, '${exercise.sets} sets'),
                        _buildExerciseDetail(Icons.repeat, exercise.reps),
                        _buildExerciseDetail(
                            Icons.timer, '${exercise.rest}s rest'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseDetail(IconData icon, String text) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _startWorkout(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Start Workout Session',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Which workout session would you like to start?',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              // Show available workout sessions
              ...widget.workout.workoutSessions.asMap().entries.map((MapEntry<int, WorkoutSession> entry) {
                final int index = entry.key;
                final WorkoutSession session = entry.value;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () =>
                        _startWorkoutSession(context, index, session),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Session ${index + 1} (${session.exercises.length} exercises)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
          ],
        );
      },
    );
  }

  void _startWorkoutSession(
      BuildContext context, int sessionIndex, WorkoutSession session) async {
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

      final String workoutName = widget.savedWorkout?.name ??
          'AI Generated Workout Session ${sessionIndex + 1}';

      // Start the workout in the provider and wait for completion
      await ref.read(activeWorkoutSessionProvider.notifier).startWorkout(
            workoutName: workoutName,
            workoutSession: session,
          );

      // Get the created session from the provider
      final ActiveWorkoutSession? activeSession = ref.read(activeWorkoutSessionProvider);

      if (activeSession == null) {
        throw Exception('Failed to create workout session');
      }

      print('Workout started successfully: ${activeSession.workoutName}');

      // Dismiss dialogs and navigate with the provider's session
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Close selection dialog

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ActiveWorkoutScreen(
              workoutSession: activeSession,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error starting workout: $e');

      // Dismiss loading dialog if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close selection dialog
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
