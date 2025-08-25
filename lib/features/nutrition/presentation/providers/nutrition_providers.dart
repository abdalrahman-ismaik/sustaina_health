import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/nutrition_models.dart';
import '../../data/services/nutrition_api_service.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/repositories/nutrition_repository.dart';

// API Service Provider
final Provider<NutritionApiService> nutritionApiServiceProvider = Provider<NutritionApiService>((ProviderRef<NutritionApiService> ref) {
  return NutritionApiService();
});

// Repository Provider
final Provider<NutritionRepository> nutritionRepositoryProvider = Provider<NutritionRepository>((ProviderRef<NutritionRepository> ref) {
  return NutritionRepositoryImpl(
    apiService: ref.watch(nutritionApiServiceProvider),
  );
});

// API Health Check Provider
final FutureProvider<bool> nutritionApiHealthProvider = FutureProvider<bool>((FutureProviderRef<bool> ref) async {
  final NutritionRepository repository = ref.watch(nutritionRepositoryProvider);
  return await repository.checkApiAvailability();
});

// Meal Analysis Provider
final StateNotifierProvider<MealAnalysisNotifier, AsyncValue<MealAnalysisResponse?>> mealAnalysisProvider = StateNotifierProvider<MealAnalysisNotifier,
    AsyncValue<MealAnalysisResponse?>>((StateNotifierProviderRef<MealAnalysisNotifier, AsyncValue<MealAnalysisResponse?>> ref) {
  return MealAnalysisNotifier(ref.watch(nutritionRepositoryProvider));
});

