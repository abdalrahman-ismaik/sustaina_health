import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/firestore_nutrition_service.dart';
import '../../data/models/nutrition_models.dart';

class FirestoreNutritionDebugPanel extends ConsumerStatefulWidget {
  const FirestoreNutritionDebugPanel({super.key});

  @override
  ConsumerState<FirestoreNutritionDebugPanel> createState() =>
      _FirestoreNutritionDebugPanelState();
}

class _FirestoreNutritionDebugPanelState
    extends ConsumerState<FirestoreNutritionDebugPanel> {
  bool _isChecking = false;
  String _connectionStatus = 'Not checked';
  String _authStatus = 'Not checked';
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
  }

  Future<void> _checkFirestoreConnection() async {
    if (mounted) {
      setState(() {
        _isChecking = true;
        _connectionStatus = 'Checking...';
        _authStatus = 'Checking...';
      });
    }

    try {
      // Check authentication
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _authStatus = '❌ Not authenticated';
            _connectionStatus = '⚠️ Cannot test without authentication';
            _isChecking = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _authStatus = '✅ Authenticated as ${user.email}';
        });
      }

      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('nutrition_data')
          .doc('connection_test')
          .set(<String, dynamic>{'timestamp': DateTime.now().toIso8601String()});

      if (mounted) {
        setState(() {
          _connectionStatus = '✅ Firestore connected successfully';
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectionStatus = '❌ Connection failed: ${e.toString()}';
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _testFirestoreNutritionOperations() async {
    if (mounted) {
      setState(() {
        _isChecking = true;
        _testResult = 'Testing Firestore nutrition operations...';
      });
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _testResult = '❌ User not authenticated';
            _isChecking = false;
          });
        }
        return;
      }

      final FirestoreNutritionService service = FirestoreNutritionService();
      final DateTime now = DateTime.now();

      // Create a test food log entry
      final FoodLogEntry testFoodLogEntry = FoodLogEntry(
        id: 'test_${now.millisecondsSinceEpoch}',
        userId: user.uid,
        foodName: 'Test Food Item',
        mealType: 'breakfast',
        servingSize: '1 cup',
        nutritionInfo: const NutritionInfo(
          calories: 250,
          carbohydrates: 30,
          protein: 15,
          fat: 8,
          fiber: 5,
          sugar: 10,
          sodium: 300,
        ),
        sustainabilityScore: 'B+',
        notes: 'Test food log entry created by debug panel',
        loggedAt: now,
      );

      if (mounted) {
        setState(() {
          _testResult = 'Creating test food log entry...';
        });
      }

      // Save food log entry
      await service.saveFoodLogEntry(testFoodLogEntry);

      if (mounted) {
        setState(() {
          _testResult = 'Testing retrieval...';
        });
      }

      // Retrieve the food log entry
      final retrievedEntry = await service.getFoodLogEntry(testFoodLogEntry.id);
      
      if (retrievedEntry == null) {
        if (mounted) {
          setState(() {
            _testResult = '❌ Failed to retrieve food log entry';
            _isChecking = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _testResult = 'Creating test meal plan...';
        });
      }

      // Create a test meal plan
      final MealPlanResponse testMealPlan = MealPlanResponse(
        dailyCaloriesRange: const DailyCaloriesRange(min: 1800, max: 2200),
        macronutrientsRange: const MacronutrientsRange(
          protein: MacronutrientRange(min: 120, max: 150),
          carbohydrates: MacronutrientRange(min: 200, max: 250),
          fat: MacronutrientRange(min: 60, max: 80),
        ),
        dailyMealPlans: <DailyMealPlan>[
          DailyMealPlan(
            day: 1,
            date: '2024-01-01',
            breakfast: const MealOption(
              description: 'Test Breakfast',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Oats', quantity: '1 cup', calories: 150),
                Ingredient(ingredient: 'Banana', quantity: '1 medium', calories: 100),
              ],
              totalCalories: 250,
              recipe: 'Mix oats with sliced banana',
            ),
            lunch: const MealOption(
              description: 'Test Lunch',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Chicken breast', quantity: '150g', calories: 200),
                Ingredient(ingredient: 'Rice', quantity: '1 cup', calories: 150),
              ],
              totalCalories: 350,
              recipe: 'Grill chicken and serve with rice',
            ),
            dinner: const MealOption(
              description: 'Test Dinner',
              ingredients: <Ingredient>[
                Ingredient(ingredient: 'Salmon', quantity: '120g', calories: 250),
                Ingredient(ingredient: 'Vegetables', quantity: '1 cup', calories: 50),
              ],
              totalCalories: 300,
              recipe: 'Bake salmon with steamed vegetables',
            ),
            snacks: const <MealOption>[],
            totalDailyCalories: 900,
            dailyMacros: const DailyMacros(
              protein: 60,
              carbohydrates: 80,
              fat: 25,
            ),
          ),
        ],
        totalDays: 1,
      );

      // Save meal plan
      final String planId = 'test_plan_${now.millisecondsSinceEpoch}';
      await service.saveMealPlan(planId, testMealPlan);

      if (mounted) {
        setState(() {
          _testResult = 'Testing meal plan retrieval...';
        });
      }

      // Retrieve meal plan
      final MealPlanResponse? retrievedPlan = await service.getMealPlan(planId);
      
      if (retrievedPlan == null) {
        if (mounted) {
          setState(() {
            _testResult = '❌ Failed to retrieve meal plan';
            _isChecking = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _testResult = 'Creating nutrition summary...';
        });
      }

      // Create daily nutrition summary
      final DailyNutritionSummary testSummary = DailyNutritionSummary(
        date: DateTime.now(),
        totalNutrition: const NutritionInfo(
          calories: 1800,
          carbohydrates: 200,
          protein: 120,
          fat: 70,
          fiber: 25,
          sugar: 50,
          sodium: 2000,
        ),
        targetCalories: 2000,
        meals: <FoodLogEntry>[testFoodLogEntry],
        sustainabilityScore: 85.0,
      );

      // Save nutrition summary
      await service.saveDailyNutritionSummary(testSummary);

      // Test nutrition stats
      final stats = await service.getNutritionStats(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _testResult = '''✅ All nutrition operations successful!

📊 Test Results:
• Food log entry: ${retrievedEntry.foodName}
• Calories: ${retrievedEntry.nutritionInfo.calories}
• Meal type: ${retrievedEntry.mealType}

📋 Meal plan saved:
• Plan ID: $planId
• Total days: ${testMealPlan.totalDays}
• Daily calories range: ${testMealPlan.dailyCaloriesRange.min}-${testMealPlan.dailyCaloriesRange.max}

📈 Nutrition stats:
• Total entries: ${stats['totalEntries']}
• Total calories: ${stats['totalCalories']}
• Average per day: ${stats['averageCaloriesPerDay']?.toStringAsFixed(1)}

💾 Data successfully stored in Firestore!''';
          _isChecking = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = '❌ Test failed: ${e.toString()}';
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _createTestNutritionData() async {
    if (mounted) {
      setState(() {
        _isChecking = true;
        _testResult = 'Creating comprehensive test nutrition data...';
      });
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _testResult = '❌ User not authenticated';
            _isChecking = false;
          });
        }
        return;
      }

      final FirestoreNutritionService service = FirestoreNutritionService();
      final DateTime now = DateTime.now();

      // Create multiple food log entries for different meals
      final List<FoodLogEntry> testEntries = <FoodLogEntry>[
        FoodLogEntry(
          id: 'breakfast_${now.millisecondsSinceEpoch}',
          userId: user.uid,
          foodName: 'Avocado Toast',
          mealType: 'breakfast',
          servingSize: '2 slices',
          nutritionInfo: const NutritionInfo(
            calories: 320,
            carbohydrates: 35,
            protein: 12,
            fat: 18,
            fiber: 8,
            sugar: 6,
            sodium: 480,
          ),
          sustainabilityScore: 'A',
          notes: 'Whole grain bread with fresh avocado',
          loggedAt: now.subtract(const Duration(hours: 2)),
        ),
        FoodLogEntry(
          id: 'lunch_${now.millisecondsSinceEpoch}',
          userId: user.uid,
          foodName: 'Quinoa Salad Bowl',
          mealType: 'lunch',
          servingSize: '1 large bowl',
          nutritionInfo: const NutritionInfo(
            calories: 450,
            carbohydrates: 65,
            protein: 18,
            fat: 12,
            fiber: 12,
            sugar: 8,
            sodium: 380,
          ),
          sustainabilityScore: 'A+',
          notes: 'Mixed vegetables with quinoa and tahini dressing',
          loggedAt: now.subtract(const Duration(hours: 4)),
        ),
        FoodLogEntry(
          id: 'snack_${now.millisecondsSinceEpoch}',
          userId: user.uid,
          foodName: 'Greek Yogurt with Berries',
          mealType: 'snack',
          servingSize: '1 cup',
          nutritionInfo: const NutritionInfo(
            calories: 180,
            carbohydrates: 22,
            protein: 15,
            fat: 4,
            fiber: 3,
            sugar: 18,
            sodium: 85,
          ),
          sustainabilityScore: 'B+',
          notes: 'Plain Greek yogurt with mixed berries',
          loggedAt: now.subtract(const Duration(hours: 1)),
        ),
      ];

      // Batch save food log entries
      await service.batchSaveFoodLogEntries(testEntries);

      if (mounted) {
        setState(() {
          _testResult = '''✅ Test nutrition data created successfully!

📱 Created ${testEntries.length} food log entries:
${testEntries.map((FoodLogEntry entry) => '• ${entry.foodName} (${entry.mealType})').join('\n')}

💾 All data saved to Firestore nutrition_data collection!

🔍 You can now:
• View entries in the nutrition tracking screen
• Check Firestore console for the data
• Test real-time sync across devices''';
          _isChecking = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = '❌ Failed to create test data: ${e.toString()}';
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.dining,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Firestore Nutrition Debug Panel',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Connection Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Connection Status:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_authStatus),
                  Text(_connectionStatus),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkFirestoreConnection,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh Connection'),
                ),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _testFirestoreNutritionOperations,
                  icon: const Icon(Icons.science),
                  label: const Text('Test Operations'),
                ),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _createTestNutritionData,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Create Test Data'),
                ),
              ],
            ),
            
            if (_testResult.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult.startsWith('❌') 
                      ? theme.colorScheme.errorContainer.withOpacity(0.3)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testResult,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
