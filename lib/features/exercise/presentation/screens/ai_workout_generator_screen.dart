import 'package:flutter/material.dart';
import 'workout_detail_screen.dart';

class AIWorkoutGeneratorScreen extends StatefulWidget {
  const AIWorkoutGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<AIWorkoutGeneratorScreen> createState() => _AIWorkoutGeneratorScreenState();
}

class _AIWorkoutGeneratorScreenState extends State<AIWorkoutGeneratorScreen> {
  String? _selectedTime;
  String? _selectedEquipment;
  String? _selectedType;
  String? _selectedIntensity;
  String? _selectedLocation;
  bool _ecoFriendly = false;

  Map<String, dynamic>? _generatedWorkout;
  String? _errorMessage;

  void _generateWorkout() {
    setState(() {
      _errorMessage = null;
      if (_selectedTime == null ||
          _selectedEquipment == null ||
          _selectedType == null ||
          _selectedIntensity == null ||
          _selectedLocation == null) {
        _errorMessage = 'Please select all preferences.';
        _generatedWorkout = null;
        return;
      }
      // Mock workout generation logic
      _generatedWorkout = {
        'name': '${_selectedType ?? ''} Workout',
        'duration': _selectedTime,
        'intensity': _selectedIntensity,
        'equipment': _selectedEquipment,
        'location': _selectedLocation,
        'eco': _ecoFriendly ? 'Eco-friendly' : 'Standard',
        'exercises': [
          {'name': 'Squats', 'reps': '12 reps'},
          {'name': 'Push-ups', 'reps': '10 reps'},
          {'name': 'Lunges', 'reps': '15 reps'},
          {'name': 'Plank', 'reps': '1 min'},
        ],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF121714)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 48.0),
                      child: Text(
                        'Workout Preferences',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Available Time
            const _SectionTitle('Available Time'),
            _RadioGroup(
              options: ['15 minutes', '30 minutes', '45 minutes', '60+ minutes'],
              groupValue: _selectedTime,
              onChanged: (val) => setState(() => _selectedTime = val),
            ),
            // Equipment
            const _SectionTitle('Equipment Available'),
            _RadioGroup(
              options: ['None', 'Minimal', 'Full Gym'],
              groupValue: _selectedEquipment,
              onChanged: (val) => setState(() => _selectedEquipment = val),
            ),
            // Workout Type
            const _SectionTitle('Workout Type Preference'),
            _RadioGroup(
              options: ['Cardio', 'Strength', 'Yoga', 'Mixed'],
              groupValue: _selectedType,
              onChanged: (val) => setState(() => _selectedType = val),
            ),
            // Intensity
            const _SectionTitle('Intensity Level'),
            _RadioGroup(
              options: ['Low', 'Moderate', 'High'],
              groupValue: _selectedIntensity,
              onChanged: (val) => setState(() => _selectedIntensity = val),
            ),
            // Location
            const _SectionTitle('Location'),
            _RadioGroup(
              options: ['Home', 'Gym', 'Outdoor'],
              groupValue: _selectedLocation,
              onChanged: (val) => setState(() => _selectedLocation = val),
            ),
            // Eco-friendly toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Prioritize eco-friendly exercises',
                      style: TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Switch(
                    value: _ecoFriendly,
                    activeColor: const Color(0xFF94E0B2),
                    onChanged: (val) => setState(() => _ecoFriendly = val),
                  ),
                ],
              ),
            ),
            // Generate Workout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _generateWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94E0B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Generate Workout',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.015,
                    ),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            if (_generatedWorkout != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(workout: _generatedWorkout!),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFFF1F4F2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generatedWorkout!['name'],
                            style: const TextStyle(
                              color: Color(0xFF121714),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Duration: ${_generatedWorkout!['duration']}'),
                          Text('Intensity: ${_generatedWorkout!['intensity']}'),
                          Text('Equipment: ${_generatedWorkout!['equipment']}'),
                          Text('Location: ${_generatedWorkout!['location']}'),
                          Text('Type: ${_generatedWorkout!['eco']}'),
                          const SizedBox(height: 12),
                          const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...(_generatedWorkout!['exercises'] as List)
                              .map<Widget>((ex) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text('${ex['name']} - ${ex['reps']}'),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Previous AI Workouts
            const _SectionTitle('Previous AI Workouts'),
            _PreviousWorkoutItem(
              title: 'Yoga Flow',
              subtitle: '30 minutes, Moderate Intensity',
              onTap: () {},
            ),
            _PreviousWorkoutItem(
              title: 'Strength Training',
              subtitle: '45 minutes, High Intensity',
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF121714),
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: -0.015,
        ),
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  final List<String> options;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  const _RadioGroup({required this.options, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return ChoiceChip(
            label: Text(option, style: const TextStyle(color: Color(0xFF121714), fontWeight: FontWeight.w500)),
            selected: groupValue == option,
            selectedColor: const Color(0xFF94E0B2),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFDDE4E0)),
            ),
            onSelected: (_) => onChanged(option),
          );
        }).toList(),
      ),
    );
  }
}

class _PreviousWorkoutItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PreviousWorkoutItem({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF121714), fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF688273), fontSize: 14)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF121714)),
          ],
        ),
      ),
    );
  }
} 