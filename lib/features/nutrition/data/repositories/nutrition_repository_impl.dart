import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../models/nutrition_models.dart';
import '../services/nutrition_api_service.dart';
import '../services/firestore_nutrition_service.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionApiService _apiService;
  final FirestoreNutritionService _firestoreService;
  final Uuid _uuid = const Uuid();

  // Deduplication mechanism
  final Set<String> _recentlySaved = <String>{};
  Timer? _cleanupTimer;

  NutritionRepositoryImpl({
    required NutritionApiService apiService,
    FirestoreNutritionService? firestoreService,
  })  : _apiService = apiService,
        _firestoreService = firestoreService ?? FirestoreNutritionService();

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
    final FoodLogEntry entryWithId =
        entry.id.isEmpty ? entry.copyWith(id: _uuid.v4()) : entry;

    // Create a unique key for deduplication based on food name, nutrition info, and timestamp
    final String dedupeKey =
        '${entryWithId.foodName}_${entryWithId.nutritionInfo.calories}_${entryWithId.loggedAt.millisecondsSinceEpoch}';

    // Check if we've recently saved this exact entry
    if (_recentlySaved.contains(dedupeKey)) {
      print(
          '🔄 Skipping duplicate save for "${entryWithId.foodName}" - already saved recently');
      return entryWithId.id;
    }

    try {
      // Add to deduplication cache
      _recentlySaved.add(dedupeKey);

      // Start cleanup timer if not already running
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer(const Duration(seconds: 30), () {
        _recentlySaved.clear();
      });

      // Save to local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> existingEntriesJson =
          prefs.getStringList('food_log_entries') ?? <String>[];

      final List<String> updatedEntries = <String>[
        ...existingEntriesJson,
        jsonEncode(entryWithId.toJson())
      ];
      await prefs.setStringList('food_log_entries', updatedEntries);

      // Save to Firestore cloud storage
      await _firestoreService.ensureNutritionModuleExists();
      await _firestoreService.saveFoodLogEntry(entryWithId);

      print(
          '✅ Food log entry "${entryWithId.foodName}" saved to both local storage and Firestore cloud! [${DateTime.now().millisecondsSinceEpoch}]');

      return entryWithId.id;
    } catch (e) {
      // Remove from cache if save failed
      _recentlySaved.remove(dedupeKey);
      print('❌ Error saving food log entry: $e');
      // If Firestore fails, at least we have local storage
      rethrow;
    }
  }

  @override
  Future<List<FoodLogEntry>> getFoodLogEntriesForDate(DateTime date) async {
    try {
      // First try to get entries from Firestore (primary source)
      final List<FoodLogEntry> firestoreEntries =
          await _firestoreService.getFoodLogEntriesForDate(date);

      print(
          '📖 Found ${firestoreEntries.length} entries from Firestore for ${date.toIso8601String().split('T')[0]}');

      // Also get local entries as fallback/backup
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> entriesJson =
          prefs.getStringList('food_log_entries') ?? <String>[];

      final List<FoodLogEntry> localEntries = entriesJson
          .map((String json) =>
              FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .where((FoodLogEntry entry) => _isSameDate(entry.loggedAt, date))
          .toList();

      print(
          '📖 Found ${localEntries.length} entries from local storage for ${date.toIso8601String().split('T')[0]}');

      // Merge entries, prioritizing Firestore but keeping local ones that might not be synced
      final Map<String, FoodLogEntry> mergedEntries = <String, FoodLogEntry>{};

      // Add local entries first
      for (final FoodLogEntry entry in localEntries) {
        mergedEntries[entry.id] = entry;
      }

      // Add/override with Firestore entries (they take priority)
      for (final FoodLogEntry entry in firestoreEntries) {
        mergedEntries[entry.id] = entry;
      }

      final List<FoodLogEntry> finalEntries = mergedEntries.values.toList();

      // Sort by logged time
      finalEntries.sort(
          (FoodLogEntry a, FoodLogEntry b) => a.loggedAt.compareTo(b.loggedAt));

      print(
          '📖 Returning ${finalEntries.length} total merged entries for ${date.toIso8601String().split('T')[0]}');
      return finalEntries;
    } catch (e) {
      print(
          '❌ Error getting food log entries from Firestore, falling back to local: $e');

      // Fallback to local storage only
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
    try {
      // Delete from local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> entriesJson =
          prefs.getStringList('food_log_entries') ?? <String>[];

      final List<String> updatedEntries = entriesJson.where((String json) {
        final FoodLogEntry entry =
            FoodLogEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
        return entry.id != entryId;
      }).toList();

      await prefs.setStringList('food_log_entries', updatedEntries);

      // Delete from Firestore cloud storage
      await _firestoreService.deleteFoodLogEntry(entryId);

      print(
          '✅ Food log entry deleted from both local storage and Firestore cloud!');
    } catch (e) {
      print('❌ Error deleting food log entry: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFoodLogEntry(FoodLogEntry entry) async {
    try {
      // Update local storage
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

      // Update in Firestore cloud storage
      await _firestoreService.updateFoodLogEntry(entry);

      print(
          '✅ Food log entry "${entry.foodName}" updated in both local storage and Firestore cloud!');
    } catch (e) {
      print('❌ Error updating food log entry: $e');
      rethrow;
    }
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
    final SavedMealPlan savedPlan = SavedMealPlan(
      id: _uuid.v4(),
      name: name,
      mealPlan: mealPlan,
      createdAt: DateTime.now(),
    );

    try {
      // Save to local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> existingPlansJson =
          prefs.getStringList('saved_meal_plans') ?? <String>[];

      final List<String> updatedPlans = <String>[
        ...existingPlansJson,
        jsonEncode(savedPlan.toJson())
      ];
      await prefs.setStringList('saved_meal_plans', updatedPlans);

      // Save to Firestore cloud storage
      await _firestoreService.ensureNutritionModuleExists();
      await _firestoreService.saveMealPlan(savedPlan.id, mealPlan);

      print(
          '✅ Meal plan "${savedPlan.name}" saved to both local storage and Firestore cloud!');

      return savedPlan.id;
    } catch (e) {
      print('❌ Error saving meal plan: $e');
      // If Firestore fails, at least we have local storage
      rethrow;
    }
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

  /// Sync food log entry to cloud only (used by data migration service)
  Future<void> syncFoodLogEntryToCloudOnly(FoodLogEntry entry) async {
    try {
      await _firestoreService.ensureNutritionModuleExists();
      await _firestoreService.saveFoodLogEntry(entry);
      print(
          '🔄 [MIGRATION] Food log entry "${entry.foodName}" synced to cloud only [${DateTime.now().millisecondsSinceEpoch}]');
    } catch (e) {
      print('❌ Error syncing food log entry to cloud: $e');
      rethrow;
    }
  }

  /// Sync meal plan to cloud only (used by data migration service)
  Future<void> syncMealPlanToCloudOnly(
      MealPlanResponse mealPlan, String name) async {
    try {
      final String planId = _uuid.v4();
      await _firestoreService.ensureNutritionModuleExists();
      await _firestoreService.saveMealPlan(planId, mealPlan);
      print('🔄 Meal plan "$name" synced to cloud');
    } catch (e) {
      print('❌ Error syncing meal plan to cloud: $e');
      rethrow;
    }
  }

  /// Dispose of resources, particularly the cleanup timer
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _recentlySaved.clear();
  }
}
