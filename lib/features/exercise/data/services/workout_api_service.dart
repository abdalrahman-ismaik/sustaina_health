import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_models.dart';

class WorkoutApiService {
  // Change this URL to match your actual API server
  static const String _baseUrl = 'http://10.0.2.2:8000'; // for Android emulator

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

      // If network error, return mock data for testing
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        print('API server not available, using mock data for testing');
        return _getMockWorkoutPlan(request);
      }

      throw WorkoutApiException('Network error: ${e.toString()}');
    }
  }

  // Mock workout plan for testing when API is not available
  WorkoutPlan _getMockWorkoutPlan(WorkoutGenerationRequest request) {
    return WorkoutPlan(
      warmup: const WorkoutComponent(
        description:
            "Begin with 5 minutes of light cardio (e.g., jumping jacks, marching in place, arm circles) to elevate heart rate and warm up muscles. Follow with 3 minutes of dynamic stretches such as leg swings, torso twists, and cat-cow stretches to prepare joints and increase mobility.",
        duration: 8,
      ),
      cardio: const WorkoutComponent(
        description:
            "Perform 15 minutes of low-intensity steady-state cardio on non-lifting days or after your strength sessions. This can include brisk walking, cycling, or using an elliptical at a comfortable pace to support cardiovascular health without hindering muscle growth.",
        duration: 15,
      ),
      sessionsPerWeek: request.workoutsPerWeek,
      workoutSessions: [
        WorkoutSession(
          exercises: [
            const Exercise(name: "Push-ups", sets: 3, reps: "10-12", rest: 60),
            const Exercise(name: "Squats", sets: 3, reps: "12-15", rest: 90),
            const Exercise(
                name: "Plank", sets: 3, reps: "30-45 seconds", rest: 60),
            const Exercise(
                name: "Lunges", sets: 3, reps: "10 per leg", rest: 75),
          ],
        ),
        WorkoutSession(
          exercises: [
            const Exercise(name: "Burpees", sets: 3, reps: "8-10", rest: 90),
            const Exercise(
                name: "Mountain Climbers", sets: 3, reps: "20 reps", rest: 60),
            const Exercise(
                name: "Jump Squats", sets: 3, reps: "12-15", rest: 75),
            const Exercise(
                name: "High Knees", sets: 3, reps: "30 seconds", rest: 45),
          ],
        ),
        WorkoutSession(
          exercises: [
            const Exercise(
                name: "Bicycle Crunches",
                sets: 3,
                reps: "15 per side",
                rest: 60),
            const Exercise(
                name: "Russian Twists", sets: 3, reps: "20 reps", rest: 60),
            const Exercise(
                name: "Dead Bug", sets: 3, reps: "10 per side", rest: 75),
            const Exercise(
                name: "Bird Dog", sets: 3, reps: "8 per side", rest: 60),
          ],
        ),
      ],
      cooldown: const WorkoutComponent(
        description:
            "Conclude each workout with 8 minutes of static stretching, holding each stretch for 20-30 seconds. Focus on major muscle groups worked, including hamstrings, quads, chest, shoulders, and back, to aid flexibility and recovery.",
        duration: 8,
      ),
    );
  }

  // Health check method to verify API availability
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
}

class WorkoutApiException implements Exception {
  final String message;
  final int? statusCode;

  const WorkoutApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
