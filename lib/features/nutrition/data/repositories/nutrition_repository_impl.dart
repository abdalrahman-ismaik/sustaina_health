import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../models/nutrition_models.dart';
import '../services/nutrition_api_service.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionApiService _apiService;
  final Uuid _uuid = const Uuid();

  NutritionRepositoryImpl({required NutritionApiService apiService})
      : _apiService = apiService;

  @override
  Future<MealAnalysisResponse> analyzeMeal(File imageFile,
      {String? mealType}) async {
    return await _apiService.analyzeMeal(imageFile, mealType: mealType);
  }

  @override
  Future<MealPlanResponse> generateMealPlan(MealPlanRequest request) async {
    return await _apiService.generateMealPlan(request);
  }

  @override
  Future<bool> checkApiAvailability() async {
    return await _apiService.checkApiHealth();
  }

  @override
  Future<String> saveFoodLogEntry(FoodLogEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existingEntriesJson =
        prefs.getStringList('food_log_entries') ?? <String>[];

    final FoodLogEntry entryWithId =
        entry.id.isEmpty ? entry.copyWith(id: _uuid.v4()) : entry;

    final List<String> updatedEntries = <String>[
      ...existingEntriesJson,
      jsonEncode(entryWithId.toJson())
    ];
    await prefs.setStringList('food_log_entries', updatedEntries);

    return entryWithId.id;
  }

  @override
  Future<List<FoodLogEntry>> getFoodLogEntriesForDate(DateTime date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson =
        prefs.getStringList('food_log_entries') ?? <String>[];

    final List<FoodLogEntry> entries = entriesJson
        .map((String json) =>
            FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .where((FoodLogEntry entry) => _isSameDate(entry.loggedAt, date))
        .toList();

    // Sort by logged time
    entries.sort(
        (FoodLogEntry a, FoodLogEntry b) => a.loggedAt.compareTo(b.loggedAt));
    return entries;
  }

  @override
  Future<DailyNutritionSummary> getDailyNutritionSummary(DateTime date) async {
    final List<FoodLogEntry> meals = await getFoodLogEntriesForDate(date);

    if (meals.isEmpty) {
      return DailyNutritionSummary(
        date: date,
        totalNutrition: const NutritionInfo(
          calories: 0,
          carbohydrates: 0,
          protein: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
        ),
        targetCalories: 2000, // Default target
        meals: <FoodLogEntry>[],
        sustainabilityScore: 0.0,
      );
    }

    // Calculate total nutrition
    int totalCalories = 0;
    int totalCarbs = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalFiber = 0;
    int totalSugar = 0;
    int totalSodium = 0;
    double sustainabilitySum = 0.0;

    for (final FoodLogEntry meal in meals) {
      totalCalories += meal.nutritionInfo.calories;
      totalCarbs += meal.nutritionInfo.carbohydrates;
      totalProtein += meal.nutritionInfo.protein;
      totalFat += meal.nutritionInfo.fat;
      totalFiber += meal.nutritionInfo.fiber;
      totalSugar += meal.nutritionInfo.sugar;
      totalSodium += meal.nutritionInfo.sodium;

      // Simple sustainability score calculation (High=100, Medium=75, Low=50)
      if (meal.sustainabilityScore != null) {
        switch (meal.sustainabilityScore!.toLowerCase()) {
          case 'high':
            sustainabilitySum += 100;
            break;
          case 'medium':
            sustainabilitySum += 75;
            break;
          case 'low':
            sustainabilitySum += 50;
            break;
          default:
            sustainabilitySum += 75; // Default to medium
        }
      } else {
        sustainabilitySum += 75; // Default to medium if not specified
      }
    }

    final NutritionInfo totalNutrition = NutritionInfo(
      calories: totalCalories,
      carbohydrates: totalCarbs,
      protein: totalProtein,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
    );

    final double avgSustainability =
        meals.isNotEmpty ? sustainabilitySum / meals.length : 0.0;

    return DailyNutritionSummary(
      date: date,
      totalNutrition: totalNutrition,
      targetCalories: 2000, // TODO: Get from user profile
      meals: meals,
      sustainabilityScore: avgSustainability,
    );
  }

  @override
  Future<void> deleteFoodLogEntry(String entryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson =
        prefs.getStringList('food_log_entries') ?? <String>[];

    final List<String> updatedEntries = entriesJson.where((String json) {
      final FoodLogEntry entry =
          FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
      return entry.id != entryId;
    }).toList();

    await prefs.setStringList('food_log_entries', updatedEntries);
  }

  @override
  Future<void> updateFoodLogEntry(FoodLogEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson =
        prefs.getStringList('food_log_entries') ?? <String>[];

    final List<String> updatedEntries = entriesJson.map((String json) {
      final FoodLogEntry existingEntry =
          FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
      if (existingEntry.id == entry.id) {
        return jsonEncode(entry.toJson());
      }
      return json;
    }).toList();

    await prefs.setStringList('food_log_entries', updatedEntries);
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final List<DailyNutritionSummary> summaries = <DailyNutritionSummary>[];

    for (DateTime date = startDate;
        date.isBefore(endDate) || _isSameDate(date, endDate);
        date = date.add(const Duration(days: 1))) {
      final DailyNutritionSummary summary =
          await getDailyNutritionSummary(date);
      summaries.add(summary);
    }

    return summaries;
  }

  @override
  Future<String> saveMealPlan(MealPlanResponse mealPlan, String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existingPlansJson =
        prefs.getStringList('saved_meal_plans') ?? <String>[];

    final SavedMealPlan savedPlan = SavedMealPlan(
      id: _uuid.v4(),
      name: name,
      mealPlan: mealPlan,
      createdAt: DateTime.now(),
    );

    final List<String> updatedPlans = <String>[
      ...existingPlansJson,
      jsonEncode(savedPlan.toJson())
    ];
    await prefs.setStringList('saved_meal_plans', updatedPlans);

    return savedPlan.id;
  }

  @override
  Future<List<SavedMealPlan>> getSavedMealPlans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> plansJson =
        prefs.getStringList('saved_meal_plans') ?? <String>[];

    final List<SavedMealPlan> plans = plansJson
        .map((String json) =>
            SavedMealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();

    // Sort by creation date (newest first)
    plans.sort((SavedMealPlan a, SavedMealPlan b) =>
        b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  @override
  Future<void> deleteSavedMealPlan(String planId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> plansJson =
        prefs.getStringList('saved_meal_plans') ?? <String>[];

    final List<String> updatedPlans = plansJson.where((String json) {
      final SavedMealPlan plan =
          SavedMealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
      return plan.id != planId;
    }).toList();

    await prefs.setStringList('saved_meal_plans', updatedPlans);
  }

  @override
  Future<void> updateSavedMealPlan(SavedMealPlan plan) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> plansJson =
        prefs.getStringList('saved_meal_plans') ?? <String>[];

    final List<String> updatedPlans = plansJson.map((String json) {
      final SavedMealPlan existing =
          SavedMealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
      if (existing.id == plan.id) {
        return jsonEncode(plan.toJson());
      }
      return json;
    }).toList();

    await prefs.setStringList('saved_meal_plans', updatedPlans);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
