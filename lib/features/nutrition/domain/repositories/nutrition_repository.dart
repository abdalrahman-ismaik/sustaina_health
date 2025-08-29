import 'dart:io';
import '../../data/models/nutrition_models.dart';

abstract class NutritionRepository {
  /// Analyze a meal photo to identify foods and nutrition information
  Future<MealAnalysisResponse> analyzeMeal(File imageFile, {String? mealType});

  /// Generate a personalized meal plan based on user preferences
  Future<MealPlanResponse> generateMealPlan(MealPlanRequest request);

  /// Check if the nutrition API is available
  Future<bool> checkApiAvailability();

  /// Save a food log entry locally
  Future<String> saveFoodLogEntry(FoodLogEntry entry);

  /// Get food log entries for a specific date
  Future<List<FoodLogEntry>> getFoodLogEntriesForDate(DateTime date);

  /// Get daily nutrition summary for a specific date
  Future<DailyNutritionSummary> getDailyNutritionSummary(DateTime date);

  /// Delete a food log entry
  Future<void> deleteFoodLogEntry(String entryId);

  /// Update a food log entry
  Future<void> updateFoodLogEntry(FoodLogEntry entry);

  /// Get nutrition trends over a date range
  Future<List<DailyNutritionSummary>> getNutritionTrends({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save a meal plan locally
  Future<String> saveMealPlan(MealPlanResponse mealPlan, String name);

  /// Get saved meal plans
  Future<List<SavedMealPlan>> getSavedMealPlans();

  /// Delete a saved meal plan
  Future<void> deleteSavedMealPlan(String planId);

  /// Update an existing saved meal plan (e.g. toggle favorite, update metadata)
  Future<void> updateSavedMealPlan(SavedMealPlan plan);
}

class SavedMealPlan {
  final String id;
  final String name;
  final MealPlanResponse mealPlan;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final bool isFavorite;

  const SavedMealPlan({
    required this.id,
    required this.name,
    required this.mealPlan,
    required this.createdAt,
    this.lastUsed,
    this.isFavorite = false,
  });

  factory SavedMealPlan.fromJson(Map<String, dynamic> json) {
    return SavedMealPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      mealPlan:
          MealPlanResponse.fromJson(json['mealPlan'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'mealPlan': mealPlan.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  SavedMealPlan copyWith({
    String? id,
    String? name,
    MealPlanResponse? mealPlan,
    DateTime? createdAt,
    DateTime? lastUsed,
    bool? isFavorite,
  }) {
    return SavedMealPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      mealPlan: mealPlan ?? this.mealPlan,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
