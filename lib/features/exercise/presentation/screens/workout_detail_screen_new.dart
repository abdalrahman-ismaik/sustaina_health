import 'package:flutter/material.dart';
import '../../data/models/workout_models.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutPlan workout;

  const WorkoutDetailScreen({Key? key, required this.workout})
      : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentSessionIndex = 0;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF121714)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Workout Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF121714),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Color(0xFF121714)),
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
                color: const Color(0xFF94E0B2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF94E0B2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Overview',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                children: [
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
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cardio - ${widget.workout.cardio.duration} min',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.workout.cardio.description,
                          style: TextStyle(
                            color: Colors.red.shade700,
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
            if (widget.workout.workoutSessions.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF121714),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF94E0B2),
                  tabs: widget.workout.workoutSessions
                      .asMap()
                      .entries
                      .map((entry) {
                    return Tab(text: 'Session ${entry.key + 1}');
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: widget.workout.workoutSessions.map((session) {
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
                  onPressed: () {
                    // TODO: Navigate to workout execution screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout execution coming soon!'),
                        backgroundColor: Color(0xFF94E0B2),
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
                    'Start Workout',
                    style: TextStyle(
                      color: Color(0xFF121714),
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
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentCard(
      String title, String duration, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title == 'Warmup' ? Icons.whatshot : Icons.self_improvement,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
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
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: color.withOpacity(0.8),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: session.exercises.length,
      itemBuilder: (context, index) {
        final exercise = session.exercises[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Exercise number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF94E0B2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF121714),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildExerciseDetail(
                            Icons.fitness_center, '${exercise.sets} sets'),
                        const SizedBox(width: 16),
                        _buildExerciseDetail(Icons.repeat, exercise.reps),
                        const SizedBox(width: 16),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
