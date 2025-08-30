import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghiraas/widgets/interactive_loading.dart';
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
  final List<String> _selectedEquipment = <String>[];

  // Equipment options
  static const List<String> equipmentOptions = <String>[
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

  static const List<String> goalOptions = <String>[
    'bulking',
    'cutting',
    'weight_loss',
    'general_fitness',
    'strength',
    'endurance',
  ];

  static const List<String> sexOptions = <String>[
    'Male',
    'Female',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final UserProfile userProfile = ref.read(userProfileProvider);
      bool loadedFromPrefs = false;
      if (userProfile.weight != null) {
        _weightController.text = userProfile.weight.toString();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? weight = prefs.getString('profile_weight');
        if (weight != null && weight.isNotEmpty) {
          _weightController.text = weight;
          loadedFromPrefs = true;
        }
      }
      if (userProfile.height != null) {
        _heightController.text = userProfile.height.toString();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? height = prefs.getString('profile_height');
        if (height != null && height.isNotEmpty) {
          _heightController.text = height;
          loadedFromPrefs = true;
        }
      }
      if (userProfile.age != null) {
        _ageController.text = userProfile.age.toString();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? age = prefs.getString('profile_age');
        if (age != null && age.isNotEmpty) {
          _ageController.text = age;
          loadedFromPrefs = true;
        }
      }
      if (userProfile.sex != null) {
        // Capitalize first letter for dropdown compatibility
        _selectedSex = userProfile.apiSex.isNotEmpty
            ? userProfile.apiSex[0].toUpperCase() +
                userProfile.apiSex.substring(1).toLowerCase()
            : null;
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? sex = prefs.getString('profile_sex');
        if (sex != null && sex.isNotEmpty) {
          _selectedSex = sex[0].toUpperCase() + sex.substring(1).toLowerCase();
          loadedFromPrefs = true;
        }
      }
      if (userProfile.fitnessGoal != null) {
        _selectedGoal = userProfile.apiGoal;
      }
      if (userProfile.workoutsPerWeek != null) {
        _workoutsPerWeek = userProfile.workoutsPerWeek!;
      }
      _selectedEquipment.clear();
      _selectedEquipment.addAll(userProfile.availableEquipment);
      if (mounted && loadedFromPrefs) setState(() {});
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
    final UserProfile userProfile = UserProfile(
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
    final AsyncValue<WorkoutPlan?> workoutState =
        ref.watch(workoutGenerationProvider);
    final AsyncValue<bool> apiHealthState = ref.watch(apiHealthProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: Text(
                        'AI Workout Generator',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurface,
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
              data: (bool isHealthy) => Container(
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
                  children: <Widget>[
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
                children: <Widget>[
                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),

                  Row(
                    children: <Widget>[
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
                    children: <Widget>[
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
                          onChanged: (String? value) =>
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
                    onChanged: (String? value) =>
                        setState(() => _selectedGoal = value),
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
                    data: (WorkoutPlan? workout) => Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _generateWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Generate New Workout',
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (workout != null) ...<Widget>[
                          const SizedBox(height: 16),
                          _buildWorkoutPreview(context, workout),
                        ],
                      ],
                    ),
                    loading: () => InteractiveLoading(
                      title: 'Generating your AI workout',
                      subtitle: 'We are composing a routine tailored to you…',
                      onCancel: () {
                        // Clear generation state
                        ref
                            .read(workoutGenerationProvider.notifier)
                            .clearWorkout();
                      },
                      color: cs.primary,
                    ),
                    error: (Object error, _) => Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _generateWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Generate Workout',
                              style: TextStyle(
                                color: cs.onPrimary,
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
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.error),
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.error,
                                  color: cs.error, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Error: ${error.toString()}',
                                style: TextStyle(
                                  color: cs.onErrorContainer,
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
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
            borderSide: BorderSide(color: cs.primary),
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
    final cs = Theme.of(context).colorScheme;
    // If value is not in items, set value to null to avoid DropdownButton error
    final String? dropdownValue =
        (value != null && items.contains(value)) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: dropdownValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cs.primary),
          ),
        ),
        items: items.map((String item) {
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Workouts per week: $_workoutsPerWeek',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Slider(
            value: _workoutsPerWeek.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: cs.primary,
            onChanged: (double value) {
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: equipmentOptions.map((String equipment) {
          final bool isSelected = _selectedEquipment.contains(equipment);
          return FilterChip(
            label: Text(equipment.replaceAll('_', ' ')),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _selectedEquipment.add(equipment);
                } else {
                  _selectedEquipment.remove(equipment);
                }
              });
            },
            selectedColor: cs.primary,
            checkmarkColor: cs.onPrimary,
            labelStyle: TextStyle(
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutPreview(BuildContext context, WorkoutPlan workout) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Workout Generated Successfully! 🎉',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${workout.sessionsPerWeek} sessions per week',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${workout.workoutSessions.length} unique workout sessions',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            WorkoutDetailScreen(workout: workout),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: cs.onPrimary,
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
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Workout',
                    style: TextStyle(
                      color: cs.primary,
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
    final UserEntity? user = ref.read(authStateProvider).value;
    final cs = Theme.of(context).colorScheme;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to save workouts'),
          backgroundColor: cs.errorContainer,
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cs.surfaceContainerHigh,
          title: Text(
            'Save Workout Plan',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Give your workout plan a name:',
                style: TextStyle(color: cs.onSurface),
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
                    borderSide: BorderSide(color: cs.primary),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a workout name'),
                      backgroundColor: cs.error,
                    ),
                  );
                  return;
                }

                try {
                  final String? workoutId = await ref
                      .read(savedWorkoutPlansProvider.notifier)
                      .saveWorkout(name: name, workout: workout);

                  if (workoutId != null) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Workout "$name" saved successfully!'),
                        backgroundColor: cs.primary,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save workout: $e'),
                      backgroundColor: cs.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: cs.onPrimary,
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
