// Nutrition API Models based on fitness-tribe-ai repository

class MealAnalysisRequest {
  final String imageBase64;
  final String? mealType; // breakfast, lunch, dinner, snack

  const MealAnalysisRequest({
    required this.imageBase64,
    this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'image': imageBase64,
      if (mealType != null) 'meal_type': mealType,
    };
  }
}

class Ingredient {
  final String ingredient;
  final String quantity;
  final int calories;

  const Ingredient({
    required this.ingredient,
    required this.quantity,
    required this.calories,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      ingredient: json['ingredient'] as String,
      quantity: json['quantity'] as String,
      calories: json['calories'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'quantity': quantity,
      'calories': calories,
    };
  }
}

class MealOption {
  final String description;
  final List<Ingredient> ingredients;
  final int totalCalories;
  final String recipe;

  const MealOption({
    required this.description,
    required this.ingredients,
    required this.totalCalories,
    required this.recipe,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCalories: json['total_calories'] as int,
      recipe: json['recipe'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'total_calories': totalCalories,
      'recipe': recipe,
    };
  }
}

class MealAnalysisResponse {
  final List<String> identifiedFoods;
  final double confidence;
  final String portionSize;
  final NutritionInfo nutritionInfo;
  final String sustainabilityScore;
  final List<String> suggestions;

  const MealAnalysisResponse({
    required this.identifiedFoods,
    required this.confidence,
    required this.portionSize,
    required this.nutritionInfo,
    required this.sustainabilityScore,
    required this.suggestions,
  });

  factory MealAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MealAnalysisResponse(
      identifiedFoods: (json['identified_foods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      portionSize: json['portion_size'] as String,
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info'] as Map<String, dynamic>),
      sustainabilityScore: json['sustainability_score'] as String,
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identified_foods': identifiedFoods,
      'confidence': confidence,
      'portion_size': portionSize,
      'nutrition_info': nutritionInfo.toJson(),
      'sustainability_score': sustainabilityScore,
      'suggestions': suggestions,
    };
  }
}

class NutritionInfo {
  final int calories;
  final int carbohydrates; // in grams
  final int protein; // in grams
  final int fat; // in grams
  final int fiber; // in grams
  final int sugar; // in grams
  final int sodium; // in mg

  const NutritionInfo({
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] as int,
      carbohydrates: json['carbohydrates'] as int,
      protein: json['protein'] as int,
      fat: json['fat'] as int,
      fiber: json['fiber'] as int,
      sugar: json['sugar'] as int,
      sodium: json['sodium'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  String get macroString => 'C ${carbohydrates}g | P ${protein}g | F ${fat}g';
}

class MealPlanRequest {
  final String goal; // weight_loss, muscle_gain, maintenance, etc.
  final int targetCalories;
  final List<String> dietaryRestrictions; // vegetarian, vegan, gluten_free, etc.
  final List<String> allergies;
  final int mealsPerDay;
  final String activityLevel; // sedentary, lightly_active, moderately_active, very_active
  final List<String> preferredCuisines;

  const MealPlanRequest({
    required this.goal,
    required this.targetCalories,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.mealsPerDay = 3,
    required this.activityLevel,
    this.preferredCuisines = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'target_calories': targetCalories,
      'dietary_restrictions': dietaryRestrictions,
      'allergies': allergies,
      'meals_per_day': mealsPerDay,
      'activity_level': activityLevel,
      'preferred_cuisines': preferredCuisines,
    };
  }
}

class MealPlanResponse {
  final List<MealOption> breakfast;
  final List<MealOption> lunch;
  final List<MealOption> dinner;
  final List<MealOption> snacks;
  final int totalDailyCalories;
  final NutritionInfo dailyNutritionSummary;

  const MealPlanResponse({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalDailyCalories,
    required this.dailyNutritionSummary,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      breakfast: (json['breakfast'] as List<dynamic>)
          .map((e) => MealOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      lunch: (json['lunch'] as List<dynamic>)
          .map((e) => MealOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      dinner: (json['dinner'] as List<dynamic>)
          .map((e) => MealOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      snacks: (json['snacks'] as List<dynamic>)
          .map((e) => MealOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDailyCalories: json['total_daily_calories'] as int,
      dailyNutritionSummary: NutritionInfo.fromJson(
          json['daily_nutrition_summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.map((e) => e.toJson()).toList(),
      'lunch': lunch.map((e) => e.toJson()).toList(),
      'dinner': dinner.map((e) => e.toJson()).toList(),
      'snacks': snacks.map((e) => e.toJson()).toList(),
      'total_daily_calories': totalDailyCalories,
      'daily_nutrition_summary': dailyNutritionSummary.toJson(),
    };
  }
}

class FoodLogEntry {
  final String id;
  final String userId;
  final String foodName;
  final String mealType; // breakfast, lunch, dinner, snack
  final String servingSize;
  final NutritionInfo nutritionInfo;
  final String? sustainabilityScore;
  final String? notes;
  final DateTime loggedAt;
  final String? imageUrl;

  const FoodLogEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.mealType,
    required this.servingSize,
    required this.nutritionInfo,
    this.sustainabilityScore,
    this.notes,
    required this.loggedAt,
    this.imageUrl,
  });

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) {
    return FoodLogEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodName: json['foodName'] as String,
      mealType: json['mealType'] as String,
      servingSize: json['servingSize'] as String,
      nutritionInfo: NutritionInfo.fromJson(json['nutritionInfo'] as Map<String, dynamic>),
      sustainabilityScore: json['sustainabilityScore'] as String?,
      notes: json['notes'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'mealType': mealType,
      'servingSize': servingSize,
      'nutritionInfo': nutritionInfo.toJson(),
      'sustainabilityScore': sustainabilityScore,
      'notes': notes,
      'loggedAt': loggedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  FoodLogEntry copyWith({
    String? id,
    String? userId,
    String? foodName,
    String? mealType,
    String? servingSize,
    NutritionInfo? nutritionInfo,
    String? sustainabilityScore,
    String? notes,
    DateTime? loggedAt,
    String? imageUrl,
  }) {
    return FoodLogEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      notes: notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class DailyNutritionSummary {
  final DateTime date;
  final NutritionInfo totalNutrition;
  final int targetCalories;
  final List<FoodLogEntry> meals;
  final double sustainabilityScore;

  const DailyNutritionSummary({
    required this.date,
    required this.totalNutrition,
    required this.targetCalories,
    required this.meals,
    required this.sustainabilityScore,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      date: DateTime.parse(json['date'] as String),
      totalNutrition: NutritionInfo.fromJson(json['totalNutrition'] as Map<String, dynamic>),
      targetCalories: json['targetCalories'] as int,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => FoodLogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      sustainabilityScore: (json['sustainabilityScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalNutrition': totalNutrition.toJson(),
      'targetCalories': targetCalories,
      'meals': meals.map((e) => e.toJson()).toList(),
      'sustainabilityScore': sustainabilityScore,
    };
  }

  // Calculate percentage of target calories consumed
  double get calorieProgress => totalNutrition.calories / targetCalories;

  // Get meals by type
  List<FoodLogEntry> getMealsByType(String mealType) {
    return meals.where((meal) => meal.mealType == mealType).toList();
  }
}

class NutritionApiException implements Exception {
  final String message;
  final int? statusCode;

  const NutritionApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
