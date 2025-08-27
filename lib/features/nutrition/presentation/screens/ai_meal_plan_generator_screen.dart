import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';
import '../widgets/day_plan_card.dart';

class AIMealPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AIMealPlanGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIMealPlanGeneratorScreen> createState() =>
      _AIMealPlanGeneratorScreenState();
}

class _AIMealPlanGeneratorScreenState
    extends ConsumerState<AIMealPlanGeneratorScreen> {
  @override
  void initState() {
    super.initState();
    _loadPersonalInfoFromPrefs();
  }

  Future<void> _loadPersonalInfoFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightController.text = prefs.getString('profile_weight') ?? '';
      _heightController.text = prefs.getString('profile_height') ?? '';
      _ageController.text = prefs.getString('profile_age') ?? '';
      final String? sex = prefs.getString('profile_sex');
      if (sex != null && sex.isNotEmpty) {
        _selectedSex = sex;
      }
    });
  }

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final List<String> _selectedDietaryRestrictions = <String>[];
  final List<String> _selectedAllergies = <String>[];
  final List<String> _selectedCuisines = <String>[];

  String _selectedGoal = 'maintenance';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedSex = 'Male';
  int _durationDays = 7;

  static const List<String> goalOptions = <String>[
    'weight_loss',
    'muscle_gain',
    'maintenance',
    'cutting',
    'bulking',
    'Gaining muscles',
  ];

  static const List<String> activityLevels = <String>[
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
  ];

  static const List<String> sexOptions = <String>[
    'Male',
    'Female',
  ];

  static const List<String> dietaryRestrictionOptions = <String>[
    'vegetarian',
    'vegan',
    'gluten_free',
    'dairy_free',
    'keto',
    'paleo',
    'low_carb',
    'low_fat',
  ];

  static const List<String> allergyOptions = <String>[
    'nuts',
    'shellfish',
    'eggs',
    'soy',
    'wheat',
    'fish',
    'milk',
    'sesame',
  ];

  static const List<String> cuisineOptions = <String>[
    'mediterranean',
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
    super.dispose();
  }

  void _generateMealPlan() {
    final MealPlanRequest request = MealPlanRequest(
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
    final AsyncValue<MealPlanResponse?> mealPlanState =
        ref.watch(mealPlanGenerationProvider);
    final AsyncValue<bool> apiHealthState =
        ref.watch(nutritionApiHealthProvider);

    return Scaffold(
      backgroundColor: SleepColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: SleepColors.surfaceGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SleepColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Meal Plan Generator',
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: mealPlanState.when(
        data: (MealPlanResponse? mealPlan) => mealPlan != null
            ? _MealPlanResult(
                mealPlan: mealPlan,
                onEdit: () {
                  ref.read(mealPlanGenerationProvider.notifier).clearMealPlan();
                },
              )
            : _MealPlanForm(
                apiHealthState: apiHealthState,
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
                onGoalChanged: (String goal) =>
                    setState(() => _selectedGoal = goal),
                onActivityLevelChanged: (String level) =>
                    setState(() => _selectedActivityLevel = level),
                onSexChanged: (String sex) =>
                    setState(() => _selectedSex = sex),
                onDurationDaysChanged: (int days) =>
                    setState(() => _durationDays = days),
                onDietaryRestrictionAdded: (String restriction) => setState(() {
                  if (!_selectedDietaryRestrictions.contains(restriction)) {
                    _selectedDietaryRestrictions.add(restriction);
                  }
                }),
                onDietaryRestrictionRemoved: (String restriction) =>
                    setState(() {
                  _selectedDietaryRestrictions.remove(restriction);
                }),
                onAllergyAdded: (String allergy) => setState(() {
                  if (!_selectedAllergies.contains(allergy)) {
                    _selectedAllergies.add(allergy);
                  }
                }),
                onAllergyRemoved: (String allergy) => setState(() {
                  _selectedAllergies.remove(allergy);
                }),
                onGenerateMealPlan: _generateMealPlan,
              ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(color: SleepColors.primaryGreen),
              SizedBox(height: 16),
              Text('Generating your personalized meal plan...',
                  style: TextStyle(
                      fontSize: 16, color: SleepColors.textSecondary)),
            ],
          ),
        ),
        error: (Object error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
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
    );
  }
}

class _MealPlanForm extends StatelessWidget {
  final AsyncValue<bool> apiHealthState;
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
  final Function(String) onGoalChanged;
  final Function(String) onActivityLevelChanged;
  final Function(String) onSexChanged;
  final Function(int) onDurationDaysChanged;
  final Function(String) onDietaryRestrictionAdded;
  final Function(String) onDietaryRestrictionRemoved;
  final Function(String) onAllergyAdded;
  final Function(String) onAllergyRemoved;
  final VoidCallback onGenerateMealPlan;

