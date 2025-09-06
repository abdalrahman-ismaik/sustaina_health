import 'package:flutter/material.dart';
import '../features/nutrition/data/services/firestore_nutrition_service.dart';
import '../features/nutrition/data/models/nutrition_models.dart';

/// Debug panel for testing Firestore nutrition operations
class FirestoreNutritionDebugPanel extends StatefulWidget {
  const FirestoreNutritionDebugPanel({super.key});

  @override
  State<FirestoreNutritionDebugPanel> createState() => _FirestoreNutritionDebugPanelState();
}

class _FirestoreNutritionDebugPanelState extends State<FirestoreNutritionDebugPanel> {
  final FirestoreNutritionService _service = FirestoreNutritionService();
  String _status = 'Ready to test nutrition cloud storage';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Cloud Storage Debug'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nutrition Firestore Debug Panel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testCreateFoodLogEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Test Food Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testCreateMealPlan,
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Test Meal Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetFoodLog,
                  icon: const Icon(Icons.list),
                  label: const Text('Get Food Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testAnalytics,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Test Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCreateFoodLogEntry() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test food log entry...';
    });

    try {
      final FoodLogEntry testEntry = FoodLogEntry(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test_user_id',
        foodName: 'Test Apple',
        mealType: 'Snack',
        servingSize: '1 medium apple',
        nutritionInfo: const NutritionInfo(
          calories: 95,
          carbohydrates: 25,
          protein: 0,
          fat: 0,
          fiber: 4,
          sugar: 19,
          sodium: 2,
        ),
        loggedAt: DateTime.now(),
        sustainabilityScore: 'High',
      );

      final String firestoreId = await _service.saveFoodLogEntry(testEntry);
      
      setState(() {
        _status = '✅ Food log entry saved to Firestore!\n'
                 'Entry: ${testEntry.foodName}\n'
                 'Firestore ID: $firestoreId\n'
                 'Calories: ${testEntry.nutritionInfo.calories}\n'
                 'Meal Type: ${testEntry.mealType}\n\n'
                 'Check Firebase Console: users/{userId}/food_log_entries/$firestoreId';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to create food log entry: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateMealPlan() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test meal plan...';
    });

    try {
      final MealPlanResponse testMealPlan = MealPlanResponse(
        dailyCaloriesRange: const DailyCaloriesRange(min: 1800, max: 2200),
        macronutrientsRange: const MacronutrientsRange(
          protein: MacronutrientRange(min: 90, max: 140),
          carbohydrates: MacronutrientRange(min: 200, max: 300),
          fat: MacronutrientRange(min: 60, max: 90),
        ),
        dailyMealPlans: <DailyMealPlan>[
          DailyMealPlan(
            day: 1,
            date: DateTime.now().toString().split(' ')[0],
            breakfast: const MealOption(
              description: 'Oatmeal with Banana',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Oats', quantity: '1 cup', calories: 150),
                Ingredient(ingredient: 'Banana', quantity: '1 medium', calories: 105),
                Ingredient(ingredient: 'Almond milk', quantity: '1 cup', calories: 95),
              ],
              totalCalories: 350,
              recipe: 'Mix oats with almond milk, add sliced banana',
            ),
            lunch: const MealOption(
              description: 'Grilled Chicken Salad',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Chicken breast', quantity: '150g', calories: 231),
                Ingredient(ingredient: 'Mixed greens', quantity: '2 cups', calories: 20),
                Ingredient(ingredient: 'Olive oil', quantity: '1 tbsp', calories: 119),
              ],
              totalCalories: 370,
              recipe: 'Grill chicken, serve over mixed greens with olive oil',
            ),
            dinner: const MealOption(
              description: 'Quinoa Bowl',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Quinoa', quantity: '1 cup cooked', calories: 222),
                Ingredient(ingredient: 'Black beans', quantity: '1/2 cup', calories: 114),
                Ingredient(ingredient: 'Avocado', quantity: '1/2 medium', calories: 160),
              ],
              totalCalories: 496,
              recipe: 'Combine cooked quinoa, black beans, and sliced avocado',
            ),
            snacks: const <MealOption>[],
            totalDailyCalories: 1216,
            dailyMacros: const DailyMacros(
              protein: 85,
              carbohydrates: 120,
              fat: 45,
            ),
          ),
        ],
        totalDays: 1,
      );

      final String planId = 'test_plan_${DateTime.now().millisecondsSinceEpoch}';
      await _service.saveMealPlan(planId, testMealPlan);
      
      setState(() {
        _status = '✅ Meal plan saved to Firestore!\n'
                 'Plan ID: $planId\n'
                 'Daily meal plans: ${testMealPlan.dailyMealPlans.length}\n'
                 'Total days: ${testMealPlan.totalDays}\n'
                 'Daily calories range: ${testMealPlan.dailyCaloriesRange.min}-${testMealPlan.dailyCaloriesRange.max}\n\n'
                 'Check Firebase Console: users/{userId}/meal_plans/$planId';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to create meal plan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetFoodLog() async {
    setState(() {
      _isLoading = true;
      _status = 'Retrieving food log entries...';
    });

    try {
      final List<FoodLogEntry> entries = await _service.getFoodLogEntriesForDate(DateTime.now());
      
      setState(() {
        _status = '✅ Retrieved ${entries.length} food log entries for today\n\n';
        if (entries.isEmpty) {
          _status += 'No entries found for today. Create a test entry first!';
        } else {
          _status += 'Entries found:\n';
          for (int i = 0; i < entries.length && i < 5; i++) {
            final FoodLogEntry entry = entries[i];
            _status += '${i + 1}. ${entry.foodName} (${entry.mealType}) - ${entry.nutritionInfo.calories} cal\n';
          }
          if (entries.length > 5) {
            _status += '... and ${entries.length - 5} more';
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to get food log entries: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAnalytics() async {
    setState(() {
      _isLoading = true;
      _status = 'Generating nutrition analytics...';
    });

    try {
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(const Duration(days: 7));
      
      final Map<String, dynamic> analytics = await _service.getNutritionAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      
      setState(() {
        _status = '✅ Nutrition Analytics (Last 7 Days)\n\n'
                 'Total Entries: ${analytics['totalEntries']}\n'
                 'Total Calories: ${analytics['totalCalories']}\n'
                 'Total Protein: ${analytics['totalProtein']}g\n'
                 'Total Carbs: ${analytics['totalCarbohydrates']}g\n'
                 'Total Fat: ${analytics['totalFat']}g\n'
                 'Avg Calories/Day: ${analytics['averageCaloriesPerDay'].toStringAsFixed(1)}\n\n'
                 'Meal Distribution:\n';
        
        final Map<String, dynamic> mealTypes = analytics['mealTypeDistribution'] as Map<String, dynamic>;
        mealTypes.forEach((String type, count) {
          _status += '$type: $count entries\n';
        });
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to generate analytics: $e';
        _isLoading = false;
      });
    }
  }
}
