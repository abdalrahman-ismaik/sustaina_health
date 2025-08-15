import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AIMealPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AIMealPlanGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIMealPlanGeneratorScreen> createState() =>
      _AIMealPlanGeneratorScreenState();
}

class _AIMealPlanGeneratorScreenState
    extends ConsumerState<AIMealPlanGeneratorScreen> {
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
    'Gaining muscles',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Meal Plan Generator',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: mealPlanState.when(
        data: (mealPlan) => mealPlan != null
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
                onGoalChanged: (goal) => setState(() => _selectedGoal = goal),
                onActivityLevelChanged: (level) =>
                    setState(() => _selectedActivityLevel = level),
                onSexChanged: (sex) => setState(() => _selectedSex = sex),
                onDurationDaysChanged: (days) =>
                    setState(() => _durationDays = days),
                onGenerateMealPlan: _generateMealPlan,
              ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF94e0b2)),
              SizedBox(height: 16),
              Text('Generating your personalized meal plan...',
                  style: TextStyle(fontSize: 16, color: Color(0xFF688273))),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          children: [
            // API Status
            apiHealthState.when(
              data: (isHealthy) => Container(
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
                  children: [
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
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 12),

            // Weight, Height, Age in a row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight (kg)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121714),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Color(0xFF121714),
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
                    children: [
                      const Text(
                        'Height (cm)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121714),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Color(0xFF121714),
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
                    children: [
                      const Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121714),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Color(0xFF121714),
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
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSex,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: sexOptions.map((sex) {
                return DropdownMenuItem(
                  value: sex,
                  child: Text(sex.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
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
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: durationDays,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'days',
              ),
              items: [7, 14, 21, 28].map((days) {
                return DropdownMenuItem(
                  value: days,
                  child: Text('$days day${days > 1 ? 's' : ''}'),
                );
              }).toList(),
              onChanged: (value) {
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
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: goalOptions
                  .map((goal) => FilterChip(
                        label: Text(goal.replaceAll('_', ' ').toUpperCase()),
                        selected: selectedGoal == goal,
                        onSelected: (selected) => onGoalChanged(goal),
                        backgroundColor: const Color(0xFFf1f4f2),
                        selectedColor: const Color(0xFF94e0b2),
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
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: activityLevels
                  .map((level) => FilterChip(
                        label: Text(level.replaceAll('_', ' ').toUpperCase()),
                        selected: selectedActivityLevel == level,
                        onSelected: (selected) => onActivityLevelChanged(level),
                        backgroundColor: const Color(0xFFf1f4f2),
                        selectedColor: const Color(0xFF94e0b2),
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
                  backgroundColor: const Color(0xFF94e0b2),
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
                    color: Color(0xFF121714),
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

class _MealPlanResult extends ConsumerWidget {
  final MealPlanResponse mealPlan;
  final VoidCallback onEdit;

  const _MealPlanResult({
    required this.mealPlan,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF94e0b2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF94e0b2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mealPlan.dailyMealPlans.length}-Day Meal Plan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (mealPlan.dailyMealPlans.isNotEmpty)
                    Text(
                      'Daily Average: ${mealPlan.dailyMealPlans.first.totalDailyCalories} calories',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  if (mealPlan.dailyMealPlans.isNotEmpty)
                    Text(
                      'Daily Macros: ${mealPlan.dailyMealPlans.first.dailyMacros.protein}g protein | '
                      '${mealPlan.dailyMealPlans.first.dailyMacros.carbohydrates}g carbs | '
                      '${mealPlan.dailyMealPlans.first.dailyMacros.fat}g fat',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF688273)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Meal Plans
            ..._buildDailyMealSections(),

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf1f4f2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Generate New Plan',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveMealPlan(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Save Plan',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDailyMealSections() {
    return mealPlan.dailyMealPlans.map((dailyPlan) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Text(
                'Day ${dailyPlan.day}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              Text(
                '${dailyPlan.totalDailyCalories} calories total',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF688273),
                ),
              ),
              const SizedBox(height: 12),

              // Meals for this day
              _buildMealCard('Breakfast', dailyPlan.breakfast),
              const SizedBox(height: 8),
              _buildMealCard('Lunch', dailyPlan.lunch),
              const SizedBox(height: 8),
              _buildMealCard('Dinner', dailyPlan.dinner),
              const SizedBox(height: 8),

              // Snacks
              if (dailyPlan.snacks.isNotEmpty) ...[
                const Text(
                  'Snacks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF121714),
                  ),
                ),
                const SizedBox(height: 4),
                ...dailyPlan.snacks.map((snack) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildMealCard('Snack', snack),
                    )),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMealCard(String mealType, MealOption meal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f4f2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF688273),
                ),
              ),
              Text(
                '${meal.calories} cal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF688273),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            meal.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF121714),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Calories: ${meal.calories} | ${meal.ingredients.length} ingredients',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF688273),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingredients: ${meal.ingredients.map((ingredient) => '${ingredient.ingredient} (${ingredient.quantity})').join(", ")}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF688273),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMealPlan(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;

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

    final name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Save Meal Plan',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Give your meal plan a name:',
                style: TextStyle(color: Color(0xFF121714)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(
                  color: Color(0xFF121714),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., "7-Day Healthy Eating Plan"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF94e0b2)),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
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
                final planName = nameController.text.trim();
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
                backgroundColor: const Color(0xFF94e0b2),
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
        final planId = await ref
            .read(savedMealPlansProvider.notifier)
            .saveMealPlan(this.mealPlan, name);

        if (planId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meal plan "$name" saved successfully!'),
              backgroundColor: const Color(0xFF94e0b2),
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
}
