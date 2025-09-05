import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../models/sleep_models.dart';
import 'package:uuid/uuid.dart';
import 'firestore_sleep_service.dart';

class SleepService {
  static const String _sleepSessionsKey = 'sleep_sessions';
  static const String _sleepGoalsKey = 'sleep_goals';
  static const String _sleepRemindersKey = 'sleep_reminders';
  static const String _sleepInsightsKey = 'sleep_insights';
  
  final Uuid _uuid = const Uuid();
  final FirestoreSleepService _firestoreService = FirestoreSleepService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isUserSignedIn => _auth.currentUser != null;

  /// Save a sleep session
  Future<String> saveSleepSession(SleepSession session) async {
    try {
      // Always save locally first
      await _saveSessionLocally(session);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureSleepModuleExists();
          await _firestoreService.saveSleepSession(session);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
      
      return session.id;
    } catch (e) {
      throw Exception('Failed to save sleep session: $e');
    }
  }

  /// Get all sleep sessions (prioritizing cloud data if available)
  Future<List<SleepSession>> getSleepSessions() async {
    try {
      if (_isUserSignedIn) {
        try {
          final cloudSessions = await _firestoreService.getSleepSessions();
          if (cloudSessions.isNotEmpty) {
            // Sync cloud data to local storage
            await _syncSessionsToLocal(cloudSessions);
            return cloudSessions;
          }
        } catch (e) {
          print('Cloud fetch failed, falling back to local data: $e');
        }
      }
      
      // Fall back to local data
      return await _getSessionsLocally();
    } catch (e) {
      throw Exception('Failed to load sleep sessions: $e');
    }
  }

