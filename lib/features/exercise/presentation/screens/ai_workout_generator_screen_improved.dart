import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_providers.dart';
import '../../data/models/workout_models.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'workout_detail_screen.dart';
import '../../../../app/theme/app_theme.dart';

class AIWorkoutGeneratorScreen extends ConsumerStatefulWidget {
  const AIWorkoutGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIWorkoutGeneratorScreen> createState() =>
      _AIWorkoutGeneratorScreenState();
}

class _AIWorkoutGeneratorScreenState
    extends ConsumerState<AIWorkoutGeneratorScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedSex;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  int _workoutsPerWeek = 3;
  final List<String> _selectedEquipment = [];

  // Equipment options grouped by category
  static const Map<String, List<String>> equipmentCategories = {
    'Free Weights': [
      'dumbbells',
      'barbell',
      'kettlebells',
      'medicine ball',
    ],
    'Resistance Training': [
      'resistance bands',
      'pull-up bar',
      'cable machine',
    ],
    'Cardio Equipment': [
      'treadmill',
      'stationary bike',
      'rowing machine',
    ],
    'Support Equipment': [
      'bench',
      'yoga mat',
      'foam roller',
    ],
  };

  static const List<String> goalOptions = [
    'bulking',
    'cutting', 
    'weight_loss',
    'general_fitness',
    'strength',
    'endurance',
  ];

  static const List<String> activityLevels = [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'extremely_active',
  ];

  static const List<String> sexOptions = [
    'male',
    'female',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
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
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _generateWorkout() {
    if (!_formKey.currentState!.validate()) return;

    // Update user profile
    final userProfile = UserProfile(
      weight: double.tryParse(_weightController.text),
      height: int.tryParse(_heightController.text),
      age: int.tryParse(_ageController.text),
      sex: _selectedSex,
      fitnessGoal: _selectedGoal,
      workoutsPerWeek: _workoutsPerWeek,
      availableEquipment: _selectedEquipment,
      activityLevel: _selectedActivityLevel,
    );

    ref.read(userProfileProvider.notifier).updateProfile(userProfile);
    ref.read(workoutGenerationProvider.notifier).generateWorkout(userProfile);
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutGenerationProvider);
    final apiHealthState = ref.watch(apiHealthProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('AI Workout Generator'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                'Back',
                style: TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: AppTheme.backgroundGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),

            // API Status Indicator
            apiHealthState.when(
              data: (isHealthy) => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHealthy 
                      ? AppTheme.successGreen.withOpacity(0.1) 
                      : AppTheme.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHealthy ? AppTheme.successGreen : AppTheme.warningOrange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.fitness_center : Icons.offline_bolt,
                      color: isHealthy ? AppTheme.successGreen : AppTheme.warningOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isHealthy
                            ? 'AI Workout Generator Online - Personalized workouts available'
                            : 'AI Services Offline - Sample workouts will be generated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isHealthy ? AppTheme.successGreen : AppTheme.warningOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // Form content
            Expanded(
              child: workoutState.when(
                data: (workout) => workout != null
                    ? _WorkoutResult(workout: workout)
                    : _FormContent(
                        pageController: _pageController,
                        currentStep: _currentStep,
                        weightController: _weightController,
                        heightController: _heightController,
                        ageController: _ageController,
                        selectedSex: _selectedSex,
                        selectedGoal: _selectedGoal,
                        selectedActivityLevel: _selectedActivityLevel,
                        workoutsPerWeek: _workoutsPerWeek,
                        selectedEquipment: _selectedEquipment,
                        onSexChanged: (sex) => setState(() => _selectedSex = sex),
                        onGoalChanged: (goal) => setState(() => _selectedGoal = goal),
                        onActivityLevelChanged: (level) => setState(() => _selectedActivityLevel = level),
                        onWorkoutsPerWeekChanged: (workouts) => setState(() => _workoutsPerWeek = workouts),
                      ),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                      SizedBox(height: 16),
                      Text(
                        'Generating your personalized workout...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Creating the perfect routine for your goals',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to Generate Workout',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(workoutGenerationProvider.notifier).clearWorkout();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom action bar
            if (_currentStep < _totalSteps - 1)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      child: const Text('Continue'),
                    ),
                  ),
                ),
              )
            else if (workoutState.value == null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateWorkout,
                      child: const Text('Generate My Workout'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final PageController pageController;
  final int currentStep;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final String? selectedSex;
  final String? selectedGoal;
  final String? selectedActivityLevel;
  final int workoutsPerWeek;
  final List<String> selectedEquipment;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onActivityLevelChanged;
  final ValueChanged<int> onWorkoutsPerWeekChanged;

  const _FormContent({
    required this.pageController,
    required this.currentStep,
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.selectedSex,
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.workoutsPerWeek,
    required this.selectedEquipment,
    required this.onSexChanged,
    required this.onGoalChanged,
    required this.onActivityLevelChanged,
    required this.onWorkoutsPerWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _PersonalInfoStep(
          weightController: weightController,
          heightController: heightController,
          ageController: ageController,
          selectedSex: selectedSex,
          onSexChanged: onSexChanged,
        ),
        _GoalsStep(
          selectedGoal: selectedGoal,
          selectedActivityLevel: selectedActivityLevel,
          onGoalChanged: onGoalChanged,
          onActivityLevelChanged: onActivityLevelChanged,
        ),
        _WorkoutPreferencesStep(
          workoutsPerWeek: workoutsPerWeek,
          onWorkoutsPerWeekChanged: onWorkoutsPerWeekChanged,
        ),
        _EquipmentStep(
          selectedEquipment: selectedEquipment,
        ),
      ],
    );
  }
}

class _PersonalInfoStep extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final String? selectedSex;
  final ValueChanged<String> onSexChanged;

  const _PersonalInfoStep({
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.selectedSex,
    required this.onSexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself to create a personalized workout plan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'e.g., 70',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0 || weight > 300) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: 'e.g., 170',
                    prefixIcon: Icon(Icons.height),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height <= 0 || height > 250) {
                      return 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: 'e.g., 25',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 16 || age > 100) {
                      return 'Age must be between 16-100';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSex,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: _AIWorkoutGeneratorScreenState.sexOptions.map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Text(_formatSexName(sex)),
                    );
                  }).toList(),
                  onChanged: (value) => onSexChanged(value!),
                  validator: (value) => value == null ? 'Please select your sex' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSexName(String sex) {
    return sex[0].toUpperCase() + sex.substring(1);
  }
}

