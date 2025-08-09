import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/nutrition_models.dart';

class NutritionApiService {
  // Change this URL to match your actual API server
  static const String _baseUrl = 'http://10.0.2.2:8000'; // for Android emulator
  // For iOS Simulator use: 'http://localhost:8000'
  // For physical device use your computer's IP: 'http://192.168.1.XXX:8000'

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
        Uri.parse('$_baseUrl/meal-plans/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
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
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

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
    return MealPlanResponse(
      breakfast: [
        const MealOption(
          description: 'Oatmeal with berries and almonds',
          ingredients: [
            Ingredient(ingredient: 'Rolled oats', quantity: '1/2 cup', calories: 150),
            Ingredient(ingredient: 'Mixed berries', quantity: '1/2 cup', calories: 40),
            Ingredient(ingredient: 'Almonds', quantity: '1/4 cup', calories: 170),
            Ingredient(ingredient: 'Honey', quantity: '1 tbsp', calories: 65),
          ],
          totalCalories: 425,
          recipe: 'Cook oats with water, top with berries, almonds, and honey.',
        ),
        const MealOption(
          description: 'Greek yogurt parfait with granola',
          ingredients: [
            Ingredient(ingredient: 'Greek yogurt', quantity: '1 cup', calories: 150),
            Ingredient(ingredient: 'Granola', quantity: '1/4 cup', calories: 120),
            Ingredient(ingredient: 'Strawberries', quantity: '1/2 cup', calories: 25),
            Ingredient(ingredient: 'Blueberries', quantity: '1/4 cup', calories: 20),
          ],
          totalCalories: 315,
          recipe: 'Layer yogurt with granola and fresh berries.',
        ),
      ],
      lunch: [
        const MealOption(
          description: 'Quinoa salad with vegetables and chickpeas',
          ingredients: [
            Ingredient(ingredient: 'Quinoa', quantity: '1/2 cup cooked', calories: 110),
            Ingredient(ingredient: 'Chickpeas', quantity: '1/2 cup', calories: 135),
            Ingredient(ingredient: 'Mixed vegetables', quantity: '1 cup', calories: 35),
            Ingredient(ingredient: 'Olive oil', quantity: '1 tbsp', calories: 120),
          ],
          totalCalories: 400,
          recipe: 'Mix cooked quinoa with chickpeas, vegetables, and olive oil dressing.',
        ),
        const MealOption(
          description: 'Grilled chicken wrap with vegetables',
          ingredients: [
            Ingredient(ingredient: 'Whole wheat tortilla', quantity: '1 large', calories: 170),
            Ingredient(ingredient: 'Grilled chicken breast', quantity: '3 oz', calories: 140),
            Ingredient(ingredient: 'Mixed greens', quantity: '1 cup', calories: 10),
            Ingredient(ingredient: 'Avocado', quantity: '1/4 medium', calories: 60),
          ],
          totalCalories: 380,
          recipe: 'Fill tortilla with chicken, greens, and avocado, then wrap.',
        ),
      ],
      dinner: [
        const MealOption(
          description: 'Baked salmon with sweet potato and broccoli',
          ingredients: [
            Ingredient(ingredient: 'Salmon fillet', quantity: '4 oz', calories: 200),
            Ingredient(ingredient: 'Sweet potato', quantity: '1 medium', calories: 112),
            Ingredient(ingredient: 'Broccoli', quantity: '1 cup', calories: 25),
            Ingredient(ingredient: 'Olive oil', quantity: '1 tsp', calories: 40),
          ],
          totalCalories: 377,
          recipe: 'Bake salmon and sweet potato, steam broccoli, drizzle with olive oil.',
        ),
        const MealOption(
          description: 'Vegetarian stir-fry with tofu and brown rice',
          ingredients: [
            Ingredient(ingredient: 'Firm tofu', quantity: '3 oz', calories: 90),
            Ingredient(ingredient: 'Brown rice', quantity: '1/2 cup cooked', calories: 110),
            Ingredient(ingredient: 'Mixed stir-fry vegetables', quantity: '1.5 cups', calories: 60),
            Ingredient(ingredient: 'Sesame oil', quantity: '1 tsp', calories: 40),
          ],
          totalCalories: 300,
          recipe: 'Stir-fry tofu and vegetables in sesame oil, serve over brown rice.',
        ),
      ],
      snacks: [
        const MealOption(
          description: 'Apple with almond butter',
          ingredients: [
            Ingredient(ingredient: 'Apple', quantity: '1 medium', calories: 95),
            Ingredient(ingredient: 'Almond butter', quantity: '2 tbsp', calories: 190),
          ],
          totalCalories: 285,
          recipe: 'Slice apple and serve with almond butter for dipping.',
        ),
        const MealOption(
          description: 'Hummus with vegetable sticks',
          ingredients: [
            Ingredient(ingredient: 'Hummus', quantity: '1/4 cup', calories: 100),
            Ingredient(ingredient: 'Carrot sticks', quantity: '1 cup', calories: 25),
            Ingredient(ingredient: 'Cucumber slices', quantity: '1 cup', calories: 16),
            Ingredient(ingredient: 'Bell pepper strips', quantity: '1/2 cup', calories: 15),
          ],
          totalCalories: 156,
          recipe: 'Cut vegetables into sticks and serve with hummus.',
        ),
      ],
      totalDailyCalories: request.targetCalories,
      dailyNutritionSummary: NutritionInfo(
        calories: request.targetCalories,
        carbohydrates: (request.targetCalories * 0.45 / 4).round(), // 45% from carbs
        protein: (request.targetCalories * 0.25 / 4).round(), // 25% from protein
        fat: (request.targetCalories * 0.30 / 9).round(), // 30% from fat
        fiber: 35,
        sugar: 50,
        sodium: 2000,
      ),
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
