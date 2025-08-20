// Nutrition API Models based on real API response structure

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
      ingredient: json['ingredient'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'quantity': quantity,
      'calories': calories,
    };
  }

  @override
  String toString() {
    return '$ingredient ($quantity)';
  }
}

class MealOption {
  final String description;
  final List<Ingredient> ingredients;
  final int totalCalories;
  final String recipe;
  final List<String> suggestedBrands;

  const MealOption({
    required this.description,
    required this.ingredients,
    required this.totalCalories,
    required this.recipe,
    this.suggestedBrands = const [],
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      description: json['description'] as String? ?? 'Unknown Meal',
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List<dynamic>)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>? ?? {}))
              .toList()
          : [],
      totalCalories: (json['total_calories'] as num?)?.toInt() ?? 0,
      recipe: json['recipe'] as String? ?? '',
      suggestedBrands: json['suggested_brands'] != null
          ? List<String>.from(json['suggested_brands'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'total_calories': totalCalories,
      'recipe': recipe,
      'suggested_brands': suggestedBrands,
    };
  }

  // Compatibility properties for UI
  String get name => description;
  int get calories => totalCalories;
}

class DailyCaloriesRange {
  final int min;
  final int max;

  const DailyCaloriesRange({
    required this.min,
    required this.max,
  });