class MealAnalysisNotifier
    extends StateNotifier<AsyncValue<MealAnalysisResponse?>> {
  final NutritionRepository _repository;

  MealAnalysisNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> analyzeMeal(File imageFile, {String? mealType}) async {
    state = const AsyncValue.loading();

    try {
      final MealAnalysisResponse analysis =
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
final StateNotifierProvider<MealPlanGenerationNotifier, AsyncValue<MealPlanResponse?>> mealPlanGenerationProvider = StateNotifierProvider<
    MealPlanGenerationNotifier, AsyncValue<MealPlanResponse?>>((StateNotifierProviderRef<MealPlanGenerationNotifier, AsyncValue<MealPlanResponse?>> ref) {
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
      final MealPlanResponse mealPlan = await _repository.generateMealPlan(request);
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
final StateNotifierProvider<FoodLogNotifier, AsyncValue<List<FoodLogEntry>>> foodLogProvider =
    StateNotifierProvider<FoodLogNotifier, AsyncValue<List<FoodLogEntry>>>(
        (StateNotifierProviderRef<FoodLogNotifier, AsyncValue<List<FoodLogEntry>>> ref) {
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
      final List<FoodLogEntry> entries = await _repository.getFoodLogEntriesForDate(date);
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
      data: (List<FoodLogEntry> entries) =>
          entries.where((FoodLogEntry entry) => entry.mealType == mealType).toList(),
      orElse: () => <FoodLogEntry>[],
    );
  }
}

// Daily Nutrition Summary Provider
final StateNotifierProvider<DailyNutritionSummaryNotifier, AsyncValue<DailyNutritionSummary>> dailyNutritionSummaryProvider = StateNotifierProvider<
    DailyNutritionSummaryNotifier, AsyncValue<DailyNutritionSummary>>((StateNotifierProviderRef<DailyNutritionSummaryNotifier, AsyncValue<DailyNutritionSummary>> ref) {
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
      final DailyNutritionSummary summary = await _repository.getDailyNutritionSummary(date);
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
final StateNotifierProvider<NutritionTrendsNotifier, AsyncValue<List<DailyNutritionSummary>>> nutritionTrendsProvider = StateNotifierProvider<NutritionTrendsNotifier,
    AsyncValue<List<DailyNutritionSummary>>>((StateNotifierProviderRef<NutritionTrendsNotifier, AsyncValue<List<DailyNutritionSummary>>> ref) {
  return NutritionTrendsNotifier(ref.watch(nutritionRepositoryProvider));
});

class NutritionTrendsNotifier
    extends StateNotifier<AsyncValue<List<DailyNutritionSummary>>> {
  final NutritionRepository _repository;

  NutritionTrendsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    // Load last 7 days by default
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 6));
    loadTrends(startDate: startDate, endDate: endDate);
  }

  Future<void> loadTrends(
      {required DateTime startDate, required DateTime endDate}) async {
    state = const AsyncValue.loading();

    try {
      final List<DailyNutritionSummary> trends = await _repository.getNutritionTrends(
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(trends);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadWeeklyTrends() async {
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 6));
    await loadTrends(startDate: startDate, endDate: endDate);
  }

  Future<void> loadMonthlyTrends() async {
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 29));
    await loadTrends(startDate: startDate, endDate: endDate);
  }
}

// Saved Meal Plans Provider
final StateNotifierProvider<SavedMealPlansNotifier, AsyncValue<List<SavedMealPlan>>> savedMealPlansProvider = StateNotifierProvider<SavedMealPlansNotifier,
    AsyncValue<List<SavedMealPlan>>>((StateNotifierProviderRef<SavedMealPlansNotifier, AsyncValue<List<SavedMealPlan>>> ref) {
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
      final List<SavedMealPlan> plans = await _repository.getSavedMealPlans();
      state = AsyncValue.data(plans);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String?> saveMealPlan(MealPlanResponse mealPlan, String name) async {
    try {
      final String planId = await _repository.saveMealPlan(mealPlan, name);
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

  Future<void> updateMealPlan(SavedMealPlan plan) async {
    try {
      await _repository.updateSavedMealPlan(plan);
      await loadSavedMealPlans();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(String planId) async {
    final AsyncValue<List<SavedMealPlan>> current = state;
    final List<SavedMealPlan> plans = current.maybeWhen(data: (List<SavedMealPlan> data) => data, orElse: () => <SavedMealPlan>[]);
    final int idx = plans.indexWhere((SavedMealPlan p) => p.id == planId);
    if (idx == -1) return;

    final SavedMealPlan target = plans[idx];
    final SavedMealPlan updated = target.copyWith(isFavorite: !target.isFavorite, lastUsed: DateTime.now());

    await updateMealPlan(updated);
  }
}

// Brand Recommendations Provider
final StateNotifierProvider<BrandRecommendationsNotifier, AsyncValue<RecommendedBrands?>> brandRecommendationsProvider = StateNotifierProvider<
    BrandRecommendationsNotifier, AsyncValue<RecommendedBrands?>>((StateNotifierProviderRef<BrandRecommendationsNotifier, AsyncValue<RecommendedBrands?>> ref) {
  return BrandRecommendationsNotifier(ref.watch(nutritionApiServiceProvider));
});

class BrandRecommendationsNotifier
    extends StateNotifier<AsyncValue<RecommendedBrands?>> {
  final NutritionApiService _apiService;

  BrandRecommendationsNotifier(this._apiService)
      : super(const AsyncValue.data(null));

  Future<void> getBrandRecommendations(String product) async {
    state = const AsyncValue.loading();

    try {
      final RecommendedBrands recommendations =
          await _apiService.getBrandRecommendations(product);
      state = AsyncValue.data(recommendations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearRecommendations() {
    state = const AsyncValue.data(null);
  }
}

// Nutrition User Preferences Provider
final StateNotifierProvider<NutritionUserPreferencesNotifier, NutritionUserPreferences> nutritionUserPreferencesProvider = StateNotifierProvider<
    NutritionUserPreferencesNotifier, NutritionUserPreferences>((StateNotifierProviderRef<NutritionUserPreferencesNotifier, NutritionUserPreferences> ref) {
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
    this.dietaryRestrictions = const <String>[],
    this.allergies = const <String>[],
    this.activityLevel = 'moderately_active',
    this.preferredCuisines = const <String>[],
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
