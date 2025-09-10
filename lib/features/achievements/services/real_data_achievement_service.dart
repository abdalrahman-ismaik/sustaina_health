import 'package:flutter/material.dart';
import '../data/repositories/achievement_repository.dart';
import '../data/models/achievement_model.dart';
import '../../exercise/data/services/workout_session_service.dart';
import '../../exercise/data/models/workout_models.dart';
import '../../sleep/data/services/sleep_service_hybrid.dart';
import '../../sleep/data/models/sleep_models.dart';
import '../../nutrition/data/services/firestore_nutrition_service.dart';
import '../../nutrition/data/models/nutrition_models.dart';
import '../../profile/data/services/carbon_footprint_service.dart';

/// Enhanced Achievement Service that fetches real data from various modules
class RealDataAchievementService {
  final AchievementRepository _repository = AchievementRepository();
  final WorkoutSessionService _workoutSessionService = WorkoutSessionService();
  final SleepService _sleepService = SleepService();
  final FirestoreNutritionService _nutritionService = FirestoreNutritionService();
  final CarbonFootprintService _carbonService = CarbonFootprintService();
  
  /// Get comprehensive sustainability stats with real data
  Stream<SustainabilityStats> watchStats() async* {
    try {
      // Fetch data from all modules
      final statsData = await _fetchAllStatsData();
      
      // Calculate comprehensive stats
      final stats = _calculateStatsFromRealData(statsData);
      
      yield stats;
      
      // Set up periodic updates every 30 seconds
      await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
        try {
          final updatedData = await _fetchAllStatsData();
          final updatedStats = _calculateStatsFromRealData(updatedData);
          yield updatedStats;
        } catch (e) {
          print('Error updating stats: $e');
          // Continue with last known stats
        }
      }
    } catch (e) {
      print('Error watching stats: $e');
      // Yield default stats if there's an error
      yield const SustainabilityStats();
    }
  }

  /// Fetch data from all modules
  Future<Map<String, dynamic>> _fetchAllStatsData() async {
    try {
      final results = await Future.wait([
        _fetchWorkoutData(),
        _fetchSleepData(),
        _fetchNutritionData(),
        _fetchCarbonData(),
        _repository.getStats(), // Get current achievement stats
      ]);

      return {
        'workouts': results[0],
        'sleep': results[1],
        'nutrition': results[2],
        'carbon': results[3],
        'achievements': results[4],
      };
    } catch (e) {
      print('Error fetching stats data: $e');
      return {
        'workouts': <ActiveWorkoutSession>[],
        'sleep': <SleepSession>[],
        'nutrition': <FoodLogEntry>[],
        'carbon': <String, double>{},
        'achievements': const SustainabilityStats(),
      };
    }
  }

  /// Fetch workout data (completed workouts)
  Future<List<ActiveWorkoutSession>> _fetchWorkoutData() async {
    try {
      // Try to get from workout session service 
      try {
        return await _workoutSessionService.getCompletedWorkouts();
      } catch (e) {
        print('Could not fetch workouts: $e');
        return <ActiveWorkoutSession>[];
      }
    } catch (e) {
      print('Error fetching workout data: $e');
      return <ActiveWorkoutSession>[];
    }
  }

  /// Fetch sleep data
  Future<List<SleepSession>> _fetchSleepData() async {
    try {
      final sessions = await _sleepService.getSleepSessions();
      // Filter sessions from last 30 days for relevant calculations
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      return sessions.where((session) => 
        session.startTime.isAfter(thirtyDaysAgo)
      ).toList();
    } catch (e) {
      print('Error fetching sleep data: $e');
      return <SleepSession>[];
    }
  }

  /// Fetch nutrition data
  Future<List<FoodLogEntry>> _fetchNutritionData() async {
    try {
      await _nutritionService.ensureNutritionModuleExists();
      final entries = await _nutritionService.getAllFoodLogEntries();
      
      // Filter entries from last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      return entries.where((entry) => 
        entry.loggedAt.isAfter(thirtyDaysAgo)
      ).toList();
    } catch (e) {
      print('Error fetching nutrition data: $e');
      return <FoodLogEntry>[];
    }
  }

  /// Fetch carbon footprint data
  Future<Map<String, double>> _fetchCarbonData() async {
    try {
      // Get carbon savings from the main carbon service
      final carbonData = await _carbonService.calculateTotalCarbonSaved();
      
      return {
        'workout': carbonData.workoutContribution,
        'nutrition': carbonData.foodContribution,
        'sleep': carbonData.sleepContribution,
        'total': carbonData.totalKgCO2Saved,
      };
    } catch (e) {
      print('Error fetching carbon data: $e');
      return {
        'workout': 0.0,
        'nutrition': 0.0,
        'sleep': 0.0,
        'total': 0.0,
      };
    }
  }

  /// Calculate comprehensive stats from real data
  SustainabilityStats _calculateStatsFromRealData(Map<String, dynamic> data) {
    final workouts = data['workouts'] as List<ActiveWorkoutSession>;
    final sleepSessions = data['sleep'] as List<SleepSession>;
    final nutritionEntries = data['nutrition'] as List<FoodLogEntry>;
    final carbonData = data['carbon'] as Map<String, double>;
    final currentStats = data['achievements'] as SustainabilityStats;

    // Calculate sustainable actions
    final sustainableActions = _calculateSustainableActions(
      workouts, sleepSessions, nutritionEntries
    );

    // Calculate local businesses supported
    final localBusinesses = _calculateLocalBusinessesSupported(nutritionEntries);

    // Calculate consistent streak across all modules
    final consistentStreak = _calculateConsistentStreak(
      workouts, sleepSessions, nutritionEntries
    );

    // Calculate total carbon saved
    final totalCarbonSaved = carbonData['total'] ?? 0.0;

    // Calculate total points (existing + new from activities)
    final newPoints = _calculateNewPoints(sustainableActions, consistentStreak, totalCarbonSaved);
    final totalPoints = currentStats.totalPoints + newPoints;

    return SustainabilityStats(
      totalPoints: totalPoints,
      carbonSaved: totalCarbonSaved,
      sustainableActions: sustainableActions,
      localBrandsSupported: localBusinesses,
      consecutiveDays: consistentStreak,
      totalAchievements: currentStats.totalAchievements,
      categoryProgress: _calculateCategoryProgress(workouts, sleepSessions, nutritionEntries),
      lastActivity: _getLastActivityTime(workouts, sleepSessions, nutritionEntries),
    );
  }

  /// Calculate sustainable actions from all modules
  int _calculateSustainableActions(
    List<ActiveWorkoutSession> workouts,
    List<SleepSession> sleepSessions,
    List<FoodLogEntry> nutritionEntries,
  ) {
    int count = 0;

    // Count completed workouts as sustainable actions
    count += workouts.where((w) => w.isCompleted).length;

    // Count good sleep sessions (6+ hours) as sustainable actions
    count += sleepSessions.where((session) {
      final hours = session.totalDuration.inHours;
      return hours >= 6;
    }).length;

    // Count sustainable food logs (good sustainability score)
    count += nutritionEntries.where((entry) {
      final score = double.tryParse(entry.sustainabilityScore ?? '0') ?? 0.0;
      return score >= 7.0; // Good sustainability score threshold
    }).length;

    return count;
  }

  /// Calculate local businesses supported from nutrition data
  int _calculateLocalBusinessesSupported(List<FoodLogEntry> nutritionEntries) {
    final localBrands = <String>{};
    
    for (final entry in nutritionEntries) {
      // For now, we'll estimate based on food names that might indicate local sources
      // This can be enhanced when we have better data structure for local businesses
      final foodName = entry.foodName.toLowerCase();
      if (foodName.contains('local') || 
          foodName.contains('farm') || 
          foodName.contains('organic') ||
          foodName.contains('artisan')) {
        localBrands.add(entry.foodName);
      }
    }
    
    return localBrands.length;
  }

  /// Calculate consistent streak across all health modules
  int _calculateConsistentStreak(
    List<ActiveWorkoutSession> workouts,
    List<SleepSession> sleepSessions,
    List<FoodLogEntry> nutritionEntries,
  ) {
    // Enhanced streak calculation that includes all sustainable activities
    // More comprehensive than home dashboard which only checks workouts
    
    if (workouts.isEmpty && sleepSessions.isEmpty && nutritionEntries.isEmpty) {
      return 0;
    }

    // Get all activity dates and sort them
    final Set<DateTime> activityDates = <DateTime>{};
    
    // Add workout dates
    for (final workout in workouts) {
      if (workout.isCompleted && workout.endTime != null) {
        final date = DateTime(
          workout.endTime!.year,
          workout.endTime!.month,
          workout.endTime!.day,
        );
        activityDates.add(date);
      }
    }

    // Add sleep dates (good sleep >= 6 hours)
    for (final session in sleepSessions) {
      if (session.totalDuration.inHours >= 6) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        activityDates.add(date);
      }
    }

    // Add nutrition dates (sustainable food logs)
    for (final entry in nutritionEntries) {
      final score = double.tryParse(entry.sustainabilityScore ?? '0') ?? 0.0;
      if (score >= 7.0) {
        final date = DateTime(
          entry.loggedAt.year,
          entry.loggedAt.month,
          entry.loggedAt.day,
        );
        activityDates.add(date);
      }
    }

    if (activityDates.isEmpty) return 0;

    // Sort dates in descending order
    final sortedDates = activityDates.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    DateTime currentDate = todayDate;

    for (final activityDate in sortedDates) {
      final daysDifference = currentDate.difference(activityDate).inDays;

      if (daysDifference <= 1) {
        streak++;
        currentDate = activityDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate new points from recent activities
  int _calculateNewPoints(int sustainableActions, int streak, double carbonSaved) {
    int points = 0;
    
    // Points for sustainable actions
    points += sustainableActions * 10;
    
    // Bonus points for streaks
    if (streak >= 7) points += 50;
    if (streak >= 30) points += 200;
    if (streak >= 100) points += 500;
    
    // Points for carbon savings
    points += (carbonSaved * 10).round();
    
    return points;
  }

  /// Calculate category progress
  Map<String, int> _calculateCategoryProgress(
    List<ActiveWorkoutSession> workouts,
    List<SleepSession> sleepSessions,
    List<FoodLogEntry> nutritionEntries,
  ) {
    return {
      'fitness': workouts.where((w) => w.isCompleted).length,
      'sleep': sleepSessions.where((s) {
        final hours = s.totalDuration.inHours;
        return hours >= 6;
      }).length,
      'nutrition': nutritionEntries.where((e) {
        final score = double.tryParse(e.sustainabilityScore ?? '0') ?? 0.0;
        return score >= 7.0;
      }).length,
    };
  }

  /// Get the most recent activity time
  DateTime? _getLastActivityTime(
    List<ActiveWorkoutSession> workouts,
    List<SleepSession> sleepSessions,
    List<FoodLogEntry> nutritionEntries,
  ) {
    final times = <DateTime>[];
    
    // Add workout times
    times.addAll(workouts
        .where((w) => w.isCompleted && w.endTime != null)
        .map((w) => w.endTime!));
    
    // Add sleep times
    times.addAll(sleepSessions.map((s) => s.startTime));
    
    // Add nutrition times
    times.addAll(nutritionEntries.map((e) => e.loggedAt));
    
    if (times.isEmpty) return null;
    
    times.sort((a, b) => b.compareTo(a));
    return times.first;
  }

  /// Get detailed carbon breakdown for popup display
  Future<Map<String, dynamic>> getCarbonBreakdown() async {
    try {
      final carbonData = await _carbonService.calculateTotalCarbonSaved();
      
      return {
        'total': carbonData.totalKgCO2Saved,
        'breakdown': {
          'exercise': {
            'total': carbonData.workoutContribution,
            'details': 'From ${carbonData.specificExamples.where((e) => e.contains('Workout')).length} workouts'
          },
          'nutrition': {
            'total': carbonData.foodContribution,
            'details': 'From sustainable food choices'
          },
          'sleep': {
            'total': carbonData.sleepContribution,
            'details': 'From healthy sleep patterns'
          },
        },
        'examples': carbonData.specificExamples,
        'lastCalculated': carbonData.lastCalculated.toIso8601String(),
      };
    } catch (e) {
      print('Error getting carbon breakdown: $e');
      return {
        'total': 0.0,
        'breakdown': {
          'exercise': {'total': 0.0, 'details': 'No data available'},
          'nutrition': {'total': 0.0, 'details': 'No data available'},
          'sleep': {'total': 0.0, 'details': 'No data available'},
        },
      };
    }
  }

  /// Get legacy stats for compatibility with existing achievement service
  Future<SustainabilityStats> getStats() async {
    final data = await _fetchAllStatsData();
    return _calculateStatsFromRealData(data);
  }

  /// Track sustainable action (for compatibility)
  Future<void> trackSustainableAction(BuildContext context, {
    double carbonSaved = 0.0,
    bool localBusinessSupported = false,
    String? actionType,
  }) async {
    // This method is kept for compatibility with existing code
    // Real tracking happens automatically through data fetching
    print('Sustainable action tracked: $actionType, carbon: $carbonSaved');
  }

  /// Watch achievements stream (delegate to repository)
  Stream<List<Achievement>> watchAchievements() => _repository.watchAchievements();

  /// Watch rewards stream (delegate to repository)
  Stream<List<SustainabilityReward>> watchRewards() => _repository.watchRewards();

  /// Redeem reward (delegate to repository)
  Future<void> redeemReward(String rewardId, int cost) async {
    try {
      await _repository.redeemReward(rewardId);
    } catch (e) {
      print('Error redeeming reward: $e');
      rethrow;
    }
  }
}