  /// Get sleep sessions for a specific date range
  Future<List<SleepSession>> getSleepSessionsForDateRange(DateTime start, DateTime end) async {
    try {
      if (_isUserSignedIn) {
        try {
          return await _firestoreService.getSleepSessionsForDateRange(start, end);
        } catch (e) {
          print('Cloud fetch failed, falling back to local data: $e');
        }
      }
      
      final List<SleepSession> sessions = await _getSessionsLocally();
      return sessions.where((SleepSession session) {
        return session.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
               session.startTime.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to load sleep sessions for date range: $e');
    }
  }

  /// Delete a sleep session
  Future<void> deleteSleepSession(String sessionId) async {
    try {
      // Delete from local storage
      await _deleteSessionLocally(sessionId);
      
      // Delete from cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.deleteSleepSession(sessionId);
        } catch (e) {
          print('Cloud delete failed, but local delete succeeded: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete sleep session: $e');
    }
  }

  /// Save sleep goal
  Future<String> saveSleepGoal(SleepGoal goal) async {
    try {
      // Save locally first
      await _saveGoalLocally(goal);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureSleepModuleExists();
          await _firestoreService.saveSleepGoal(goal);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
      
      return goal.id;
    } catch (e) {
      throw Exception('Failed to save sleep goal: $e');
    }
  }

  /// Get sleep goals
  Future<List<SleepGoal>> getSleepGoals() async {
    try {
      if (_isUserSignedIn) {
        try {
          final cloudGoals = await _firestoreService.getSleepGoals();
          if (cloudGoals.isNotEmpty) {
            await _syncGoalsToLocal(cloudGoals);
            return cloudGoals;
          }
        } catch (e) {
          print('Cloud fetch failed, falling back to local data: $e');
        }
      }
      
      return await _getGoalsLocally();
    } catch (e) {
      throw Exception('Failed to load sleep goals: $e');
    }
  }

  /// Save sleep reminder
  Future<String> saveSleepReminder(SleepReminder reminder) async {
    try {
      await _saveReminderLocally(reminder);
      
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureSleepModuleExists();
          await _firestoreService.saveSleepReminder(reminder);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
      
      return reminder.id;
    } catch (e) {
      throw Exception('Failed to save sleep reminder: $e');
    }
  }

  /// Get sleep reminders
  Future<List<SleepReminder>> getSleepReminders() async {
    try {
      if (_isUserSignedIn) {
        try {
          final cloudReminders = await _firestoreService.getSleepReminders();
          if (cloudReminders.isNotEmpty) {
            await _syncRemindersToLocal(cloudReminders);
            return cloudReminders;
          }
        } catch (e) {
          print('Cloud fetch failed, falling back to local data: $e');
        }
      }
      
      return await _getRemindersLocally();
    } catch (e) {
      throw Exception('Failed to load sleep reminders: $e');
    }
  }

  /// Save sleep insight
  Future<String> saveSleepInsight(SleepInsight insight) async {
    try {
      await _saveInsightLocally(insight);
      
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureSleepModuleExists();
          await _firestoreService.saveSleepInsight(insight);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
      
      return insight.id;
    } catch (e) {
      throw Exception('Failed to save sleep insight: $e');
    }
  }

  /// Get sleep insights
  Future<List<SleepInsight>> getSleepInsights() async {
    try {
      if (_isUserSignedIn) {
        try {
          final cloudInsights = await _firestoreService.getSleepInsights();
          if (cloudInsights.isNotEmpty) {
            await _syncInsightsToLocal(cloudInsights);
            return cloudInsights;
          }
        } catch (e) {
          print('Cloud fetch failed, falling back to local data: $e');
        }
      }
      
      return await _getInsightsLocally();
    } catch (e) {
      throw Exception('Failed to load sleep insights: $e');
    }
  }

  /// Calculate sleep statistics
  Future<SleepStats> calculateSleepStats({int days = 7}) async {
    try {
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(Duration(days: days));
      final List<SleepSession> sessions = await getSleepSessionsForDateRange(startDate, endDate);
      
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
          weeklyTrends: <String, double>{},
        );
      }
      
      // Calculate averages
      final Duration totalDuration = sessions.fold<Duration>(
        Duration.zero,
        (Duration sum, SleepSession session) => sum + session.totalDuration,
      );
      final Duration averageDuration = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ sessions.length,
      );
      
      final double averageQuality = sessions.fold<double>(
        0.0,
        (double sum, SleepSession session) => sum + session.sleepQuality,
      ) / sessions.length;
      
      // Find best and worst sleep
      final Duration bestSleep = sessions
          .map((SleepSession s) => s.totalDuration)
          .reduce((Duration a, Duration b) => a > b ? a : b);
      final Duration worstSleep = sessions
          .map((SleepSession s) => s.totalDuration)
          .reduce((Duration a, Duration b) => a < b ? a : b);
      
      // Calculate consistency score
      final double consistencyScore = _calculateConsistencyScore(sessions);
      
      // Calculate sustainability score
      final double sustainabilityScore = _calculateSustainabilityScore(sessions);
      
      // Calculate weekly trends
      final Map<String, double> weeklyTrends = _calculateWeeklyTrends(sessions);
      
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
      final List<SleepSession> sessions = await getSleepSessions();
      final SleepStats stats = await calculateSleepStats();
      final List<SleepInsight> insights = <SleepInsight>[];
      
      if (sessions.isEmpty) {
        return <SleepInsight>[
          SleepInsight(
            id: _uuid.v4(),
            title: 'Start Tracking Your Sleep',
            description: 'Begin your sleep journey by tracking your first sleep session.',
            type: SleepInsightType.quality,
            impact: 0.8,
            recommendations: ['Track your first sleep session to get personalized insights.'],
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
          impact: 0.9,
          recommendations: [
            'Maintain a consistent sleep schedule',
            'Create a relaxing bedtime routine'
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
          impact: 0.85,
          recommendations: [
            'Try going to bed 30 minutes earlier each night',
            'Aim for 7-8 hours of sleep'
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Consistency insights
      if (stats.consistencyScore < 0.7) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Improve Sleep Consistency',
          description: 'Your sleep schedule varies significantly.',
          type: SleepInsightType.consistency,
          impact: 0.7,
          recommendations: [
            'Go to bed and wake up at the same time every day',
            'Maintain schedule even on weekends'
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Sustainability insights
      if (stats.sustainabilityScore < 0.6) {
        insights.add(SleepInsight(
          id: _uuid.v4(),
          title: 'Enhance Sleep Sustainability',
          description: 'You can make your sleep routine more eco-friendly.',
          type: SleepInsightType.sustainability,
          impact: 0.6,
          recommendations: [
            'Use natural ventilation',
            'Choose eco-friendly bedding',
            'Use energy-efficient devices'
          ],
          createdAt: DateTime.now(),
        ));
      }
      
      // Save generated insights
      for (final insight in insights) {
        await saveSleepInsight(insight);
      }
      
      return insights;
    } catch (e) {
      throw Exception('Failed to generate sleep insights: $e');
    }
  }

  // Sync methods for data migration
  Future<void> syncLocalDataToCloud() async {
    if (!_isUserSignedIn) return;
    
    try {
      await _firestoreService.ensureSleepModuleExists();
      
      // Sync sessions
      final localSessions = await _getSessionsLocally();
      for (final session in localSessions) {
        await _firestoreService.saveSleepSession(session);
      }
      
      // Sync goals
      final localGoals = await _getGoalsLocally();
      for (final goal in localGoals) {
        await _firestoreService.saveSleepGoal(goal);
      }
      
      // Sync reminders
      final localReminders = await _getRemindersLocally();
      for (final reminder in localReminders) {
        await _firestoreService.saveSleepReminder(reminder);
      }
      
      // Sync insights
      final localInsights = await _getInsightsLocally();
      for (final insight in localInsights) {
        await _firestoreService.saveSleepInsight(insight);
      }
    } catch (e) {
      print('Failed to sync local data to cloud: $e');
    }
  }

  // Stream methods for real-time updates
  Stream<List<SleepSession>> watchSleepSessions({DateTime? date}) {
    if (_isUserSignedIn) {
      return _firestoreService.watchSleepSessions(date: date);
    } else {
      // For offline users, return a stream that emits local data once
      return Stream.fromFuture(_getSessionsLocally());
    }
  }

  // Private local storage methods
  Future<void> _saveSessionLocally(SleepSession session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SleepSession> sessions = await _getSessionsLocally();
    
    // Remove existing session if it exists
    sessions.removeWhere((s) => s.id == session.id);
    sessions.add(session);
    
    final List<Map<String, dynamic>> sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sleepSessionsKey, jsonEncode(sessionsJson));
  }

  Future<List<SleepSession>> _getSessionsLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sleepSessionsKey);
    
    if (sessionsJson == null) return <SleepSession>[];
    
    final List<dynamic> sessionsList = jsonDecode(sessionsJson);
    return sessionsList
        .map((json) => SleepSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _deleteSessionLocally(String sessionId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SleepSession> sessions = await _getSessionsLocally();
    
    sessions.removeWhere((session) => session.id == sessionId);
    
    final List<Map<String, dynamic>> sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sleepSessionsKey, jsonEncode(sessionsJson));
  }

  Future<void> _syncSessionsToLocal(List<SleepSession> cloudSessions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> sessionsJson = cloudSessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sleepSessionsKey, jsonEncode(sessionsJson));
  }

  // Similar methods for goals, reminders, and insights
  Future<void> _saveGoalLocally(SleepGoal goal) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SleepGoal> goals = await _getGoalsLocally();
    
    goals.removeWhere((g) => g.id == goal.id);
    goals.add(goal);
    
    final List<Map<String, dynamic>> goalsJson = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_sleepGoalsKey, jsonEncode(goalsJson));
  }