class _GoalsStep extends StatelessWidget {
  final String? selectedGoal;
  final String? selectedActivityLevel;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onActivityLevelChanged;

  const _GoalsStep({
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.onGoalChanged,
    required this.onActivityLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitness Goals & Activity',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What are your fitness goals and current activity level?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Fitness Goal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._AIWorkoutGeneratorScreenState.goalOptions.map((goal) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _SelectionCard(
              title: _formatGoalName(goal),
              subtitle: _getGoalDescription(goal),
              isSelected: selectedGoal == goal,
              onTap: () => onGoalChanged(goal),
            ),
          )),
          
          const SizedBox(height: 24),
          
          Text(
            'Activity Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._AIWorkoutGeneratorScreenState.activityLevels.map((level) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _SelectionCard(
              title: _formatActivityName(level),
              subtitle: _getActivityDescription(level),
              isSelected: selectedActivityLevel == level,
              onTap: () => onActivityLevelChanged(level),
            ),
          )),
        ],
      ),
    );
  }

  String _formatGoalName(String goal) {
    return goal.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
  
  String _formatActivityName(String activity) {
    return activity.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'bulking': return 'Gain muscle mass and size';
      case 'cutting': return 'Reduce body fat while maintaining muscle';
      case 'weight_loss': return 'Lose weight and improve health';
      case 'general_fitness': return 'Improve overall fitness and health';
      case 'strength': return 'Build maximum strength and power';
      case 'endurance': return 'Improve cardiovascular endurance';
      default: return '';
    }
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'sedentary': return 'Little to no exercise';
      case 'lightly_active': return 'Light exercise 1-3 days/week';
      case 'moderately_active': return 'Moderate exercise 3-5 days/week';
      case 'very_active': return 'Heavy exercise 6-7 days/week';
      case 'extremely_active': return 'Very heavy exercise, physical job';
      default: return '';
    }
  }
}

class _WorkoutPreferencesStep extends StatelessWidget {
  final int workoutsPerWeek;
  final ValueChanged<int> onWorkoutsPerWeekChanged;

