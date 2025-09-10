import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/data/services/hybrid_profile_service.dart';
import '../../data/services/profile_setup_service.dart';
import '../../../../app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoSetupScreen extends ConsumerStatefulWidget {
  final bool isFirstTime; // true for new users, false for updates

  const PersonalInfoSetupScreen({
    Key? key,
    this.isFirstTime = true,
  }) : super(key: key);

  @override
  ConsumerState<PersonalInfoSetupScreen> createState() =>
      _PersonalInfoSetupScreenState();
}

class _PersonalInfoSetupScreenState
    extends ConsumerState<PersonalInfoSetupScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Profile data controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Profile selections
  String? _selectedSex;
  String? _selectedFitnessGoal;
  int? _selectedWorkoutsPerWeek;
  String? _selectedActivityLevel;
  List<String> _selectedEquipment = <String>[];

  // Health goals
  List<HealthGoal> _healthGoals = <HealthGoal>[];

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLoadingExistingData = true;
  bool _hasPrefilledData = false;

  final HybridProfileService _profileService = HybridProfileService();

  // Predefined options
  final List<String> _sexOptions = <String>['Male', 'Female', 'Other'];
  final List<String> _fitnessGoals = <String>[
    'Weight Loss',
    'Muscle Gain',
    'Maintain Weight',
    'Improve Endurance',
    'General Fitness',
    'Strength Building',
    'Flexibility',
  ];
  final List<int> _workoutFrequencies = <int>[1, 2, 3, 4, 5, 6, 7];
  final List<String> _activityLevels = <String>[
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];
  final List<String> _equipmentOptions = <String>[
    'Dumbbells',
    'Barbells',
    'Resistance Bands',
    'Pull-up Bar',
    'Yoga Mat',
    'Kettlebells',
    'Medicine Ball',
    'Treadmill',
    'Exercise Bike',
    'No Equipment',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfileData();
  }

  Future<void> _loadExistingProfileData() async {
    setState(() {
      _isLoadingExistingData = true;
    });

    try {
      final UserProfile? existingProfile =
          await _profileService.getUserProfile();

      if (existingProfile != null) {
        setState(() {
          _hasPrefilledData = true;

          // Pre-fill basic info
          if (existingProfile.weight != null) {
            _weightController.text = existingProfile.weight!.toString();
          }
          if (existingProfile.height != null) {
            _heightController.text = existingProfile.height!.toString();
          }
          if (existingProfile.age != null) {
            _ageController.text = existingProfile.age!.toString();
          }

          // Pre-fill selections
          _selectedSex = existingProfile.sex;
          _selectedFitnessGoal = existingProfile.fitnessGoal;
          _selectedWorkoutsPerWeek = existingProfile.workoutsPerWeek;
          _selectedActivityLevel = existingProfile.activityLevel;

          // Pre-fill equipment
          if (existingProfile.availableEquipment.isNotEmpty) {
            _selectedEquipment =
                List<String>.from(existingProfile.availableEquipment);
          }

          // Health goals are managed separately in this UI - keeping empty list for now
          // since they are not part of the UserProfile model
        });
      }
    } catch (e) {
      print('Error loading existing profile data: $e');
      // Continue with empty form if there's an error
    } finally {
      setState(() {
        _isLoadingExistingData = false;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: cs.onSurface),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
        title: Text(
          widget.isFirstTime ? 'Complete Your Profile' : 'Update Profile',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingExistingData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile data...',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Info banner for pre-filled data
                  if (_hasPrefilledData)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: cs.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            color: cs.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your existing profile data has been loaded. You can update it below.',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 4,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) =>
                          setState(() => _currentPage = page),
                      children: <Widget>[
                        _buildBasicInfoPage(cs),
                        _buildFitnessPreferencesPage(cs),
                        _buildEquipmentPage(cs),
                        _buildHealthGoalsPage(cs),
                      ],
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: const Text('Previous'),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleNextOrFinish,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(_currentPage == 3
                                    ? 'Complete Setup'
                                    : 'Next'),
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

  Widget _buildBasicInfoPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Age
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Age',
              suffixText: 'years',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty)
                return 'Please enter your age';
              final int? age = int.tryParse(value);
              if (age == null || age < 13 || age > 120)
                return 'Please enter a valid age';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Sex
          DropdownButtonFormField<String>(
            value: _selectedSex,
            decoration: InputDecoration(
              labelText: 'Sex',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _sexOptions
                .map((String sex) => DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    ))
                .toList(),
            onChanged: (String? value) => setState(() => _selectedSex = value),
            validator: (String? value) =>
                value == null ? 'Please select your sex' : null,
          ),
          const SizedBox(height: 16),

          // Weight
          TextFormField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty)
                return 'Please enter your weight';
              final double? weight = double.tryParse(value);
              if (weight == null || weight < 20 || weight > 300)
                return 'Please enter a valid weight';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Height
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Height',
              suffixText: 'cm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty)
                return 'Please enter your height';
              final int? height = int.tryParse(value);
              if (height == null || height < 100 || height > 250)
                return 'Please enter a valid height';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessPreferencesPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Fitness Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your fitness goals and activity level',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Fitness Goal
          Text(
            'Primary Fitness Goal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fitnessGoals
                .map((String goal) => FilterChip(
                      label: Text(goal),
                      selected: _selectedFitnessGoal == goal,
                      onSelected: (bool selected) =>
                          setState(() => _selectedFitnessGoal = goal),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Activity Level
          Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ..._activityLevels.map((String level) => RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _selectedActivityLevel,
                onChanged: (String? value) =>
                    setState(() => _selectedActivityLevel = value),
              )),
          const SizedBox(height: 24),

          // Workouts per week
          Text(
            'How many times per week do you want to workout?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _workoutFrequencies
                .map((int freq) => FilterChip(
                      label: Text('$freq${freq == 1 ? ' day' : ' days'}'),
                      selected: _selectedWorkoutsPerWeek == freq,
                      onSelected: (bool selected) =>
                          setState(() => _selectedWorkoutsPerWeek = freq),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Available Equipment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the equipment you have access to',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentOptions
                .map((String equipment) => FilterChip(
                      label: Text(equipment),
                      selected: _selectedEquipment.contains(equipment),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedEquipment.add(equipment);
                          } else {
                            _selectedEquipment.remove(equipment);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthGoalsPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Health Goals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set specific health goals to track your progress',
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Health goals list
          ..._healthGoals
              .asMap()
              .entries
              .map((MapEntry<int, HealthGoal> entry) {
            final int index = entry.key;
            final HealthGoal goal = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          goal.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => _healthGoals.removeAt(index)),
                        ),
                      ],
                    ),
                    Text('Target: ${goal.target}'),
                    Text('Current: ${goal.current}'),
                  ],
                ),
              ),
            );
          }),

          // Add goal button
          OutlinedButton.icon(
            onPressed: _showAddGoalDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Health Goal'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final TextEditingController typeController = TextEditingController();
    final TextEditingController targetController = TextEditingController();
    final TextEditingController currentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Health Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Goal Type (e.g., Target Weight)',
              ),
            ),
            TextField(
              controller: targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Value',
              ),
            ),
            TextField(
              controller: currentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Current Value',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (typeController.text.isNotEmpty &&
                  targetController.text.isNotEmpty &&
                  currentController.text.isNotEmpty) {
                final HealthGoal goal = HealthGoal(
                  type: typeController.text,
                  target: double.parse(targetController.text),
                  current: double.parse(currentController.text),
                  deadline: DateTime.now()
                      .add(const Duration(days: 90)), // 3 months default
                );
                setState(() => _healthGoals.add(goal));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextOrFinish() async {
    if (_currentPage < 3) {
      // Validate current page
      if (_currentPage == 0 && !_validateBasicInfo()) return;
      if (_currentPage == 1 && !_validateFitnessPreferences()) return;

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final step - save all data
      await _saveProfileData();
    }
  }

  bool _validateBasicInfo() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateFitnessPreferences() {
    if (_selectedFitnessGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fitness goal')),
      );
      return false;
    }
    if (_selectedActivityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your activity level')),
      );
      return false;
    }
    if (_selectedWorkoutsPerWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select workout frequency')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveProfileData() async {
    setState(() => _isLoading = true);

    try {
      // Create UserProfile object
      final UserProfile profile = UserProfile(
        weight: double.parse(_weightController.text),
        height: int.parse(_heightController.text),
        age: int.parse(_ageController.text),
        sex: _selectedSex!,
        fitnessGoal: _selectedFitnessGoal!,
        workoutsPerWeek: _selectedWorkoutsPerWeek!,
        availableEquipment: _selectedEquipment,
        activityLevel: _selectedActivityLevel!,
      );

      // Save profile using hybrid service
      await _profileService.saveUserProfile(profile);

      // Save health goals to cloud storage
      for (final HealthGoal goal in _healthGoals) {
        try {
          await _profileService.saveHealthGoal(goal.toJson());
        } catch (e) {
          print('Failed to save health goal: ${goal.type}, error: $e');
        }
      }

      // Invalidate the profile setup provider to refresh the state
      ref.invalidate(profileSetupCompletedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to main app
        if (widget.isFirstTime) {
          // Navigate to home - the router will handle this based on updated profile state
          context.go(RouteNames.home);
        } else {
          // Just go back for profile updates
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Health Goal model class
class HealthGoal {
  final String type;
  final double target;
  final double current;
  final DateTime deadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HealthGoal({
    required this.type,
    required this.target,
    required this.current,
    required this.deadline,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'target': target,
      'current': current,
      'deadline': deadline.toIso8601String(),
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal(
      type: json['type'],
      target: json['target'].toDouble(),
      current: json['current'].toDouble(),
      deadline: DateTime.parse(json['deadline']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