  factory DailyCaloriesRange.fromJson(Map<String, dynamic> json) {
    return DailyCaloriesRange(
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}

class MacronutrientsRange {
  final MacronutrientRange protein;
  final MacronutrientRange carbohydrates;
  final MacronutrientRange fat;

  const MacronutrientsRange({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory MacronutrientsRange.fromJson(Map<String, dynamic> json) {
    return MacronutrientsRange(
      protein: MacronutrientRange.fromJson(
          json['protein'] as Map<String, dynamic>? ?? {}),
      carbohydrates: MacronutrientRange.fromJson(
          json['carbohydrates'] as Map<String, dynamic>? ?? {}),
      fat: MacronutrientRange.fromJson(
          json['fat'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein.toJson(),
      'carbohydrates': carbohydrates.toJson(),
      'fat': fat.toJson(),
    };
  }
}

class MacronutrientRange {
  final int min;
  final int max;

  const MacronutrientRange({
    required this.min,
    required this.max,
  });

  factory MacronutrientRange.fromJson(Map<String, dynamic> json) {
    return MacronutrientRange(
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}

class SustainabilityInfo {
  final String environmentalImpact;
  final String nutritionImpact;
  final int overallScore;
  final String description;

  const SustainabilityInfo({
    required this.environmentalImpact,
    required this.nutritionImpact,
    required this.overallScore,
    required this.description,
  });

  factory SustainabilityInfo.fromJson(Map<String, dynamic> json) {
    return SustainabilityInfo(
      environmentalImpact: json['environmental_impact'] as String,
      nutritionImpact: json['nutrition_impact'] as String,
      overallScore: (json['Overall_score'] as num).toInt(),
      description: json['Description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environmental_impact': environmentalImpact,
      'nutrition_impact': nutritionImpact,
      'Overall_score': overallScore,
      'Description': description,
    };
  }
}

class MealAnalysisResponse {
  final String foodName;
  final int totalCalories;
  final Map<String, int> caloriesPerIngredient;
  final SustainabilityInfo sustainability;
  final int totalProtein;
  final int totalCarbohydrates;
  final int totalFats;

  const MealAnalysisResponse({
    required this.foodName,
    required this.totalCalories,
    required this.caloriesPerIngredient,
    required this.sustainability,
    required this.totalProtein,
    required this.totalCarbohydrates,
    required this.totalFats,
  });

  factory MealAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MealAnalysisResponse(
      foodName: json['food_name'] as String,
      totalCalories: (json['total_calories'] as num).toInt(),
      caloriesPerIngredient: Map<String, int>.from(
        (json['calories_per_ingredient'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        ),
      ),
      sustainability: SustainabilityInfo.fromJson(
        json['sustainability'] as Map<String, dynamic>,
      ),
      totalProtein: (json['total_protein'] as num).toInt(),
      totalCarbohydrates: (json['total_carbohydrates'] as num).toInt(),
      totalFats: (json['total_fats'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'total_calories': totalCalories,
      'calories_per_ingredient': caloriesPerIngredient,
      'sustainability': sustainability.toJson(),
      'total_protein': totalProtein,
      'total_carbohydrates': totalCarbohydrates,
      'total_fats': totalFats,
    };
  }

  // Get list of ingredients from the calories per ingredient map
  List<String> get ingredients => caloriesPerIngredient.keys.toList();
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
      calories: (json['calories'] as num).toInt(),
      carbohydrates: (json['carbohydrates'] as num).toInt(),
      protein: (json['protein'] as num).toInt(),
      fat: (json['fat'] as num).toInt(),
      fiber: (json['fiber'] as num).toInt(),
      sugar: (json['sugar'] as num).toInt(),
      sodium: (json['sodium'] as num).toInt(),
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
  final double weight;
  final double height;
  final int age;
  final String sex;
  final String goal;
  final List<String> dietaryPreferences;
  final List<String> foodIntolerance;
  final int durationDays;

  const MealPlanRequest({
    required this.weight,
    required this.height,
    required this.age,
    required this.sex,
    required this.goal,
    this.dietaryPreferences = const [],
    this.foodIntolerance = const [],
    required this.durationDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'sex': sex,
      'goal': goal,
      'dietary_preferences': dietaryPreferences,
      'food_intolerance': foodIntolerance,
      'duration_days': durationDays,
    };
  }
}

class MealPlanResponse {
  final DailyCaloriesRange dailyCaloriesRange;
  final MacronutrientsRange macronutrientsRange;
  final List<DailyMealPlan> dailyMealPlans;
  final int totalDays;

  const MealPlanResponse({
    required this.dailyCaloriesRange,
    required this.macronutrientsRange,
    required this.dailyMealPlans,
    required this.totalDays,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      dailyCaloriesRange: DailyCaloriesRange.fromJson(
          json['daily_calories_range'] as Map<String, dynamic>? ?? {}),
      macronutrientsRange: MacronutrientsRange.fromJson(
          json['macronutrients_range'] as Map<String, dynamic>? ?? {}),
      dailyMealPlans: json['daily_meal_plans'] != null
          ? (json['daily_meal_plans'] as List<dynamic>)
              .map((e) =>
                  DailyMealPlan.fromJson(e as Map<String, dynamic>? ?? {}))
              .toList()
          : [],
      totalDays: (json['total_days'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_calories_range': dailyCaloriesRange.toJson(),
      'macronutrients_range': macronutrientsRange.toJson(),
      'daily_meal_plans': dailyMealPlans.map((e) => e.toJson()).toList(),
      'total_days': totalDays,
    };
  }
}

class DailyMealPlan {
  final int day;
  final String date;
  final MealOption breakfast;
  final MealOption lunch;
  final MealOption dinner;
  final List<MealOption> snacks;
  final int totalDailyCalories;
  final DailyMacros dailyMacros;

  const DailyMealPlan({
    required this.day,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalDailyCalories,
    required this.dailyMacros,
  });

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      day: (json['day'] as num?)?.toInt() ?? 1,
      date: json['date'] as String? ?? '',
      breakfast:
          MealOption.fromJson(json['breakfast'] as Map<String, dynamic>? ?? {}),
      lunch: MealOption.fromJson(json['lunch'] as Map<String, dynamic>? ?? {}),
      dinner:
          MealOption.fromJson(json['dinner'] as Map<String, dynamic>? ?? {}),
      snacks: json['snacks'] != null
          ? (json['snacks'] as List<dynamic>)
              .map((e) => MealOption.fromJson(e as Map<String, dynamic>? ?? {}))
              .toList()
          : [],
      totalDailyCalories: (json['total_daily_calories'] as num?)?.toInt() ?? 0,
      dailyMacros: DailyMacros.fromJson(
          json['daily_macros'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'breakfast': breakfast.toJson(),
      'lunch': lunch.toJson(),
      'dinner': dinner.toJson(),
      'snacks': snacks.map((e) => e.toJson()).toList(),
      'total_daily_calories': totalDailyCalories,
      'daily_macros': dailyMacros.toJson(),
    };
  }
}

class DailyMacros {
  final int protein;
  final int carbohydrates;
  final int fat;

  const DailyMacros({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory DailyMacros.fromJson(Map<String, dynamic> json) {
    return DailyMacros(
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbohydrates: (json['carbohydrates'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
    };
  }

  String get macroString => 'C ${carbohydrates}g | P ${protein}g | F ${fat}g';
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
      nutritionInfo:
          NutritionInfo.fromJson(json['nutritionInfo'] as Map<String, dynamic>),
      sustainabilityScore: json['sustainabilityScore'] as String?,
      notes: json['notes'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
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
      totalNutrition: NutritionInfo.fromJson(
          json['totalNutrition'] as Map<String, dynamic>),
      targetCalories: (json['targetCalories'] as num).toInt(),
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

class RecommendedBrand {
  final String name;
  final double price;
  final String sustainabilityRating;
  final String description;

  const RecommendedBrand({
    required this.name,
    required this.price,
    required this.sustainabilityRating,
    required this.description,
  });

  factory RecommendedBrand.fromJson(Map<String, dynamic> json) {
    return RecommendedBrand(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      sustainabilityRating: json['sustainability_rating'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'sustainability_rating': sustainabilityRating,
      'description': description,
    };
  }
}

class RecommendedBrands {
  final List<RecommendedBrand> brands;

  const RecommendedBrands({
    required this.brands,
  });

  factory RecommendedBrands.fromJson(Map<String, dynamic> json) {
    return RecommendedBrands(
      brands: (json['brands'] as List<dynamic>)
          .map((e) => RecommendedBrand.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brands': brands.map((e) => e.toJson()).toList(),
    };
  }
}

class NutritionApiException implements Exception {
  final String message;
  final int? statusCode;

  const NutritionApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