  const _WorkoutPreferencesStep({
    required this.workoutsPerWeek,
    required this.onWorkoutsPerWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Preferences',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How often do you want to work out per week?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textTertiary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          '$workoutsPerWeek',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          workoutsPerWeek == 1 ? 'day per week' : 'days per week',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Slider(
                  value: workoutsPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (value) => onWorkoutsPerWeekChanged(value.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 day',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '7 days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getWorkoutRecommendation(workoutsPerWeek),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Workout benefits
          _WorkoutBenefits(),
        ],
      ),
    );
  }

  String _getWorkoutRecommendation(int days) {
    switch (days) {
      case 1:
      case 2:
        return 'Great for beginners or busy schedules. Focus on full-body workouts.';
      case 3:
      case 4:
        return 'Ideal for most people. Allows for balanced training and recovery.';
      case 5:
      case 6:
        return 'For dedicated fitness enthusiasts. More volume and muscle targeting.';
      case 7:
        return 'For advanced athletes. Includes active recovery sessions.';
      default:
        return '';
    }
  }
}

class _WorkoutBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'icon': Icons.favorite,
        'title': 'Heart Health',
        'description': 'Strengthen your cardiovascular system',
      },
      {
        'icon': Icons.psychology,
        'title': 'Mental Wellbeing',
        'description': 'Reduce stress and improve mood',
      },
      {
        'icon': Icons.battery_charging_full,
        'title': 'Energy Levels',
        'description': 'Boost daily energy and stamina',
      },
      {
        'icon': Icons.nights_stay,
        'title': 'Better Sleep',
        'description': 'Improve sleep quality and duration',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Benefits',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...benefits.map((benefit) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.textTertiary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: AppTheme.accentGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      benefit['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  final List<String> selectedEquipment;

  const _EquipmentStep({
    required this.selectedEquipment,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Equipment',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the equipment you have access to (optional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          ..._AIWorkoutGeneratorScreenState.equipmentCategories.entries.map(
            (category) => Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: _EquipmentCategory(
                title: category.key,
                equipment: category.value,
                selectedEquipment: selectedEquipment,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.secondaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.secondaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Don\'t worry if you don\'t have equipment! We can create bodyweight workouts that are just as effective.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCategory extends StatefulWidget {
  final String title;
  final List<String> equipment;
  final List<String> selectedEquipment;

  const _EquipmentCategory({
    required this.title,
    required this.equipment,
    required this.selectedEquipment,
  });

  @override
  State<_EquipmentCategory> createState() => _EquipmentCategoryState();
}

class _EquipmentCategoryState extends State<_EquipmentCategory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.equipment.map((equipment) {
            final isSelected = widget.selectedEquipment.contains(equipment);
            return FilterChip(
              label: Text(_formatEquipmentName(equipment)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    widget.selectedEquipment.add(equipment);
                  } else {
                    widget.selectedEquipment.remove(equipment);
                  }
                });
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatEquipmentName(String equipment) {
    return equipment.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutResult extends StatelessWidget {
  final WorkoutPlan workout;

  const _WorkoutResult({required this.workout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.successGreen, AppTheme.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Workout Generated!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${workout.sessionsPerWeek} sessions per week',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Workout overview
          Text(
            'Workout Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Sessions',
                  value: '${workout.workoutSessions.length}',
                  subtitle: 'unique workouts',
                  icon: Icons.fitness_center,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Frequency',
                  value: '${workout.sessionsPerWeek}x',
                  subtitle: 'per week',
                  icon: Icons.calendar_today,
                  color: AppTheme.secondaryBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Warm-up',
                  value: '${workout.warmup.duration}',
                  subtitle: 'minutes',
                  icon: Icons.play_circle_outline,
                  color: AppTheme.warningOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Cool-down',
                  value: '${workout.cooldown.duration}',
                  subtitle: 'minutes',
                  icon: Icons.pause_circle_outline,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Workout sessions preview
          Text(
            'Workout Sessions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ...workout.workoutSessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textTertiary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Session ${index + 1}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${session.exercises.length} exercises',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...session.exercises.take(3).map((exercise) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${exercise.sets} sets',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (session.exercises.length > 3) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ ${session.exercises.length - 3} more exercises',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSaveWorkoutDialog(context, workout),
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save Workout'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(workout: workout),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSaveWorkoutDialog(BuildContext context, WorkoutPlan workout) {
    // TODO: Implement save workout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save workout functionality coming soon!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
