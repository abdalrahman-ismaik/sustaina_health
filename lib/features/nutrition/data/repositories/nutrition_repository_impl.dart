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
  Future<MealAnalysisResponse> analyzeMeal(File imageFile, {String? mealType}) async {
    final base64Image = await _apiService.imageToBase64(imageFile);
    final request = MealAnalysisRequest(
      imageBase64: base64Image,
      mealType: mealType,
    );
    return await _apiService.analyzeMeal(request);
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
    final prefs = await SharedPreferences.getInstance();
    final existingEntriesJson = prefs.getStringList('food_log_entries') ?? [];
    
    final entryWithId = entry.id.isEmpty ? 
        entry.copyWith(id: _uuid.v4()) : entry;
    
    final updatedEntries = [...existingEntriesJson, jsonEncode(entryWithId.toJson())];
    await prefs.setStringList('food_log_entries', updatedEntries);
    
    return entryWithId.id;
  }

  @override
  Future<List<FoodLogEntry>> getFoodLogEntriesForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('food_log_entries') ?? [];
    
    final entries = entriesJson
        .map((json) => FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .where((entry) => _isSameDate(entry.loggedAt, date))
        .toList();
    
    // Sort by logged time
    entries.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return entries;
  }

  @override
  Future<DailyNutritionSummary> getDailyNutritionSummary(DateTime date) async {
    final meals = await getFoodLogEntriesForDate(date);
    
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
        meals: [],
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

    for (final meal in meals) {
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

    final totalNutrition = NutritionInfo(
      calories: totalCalories,
      carbohydrates: totalCarbs,
      protein: totalProtein,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
    );

    final avgSustainability = meals.isNotEmpty ? sustainabilitySum / meals.length : 0.0;

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
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('food_log_entries') ?? [];
    
    final updatedEntries = entriesJson.where((json) {
      final entry = FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
      return entry.id != entryId;
    }).toList();
    
    await prefs.setStringList('food_log_entries', updatedEntries);
  }

  @override
  Future<void> updateFoodLogEntry(FoodLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('food_log_entries') ?? [];
    
    final updatedEntries = entriesJson.map((json) {
      final existingEntry = FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
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
    final summaries = <DailyNutritionSummary>[];
    
    for (DateTime date = startDate; 
         date.isBefore(endDate) || _isSameDate(date, endDate); 
         date = date.add(const Duration(days: 1))) {
      final summary = await getDailyNutritionSummary(date);
      summaries.add(summary);
    }
    
    return summaries;
  }

  @override
  Future<String> saveMealPlan(MealPlanResponse mealPlan, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPlansJson = prefs.getStringList('saved_meal_plans') ?? [];
    
    final savedPlan = SavedMealPlan(
      id: _uuid.v4(),
      name: name,
      mealPlan: mealPlan,
      createdAt: DateTime.now(),
    );
    
    final updatedPlans = [...existingPlansJson, jsonEncode(savedPlan.toJson())];
    await prefs.setStringList('saved_meal_plans', updatedPlans);
    
    return savedPlan.id;
  }

  @override
  Future<List<SavedMealPlan>> getSavedMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('saved_meal_plans') ?? [];
    
    final plans = plansJson
        .map((json) => SavedMealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
    
    // Sort by creation date (newest first)
    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  @override
  Future<void> deleteSavedMealPlan(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('saved_meal_plans') ?? [];
    
    final updatedPlans = plansJson.where((json) {
      final plan = SavedMealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
      return plan.id != planId;
    }).toList();
    
    await prefs.setStringList('saved_meal_plans', updatedPlans);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
