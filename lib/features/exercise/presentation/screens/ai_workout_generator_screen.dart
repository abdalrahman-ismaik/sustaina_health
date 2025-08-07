import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'workout_detail_screen.dart';

class AIWorkoutGeneratorScreen extends ConsumerStatefulWidget {
  const AIWorkoutGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIWorkoutGeneratorScreen> createState() =>
      _AIWorkoutGeneratorScreenState();
}

class _AIWorkoutGeneratorScreenState
    extends ConsumerState<AIWorkoutGeneratorScreen> {
  // User profile fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedSex;
  String? _selectedGoal;
  int _workoutsPerWeek = 3;
  final List<String> _selectedEquipment = [];

  // Equipment options
  static const List<String> equipmentOptions = [
    'dumbbells',
    'barbell',
    'resistance bands',
    'kettlebells',
    'pull-up bar',
    'bench',
    'cable machine',
    'treadmill',
    'stationary bike',
    'yoga mat',
    'foam roller',
    'medicine ball',
  ];

  static const List<String> goalOptions = [
    'bulking',
    'cutting',
    'weight_loss',
    'general_fitness',
    'strength',
    'endurance',
  ];

  static const List<String> sexOptions = [
    'male',
    'female',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current user profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile.weight != null) {
        _weightController.text = userProfile.weight.toString();
      }
      if (userProfile.height != null) {
        _heightController.text = userProfile.height.toString();
      }
      if (userProfile.age != null) {
        _ageController.text = userProfile.age.toString();
      }
      if (userProfile.sex != null) {
        _selectedSex = userProfile.apiSex;
      }
      if (userProfile.fitnessGoal != null) {
        _selectedGoal = userProfile.apiGoal;
      }
      if (userProfile.workoutsPerWeek != null) {
        _workoutsPerWeek = userProfile.workoutsPerWeek!;
      }
      _selectedEquipment.addAll(userProfile.availableEquipment);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _generateWorkout() {
    // Validate inputs
    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedSex == null ||
        _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update user profile
    final userProfile = UserProfile(
      weight: double.tryParse(_weightController.text),
      height: int.tryParse(_heightController.text),
      age: int.tryParse(_ageController.text),
      sex: _selectedSex,
      fitnessGoal: _selectedGoal,
      workoutsPerWeek: _workoutsPerWeek,
      availableEquipment: _selectedEquipment,
    );

    ref.read(userProfileProvider.notifier).updateProfile(userProfile);
    ref.read(workoutGenerationProvider.notifier).generateWorkout(userProfile);
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutGenerationProvider);
    final apiHealthState = ref.watch(apiHealthProvider);

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
                    child: Padding(
                      padding: EdgeInsets.only(right: 48.0),
                      child: Text(
                        'AI Workout Generator',
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

            // API Status Indicator
            apiHealthState.when(
              data: (isHealthy) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHealthy ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.error,
                      color: isHealthy ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHealthy
                          ? 'API Connected'
                          : 'API Unavailable - Please start the API server',
                      style: TextStyle(
                        color: isHealthy
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: 'Age',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedSex,
                          label: 'Sex',
                          items: sexOptions,
                          onChanged: (value) =>
                              setState(() => _selectedSex = value),
                        ),
                      ),
                    ],
                  ),

                  // Fitness Goals Section
                  _buildSectionTitle('Fitness Goal'),
                  _buildDropdown(
                    value: _selectedGoal,
                    label: 'Select your goal',
                    items: goalOptions,
                    onChanged: (value) => setState(() => _selectedGoal = value),
                  ),

                  // Workouts per week
                  _buildSectionTitle('Workouts per Week'),
                  _buildWorkoutsPerWeekSlider(),

                  // Equipment Section
                  _buildSectionTitle('Available Equipment'),
                  _buildEquipmentSelector(),

                  const SizedBox(height: 24),

                  // Generate Button
                  workoutState.when(
                    data: (workout) => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _generateWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF94E0B2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Generate New Workout',
                              style: TextStyle(
                                color: Color(0xFF121714),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (workout != null) ...[
                          const SizedBox(height: 16),
                          _buildWorkoutPreview(workout),
                        ],
                      ],
                    ),
                    loading: () => const SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF94E0B2),
                        ),
                      ),
                    ),
                    error: (error, _) => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _generateWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF94E0B2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Generate Workout',
                              style: TextStyle(
                                color: Color(0xFF121714),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Error: ${error.toString()}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF121714),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF94E0B2)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF94E0B2)),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.replaceAll('_', ' ').toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildWorkoutsPerWeekSlider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workouts per week: $_workoutsPerWeek',
            style: const TextStyle(
              color: Color(0xFF121714),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Slider(
            value: _workoutsPerWeek.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: const Color(0xFF94E0B2),
            onChanged: (value) {
              setState(() {
                _workoutsPerWeek = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: equipmentOptions.map((equipment) {
          final isSelected = _selectedEquipment.contains(equipment);
          return FilterChip(
            label: Text(equipment.replaceAll('_', ' ')),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedEquipment.add(equipment);
                } else {
                  _selectedEquipment.remove(equipment);
                }
              });
            },
            selectedColor: const Color(0xFF94E0B2),
            checkmarkColor: const Color(0xFF121714),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF121714) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutPreview(WorkoutPlan workout) {
    return Container(
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
            'Workout Generated Successfully! 🎉',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${workout.sessionsPerWeek} sessions per week',
            style: const TextStyle(
              color: Color(0xFF121714),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${workout.workoutSessions.length} unique workout sessions',
            style: const TextStyle(
              color: Color(0xFF121714),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutDetailScreen(workout: workout),
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
                    'View Details',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSaveWorkoutDialog(context, workout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF94E0B2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Workout',
                    style: TextStyle(
                      color: Color(0xFF94E0B2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSaveWorkoutDialog(BuildContext context, WorkoutPlan workout) {
    final user = ref.read(authStateProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save workouts'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Save Workout Plan',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Give your workout plan a name:',
                style: TextStyle(color: Color(0xFF121714)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., "Full Body Strength Training"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF94E0B2)),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
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
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a workout name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final workoutId = await ref
                      .read(savedWorkoutPlansProvider.notifier)
                      .saveWorkout(name: name, workout: workout);

                  if (workoutId != null) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Workout "$name" saved successfully!'),
                        backgroundColor: const Color(0xFF94E0B2),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save workout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94E0B2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
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
}
