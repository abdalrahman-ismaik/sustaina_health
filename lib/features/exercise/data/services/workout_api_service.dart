import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_models.dart';

class WorkoutApiService {
  // Deployed fitness-tribe-ai server
  static const String _baseUrl = 'https://fitness-tribe-ai-4s89.onrender.com';
  // Previously used local URL: 'http://10.0.2.2:8000' for Android emulator

  Future<WorkoutPlan> generateWorkout(WorkoutGenerationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workout-plans/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return WorkoutPlan.fromJson(data);
      } else {
        throw WorkoutApiException(
          'Failed to generate workout: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is WorkoutApiException) {
        rethrow;
      }

      // If network error, throw meaningful error
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw WorkoutApiException(
          'Unable to connect to workout generation service. Please check your internet connection and try again.',
          statusCode: 503,
        );
      }

      throw WorkoutApiException('Network error: ${e.toString()}');
    }
  }



  // Health check method to verify API availability
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
}

class WorkoutApiException implements Exception {
  final String message;
  final int? statusCode;

  const WorkoutApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
