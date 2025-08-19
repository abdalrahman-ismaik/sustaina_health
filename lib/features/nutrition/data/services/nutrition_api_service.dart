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

  /// Get sustainable brand recommendations for a specific product
  Future<RecommendedBrands> getBrandRecommendations(String product) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/recommendations/brands?product=${Uri.encodeComponent(product)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw NutritionApiException('Request timeout');
        },
      );

      print(
          'Brand recommendations response status: ${response.statusCode}'); // Debug log
      print(
          'Brand recommendations response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return RecommendedBrands.fromJson(data);
      } else {
        throw NutritionApiException(
          'Failed to get brand recommendations: ${response.statusCode}',
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
        print(
            'API server not available, using mock brand recommendations for testing');
        return _getMockBrandRecommendations(product);
      }

      throw NutritionApiException('Network error: ${e.toString()}');
    }
  }

  // Mock meal analysis for testing when API is not available
  MealAnalysisResponse _getMockMealAnalysis() {
    return const MealAnalysisResponse(
      foodName: "Chicken Pesto Fusilli with Cherry Tomatoes",
      totalCalories: 780,
      caloriesPerIngredient: {
        "Fusilli Pasta": 340,
        "Grilled Chicken Breast": 192,
        "Pesto Sauce": 237,
        "Cherry Tomatoes": 11
      },
      sustainability: SustainabilityInfo(
        environmentalImpact: "medium",
        nutritionImpact: "high",
        overallScore: 70,
        description:
            "A balanced meal with good protein and energy, though the chicken and dairy in pesto contribute to a moderate environmental footprint.",
      ),
      totalProtein: 52,
      totalCarbohydrates: 68,
      totalFats: 31,
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

  // Mock brand recommendations for testing when API is not available
  RecommendedBrands _getMockBrandRecommendations(String product) {
    // Generate mock recommendations based on product type
    final mockBrands = <RecommendedBrand>[];

    if (product.toLowerCase().contains('olive oil')) {
      mockBrands.addAll([
        const RecommendedBrand(
          name: 'Al Jouf Organic Olive Oil',
          price: 45.0,
          sustainabilityRating: 'A+',
          description:
              'Premium organic extra virgin olive oil from UAE local farms. Cold-pressed and sustainably produced with minimal environmental impact.',
        ),
        const RecommendedBrand(
          name: 'Emirates Gold Olive Oil',
          price: 38.0,
          sustainabilityRating: 'A',
          description:
              'High-quality olive oil sourced from sustainable farms in the Mediterranean. Available in UAE with eco-friendly packaging.',
        ),
        const RecommendedBrand(
          name: 'Green Valley Organic',
          price: 52.0,
          sustainabilityRating: 'A+',
          description:
              'Certified organic olive oil with zero-waste production methods. Supports local sustainable agriculture initiatives in the region.',
        ),
      ]);
    } else if (product.toLowerCase().contains('rice') ||
        product.toLowerCase().contains('grain')) {
      mockBrands.addAll([
        const RecommendedBrand(
          name: 'Emirates Organic Rice',
          price: 25.0,
          sustainabilityRating: 'A',
          description:
              'Locally sourced organic basmati rice. Grown using sustainable farming practices with reduced water consumption.',
        ),
        const RecommendedBrand(
          name: 'Al Ain Farms Brown Rice',
          price: 22.0,
          sustainabilityRating: 'B+',
          description:
              'Whole grain brown rice from organic farms. Packaging made from recyclable materials, supporting circular economy.',
        ),
        const RecommendedBrand(
          name: 'Desert Bloom Quinoa',
          price: 35.0,
          sustainabilityRating: 'A+',
          description:
              'Premium quinoa alternative to rice. High protein content and grown with minimal water usage in arid-adapted farms.',
        ),
      ]);
    } else {
      // Generic sustainable food recommendations for UAE market
      mockBrands.addAll([
        RecommendedBrand(
          name: 'UAE Organic Choice',
          price: 30.0,
          sustainabilityRating: 'A',
          description:
              'Local sustainable alternative for $product. Certified organic and ethically sourced from UAE suppliers.',
        ),
        RecommendedBrand(
          name: 'Emirates Green Brand',
          price: 28.0,
          sustainabilityRating: 'B+',
          description:
              'Eco-friendly $product option. Supports local farmers and uses sustainable packaging materials.',
        ),
        RecommendedBrand(
          name: 'Sustainable Emirates',
          price: 35.0,
          sustainabilityRating: 'A+',
          description:
              'Premium sustainable $product. Zero-waste production and carbon-neutral shipping across the UAE.',
        ),
      ]);
    }

    return RecommendedBrands(brands: mockBrands);
  }
}
