import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;
  const WorkoutDetailScreen({Key? key, required this.workoutId}) : super(key: key);

  static const Map<String, dynamic> workout = {
    'duration': '45 minutes',
    'difficulty': 'Intermediate',
    'equipment': 'Dumbbells, Mat',
    'sustainability': 'High',
    'exercises': [
      {
        'name': 'Squats',
        'reps': '12 reps',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB7p6Mh09U0nl53ZCOhAqCa48xGd2jR8kwkLWzpdH_kRVUEoPNYDUFUByBKYwKdJz1XfhO9zG5FgEaQm54FzOoRp5zPZ_cM6tiqEpUAhNqd6J2YV9x_goancs8KnJlyTE194tZgEb94B7bNmKaXZlmMzLTe0-AEr66hYmIfN48biAV7qSR0l6mcKKEVNKL5X0TNZPu0DtXXhrofvKOfX5bCbsHQusHCNf_rfcNNwuTiwuO5Xj4V-HTi-x6YVV2T-geE_pN-jjEnAvek',
      },
      {
        'name': 'Push-ups',
        'reps': '10 reps',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjMHF9UZSoWlau4d8IRihZn-uakJ_7OOqtsVINiyGJASdBXb0tdvin6THu0TsH-4no5ZLU07_eNgWOAJcbGYkKCQimUgYJr6RADLwnPLi9pVhfXk9IaT8FSNG376zApglcmTkm2iiL-3pZr4GaA93hpuValskXOyA5J0izhp5rEOI24WMs4UdPk-kPT2nnZURjI4lKZV4IFao9p__BpMTXXGrFPUvr6BL_rUbb8xCsrdesu8iHz0Ar2biNRTKRyEr7qOTVB9VIbAyK',
      },
      {
        'name': 'Lunges',
        'reps': '15 reps',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAnBheBcYJWQ9SAxuBa8kaWCpDypi9kF9oi039LL_B8P4bxPRL-PPvi13lgX3wHtKHNDe4kTCAbNxLxypiANNF5WktfqLzRGyuXpsMCDH-lUJZeT-L0I7IhIsIMvbGwsz5O4zZc58jPdlnQdkyXzz1Rs6OZs_cggNntSz-b55lswgAIivARcISbDSnAOV_y7rD0j9mIb5HdqyEVbh9ZT2Mi0jI_fVT0zvUKf9WzWEpwybjKAcZg3MyZxW15wqgSdc9pwWt-Fvzflvfy',
      },
      {
        'name': 'Plank',
        'reps': '20 reps',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAPkDGFzbpnHxQxhj7z0revRDk_QZ03t6Jo39n5D-LoQns1Vzm5wkJy8tiIBtYiVPe8IpFbX4BgiS2psEqR19gtRROSJ59scoMcR8QYjZUDOF2RYvRJTxTjDDMCuxSB48EGowNBDLt8wt83EEi4H15TYTTi8KxZHUpAEzG8UfxAcEehCe3NrWG2dJe22EnJPp-eo0ZDjz7KALfEJ3yxda1cpvrjNrFGU9CaV_eW-lKhtvX8Lbgq9OpdRdkIu9zXE_rKdTDx8jIRV2DF',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout Overview',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Banner image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 218,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAJrIxVR1HOFi4MnTLXNB3q9Y5jm6nkIXOgEaF_hZ8OnRDTcvU0NBtPRqhVFy5gvdOY3APIrQ3t1ICwdoKJ58UqZLkFHgYUktAKMRCaR-sqTiuUzl3t7AGtV06QFyVEuf-ZFYLw8BqxgA3Qv7yoej0WjC_9xunQuQA2MYT-mO6Jvu1tRSME7ocG1XlokkKMR4Vg7b0GxoqoxBboXVrQn7v09bZhaj6uhBvMSWU9M-htqmQg6-04oB73u7UE2lPkTICjswLjI-sI4C_C'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Workout Details',
              style: TextStyle(
                color: Color(0xFF121714),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.015,
              ),
            ),
          ),
          _DetailRow(label: 'Total Duration', value: workout['duration']),
          _DetailRow(label: 'Difficulty', value: workout['difficulty']),
          _DetailRow(label: 'Equipment', value: workout['equipment']),
          _DetailRow(label: 'Sustainability Score', value: workout['sustainability']),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Exercises',
              style: TextStyle(
                color: Color(0xFF121714),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.015,
              ),
            ),
          ),
          ...List<Widget>.from((workout['exercises'] as List).map((ex) => _ExerciseCard(
                name: ex['name'],
                reps: ex['reps'],
                imageUrl: ex['image'],
              ))),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      foregroundColor: const Color(0xFF121714),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.015,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Start Workout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F4F2),
                      foregroundColor: const Color(0xFF121714),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.015,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Save Workout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _WorkoutNavBar(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF688273), fontSize: 14)),
          Text(value, style: const TextStyle(color: Color(0xFF121714), fontSize: 14)),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String name;
  final String reps;
  final String imageUrl;
  const _ExerciseCard({required this.name, required this.reps, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Color(0xFF121714), fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 2),
                Text(reps, style: const TextStyle(color: Color(0xFF688273), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF121714),
      unselectedItemColor: const Color(0xFF688273),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Exercise'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
        BottomNavigationBarItem(icon: Icon(Icons.nightlight_round), label: 'Sleep'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (int index) {
        // TODO: Implement navigation
      },
    );
  }
}