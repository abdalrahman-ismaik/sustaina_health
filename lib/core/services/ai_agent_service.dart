import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/exercise/data/models/workout_models.dart';
import '../../features/nutrition/data/models/nutrition_models.dart';
import '../../features/exercise/data/services/firestore_workout_service.dart';
import '../../features/nutrition/data/services/firestore_nutrition_service.dart';

class AIAgentService {
  // Update this URL to your actual API endpoint
  static const String _baseUrl = 'https://fitness-tribe-ai-4s89.onrender.com';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreWorkoutService _workoutService = FirestoreWorkoutService();
  final FirestoreNutritionService _nutritionService = FirestoreNutritionService();
  
  // Store the last response data for potential saving
  AIAgentResponse? _lastResponse;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// Send a message to the AI agent and get a response
  Future<AIAgentResponse> sendMessage(String userMessage) async {
    try {
      // Build URL with query parameters
      final Uri uri = Uri.parse('$_baseUrl/agent/generate').replace(
        queryParameters: <String, String>{
          'user_message': userMessage,
          'user_id': _userId,
        },
      );
      
      // Debug logging
      print('AI Agent Request URL: $uri');
      
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 200),
        onTimeout: () {
          throw AIAgentException('Request timeout');
        },
      );

      // Debug logging for response
      print('AI Agent Response Status: ${response.statusCode}');
      print('AI Agent Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return AIAgentResponse.fromJson(data);
      } else {
        throw AIAgentException(
          'Failed to get AI response: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIAgentException) {
        rethrow;
      }

      // If network error, return mock response for testing
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        print('AI Agent API server not available, using mock response for testing');
        return _getMockResponse(userMessage);
      }

