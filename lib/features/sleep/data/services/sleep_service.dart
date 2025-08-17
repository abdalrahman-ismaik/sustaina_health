import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../models/sleep_models.dart';
import 'package:uuid/uuid.dart';

class SleepService {
  static const String _sleepSessionsKey = 'sleep_sessions';
  static const String _sleepGoalsKey = 'sleep_goals';
  static const String _sleepRemindersKey = 'sleep_reminders';
  static const String _sleepInsightsKey = 'sleep_insights';
  
  final Uuid _uuid = const Uuid();

  /// Save a sleep session
  Future<String> saveSleepSession(SleepSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSleepSessions();
      
      // Add new session
      sessions.add(session);
      
      // Save to storage
      final sessionsJson = sessions.map((s) => s.toJson()).toList();
      await prefs.setString(_sleepSessionsKey, jsonEncode(sessionsJson));
      
      return session.id;
    } catch (e) {
      throw Exception('Failed to save sleep session: $e');
    }
  }

  /// Get all sleep sessions
  Future<List<SleepSession>> getSleepSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sleepSessionsKey);
      
      if (sessionsJson == null) return [];
      
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      return sessionsList
          .map((json) => SleepSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sleep sessions: $e');
    }
  }

  /// Get sleep sessions for a specific date range
  Future<List<SleepSession>> getSleepSessionsForDateRange(DateTime start, DateTime end) async {
    final sessions = await getSleepSessions();
    return sessions.where((session) {
      return session.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
             session.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Delete a sleep session
  Future<void> deleteSleepSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSleepSessions();
      
      sessions.removeWhere((session) => session.id == sessionId);
      
      final sessionsJson = sessions.map((s) => s.toJson()).toList();
      await prefs.setString(_sleepSessionsKey, jsonEncode(sessionsJson));
    } catch (e) {
      throw Exception('Failed to delete sleep session: $e');
    }
  }

  /// Save sleep goal
  Future<String> saveSleepGoal(SleepGoal goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goals = await getSleepGoals();
      
      // Remove existing goal if it exists
      goals.removeWhere((g) => g.id == goal.id);
      goals.add(goal);
      
      final goalsJson = goals.map((g) => g.toJson()).toList();
      await prefs.setString(_sleepGoalsKey, jsonEncode(goalsJson));
      
      return goal.id;
    } catch (e) {
      throw Exception('Failed to save sleep goal: $e');
    }
  }

  /// Get sleep goals
  Future<List<SleepGoal>> getSleepGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_sleepGoalsKey);
      
      if (goalsJson == null) return [];
      
      final List<dynamic> goalsList = jsonDecode(goalsJson);
      return goalsList
          .map((json) => SleepGoal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sleep goals: $e');
    }
  }

  /// Save sleep reminder
  Future<String> saveSleepReminder(SleepReminder reminder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await getSleepReminders();
      
      // Remove existing reminder if it exists
      reminders.removeWhere((r) => r.id == reminder.id);
      reminders.add(reminder);
      
      final remindersJson = reminders.map((r) => r.toJson()).toList();
      await prefs.setString(_sleepRemindersKey, jsonEncode(remindersJson));
      
      return reminder.id;
    } catch (e) {
      throw Exception('Failed to save sleep reminder: $e');
    }
  }

  /// Get sleep reminders
  Future<List<SleepReminder>> getSleepReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_sleepRemindersKey);
      
      if (remindersJson == null) return [];
      
      final List<dynamic> remindersList = jsonDecode(remindersJson);
      return remindersList
          .map((json) => SleepReminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sleep reminders: $e');
    }
  }

  /// Save sleep insight
  Future<String> saveSleepInsight(SleepInsight insight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final insights = await getSleepInsights();
      
      // Remove existing insight if it exists
      insights.removeWhere((i) => i.id == insight.id);
      insights.add(insight);
      
      final insightsJson = insights.map((i) => i.toJson()).toList();
      await prefs.setString(_sleepInsightsKey, jsonEncode(insightsJson));
      
      return insight.id;
    } catch (e) {
      throw Exception('Failed to save sleep insight: $e');
    }
  }

  /// Get sleep insights
  Future<List<SleepInsight>> getSleepInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final insightsJson = prefs.getString(_sleepInsightsKey);
      
      if (insightsJson == null) return [];
      
      final List<dynamic> insightsList = jsonDecode(insightsJson);
      return insightsList
          .map((json) => SleepInsight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load sleep insights: $e');
    }
  }

  /// Calculate sleep statistics
  Future<SleepStats> calculateSleepStats({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      final sessions = await getSleepSessionsForDateRange(startDate, endDate);
      
      if (sessions.isEmpty) {
        return const SleepStats(
          averageDuration: Duration(hours: 0),
          averageQuality: 0.0,
          totalSleepTime: Duration(hours: 0),
          totalSessions: 0,
          bestSleep: Duration(hours: 0),
          worstSleep: Duration(hours: 0),
          consistencyScore: 0.0,
          sustainabilityScore: 0.0,
          weeklyTrends: {},
        );
      }
      
      // Calculate averages
      final totalDuration = sessions.fold<Duration>(
        Duration.zero,
        (sum, session) => sum + session.totalDuration,
      );
      final averageDuration = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ sessions.length,
      );
      
      final averageQuality = sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.sleepQuality,
      ) / sessions.length;
      
      // Find best and worst sleep
      final bestSleep = sessions
          .map((s) => s.totalDuration)
          .reduce((a, b) => a > b ? a : b);
      final worstSleep = sessions
          .map((s) => s.totalDuration)
          .reduce((a, b) => a < b ? a : b);
      
      // Calculate consistency score
      final consistencyScore = _calculateConsistencyScore(sessions);
      
      // Calculate sustainability score
      final sustainabilityScore = _calculateSustainabilityScore(sessions);
      
      // Calculate weekly trends
      final weeklyTrends = _calculateWeeklyTrends(sessions);
      
      return SleepStats(
        averageDuration: averageDuration,
        averageQuality: averageQuality,
        totalSleepTime: totalDuration,
        totalSessions: sessions.length,
        bestSleep: bestSleep,
        worstSleep: worstSleep,
        consistencyScore: consistencyScore,
        sustainabilityScore: sustainabilityScore,
        weeklyTrends: weeklyTrends,
      );
    } catch (e) {
      throw Exception('Failed to calculate sleep stats: $e');
    }
  }

  /// Generate sleep insights
  Future<List<SleepInsight>> generateSleepInsights() async {
    try {
      final sessions = await getSleepSessions();
      final stats = await calculateSleepStats();
      final insights = <SleepInsight>[];
      
      if (sessions.isEmpty) {
        return [
          SleepInsight(
            id: _uuid.v4(),
            title: 'Start Tracking Your Sleep',
            description: 'Begin your sleep journey by tracking your first sleep session.',
            type: SleepInsightType.quality,
            impact: 0.0,
            recommendations: [
              'Set up your sleep environment',
              'Create a bedtime routine',
              'Track your first sleep session',
            ],
            createdAt: DateTime.now(),
          ),
        ];
      }
      
      // Quality insights
      if (stats.averageQuality < 7.0) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Improve Sleep Quality',
          description: 'Your average sleep quality is below optimal levels.',
          type: SleepInsightType.quality,
          impact: 0.8,
          recommendations: [
            'Maintain a consistent sleep schedule',
            'Create a relaxing bedtime routine',
            'Optimize your sleep environment',
            'Limit screen time before bed',
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Duration insights
      if (stats.averageDuration.inHours < 7) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Increase Sleep Duration',
          description: 'You\'re getting less than the recommended 7-9 hours of sleep.',
          type: SleepInsightType.duration,
          impact: 0.9,
          recommendations: [
            'Go to bed 30 minutes earlier',
            'Avoid caffeine after 2 PM',
            'Create a wind-down routine',
            'Set a consistent wake-up time',
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Consistency insights
      if (stats.consistencyScore < 0.7) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Improve Sleep Consistency',
          description: 'Your sleep schedule varies significantly from day to day.',
          type: SleepInsightType.consistency,
          impact: 0.7,
          recommendations: [
            'Set consistent bed and wake times',
            'Use an alarm clock consistently',
            'Avoid weekend sleep-ins',
            'Create a morning routine',
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Sustainability insights
      if (stats.sustainabilityScore < 0.6) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Enhance Sleep Sustainability',
          description: 'Make your sleep routine more environmentally friendly.',
          type: SleepInsightType.sustainability,
          impact: 0.5,
          recommendations: [
            'Use energy-efficient lighting',
            'Choose eco-friendly bedding',
            'Optimize room temperature naturally',
            'Reduce electronic device usage',
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      return insights;
    } catch (e) {
      throw Exception('Failed to generate sleep insights: $e');
    }
  }

  /// Create a new sleep session
  Future<SleepSession> createSleepSession({
    required DateTime startTime,
    required DateTime endTime,
    required double sleepQuality,
    required String mood,
    required SleepEnvironment environment,
    required SleepStages stages,
    required SleepSustainability sustainability,
    String? notes,
  }) async {
    final session = SleepSession(
      id: _uuid.v4(),
      startTime: startTime,
      endTime: endTime,
      totalDuration: endTime.difference(startTime),
      sleepQuality: sleepQuality,
      mood: mood,
      environment: environment,
      stages: stages,
      sustainability: sustainability,
      createdAt: DateTime.now(),
      notes: notes,
    );
    
    await saveSleepSession(session);
    return session;
  }

  /// Create a default sleep goal
  Future<SleepGoal> createDefaultSleepGoal() async {
    final goal = SleepGoal(
      id: _uuid.v4(),
      targetDuration: const Duration(hours: 8),
      targetBedtime: const TimeOfDay(hour: 22, minute: 0),
      targetWakeTime: const TimeOfDay(hour: 6, minute: 0),
      targetQuality: 8.0,
      reminderEnabled: true,
      createdAt: DateTime.now(),
    );
    
    await saveSleepGoal(goal);
    return goal;
  }

  /// Create a default sleep reminder
  Future<SleepReminder> createDefaultSleepReminder() async {
    final reminder = SleepReminder(
      id: _uuid.v4(),
      time: const TimeOfDay(hour: 21, minute: 30),
      enabled: true,
      days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      message: 'Time to prepare for bed!',
      createdAt: DateTime.now(),
    );
    
    await saveSleepReminder(reminder);
    return reminder;
  }

  // Helper methods
  double _calculateConsistencyScore(List<SleepSession> sessions) {
    if (sessions.length < 2) return 1.0;
    
    final durations = sessions.map((s) => s.totalDuration.inMinutes).toList();
    final mean = durations.reduce((a, b) => a + b) / durations.length;
    final variance = durations.map((d) => (d - mean) * (d - mean)).reduce((a, b) => a + b) / durations.length;
    final standardDeviation = sqrt(variance);
    
    // Normalize to 0-1 scale (lower SD = higher consistency)
    return (1.0 - (standardDeviation / mean)).clamp(0.0, 1.0);
  }

  double _calculateSustainabilityScore(List<SleepSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (final session in sessions) {
      double sessionScore = 0.0;
      
      // Environment factors
      if (session.environment.ecoFriendly) sessionScore += 0.2;
      if (session.environment.energyEfficient) sessionScore += 0.2;
      if (session.environment.naturalLight) sessionScore += 0.1;
      if (session.environment.screenTime < 1.0) sessionScore += 0.1;
      
      // Sustainability factors
      if (session.sustainability.usedEcoFriendlyBedding) sessionScore += 0.2;
      if (session.sustainability.usedNaturalVentilation) sessionScore += 0.1;
      if (session.sustainability.usedEnergyEfficientDevices) sessionScore += 0.1;
      
      totalScore += sessionScore;
    }
    
    return totalScore / sessions.length;
  }

  Map<String, double> _calculateWeeklyTrends(List<SleepSession> sessions) {
    final trends = <String, double>{};
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final weekday in weekdays) {
      final weekdaySessions = sessions.where((s) {
        final weekdayName = _getWeekdayName(s.startTime.weekday);
        return weekdayName == weekday;
      }).toList();
      
      if (weekdaySessions.isNotEmpty) {
        final avgDuration = weekdaySessions
            .map((s) => s.totalDuration.inHours)
            .reduce((a, b) => a + b) / weekdaySessions.length;
        trends[weekday] = avgDuration;
      } else {
        trends[weekday] = 0.0;
      }
    }
    
    return trends;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }
}

// Helper function for square root
double sqrt(double x) {
  return x < 0 ? 0 : math.sqrt(x);
}