  const _MealPlanForm({
    required this.apiHealthState,
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
    required this.onDietaryRestrictionAdded,
    required this.onDietaryRestrictionRemoved,
    required this.onAllergyAdded,
    required this.onAllergyRemoved,
    required this.onGenerateMealPlan,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // API Status
            apiHealthState.when(
              data: (bool isHealthy) => Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                          ? 'AI Meal Planning Available'
                          : 'AI Service Unavailable - Using Mock Data',
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

            // Personal Information Section
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Weight, Height, Age in a row
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Weight (kg)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SleepColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: SleepColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '70',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Height (cm)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SleepColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: SleepColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '170',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SleepColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: SleepColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '25',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sex Selection
            const Text(
              'Sex',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSex,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: sexOptions.map((String sex) {
                return DropdownMenuItem(
                  value: sex,
                  child: Text(sex.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) onSexChanged(value);
              },
            ),
            const SizedBox(height: 16),

            // Duration
            const Text(
              'Meal Plan Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: durationDays,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'days',
              ),
              items: <int>[7, 14, 21, 28].map((int days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text('$days day${days > 1 ? 's' : ''}'),
                );
              }).toList(),
              onChanged: (int? value) {
                if (value != null) onDurationDaysChanged(value);
              },
            ),
            const SizedBox(height: 16),

            // Goal Selection
            const Text(
              'Nutrition Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: goalOptions
                  .map((String goal) => FilterChip(
                        label: Text(goal.replaceAll('_', ' ').toUpperCase()),
                        selected: selectedGoal == goal,
                        onSelected: (bool selected) => onGoalChanged(goal),
                        backgroundColor: SleepColors.surfaceGrey,
                        selectedColor: SleepColors.primaryGreen,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Activity Level
            const Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: activityLevels
                  .map((String level) => FilterChip(
                        label: Text(level.replaceAll('_', ' ').toUpperCase()),
                        selected: selectedActivityLevel == level,
                        onSelected: (bool selected) =>
                            onActivityLevelChanged(level),
                        backgroundColor: SleepColors.surfaceGrey,
                        selectedColor: SleepColors.primaryGreen,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Dietary Preferences
            const Text(
              'Dietary Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: dietaryRestrictionOptions
                  .map((String restriction) => FilterChip(
                        label: Text(
                            restriction.replaceAll('_', ' ').toUpperCase()),
                        selected:
                            selectedDietaryRestrictions.contains(restriction),
                        onSelected: (bool selected) {
                          if (selected) {
                            onDietaryRestrictionAdded(restriction);
                          } else {
                            onDietaryRestrictionRemoved(restriction);
                          }
                        },
                        backgroundColor: SleepColors.surfaceGrey,
                        selectedColor: SleepColors.primaryGreen,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Food Intolerance/Allergies
            const Text(
              'Food Allergies & Intolerances',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SleepColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allergyOptions
                  .map((String allergy) => FilterChip(
                        label: Text(allergy.replaceAll('_', ' ').toUpperCase()),
                        selected: selectedAllergies.contains(allergy),
                        onSelected: (bool selected) {
                          if (selected) {
                            onAllergyAdded(allergy);
                          } else {
                            onAllergyRemoved(allergy);
                          }
                        },
                        backgroundColor: SleepColors.surfaceGrey,
                        selectedColor:
                            SleepColors.errorRed, // Red color for allergies
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGenerateMealPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SleepColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Generate Meal Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SleepColors.textPrimary,
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

class _MealPlanResult extends ConsumerStatefulWidget {
  final MealPlanResponse mealPlan;
  final VoidCallback onEdit;

  const _MealPlanResult({
    required this.mealPlan,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<_MealPlanResult> createState() => _MealPlanResultState();
}

class _MealPlanResultState extends ConsumerState<_MealPlanResult> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealPlan = widget.mealPlan;
    final int totalDays = mealPlan.dailyMealPlans.length;

    return Scaffold(
      backgroundColor: SleepColors.backgroundGrey,
      appBar: AppBar(
        title: Text('$totalDays-Day Meal Plan'),
        backgroundColor: SleepColors.surfaceGrey,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: widget.onEdit,
            tooltip: 'Generate New Plan',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveMealPlan(context, ref, mealPlan),
            tooltip: 'Save Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          // PageView area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalDays,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final dailyPlan = mealPlan.dailyMealPlans[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double t = 0.0;
                    if (_pageController.position.haveDimensions) {
                      final double current = (_pageController.page ?? _currentPage.toDouble());
                      t = current - index.toDouble();
                    } else {
                      t = (_currentPage - index).toDouble();
                    }
                    final double scale = (1 - (t.abs() * 0.06)).clamp(0.92, 1.0);
                    final double opacity = (1 - (t.abs() * 0.3)).clamp(0.5, 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: DayPlanCard(dailyPlan: dailyPlan),
                );
              },
            ),
          ),

          // Indicator and actions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(totalDays, (int index) {
                final bool selected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? SleepColors.primaryGreen
                        : SleepColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  
}



void _saveMealPlan(
    BuildContext context, WidgetRef ref, MealPlanResponse mealPlan) async {
  final UserEntity? user = ref.read(authStateProvider).value;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in to save meal plans'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  final TextEditingController nameController = TextEditingController();

  final String? name = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Save Meal Plan',
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Give your meal plan a name:',
              style: TextStyle(color: SleepColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(
                color: SleepColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., "7-Day Healthy Eating Plan"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: SleepColors.primaryGreen),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final String planName = nameController.text.trim();
              if (planName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a meal plan name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(planName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SleepColors.primaryGreen,
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (name != null && name.isNotEmpty) {
    try {
      final String? planId = await ref
          .read(savedMealPlansProvider.notifier)
          .saveMealPlan(mealPlan, name);

      if (planId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal plan "$name" saved successfully!'),
            backgroundColor: SleepColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
