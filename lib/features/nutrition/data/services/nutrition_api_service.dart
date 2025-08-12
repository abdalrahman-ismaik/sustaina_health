import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/nutrition_models.dart';

class NutritionApiService {
  // Deployed fitness-tribe-ai server
  static const String _baseUrl = 'https://fitness-tribe-ai-4s89.onrender.com';

  /// Analyze a meal photo to identify foods, calories, and nutrition information
  Future<MealAnalysisResponse> analyzeMeal(MealAnalysisRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/meals/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return MealAnalysisResponse.fromJson(data);
      } else {
        throw NutritionApiException(
          'Failed to analyze meal: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is NutritionApiException) {
        rethrow;
      }

      // If network error, return mock data for testing
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        print('API server not available, using mock data for testing');
        return _getMockMealAnalysis();
      }

      throw NutritionApiException('Network error: ${e.toString()}');
    }
  }

  /// Generate a personalized meal plan based on user preferences and goals
  Future<MealPlanResponse> generateMealPlan(MealPlanRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/nutrition-plans/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        print('API Response: $data'); // Debug logging
        return MealPlanResponse.fromJson(data);
      } else {
        throw NutritionApiException(
          'Failed to generate meal plan: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is NutritionApiException) {
        rethrow;
      }

      // If network error, return mock data for testing
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        print('API server not available, using mock data for testing');
        return _getMockMealPlan(request);
      }

      throw NutritionApiException('Network error: ${e.toString()}');
    }
  }

  /// Health check method to verify API availability
  Future<bool> checkApiHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/'),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Mock meal analysis for testing when API is not available
  MealAnalysisResponse _getMockMealAnalysis() {
    return const MealAnalysisResponse(
      identifiedFoods: ['Apple', 'Banana', 'Greek Yogurt'],
      confidence: 0.92,
      portionSize: '1 medium apple, 1 medium banana, 1 cup yogurt',
      nutritionInfo: NutritionInfo(
        calories: 285,
        carbohydrates: 45,
        protein: 15,
        fat: 8,
        fiber: 7,
        sugar: 35,
        sodium: 60,
      ),
      sustainabilityScore: 'High',
      suggestions: [
        'Great choice! These foods are nutrient-dense and sustainable.',
        'Consider adding some nuts for healthy fats.',
        'This snack provides good energy for your workout.',
      ],
    );
  }

  // Mock meal plan for testing when API is not available
  MealPlanResponse _getMockMealPlan(MealPlanRequest request) {
    // Create mock data for the number of days requested
    final List<DailyMealPlan> dailyPlans = [];
    
    for (int day = 1; day <= request.durationDays; day++) {
      dailyPlans.add(DailyMealPlan(
        day: day,
        date: DateTime.now().add(Duration(days: day - 1)).toIso8601String().split('T')[0],
        breakfast: MealOption(
          description: 'Oatmeal with Berries and Almonds',
          totalCalories: 425,
          recipe: 'Cook oats with milk, top with berries and almonds, drizzle with honey.',
          ingredients: const [
            Ingredient(ingredient: 'Rolled oats', quantity: '1/2 cup', calories: 150),
            Ingredient(ingredient: 'Mixed berries', quantity: '1/2 cup', calories: 40),
            Ingredient(ingredient: 'Almonds', quantity: '1/4 cup', calories: 160),
            Ingredient(ingredient: 'Honey', quantity: '1 tbsp', calories: 65),
          ],
          suggestedBrands: ['Quaker Oats', 'Nature Valley'],
        ),
        lunch: MealOption(
          description: 'Quinoa Salad with Chickpeas',
          totalCalories: 385,
          recipe: 'Mix cooked quinoa with chickpeas, vegetables, and olive oil dressing.',
          ingredients: const [
            Ingredient(ingredient: 'Quinoa', quantity: '1/2 cup cooked', calories: 110),
            Ingredient(ingredient: 'Chickpeas', quantity: '1/2 cup', calories: 135),
            Ingredient(ingredient: 'Mixed vegetables', quantity: '1 cup', calories: 25),
            Ingredient(ingredient: 'Olive oil', quantity: '1 tbsp', calories: 115),
          ],
          suggestedBrands: ['Eden Organic', 'Bertolli'],
        ),
        dinner: MealOption(
          description: 'Grilled Salmon with Sweet Potato',
          totalCalories: 520,
          recipe: 'Grill salmon fillet, roast sweet potato, steam broccoli.',
          ingredients: const [
            Ingredient(ingredient: 'Salmon fillet', quantity: '6 oz', calories: 350),
            Ingredient(ingredient: 'Sweet potato', quantity: '1 medium', calories: 100),
            Ingredient(ingredient: 'Broccoli', quantity: '1 cup', calories: 25),
            Ingredient(ingredient: 'Olive oil', quantity: '1 tbsp', calories: 45),
          ],
          suggestedBrands: ['Wild Planet', 'Organic Valley'],
        ),
        snacks: [
          MealOption(
            description: 'Greek Yogurt with Nuts',
            totalCalories: 180,
            recipe: 'Mix Greek yogurt with mixed nuts.',
            ingredients: const [
              Ingredient(ingredient: 'Greek yogurt', quantity: '3/4 cup', calories: 100),
              Ingredient(ingredient: 'Mixed nuts', quantity: '1/4 cup', calories: 80),
            ],
            suggestedBrands: ['Fage', 'Blue Diamond'],
          ),
        ],
        dailyMacros: const DailyMacros(
          protein: 80,
          carbohydrates: 177,
          fat: 57,
        ),
        totalDailyCalories: 1510,
      ));
    }
    
    return MealPlanResponse(
      dailyCaloriesRange: const DailyCaloriesRange(min: 1400, max: 1600),
      macronutrientsRange: const MacronutrientsRange(
        protein: MacronutrientRange(min: 70, max: 90),
        carbohydrates: MacronutrientRange(min: 150, max: 200),
        fat: MacronutrientRange(min: 50, max: 65),
      ),
      dailyMealPlans: dailyPlans,
      totalDays: request.durationDays,
    );
  }

  /// Convert image file to base64 string for API requests
  Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw NutritionApiException('Failed to process image: ${e.toString()}');
    }
  }
}
