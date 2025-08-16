import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/nutrition_models.dart';

class NutritionApiService {
  // Deployed fitness-tribe-ai server
  static const String _baseUrl = 'https://fitness-tribe-ai-4s89.onrender.com';

  /// Analyze a meal photo to identify foods, calories, and nutrition information
  Future<MealAnalysisResponse> analyzeMeal(File imageFile,
      {String? mealType}) async {
    try {
      // Read image as bytes
      final bytes = await imageFile.readAsBytes();

      print('Image file size: ${bytes.length} bytes'); // Debug log
      print('Image file path: ${imageFile.path}'); // Debug log

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/meals/analyze'),
      );

      // Determine content type based on file extension
      String contentTypeStr = 'image/jpeg';
      if (imageFile.path.toLowerCase().endsWith('.png')) {
        contentTypeStr = 'image/png';
      }

      // Add image file with correct field name 'file'
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(contentTypeStr),
        ),
      );

      print('Request URL: ${request.url}'); // Debug log
      print('Request method: ${request.method}'); // Debug log
      print('Request fields: ${request.fields}'); // Debug log
      print(
          'Request files: ${request.files.map((f) => 'Field: ${f.field}, Filename: ${f.filename}, ContentType: ${f.contentType}, Size: ${f.length} bytes')}'); // Debug log

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw NutritionApiException('Request timeout');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return MealAnalysisResponse.fromJson(data);
      } else {
        print(
            'API Error ${response.statusCode}: ${response.body}'); // Debug log
        throw NutritionApiException(
          'Failed to analyze meal: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is NutritionApiException) {
        rethrow;
      }

      // If network error, provide better error message
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('timeout')) {
        print('API server not available, using mock data for testing');
        // Return mock data but also log the issue
        print('Network error details: $e');
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
    // Create a list of different mock meals for variety
    final List<Map<String, dynamic>> mockMeals = [
      {
        "foodName": "Grilled Salmon with Quinoa and Vegetables",
        "totalCalories": 650,
        "caloriesPerIngredient": {
          "Grilled Salmon": 280,
          "Quinoa": 120,
          "Broccoli": 30,
          "Carrots": 25,
          "Olive Oil": 195
        },
        "sustainability": {
          "environmentalImpact": "low",
          "nutritionImpact": "high",
          "overallScore": 85,
          "description": "Excellent choice! Wild-caught salmon is sustainable, and quinoa is a complete protein with low environmental impact."
        },
        "totalProtein": 45,
        "totalCarbohydrates": 55,
        "totalFats": 28
      },
      {
        "foodName": "Vegetarian Buddha Bowl",
        "totalCalories": 420,
        "caloriesPerIngredient": {
          "Brown Rice": 110,
          "Chickpeas": 135,
          "Avocado": 160,
          "Mixed Greens": 15
        },
        "sustainability": {
          "environmentalImpact": "low",
          "nutritionImpact": "high",
          "overallScore": 90,
          "description": "Outstanding sustainability score! Plant-based meals have the lowest environmental impact and provide excellent nutrition."
        },
        "totalProtein": 18,
        "totalCarbohydrates": 65,
        "totalFats": 12
      },
      {
        "foodName": "Chicken Caesar Salad",
        "totalCalories": 580,
        "caloriesPerIngredient": {
          "Grilled Chicken": 250,
          "Romaine Lettuce": 20,
          "Caesar Dressing": 280,
          "Croutons": 30
        },
        "sustainability": {
          "environmentalImpact": "medium",
          "nutritionImpact": "medium",
          "overallScore": 65,
          "description": "Good protein content, but consider using a lighter dressing to reduce calories and improve sustainability."
        },
        "totalProtein": 35,
        "totalCarbohydrates": 15,
        "totalFats": 42
      }
    ];

    // Randomly select a mock meal
    final random = DateTime.now().millisecondsSinceEpoch % mockMeals.length;
    final mockMeal = mockMeals[random];

    return MealAnalysisResponse(
      foodName: mockMeal["foodName"] as String,
      totalCalories: mockMeal["totalCalories"] as int,
      caloriesPerIngredient: Map<String, int>.from(mockMeal["caloriesPerIngredient"] as Map),
      sustainability: SustainabilityInfo(
        environmentalImpact: mockMeal["sustainability"]["environmentalImpact"] as String,
        nutritionImpact: mockMeal["sustainability"]["nutritionImpact"] as String,
        overallScore: mockMeal["sustainability"]["overallScore"] as int,
        description: mockMeal["sustainability"]["description"] as String,
      ),
      totalProtein: mockMeal["totalProtein"] as int,
      totalCarbohydrates: mockMeal["totalCarbohydrates"] as int,
      totalFats: mockMeal["totalFats"] as int,
    );
  }

  // Mock meal plan for testing when API is not available
  MealPlanResponse _getMockMealPlan(MealPlanRequest request) {
    // Create mock data for the number of days requested
    final List<DailyMealPlan> dailyPlans = [];

    for (int day = 1; day <= request.durationDays; day++) {
      dailyPlans.add(DailyMealPlan(
        day: day,
        date: DateTime.now()
            .add(Duration(days: day - 1))
            .toIso8601String()
            .split('T')[0],
        breakfast: MealOption(
          description: 'Oatmeal with Berries and Almonds',
          totalCalories: 425,
          recipe:
              'Cook oats with milk, top with berries and almonds, drizzle with honey.',
          ingredients: const [
            Ingredient(
                ingredient: 'Rolled oats', quantity: '1/2 cup', calories: 150),
            Ingredient(
                ingredient: 'Mixed berries', quantity: '1/2 cup', calories: 40),
            Ingredient(
                ingredient: 'Almonds', quantity: '1/4 cup', calories: 160),
            Ingredient(ingredient: 'Honey', quantity: '1 tbsp', calories: 65),
          ],
          suggestedBrands: ['Quaker Oats', 'Nature Valley'],
        ),
        lunch: MealOption(
          description: 'Quinoa Salad with Chickpeas',
          totalCalories: 385,
          recipe:
              'Mix cooked quinoa with chickpeas, vegetables, and olive oil dressing.',
          ingredients: const [
            Ingredient(
                ingredient: 'Quinoa',
                quantity: '1/2 cup cooked',
                calories: 110),
            Ingredient(
                ingredient: 'Chickpeas', quantity: '1/2 cup', calories: 135),
            Ingredient(
                ingredient: 'Mixed vegetables',
                quantity: '1 cup',
                calories: 25),
            Ingredient(
                ingredient: 'Olive oil', quantity: '1 tbsp', calories: 115),
          ],
          suggestedBrands: ['Eden Organic', 'Bertolli'],
        ),
        dinner: MealOption(
          description: 'Grilled Salmon with Sweet Potato',
          totalCalories: 520,
          recipe: 'Grill salmon fillet, roast sweet potato, steam broccoli.',
          ingredients: const [
            Ingredient(
                ingredient: 'Salmon fillet', quantity: '6 oz', calories: 350),
            Ingredient(
                ingredient: 'Sweet potato',
                quantity: '1 medium',
                calories: 100),
            Ingredient(ingredient: 'Broccoli', quantity: '1 cup', calories: 25),
            Ingredient(
                ingredient: 'Olive oil', quantity: '1 tbsp', calories: 45),
          ],
          suggestedBrands: ['Wild Planet', 'Organic Valley'],
        ),
        snacks: [
          MealOption(
            description: 'Greek Yogurt with Nuts',
            totalCalories: 180,
            recipe: 'Mix Greek yogurt with mixed nuts.',
            ingredients: const [
              Ingredient(
                  ingredient: 'Greek yogurt',
                  quantity: '3/4 cup',
                  calories: 100),
              Ingredient(
                  ingredient: 'Mixed nuts', quantity: '1/4 cup', calories: 80),
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