  Future<List<SleepGoal>> _getGoalsLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString(_sleepGoalsKey);
    
    if (goalsJson == null) return <SleepGoal>[];
    
    final List<dynamic> goalsList = jsonDecode(goalsJson);
    return goalsList
        .map((json) => SleepGoal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _syncGoalsToLocal(List<SleepGoal> cloudGoals) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> goalsJson = cloudGoals.map((g) => g.toJson()).toList();
    await prefs.setString(_sleepGoalsKey, jsonEncode(goalsJson));
  }

  Future<void> _saveReminderLocally(SleepReminder reminder) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SleepReminder> reminders = await _getRemindersLocally();
    
    reminders.removeWhere((r) => r.id == reminder.id);
    reminders.add(reminder);
    
    final List<Map<String, dynamic>> remindersJson = reminders.map((r) => r.toJson()).toList();
    await prefs.setString(_sleepRemindersKey, jsonEncode(remindersJson));
  }

  Future<List<SleepReminder>> _getRemindersLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString(_sleepRemindersKey);
    
    if (remindersJson == null) return <SleepReminder>[];
    
    final List<dynamic> remindersList = jsonDecode(remindersJson);
    return remindersList
        .map((json) => SleepReminder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _syncRemindersToLocal(List<SleepReminder> cloudReminders) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> remindersJson = cloudReminders.map((r) => r.toJson()).toList();
    await prefs.setString(_sleepRemindersKey, jsonEncode(remindersJson));
  }

  Future<void> _saveInsightLocally(SleepInsight insight) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SleepInsight> insights = await _getInsightsLocally();
    
    insights.removeWhere((i) => i.id == insight.id);
    insights.add(insight);
    
    final List<Map<String, dynamic>> insightsJson = insights.map((i) => i.toJson()).toList();
    await prefs.setString(_sleepInsightsKey, jsonEncode(insightsJson));
  }

  Future<List<SleepInsight>> _getInsightsLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? insightsJson = prefs.getString(_sleepInsightsKey);
    
    if (insightsJson == null) return <SleepInsight>[];
    
    final List<dynamic> insightsList = jsonDecode(insightsJson);
    return insightsList
        .map((json) => SleepInsight.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _syncInsightsToLocal(List<SleepInsight> cloudInsights) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> insightsJson = cloudInsights.map((i) => i.toJson()).toList();
    await prefs.setString(_sleepInsightsKey, jsonEncode(insightsJson));
  }

  // Calculation methods (unchanged from original implementation)
  double _calculateConsistencyScore(List<SleepSession> sessions) {
    if (sessions.length < 2) return 1.0;
    
    final List<int> durations = sessions.map((s) => s.totalDuration.inMinutes).toList();
    final double mean = durations.reduce((a, b) => a + b) / durations.length;
    final double variance = durations.map((d) => (d - mean) * (d - mean)).reduce((a, b) => a + b) / durations.length;
    final double standardDeviation = variance > 0 ? math.sqrt(variance) : 0.0;
    
    return mean > 0 ? (1.0 - (standardDeviation / mean)).clamp(0.0, 1.0) : 0.0;
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
    final Map<String, double> trends = {};
    
    // Group sessions by week
    final Map<int, List<SleepSession>> weeklyData = {};
    for (final session in sessions) {
      final weekNumber = _getWeekNumber(session.startTime);
      weeklyData.putIfAbsent(weekNumber, () => []).add(session);
    }
    
    // Calculate weekly averages
    for (final entry in weeklyData.entries) {
      final weekSessions = entry.value;
      final avgDuration = weekSessions
          .map((s) => s.totalDuration.inHours)
          .reduce((a, b) => a + b) / weekSessions.length;
      final avgQuality = weekSessions
          .map((s) => s.sleepQuality)
          .reduce((a, b) => a + b) / weekSessions.length;
      
      trends['week_${entry.key}_duration'] = avgDuration;
      trends['week_${entry.key}_quality'] = avgQuality;
    }
    
    return trends;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return (dayOfYear / 7).ceil();
  }

  /// Sync all local data to cloud (comprehensive migration)
  Future<void> syncToCloud() async {
    if (!_isUserSignedIn) {
      throw Exception('User not authenticated');
    }

    try {
      // Ensure sleep module exists in cloud
      await _firestoreService.ensureSleepModuleExists();

      // Sync all sleep sessions
      final localSessions = await _getSessionsLocally();
      for (final session in localSessions) {
        try {
          await _firestoreService.saveSleepSession(session);
        } catch (e) {
          print('Failed to sync sleep session ${session.id}: $e');
        }
      }

      // Sync all sleep goals
      final localGoals = await _getGoalsLocally();
      for (final goal in localGoals) {
        try {
          await _firestoreService.saveSleepGoal(goal);
        } catch (e) {
          print('Failed to sync sleep goal ${goal.id}: $e');
        }
      }

      // Sync all sleep reminders
      final localReminders = await _getRemindersLocally();
      for (final reminder in localReminders) {
        try {
          await _firestoreService.saveSleepReminder(reminder);
        } catch (e) {
          print('Failed to sync sleep reminder ${reminder.id}: $e');
        }
      }

      // Sync all sleep insights
      final localInsights = await _getInsightsLocally();
      for (final insight in localInsights) {
        try {
          await _firestoreService.saveSleepInsight(insight);
        } catch (e) {
          print('Failed to sync sleep insight ${insight.id}: $e');
        }
      }

      print('Sleep data sync to cloud completed');
    } catch (e) {
      throw Exception('Failed to sync sleep data to cloud: $e');
    }
  }

  /// Get sync status for sleep data
  Future<Map<String, int>> getSyncStatus() async {
    final localSessions = await _getSessionsLocally();
    final localGoals = await _getGoalsLocally();
    final localReminders = await _getRemindersLocally();
    final localInsights = await _getInsightsLocally();

    final totalItems = localSessions.length + localGoals.length + 
                      localReminders.length + localInsights.length;

    return {
      'totalItems': totalItems,
      'sessions': localSessions.length,
      'goals': localGoals.length,
      'reminders': localReminders.length,
      'insights': localInsights.length,
    };
  }
}
