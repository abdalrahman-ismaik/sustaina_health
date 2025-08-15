import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';
import '../../../../app/theme/app_theme.dart';

class AIMealPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AIMealPlanGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIMealPlanGeneratorScreen> createState() =>
      _AIMealPlanGeneratorScreenState();
}

class _AIMealPlanGeneratorScreenState
    extends ConsumerState<AIMealPlanGeneratorScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  final List<String> _selectedDietaryRestrictions = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedCuisines = [];
  
  String _selectedGoal = 'maintenance';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedSex = 'Male';
  int _durationDays = 7;

  static const List<String> goalOptions = [
    'weight_loss',
    'muscle_gain', 
    'maintenance',
    'cutting',
    'bulking',
  ];

  static const List<String> activityLevels = [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
  ];

  static const List<String> sexOptions = [
    'Male',
    'Female',
  ];

  static const List<String> dietaryRestrictionOptions = [
    'vegetarian',
    'vegan', 
    'gluten_free',
    'dairy_free',
    'keto',
    'paleo',
    'low_carb',
    'low_fat',
  ];

  static const List<String> allergyOptions = [
    'nuts',
    'shellfish',
    'eggs',
    'soy',
    'wheat',
    'fish',
    'milk',
    'sesame',
  ];

  static const List<String> cuisineOptions = [
    'asian',
    'mexican',
    'italian',
    'indian',
    'american', 
    'middle_eastern',
    'latin_american',
  ];

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

  void _generateMealPlan() {
    if (!_formKey.currentState!.validate()) return;

    final request = MealPlanRequest(
      weight: double.tryParse(_weightController.text) ?? 70.0,
      height: double.tryParse(_heightController.text) ?? 170.0,
      age: int.tryParse(_ageController.text) ?? 25,
      sex: _selectedSex,
      goal: _selectedGoal,
      dietaryPreferences: _selectedDietaryRestrictions,
      foodIntolerance: _selectedAllergies,
      durationDays: _durationDays,
    );

    ref.read(mealPlanGenerationProvider.notifier).generateMealPlan(request);
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanState = ref.watch(mealPlanGenerationProvider);
    final apiHealthState = ref.watch(nutritionApiHealthProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('AI Meal Plan Generator'),
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
                  color: isHealthy ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHealthy ? AppTheme.successGreen : AppTheme.errorRed,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.error,
                      color: isHealthy ? AppTheme.successGreen : AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isHealthy
                            ? 'AI Services Online - Real-time meal planning available'
                            : 'AI Services Offline - Sample meal plans will be generated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isHealthy ? AppTheme.successGreen : AppTheme.errorRed,
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
              child: mealPlanState.when(
                data: (mealPlan) => mealPlan != null
                    ? _MealPlanResult(mealPlan: mealPlan)
                    : _FormContent(
                        pageController: _pageController,
                        currentStep: _currentStep,
                        weightController: _weightController,
                        heightController: _heightController,
                        ageController: _ageController,
                        selectedGoal: _selectedGoal,
                        selectedActivityLevel: _selectedActivityLevel,
                        selectedSex: _selectedSex,
                        durationDays: _durationDays,
                        selectedDietaryRestrictions: _selectedDietaryRestrictions,
                        selectedAllergies: _selectedAllergies,
                        selectedCuisines: _selectedCuisines,
                        goalOptions: goalOptions,
                        activityLevels: activityLevels,
                        sexOptions: sexOptions,
                        dietaryRestrictionOptions: dietaryRestrictionOptions,
                        allergyOptions: allergyOptions,
                        cuisineOptions: cuisineOptions,
                        onGoalChanged: (goal) => setState(() => _selectedGoal = goal),
                        onActivityLevelChanged: (level) => setState(() => _selectedActivityLevel = level),
                        onSexChanged: (sex) => setState(() => _selectedSex = sex),
                        onDurationDaysChanged: (days) => setState(() => _durationDays = days),
                      ),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                      SizedBox(height: 16),
                      Text(
                        'Generating your personalized meal plan...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This may take a few moments',
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
                          'Failed to Generate Meal Plan',
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
                            ref.read(mealPlanGenerationProvider.notifier).clearMealPlan();
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
            else if (mealPlanState.value == null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateMealPlan,
                      child: const Text('Generate My Meal Plan'),
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
  final String selectedGoal;
  final String selectedActivityLevel;
  final String selectedSex;
  final int durationDays;
  final List<String> selectedDietaryRestrictions;
  final List<String> selectedAllergies;
  final List<String> selectedCuisines;
  final List<String> goalOptions;
  final List<String> activityLevels;
  final List<String> sexOptions;
  final List<String> dietaryRestrictionOptions;
  final List<String> allergyOptions;
  final List<String> cuisineOptions;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onActivityLevelChanged;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<int> onDurationDaysChanged;

  const _FormContent({
    required this.pageController,
    required this.currentStep,
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.selectedSex,
    required this.durationDays,
    required this.selectedDietaryRestrictions,
    required this.selectedAllergies,
    required this.selectedCuisines,
    required this.goalOptions,
    required this.activityLevels,
    required this.sexOptions,
    required this.dietaryRestrictionOptions,
    required this.allergyOptions,
    required this.cuisineOptions,
    required this.onGoalChanged,
    required this.onActivityLevelChanged,
    required this.onSexChanged,
    required this.onDurationDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _BasicInfoStep(
          weightController: weightController,
          heightController: heightController,
          ageController: ageController,
          selectedSex: selectedSex,
          sexOptions: sexOptions,
          onSexChanged: onSexChanged,
        ),
        _GoalsActivityStep(
          selectedGoal: selectedGoal,
          selectedActivityLevel: selectedActivityLevel,
          goalOptions: goalOptions,
          activityLevels: activityLevels,
          onGoalChanged: onGoalChanged,
          onActivityLevelChanged: onActivityLevelChanged,
        ),
        _DietaryPreferencesStep(
          selectedDietaryRestrictions: selectedDietaryRestrictions,
          selectedAllergies: selectedAllergies,
          dietaryRestrictionOptions: dietaryRestrictionOptions,
          allergyOptions: allergyOptions,
        ),
        _DurationCuisineStep(
          durationDays: durationDays,
          selectedCuisines: selectedCuisines,
          cuisineOptions: cuisineOptions,
          onDurationDaysChanged: onDurationDaysChanged,
        ),
      ],
    );
  }
}

class _BasicInfoStep extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final String selectedSex;
  final List<String> sexOptions;
  final ValueChanged<String> onSexChanged;

  const _BasicInfoStep({
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.selectedSex,
    required this.sexOptions,
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
            'Basic Information',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself to create a personalized meal plan',
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
                    if (age == null || age < 18 || age > 100) {
                      return 'Age must be between 18-100';
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
                  items: sexOptions.map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (value) => onSexChanged(value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalsActivityStep extends StatelessWidget {
  final String selectedGoal;
  final String selectedActivityLevel;
  final List<String> goalOptions;
  final List<String> activityLevels;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onActivityLevelChanged;

  const _GoalsActivityStep({
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.goalOptions,
    required this.activityLevels,
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
            'Goals & Activity',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What are your fitness goals and activity level?',
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
          
          ...goalOptions.map((goal) => Container(
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
          
          ...activityLevels.map((level) => Container(
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
      case 'weight_loss': return 'Reduce body weight and fat';
      case 'muscle_gain': return 'Build lean muscle mass';
      case 'maintenance': return 'Maintain current weight';
      case 'cutting': return 'Reduce fat while preserving muscle';
      case 'bulking': return 'Gain weight and muscle mass';
      default: return '';
    }
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'sedentary': return 'Little to no exercise';
      case 'lightly_active': return 'Light exercise 1-3 days/week';
      case 'moderately_active': return 'Moderate exercise 3-5 days/week';
      case 'very_active': return 'Heavy exercise 6-7 days/week';
      default: return '';
    }
  }
}

class _DietaryPreferencesStep extends StatelessWidget {
  final List<String> selectedDietaryRestrictions;
  final List<String> selectedAllergies;
  final List<String> dietaryRestrictionOptions;
  final List<String> allergyOptions;

  const _DietaryPreferencesStep({
    required this.selectedDietaryRestrictions,
    required this.selectedAllergies,
    required this.dietaryRestrictionOptions,
    required this.allergyOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select any dietary restrictions or allergies you have',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Dietary Restrictions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dietaryRestrictionOptions.map((restriction) {
              final isSelected = selectedDietaryRestrictions.contains(restriction);
              return FilterChip(
                label: Text(_formatOptionName(restriction)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedDietaryRestrictions.add(restriction);
                  } else {
                    selectedDietaryRestrictions.remove(restriction);
                  }
                },
                selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryGreen,
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Food Allergies',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergyOptions.map((allergy) {
              final isSelected = selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(_formatOptionName(allergy)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedAllergies.add(allergy);
                  } else {
                    selectedAllergies.remove(allergy);
                  }
                },
                selectedColor: AppTheme.errorRed.withOpacity(0.1),
                checkmarkColor: AppTheme.errorRed,
                side: BorderSide(
                  color: isSelected ? AppTheme.errorRed : AppTheme.textTertiary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatOptionName(String option) {
    return option.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class _DurationCuisineStep extends StatelessWidget {
  final int durationDays;
  final List<String> selectedCuisines;
  final List<String> cuisineOptions;
  final ValueChanged<int> onDurationDaysChanged;

  const _DurationCuisineStep({
    required this.durationDays,
    required this.selectedCuisines,
    required this.cuisineOptions,
    required this.onDurationDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Duration & Cuisine',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How long should your meal plan be and what cuisines do you prefer?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Plan Duration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textTertiary),
            ),
            child: Column(
              children: [
                Text(
                  '$durationDays days',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: durationDays.toDouble(),
                  min: 3,
                  max: 14,
                  divisions: 11,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (value) => onDurationDaysChanged(value.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3 days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '14 days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Preferred Cuisines (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cuisineOptions.map((cuisine) {
              final isSelected = selectedCuisines.contains(cuisine);
              return FilterChip(
                label: Text(_formatCuisineName(cuisine)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedCuisines.add(cuisine);
                  } else {
                    selectedCuisines.remove(cuisine);
                  }
                },
                selectedColor: AppTheme.secondaryBlue.withOpacity(0.1),
                checkmarkColor: AppTheme.secondaryBlue,
                side: BorderSide(
                  color: isSelected ? AppTheme.secondaryBlue : AppTheme.textTertiary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatCuisineName(String cuisine) {
    return cuisine.replaceAll('_', ' ').split(' ').map((word) => 
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

class _MealPlanResult extends StatelessWidget {
  final MealPlanResponse mealPlan;

  const _MealPlanResult({required this.mealPlan});

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
                  'Meal Plan Generated!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${mealPlan.totalDays} days of personalized nutrition',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Daily overview
          Text(
            'Daily Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Calories',
                  value: '${mealPlan.dailyCaloriesRange.min}-${mealPlan.dailyCaloriesRange.max}',
                  subtitle: 'kcal/day',
                  icon: Icons.local_fire_department,
                  color: AppTheme.warningOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Protein',
                  value: '${mealPlan.macronutrientsRange.protein.min}-${mealPlan.macronutrientsRange.protein.max}',
                  subtitle: 'grams/day',
                  icon: Icons.fitness_center,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Carbs',
                  value: '${mealPlan.macronutrientsRange.carbohydrates.min}-${mealPlan.macronutrientsRange.carbohydrates.max}',
                  subtitle: 'grams/day',
                  icon: Icons.grain,
                  color: AppTheme.secondaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Fat',
                  value: '${mealPlan.macronutrientsRange.fat.min}-${mealPlan.macronutrientsRange.fat.max}',
                  subtitle: 'grams/day',
                  icon: Icons.opacity,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Meal plan preview
          Text(
            'Meal Plan Preview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          ...mealPlan.dailyMealPlans.take(3).map((dayPlan) =>
            Container(
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
                        'Day ${dayPlan.day}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dayPlan.totalDailyCalories} kcal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MealPreview(label: 'Breakfast', meal: dayPlan.breakfast),
                  _MealPreview(label: 'Lunch', meal: dayPlan.lunch),
                  _MealPreview(label: 'Dinner', meal: dayPlan.dinner),
                  if (dayPlan.snacks.isNotEmpty)
                    _MealPreview(label: 'Snacks', meal: dayPlan.snacks.first),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement save meal plan
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save Plan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement view full meal plan
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Full Plan'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
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

class _MealPreview extends StatelessWidget {
  final String label;
  final MealOption meal;

  const _MealPreview({
    required this.label,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              meal.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${meal.totalCalories} kcal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
