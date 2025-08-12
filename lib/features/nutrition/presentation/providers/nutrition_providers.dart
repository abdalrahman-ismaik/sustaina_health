import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/nutrition_models.dart';
import '../../data/services/nutrition_api_service.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/repositories/nutrition_repository.dart';

// API Service Provider
final nutritionApiServiceProvider = Provider<NutritionApiService>((ref) {
  return NutritionApiService();
});

// Repository Provider
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepositoryImpl(
    apiService: ref.watch(nutritionApiServiceProvider),
  );
});

// API Health Check Provider
final nutritionApiHealthProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return await repository.checkApiAvailability();
});

// Meal Analysis Provider
final mealAnalysisProvider = StateNotifierProvider<MealAnalysisNotifier,
    AsyncValue<MealAnalysisResponse?>>((ref) {
  return MealAnalysisNotifier(ref.watch(nutritionRepositoryProvider));
});

class MealAnalysisNotifier
    extends StateNotifier<AsyncValue<MealAnalysisResponse?>> {
  final NutritionRepository _repository;

  MealAnalysisNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> analyzeMeal(File imageFile, {String? mealType}) async {
    state = const AsyncValue.loading();

    try {
      final analysis =
          await _repository.analyzeMeal(imageFile, mealType: mealType);
      state = AsyncValue.data(analysis);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearAnalysis() {
    state = const AsyncValue.data(null);
  }
}

// Meal Plan Generation Provider
final mealPlanGenerationProvider = StateNotifierProvider<
    MealPlanGenerationNotifier, AsyncValue<MealPlanResponse?>>((ref) {
  return MealPlanGenerationNotifier(ref.watch(nutritionRepositoryProvider));
});

class MealPlanGenerationNotifier
    extends StateNotifier<AsyncValue<MealPlanResponse?>> {
  final NutritionRepository _repository;

  MealPlanGenerationNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> generateMealPlan(MealPlanRequest request) async {
    state = const AsyncValue.loading();

    try {
      final mealPlan = await _repository.generateMealPlan(request);
      state = AsyncValue.data(mealPlan);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearMealPlan() {
    state = const AsyncValue.data(null);
  }
}

// Food Log Provider
final foodLogProvider =
    StateNotifierProvider<FoodLogNotifier, AsyncValue<List<FoodLogEntry>>>(
        (ref) {
  return FoodLogNotifier(ref.watch(nutritionRepositoryProvider));
});

class FoodLogNotifier extends StateNotifier<AsyncValue<List<FoodLogEntry>>> {
  final NutritionRepository _repository;
  DateTime _currentDate = DateTime.now();

  FoodLogNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFoodLogForDate(_currentDate);
  }

  DateTime get currentDate => _currentDate;

  Future<void> loadFoodLogForDate(DateTime date) async {
    _currentDate = date;
    state = const AsyncValue.loading();

    try {
      final entries = await _repository.getFoodLogEntriesForDate(date);
      state = AsyncValue.data(entries);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addFoodLogEntry(FoodLogEntry entry) async {
    try {
      await _repository.saveFoodLogEntry(entry);
      // Reload the current date to show the new entry
      await loadFoodLogForDate(_currentDate);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateFoodLogEntry(FoodLogEntry entry) async {
    try {
      await _repository.updateFoodLogEntry(entry);
      await loadFoodLogForDate(_currentDate);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteFoodLogEntry(String entryId) async {
    try {
      await _repository.deleteFoodLogEntry(entryId);
      await loadFoodLogForDate(_currentDate);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> changeDate(DateTime newDate) async {
    await loadFoodLogForDate(newDate);
  }

  List<FoodLogEntry> getMealsByType(String mealType) {
    return state.maybeWhen(
      data: (entries) =>
          entries.where((entry) => entry.mealType == mealType).toList(),
      orElse: () => [],
    );
  }
}

// Daily Nutrition Summary Provider
final dailyNutritionSummaryProvider = StateNotifierProvider<
    DailyNutritionSummaryNotifier, AsyncValue<DailyNutritionSummary>>((ref) {
  return DailyNutritionSummaryNotifier(ref.watch(nutritionRepositoryProvider));
});

class DailyNutritionSummaryNotifier
    extends StateNotifier<AsyncValue<DailyNutritionSummary>> {
  final NutritionRepository _repository;
  DateTime _currentDate = DateTime.now();

  DailyNutritionSummaryNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadSummaryForDate(_currentDate);
  }

  DateTime get currentDate => _currentDate;

  Future<void> loadSummaryForDate(DateTime date) async {
    _currentDate = date;
    state = const AsyncValue.loading();

    try {
      final summary = await _repository.getDailyNutritionSummary(date);
      state = AsyncValue.data(summary);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> changeDate(DateTime newDate) async {
    await loadSummaryForDate(newDate);
  }

  Future<void> refreshSummary() async {
    await loadSummaryForDate(_currentDate);
  }
}

// Nutrition Trends Provider
final nutritionTrendsProvider = StateNotifierProvider<NutritionTrendsNotifier,
    AsyncValue<List<DailyNutritionSummary>>>((ref) {
  return NutritionTrendsNotifier(ref.watch(nutritionRepositoryProvider));
});

class NutritionTrendsNotifier
    extends StateNotifier<AsyncValue<List<DailyNutritionSummary>>> {
  final NutritionRepository _repository;

  NutritionTrendsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    // Load last 7 days by default
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    loadTrends(startDate: startDate, endDate: endDate);
  }

  Future<void> loadTrends(
      {required DateTime startDate, required DateTime endDate}) async {
    state = const AsyncValue.loading();

    try {
      final trends = await _repository.getNutritionTrends(
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(trends);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadWeeklyTrends() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    await loadTrends(startDate: startDate, endDate: endDate);
  }

  Future<void> loadMonthlyTrends() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 29));
    await loadTrends(startDate: startDate, endDate: endDate);
  }
}

// Saved Meal Plans Provider
final savedMealPlansProvider = StateNotifierProvider<SavedMealPlansNotifier,
    AsyncValue<List<SavedMealPlan>>>((ref) {
  return SavedMealPlansNotifier(ref.watch(nutritionRepositoryProvider));
});

class SavedMealPlansNotifier
    extends StateNotifier<AsyncValue<List<SavedMealPlan>>> {
  final NutritionRepository _repository;

  SavedMealPlansNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSavedMealPlans();
  }

  Future<void> loadSavedMealPlans() async {
    state = const AsyncValue.loading();

    try {
      final plans = await _repository.getSavedMealPlans();
      state = AsyncValue.data(plans);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String?> saveMealPlan(MealPlanResponse mealPlan, String name) async {
    try {
      final planId = await _repository.saveMealPlan(mealPlan, name);
      await loadSavedMealPlans(); // Refresh the list
      return planId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> deleteMealPlan(String planId) async {
    try {
      await _repository.deleteSavedMealPlan(planId);
      await loadSavedMealPlans(); // Refresh the list
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Nutrition User Preferences Provider
final nutritionUserPreferencesProvider = StateNotifierProvider<
    NutritionUserPreferencesNotifier, NutritionUserPreferences>((ref) {
  return NutritionUserPreferencesNotifier();
});

class NutritionUserPreferencesNotifier
    extends StateNotifier<NutritionUserPreferences> {
  NutritionUserPreferencesNotifier() : super(const NutritionUserPreferences());

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void updateTargetCalories(int calories) {
    state = state.copyWith(targetCalories: calories);
  }

  void updateDietaryRestrictions(List<String> restrictions) {
    state = state.copyWith(dietaryRestrictions: restrictions);
  }

  void updateAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
  }

  void updateActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void updatePreferredCuisines(List<String> cuisines) {
    state = state.copyWith(preferredCuisines: cuisines);
  }

  void updateMealsPerDay(int meals) {
    state = state.copyWith(mealsPerDay: meals);
  }
}

class NutritionUserPreferences {
  final String goal;
  final int targetCalories;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final String activityLevel;
  final List<String> preferredCuisines;
  final int mealsPerDay;

  const NutritionUserPreferences({
    this.goal = 'maintenance',
    this.targetCalories = 2000,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.activityLevel = 'moderately_active',
    this.preferredCuisines = const [],
    this.mealsPerDay = 3,
  });

  NutritionUserPreferences copyWith({
    String? goal,
    int? targetCalories,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    String? activityLevel,
    List<String>? preferredCuisines,
    int? mealsPerDay,
  }) {
    return NutritionUserPreferences(
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      activityLevel: activityLevel ?? this.activityLevel,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
    );
  }

  MealPlanRequest toMealPlanRequest() {
    // Convert old format to new API format with default values
    // You may want to collect these from user input in the future
    return MealPlanRequest(
      weight: 70.0, // Default weight in kg - should be collected from user
      height: 170.0, // Default height in cm - should be collected from user
      age: 25, // Default age - should be collected from user
      sex: 'Male', // Default sex - should be collected from user
      goal: goal, // Map existing goal
      dietaryPreferences:
          dietaryRestrictions, // Map dietary restrictions to preferences
      foodIntolerance: allergies, // Map allergies to food intolerance
      durationDays: 7, // Default to 7 days plan
    );
  }
}
