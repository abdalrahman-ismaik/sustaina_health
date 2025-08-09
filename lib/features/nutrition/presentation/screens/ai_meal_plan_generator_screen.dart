import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';

class AIMealPlanGeneratorScreen extends ConsumerStatefulWidget {
  const AIMealPlanGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIMealPlanGeneratorScreen> createState() =>
      _AIMealPlanGeneratorScreenState();
}

class _AIMealPlanGeneratorScreenState extends ConsumerState<AIMealPlanGeneratorScreen> {
  final TextEditingController _caloriesController = TextEditingController(text: '2000');
  final List<String> _selectedDietaryRestrictions = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedCuisines = [];
  
  String _selectedGoal = 'maintenance';
  String _selectedActivityLevel = 'moderately_active';
  int _mealsPerDay = 3;

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
    _caloriesController.dispose();
    super.dispose();
  }

  void _generateMealPlan() {
    final calories = int.tryParse(_caloriesController.text) ?? 2000;
    
    final request = MealPlanRequest(
      goal: _selectedGoal,
      targetCalories: calories,
      dietaryRestrictions: _selectedDietaryRestrictions,
      allergies: _selectedAllergies,
      mealsPerDay: _mealsPerDay,
      activityLevel: _selectedActivityLevel,
      preferredCuisines: _selectedCuisines,
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
                caloriesController: _caloriesController,
                selectedGoal: _selectedGoal,
                selectedActivityLevel: _selectedActivityLevel,
                mealsPerDay: _mealsPerDay,
                selectedDietaryRestrictions: _selectedDietaryRestrictions,
                selectedAllergies: _selectedAllergies,
                selectedCuisines: _selectedCuisines,
                goalOptions: goalOptions,
                activityLevels: activityLevels,
                dietaryRestrictionOptions: dietaryRestrictionOptions,
                allergyOptions: allergyOptions,
                cuisineOptions: cuisineOptions,
                onGoalChanged: (goal) => setState(() => _selectedGoal = goal),
                onActivityLevelChanged: (level) => setState(() => _selectedActivityLevel = level),
                onMealsPerDayChanged: (meals) => setState(() => _mealsPerDay = meals),
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
  final TextEditingController caloriesController;
  final String selectedGoal;
  final String selectedActivityLevel;
  final int mealsPerDay;
  final List<String> selectedDietaryRestrictions;
  final List<String> selectedAllergies;
  final List<String> selectedCuisines;
  final List<String> goalOptions;
  final List<String> activityLevels;
  final List<String> dietaryRestrictionOptions;
  final List<String> allergyOptions;
  final List<String> cuisineOptions;
  final Function(String) onGoalChanged;
  final Function(String) onActivityLevelChanged;
  final Function(int) onMealsPerDayChanged;
  final VoidCallback onGenerateMealPlan;

  const _MealPlanForm({
    required this.apiHealthState,
    required this.caloriesController,
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.mealsPerDay,
    required this.selectedDietaryRestrictions,
    required this.selectedAllergies,
    required this.selectedCuisines,
    required this.goalOptions,
    required this.activityLevels,
    required this.dietaryRestrictionOptions,
    required this.allergyOptions,
    required this.cuisineOptions,
    required this.onGoalChanged,
    required this.onActivityLevelChanged,
    required this.onMealsPerDayChanged,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHealthy ? Colors.green.shade100 : Colors.red.shade100,
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
                        color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // Target Calories
            const Text(
              'Target Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '2000',
                suffixText: 'kcal/day',
              ),
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
              children: goalOptions.map((goal) => FilterChip(
                label: Text(goal.replaceAll('_', ' ').toUpperCase()),
                selected: selectedGoal == goal,
                onSelected: (selected) => onGoalChanged(goal),
                backgroundColor: const Color(0xFFf1f4f2),
                selectedColor: const Color(0xFF94e0b2),
              )).toList(),
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
              children: activityLevels.map((level) => FilterChip(
                label: Text(level.replaceAll('_', ' ').toUpperCase()),
                selected: selectedActivityLevel == level,
                onSelected: (selected) => onActivityLevelChanged(level),
                backgroundColor: const Color(0xFFf1f4f2),
                selectedColor: const Color(0xFF94e0b2),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Meals Per Day
            const Text(
              'Meals Per Day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: mealsPerDay.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              label: '$mealsPerDay meals',
              onChanged: (value) => onMealsPerDayChanged(value.round()),
              activeColor: const Color(0xFF94e0b2),
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
                  const Text(
                    'Daily Nutrition Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Calories: ${mealPlan.totalDailyCalories} kcal',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Macros: ${mealPlan.dailyNutritionSummary.macroString}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF688273)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal Options
            ..._buildMealSections(),

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

  List<Widget> _buildMealSections() {
    final sections = [
      ('Breakfast', mealPlan.breakfast),
      ('Lunch', mealPlan.lunch),
      ('Dinner', mealPlan.dinner),
      ('Snacks', mealPlan.snacks),
    ];

    return sections.where((section) => section.$2.isNotEmpty).map((section) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.$1,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121714),
            ),
          ),
          const SizedBox(height: 8),
          ...section.$2.map((meal) => _MealOptionCard(meal: meal)),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  void _saveMealPlan(BuildContext context, WidgetRef ref) async {
    // Show dialog to enter name
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Meal Plan'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter meal plan name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      try {
        await ref.read(savedMealPlansProvider.notifier).saveMealPlan(mealPlan, name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal plan "$name" saved successfully!'),
            backgroundColor: const Color(0xFF94e0b2),
          ),
        );
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

class _MealOptionCard extends StatelessWidget {
  final MealOption meal;

  const _MealOptionCard({required this.meal, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f4f2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121714),
                  ),
                ),
              ),
              Text(
                '${meal.totalCalories} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF688273),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ingredients: ${meal.ingredients.map((i) => i.ingredient).join(', ')}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF688273),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meal.recipe,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF688273),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