      throw AIAgentException('Network error: ${e.toString()}');
    }
  }

  /// Process the AI response and return formatted text with save options
  Future<String> processAIResponse(AIAgentResponse response) async {
    // Store the response for potential saving
    _lastResponse = response;
    
    if (response.data != null) {
      // Check if it's a workout plan or meal plan but don't save automatically
      if (_isWorkoutPlan(response.data!)) {
        return '${response.text}\n\n📋 I\'ve generated a workout plan for you! Would you like to save it to your library?';
      } else if (_isMealPlan(response.data!)) {
        return '${response.text}\n\n🍽️ I\'ve created a meal plan for you! Would you like to save it to your library?';
      }
    }
    
    // No data to save, just return the text response
    return response.text;
  }

  /// Check if the last response contains a saveable plan
  bool get hasLastPlan => _lastResponse?.data != null;
  
  /// Check if the last response is a workout plan
  bool get isLastResponseWorkout => _lastResponse?.data != null && _isWorkoutPlan(_lastResponse!.data!);
  
  /// Check if the last response is a meal plan
  bool get isLastResponseMeal => _lastResponse?.data != null && _isMealPlan(_lastResponse!.data!);
  
  /// Get the last response data for viewing
  Map<String, dynamic>? get lastResponseData => _lastResponse?.data;

  /// Save the last generated workout plan to Firebase
  Future<void> saveLastWorkoutPlan() async {
    if (_lastResponse?.data == null || !_isWorkoutPlan(_lastResponse!.data!)) {
      throw Exception('No workout plan to save');
    }
    await saveWorkoutPlan(_lastResponse!.data!);
  }

  /// Save the last generated meal plan to Firebase
  Future<void> saveLastMealPlan() async {
    if (_lastResponse?.data == null || !_isMealPlan(_lastResponse!.data!)) {
      throw Exception('No meal plan to save');
    }
    await saveMealPlan(_lastResponse!.data!);
  }

  /// Save workout plan to Firebase (called when user confirms)
  Future<void> saveWorkoutPlan(Map<String, dynamic> data) async {
    try {
      print('AIAgentService: Attempting to save workout plan');
      print('AIAgentService: Data structure: ${data.keys.toList()}');
      print('AIAgentService: Using FirebaseWorkoutService to save to workout_plans collection');
      
      // Transform the API response to match our WorkoutPlan model
      final Map<String, dynamic> transformedData = _transformWorkoutPlanData(data);
      print('AIAgentService: Transformed data structure: ${transformedData.keys.toList()}');
      
      final WorkoutPlan workoutPlan = WorkoutPlan.fromJson(transformedData);
      final String planName = 'AI Generated Workout - ${DateTime.now().toLocal().toString().split(' ')[0]}';
      
      print('AIAgentService: Created WorkoutPlan object successfully');
      print('AIAgentService: Plan name: $planName');
      print('AIAgentService: Calling FirestoreWorkoutService.saveWorkoutPlan()...');
      
      // Create SavedWorkoutPlan object that FirestoreWorkoutService expects
      final SavedWorkoutPlan savedWorkoutPlan = SavedWorkoutPlan(
        id: '', // Will be set by Firestore
        userId: _userId,
        name: planName,
        workoutPlan: workoutPlan,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        isFavorite: false,
      );
      
      final String savedId = await _workoutService.saveWorkoutPlan(savedWorkoutPlan);
      
      print('AIAgentService: Workout plan saved successfully with ID: $savedId');
      print('AIAgentService: Plan saved to Firestore path: users/$_userId/exercise/data/workout_plans');
    } catch (e) {
      print('AIAgentService: Error saving workout plan: $e');
      print('AIAgentService: Stack trace: ${StackTrace.current}');
      throw Exception('Failed to save workout plan: $e');
    }
  }

  /// Transform API response data to match our WorkoutPlan model
  Map<String, dynamic> _transformWorkoutPlanData(Map<String, dynamic> apiData) {
    print('AIAgentService: Starting data transformation...');
    print('AIAgentService: Original sessions count: ${(apiData['workout_sessions'] as List).length}');
    
    // Transform workout sessions to remove exercise_id and ensure proper structure
    final List<Map<String, dynamic>> transformedSessions = 
        (apiData['workout_sessions'] as List).map<Map<String, dynamic>>((session) {
      final List<Map<String, dynamic>> transformedExercises = 
          (session['exercises'] as List).map<Map<String, dynamic>>((exercise) {
        print('AIAgentService: Transforming exercise: ${exercise['name']}');
        // Remove exercise_id and keep only the fields our Exercise model expects
        return <String, dynamic>{
          'name': exercise['name'],
          'sets': exercise['sets'],
          'reps': exercise['reps'].toString(), // Ensure it's a string
          'rest': exercise['rest'],
        };
      }).toList();
      
      print('AIAgentService: Session has ${transformedExercises.length} exercises');
      return <String, dynamic>{
        'exercises': transformedExercises,
      };
    }).toList();

    final Map<String, dynamic> result = <String, dynamic>{
      'warmup': apiData['warmup'],
      'cardio': apiData['cardio'],
      'sessions_per_week': apiData['sessions_per_week'],
      'workout_sessions': transformedSessions,
      'cooldown': apiData['cooldown'],
    };
    
    print('AIAgentService: Transformation complete. Transformed sessions count: ${transformedSessions.length}');
    return result;
  }

  /// Save meal plan to Firebase (called when user confirms)
  Future<void> saveMealPlan(Map<String, dynamic> data) async {
    try {
      print('AIAgentService: Attempting to save meal plan');
      print('AIAgentService: Data structure: ${data.keys.toList()}');
      
      final MealPlanResponse mealPlan = MealPlanResponse.fromJson(data);
      final String planId = 'ai_generated_${DateTime.now().millisecondsSinceEpoch}';
      
      print('AIAgentService: Created MealPlanResponse object successfully');
      print('AIAgentService: Plan ID: $planId');
      
      await _nutritionService.saveMealPlan(planId, mealPlan);
      
      print('AIAgentService: Meal plan saved successfully with ID: $planId');
    } catch (e) {
      print('AIAgentService: Error saving meal plan: $e');
      throw Exception('Failed to save meal plan: $e');
    }
  }

  /// Check if the data represents a workout plan
  bool _isWorkoutPlan(Map<String, dynamic> data) {
    // Look for workout plan specific fields in API response
    return data.containsKey('workout_sessions') &&
           data.containsKey('warmup') &&
           data.containsKey('cooldown') &&
           data.containsKey('sessions_per_week');
  }

  /// Check if the data represents a meal plan
  bool _isMealPlan(Map<String, dynamic> data) {
    // Look for meal plan specific fields
    return data.containsKey('daily_meal_plans') ||
           data.containsKey('daily_calories_range') ||
           data.containsKey('macronutrients_range') ||
           data.containsKey('breakfast') ||
           data.containsKey('lunch') ||
           data.containsKey('dinner');
  }

  /// Generate a mock response for testing when API is not available
  AIAgentResponse _getMockResponse(String userMessage) {
    final String lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('workout') || lowerMessage.contains('exercise')) {
      // Return a mock workout plan
      return AIAgentResponse(
        text: 'I\'ve created a personalized workout plan for you! This includes strength training and cardio exercises tailored to your fitness level.',
        data: _getMockWorkoutPlan(),
      );
    } else if (lowerMessage.contains('meal') || lowerMessage.contains('nutrition') || lowerMessage.contains('diet')) {
      // Return a mock meal plan
      return AIAgentResponse(
        text: 'Here\'s a personalized 3-day meal plan designed to meet your nutritional goals with sustainable and healthy options!',
        data: _getMockMealPlan(),
      );
    } else {
      // Return just analysis text
      return AIAgentResponse(
        text: _generateAnalysisResponse(userMessage),
        data: null,
      );
    }
  }

  /// Generate analysis response for non-generation requests
  String _generateAnalysisResponse(String message) {
    final String lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('sleep')) {
      return 'Based on your query about sleep, I recommend maintaining a consistent sleep schedule of 7-9 hours per night. Good sleep hygiene includes avoiding screens before bedtime, keeping your room cool and dark, and establishing a relaxing bedtime routine.';
    } else if (lowerMessage.contains('sustainability') || lowerMessage.contains('environment')) {
      return 'Great question about sustainability! Small daily choices can make a big impact. Consider eating more plant-based meals, using reusable containers, walking or cycling for short trips, and choosing locally sourced foods when possible.';
    } else if (lowerMessage.contains('health') || lowerMessage.contains('wellness')) {
      return 'For optimal health and wellness, focus on a balanced approach: regular physical activity, nutritious whole foods, adequate sleep, stress management, and staying hydrated. Remember that small, consistent changes lead to lasting results.';
    } else {
      return 'I\'m here to help with health, fitness, nutrition, and sustainability advice. Could you be more specific about what you\'d like to know? I can create personalized workout plans, meal plans, or provide health guidance.';
    }
  }

  /// Mock workout plan data
  Map<String, dynamic> _getMockWorkoutPlan() {
    return <String, dynamic>{
      'warmup': <String, dynamic>{
        'description': 'Dynamic stretching and light cardio',
        'duration': 10,
      },
      'cardio': <String, dynamic>{
        'description': 'Moderate intensity cardio',
        'duration': 20,
      },
      'sessions_per_week': 3,
      'workout_sessions': <Map<String, dynamic>>[
        <String, dynamic>{
          'exercises': [
            <String, dynamic>{
              'name': 'Push-ups',
              'sets': 3,
              'reps': '12-15',
              'rest': 60,
            },
            <String, dynamic>{
              'name': 'Squats',
              'sets': 3,
              'reps': '15-20',
              'rest': 60,
            },
            <String, dynamic>{
              'name': 'Plank',
              'sets': 3,
              'reps': '30-45 seconds',
              'rest': 45,
            },
          ],
        },
        <String, dynamic>{
          'exercises': [
            <String, dynamic>{
              'name': 'Lunges',
              'sets': 3,
              'reps': '12 each leg',
              'rest': 60,
            },
            <String, dynamic>{
              'name': 'Mountain Climbers',
              'sets': 3,
              'reps': '20-30',
              'rest': 45,
            },
            <String, dynamic>{
              'name': 'Burpees',
              'sets': 2,
              'reps': '8-12',
              'rest': 90,
            },
          ],
        },
      ],
      'cooldown': <String, dynamic>{
        'description': 'Static stretching and relaxation',
        'duration': 10,
      },
    };
  }

  /// Mock meal plan data
  Map<String, dynamic> _getMockMealPlan() {
    return <String, dynamic>{
      'daily_calories_range': <String, int>{
        'min': 1400,
        'max': 1600,
      },
      'macronutrients_range': <String, Map<String, int>>{
        'protein': <String, int>{'min': 70, 'max': 90},
        'carbohydrates': <String, int>{'min': 150, 'max': 200},
        'fat': <String, int>{'min': 50, 'max': 65},
      },
      'total_days': 3,
      'daily_meal_plans': <Map<String, dynamic>>[
        <String, dynamic>{
          'day': 1,
          'date': DateTime.now().toIso8601String().split('T')[0],
          'breakfast': <String, dynamic>{
            'description': 'Oatmeal with Berries and Almonds',
            'total_calories': 425,
            'recipe': 'Cook oats with milk, top with berries and almonds, drizzle with honey.',
            'ingredients': <Map<String, dynamic>>[
              <String, dynamic>{'ingredient': 'Rolled oats', 'quantity': '1/2 cup', 'calories': 150},
              <String, dynamic>{'ingredient': 'Mixed berries', 'quantity': '1/2 cup', 'calories': 40},
              <String, dynamic>{'ingredient': 'Almonds', 'quantity': '1/4 cup', 'calories': 160},
              <String, dynamic>{'ingredient': 'Honey', 'quantity': '1 tbsp', 'calories': 65},
            ],
            'suggested_brands': <String>['Quaker Oats', 'Nature Valley'],
          },
          'lunch': <String, dynamic>{
            'description': 'Quinoa Salad with Chickpeas',
            'total_calories': 385,
            'recipe': 'Mix cooked quinoa with chickpeas, vegetables, and olive oil dressing.',
            'ingredients': <Map<String, dynamic>>[
              <String, dynamic>{'ingredient': 'Quinoa', 'quantity': '1/2 cup cooked', 'calories': 110},
              <String, dynamic>{'ingredient': 'Chickpeas', 'quantity': '1/2 cup', 'calories': 135},
              <String, dynamic>{'ingredient': 'Mixed vegetables', 'quantity': '1 cup', 'calories': 25},
              <String, dynamic>{'ingredient': 'Olive oil', 'quantity': '1 tbsp', 'calories': 115},
            ],
            'suggested_brands': <String>['Eden Organic', 'Bertolli'],
          },
          'dinner': <String, dynamic>{
            'description': 'Grilled Salmon with Sweet Potato',
            'total_calories': 520,
            'recipe': 'Grill salmon fillet, roast sweet potato, steam broccoli.',
            'ingredients': <Map<String, dynamic>>[
              <String, dynamic>{'ingredient': 'Salmon fillet', 'quantity': '6 oz', 'calories': 350},
              <String, dynamic>{'ingredient': 'Sweet potato', 'quantity': '1 medium', 'calories': 100},
              <String, dynamic>{'ingredient': 'Broccoli', 'quantity': '1 cup', 'calories': 25},
              <String, dynamic>{'ingredient': 'Olive oil', 'quantity': '1 tbsp', 'calories': 45},
            ],
            'suggested_brands': <String>['Wild Planet', 'Organic Valley'],
          },
          'snacks': <Map<String, dynamic>>[
            <String, dynamic>{
              'description': 'Greek Yogurt with Nuts',
              'total_calories': 180,
              'recipe': 'Mix Greek yogurt with mixed nuts.',
              'ingredients': <Map<String, dynamic>>[
                <String, dynamic>{'ingredient': 'Greek yogurt', 'quantity': '3/4 cup', 'calories': 100},
                <String, dynamic>{'ingredient': 'Mixed nuts', 'quantity': '1/4 cup', 'calories': 80},
              ],
              'suggested_brands': <String>['Fage', 'Blue Diamond'],
            },
          ],
          'daily_macros': <String, int>{
            'protein': 80,
            'carbohydrates': 177,
            'fat': 57,
          },
          'total_daily_calories': 1510,
        },
      ],
    };
  }
}

/// AI Agent response model
class AIAgentResponse {
  final String text;
  final Map<String, dynamic>? data;

  const AIAgentResponse({
    required this.text,
    this.data,
  });

  factory AIAgentResponse.fromJson(Map<String, dynamic> json) {
    return AIAgentResponse(
      text: json['text'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'data': data,
    };
  }
}

/// Exception for AI Agent API errors
class AIAgentException implements Exception {
  final String message;
  final int? statusCode;

  const AIAgentException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
