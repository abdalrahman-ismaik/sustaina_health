import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> workout;
  const WorkoutDetailScreen({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final exercises = workout['exercises'] as List? ?? [];
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: const Color(0xFFF1F4F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['name'] ?? 'Workout',
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Duration: ${workout['duration']}'),
                    Text('Intensity: ${workout['intensity']}'),
                    Text('Equipment: ${workout['equipment']}'),
                    Text('Location: ${workout['location']}'),
                    Text('Type: ${workout['eco']}'),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Exercises',
              style: TextStyle(
                color: Color(0xFF121714),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ...exercises.map((ex) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      ex['name'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      ex['reps'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF688273),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }
} 