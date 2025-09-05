import 'package:flutter/material.dart';
import '../../data/services/firestore_sleep_service.dart';
import '../../data/models/sleep_models.dart';

class FirestoreSleepDebugPanel extends StatefulWidget {
  const FirestoreSleepDebugPanel({super.key});

  @override
  State<FirestoreSleepDebugPanel> createState() => _FirestoreSleepDebugPanelState();
}

class _FirestoreSleepDebugPanelState extends State<FirestoreSleepDebugPanel> {
  final FirestoreSleepService _sleepService = FirestoreSleepService();
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Sleep Debug Panel'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Session Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Create Test Sleep Session',
                      _createTestSleepSession,
                    ),
                    _buildTestButton(
                      'Get All Sleep Sessions',
                      _getAllSleepSessions,
                    ),
                    _buildTestButton(
                      'Get Sleep Sessions (Last 7 Days)',
                      _getRecentSleepSessions,
                    ),
                    _buildTestButton(
                      'Watch Sleep Sessions (Stream)',
                      _watchSleepSessions,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Goal Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Create Test Sleep Goal',
                      _createTestSleepGoal,
                    ),
                    _buildTestButton(
                      'Get All Sleep Goals',
                      _getAllSleepGoals,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Reminder Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Create Test Sleep Reminder',
                      _createTestSleepReminder,
                    ),
                    _buildTestButton(
                      'Get All Sleep Reminders',
                      _getAllSleepReminders,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Insight Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Create Test Sleep Insight',
                      _createTestSleepInsight,
                    ),
                    _buildTestButton(
                      'Get All Sleep Insights',
                      _getAllSleepInsights,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Get Sleep Analytics (Last 30 Days)',
                      _getSleepAnalytics,
                    ),
                    _buildTestButton(
                      'Search Sleep Sessions',
                      _searchSleepSessions,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cleanup Tests',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildTestButton(
                      'Delete All Test Data',
                      _deleteAllTestData,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(_result),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color != null ? Colors.white : null,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  void _updateResult(String result) {
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  void _setLoading() {
    setState(() {
      _isLoading = true;
      _result = '';
    });
  }

  // Sleep Session test methods
  Future<void> _createTestSleepSession() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testSession = SleepSession(
        id: 'test_session_${DateTime.now().millisecondsSinceEpoch}',
        startTime: DateTime.now().subtract(const Duration(hours: 8)),
        endTime: DateTime.now(),
        totalDuration: const Duration(hours: 8),
        sleepQuality: 8.0,
        mood: 'refreshed',
        environment: const SleepEnvironment(
          roomTemperature: 22.0,
          noiseLevel: 'quiet',
          lightExposure: 'dark',
          screenTime: 0.5,
          naturalLight: false,
          ecoFriendly: true,
          energyEfficient: true,
        ),
        stages: const SleepStages(
          awakeTime: Duration(minutes: 30),
          lightSleep: Duration(hours: 3),
          deepSleep: Duration(hours: 2, minutes: 30),
          remSleep: Duration(hours: 2),
        ),
        sustainability: const SleepSustainability(
          energySaved: 2.5,
          carbonFootprintReduction: 1.8,
          usedEcoFriendlyBedding: true,
          usedNaturalVentilation: true,
          usedEnergyEfficientDevices: true,
        ),
        createdAt: DateTime.now(),
        notes: 'Test sleep session created from debug panel',
      );

      await _sleepService.saveSleepSession(testSession);
      _updateResult('Sleep session created successfully! ID: ${testSession.id}');
    } catch (e) {
      _updateResult('Error creating sleep session: $e');
    }
  }

  Future<void> _getAllSleepSessions() async {
    _setLoading();
    try {
      final sessions = await _sleepService.getSleepSessions(limit: 10);
      _updateResult('Found ${sessions.length} sleep sessions:\n\n${sessions.map((s) => 'ID: ${s.id}\nDate: ${s.startTime}\nQuality: ${s.sleepQuality}/10\nMood: ${s.mood}\nDuration: ${s.totalDuration.inHours}h ${s.totalDuration.inMinutes % 60}m\n').join('\n')}');
    } catch (e) {
      _updateResult('Error getting sleep sessions: $e');
    }
  }

  Future<void> _getRecentSleepSessions() async {
    _setLoading();
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      final sessions = await _sleepService.getSleepSessionsForDateRange(startDate, endDate);
      _updateResult('Found ${sessions.length} sleep sessions in the last 7 days:\n\n${sessions.map((s) => 'Date: ${s.startTime.toString().split(' ')[0]}\nQuality: ${s.sleepQuality}/10\nDuration: ${s.totalDuration.inHours}h ${s.totalDuration.inMinutes % 60}m\n').join('\n')}');
    } catch (e) {
      _updateResult('Error getting recent sleep sessions: $e');
    }
  }

  Future<void> _watchSleepSessions() async {
    _setLoading();
    try {
      final stream = _sleepService.watchSleepSessions();
      final sessions = await stream.first;
      _updateResult('Real-time stream connected! Found ${sessions.length} sleep sessions:\n\n${sessions.map((s) => 'ID: ${s.id}\nDate: ${s.startTime}\nQuality: ${s.sleepQuality}/10\n').join('\n')}');
    } catch (e) {
      _updateResult('Error watching sleep sessions: $e');
    }
  }

  // Sleep Goal test methods
  Future<void> _createTestSleepGoal() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testGoal = SleepGoal(
        id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
        targetBedtime: const TimeOfDay(hour: 22, minute: 30),
        targetWakeTime: const TimeOfDay(hour: 6, minute: 30),
        targetDuration: const Duration(hours: 8),
        targetQuality: 8.0,
        reminderEnabled: true,
        createdAt: DateTime.now(),
      );

      await _sleepService.saveSleepGoal(testGoal);
      _updateResult('Sleep goal created successfully! ID: ${testGoal.id}\nBedtime: ${testGoal.targetBedtime.format(context)}\nWake time: ${testGoal.targetWakeTime.format(context)}\nTarget duration: ${testGoal.targetDuration.inHours}h');
    } catch (e) {
      _updateResult('Error creating sleep goal: $e');
    }
  }

  Future<void> _getAllSleepGoals() async {
    _setLoading();
    try {
      final goals = await _sleepService.getSleepGoals();
      _updateResult('Found ${goals.length} sleep goals:\n\n${goals.map((g) => 'ID: ${g.id}\nBedtime: ${g.targetBedtime.format(context)}\nWake time: ${g.targetWakeTime.format(context)}\nTarget duration: ${g.targetDuration.inHours}h\nTarget quality: ${g.targetQuality}\nReminder enabled: ${g.reminderEnabled}\n').join('\n')}');
    } catch (e) {
      _updateResult('Error getting sleep goals: $e');
    }
  }

  // Sleep Reminder test methods
  Future<void> _createTestSleepReminder() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testReminder = SleepReminder(
        id: 'test_reminder_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Time to start winding down for bed!',
        time: const TimeOfDay(hour: 21, minute: 30),
        enabled: true,
        days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        createdAt: DateTime.now(),
      );

      await _sleepService.saveSleepReminder(testReminder);
      _updateResult('Sleep reminder created successfully! ID: ${testReminder.id}\nMessage: ${testReminder.message}\nTime: ${testReminder.time.format(context)}\nRepeat days: ${testReminder.days.join(', ')}');
    } catch (e) {
      _updateResult('Error creating sleep reminder: $e');
    }
  }

  Future<void> _getAllSleepReminders() async {
    _setLoading();
    try {
      final reminders = await _sleepService.getSleepReminders();
      _updateResult('Found ${reminders.length} sleep reminders:\n\n${reminders.map((r) => 'ID: ${r.id}\nMessage: ${r.message}\nTime: ${r.time.format(context)}\nEnabled: ${r.enabled}\nDays: ${r.days.join(', ')}\n').join('\n')}');
    } catch (e) {
      _updateResult('Error getting sleep reminders: $e');
    }
  }

  // Sleep Insight test methods
  Future<void> _createTestSleepInsight() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testInsight = SleepInsight(
        id: 'test_insight_${DateTime.now().millisecondsSinceEpoch}',
        type: SleepInsightType.quality,
        title: 'Sleep Quality Insight',
        description: 'Your sleep quality improves when you maintain consistent bedtimes.',
        impact: 0.75,
        recommendations: [
          'Try to go to bed at the same time each night for better sleep quality.',
          'Maintain a cool room temperature for better deep sleep.',
          'Limit screen time before bed to improve sleep onset.',
        ],
        createdAt: DateTime.now(),
      );

      await _sleepService.saveSleepInsight(testInsight);
      _updateResult('Sleep insight created successfully! ID: ${testInsight.id}\nType: ${testInsight.type.name}\nTitle: ${testInsight.title}\nImpact: ${testInsight.impact}');
    } catch (e) {
      _updateResult('Error creating sleep insight: $e');
    }
  }

  Future<void> _getAllSleepInsights() async {
    _setLoading();
    try {
      final insights = await _sleepService.getSleepInsights();
      _updateResult('Found ${insights.length} sleep insights:\n\n${insights.map((i) => 'ID: ${i.id}\nType: ${i.type.name}\nTitle: ${i.title}\nImpact: ${i.impact}\nRecommendations: ${i.recommendations.length}\nCreated: ${i.createdAt.toString().split(' ')[0]}\n').join('\n')}');
    } catch (e) {
      _updateResult('Error getting sleep insights: $e');
    }
  }

  // Analytics test methods
  Future<void> _getSleepAnalytics() async {
    _setLoading();
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final analytics = await _sleepService.getSleepAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      final result = StringBuffer();
      result.writeln('Sleep Analytics (Last 30 Days):');
      result.writeln('Total Sessions: ${analytics['totalSessions']}');
      result.writeln('Average Duration: ${analytics['averageDuration'].toStringAsFixed(1)} hours');
      result.writeln('Average Quality: ${analytics['averageQuality'].toStringAsFixed(1)}/10');
      result.writeln('Total Sleep Time: ${analytics['totalSleepTime'].toStringAsFixed(1)} hours');
      result.writeln('Consistency Score: ${(analytics['consistencyScore'] * 100).toStringAsFixed(1)}%');
      result.writeln('Sustainability Score: ${(analytics['sustainabilityScore'] * 100).toStringAsFixed(1)}%');
      result.writeln('\nMood Breakdown:');
      final moodBreakdown = analytics['moodBreakdown'] as Map<String, int>;
      for (final entry in moodBreakdown.entries) {
        result.writeln('  ${entry.key}: ${entry.value} sessions');
      }

      _updateResult(result.toString());
    } catch (e) {
      _updateResult('Error getting sleep analytics: $e');
    }
  }

  Future<void> _searchSleepSessions() async {
    _setLoading();
    try {
      final sessions = await _sleepService.searchSleepSessions(
        searchTerm: 'refreshed',
        limit: 5,
      );
      _updateResult('Found ${sessions.length} sleep sessions containing "refreshed":\n\n${sessions.map((s) => 'Date: ${s.startTime.toString().split(' ')[0]}\nMood: ${s.mood}\nQuality: ${s.sleepQuality}/10\n').join('\n')}');
    } catch (e) {
      _updateResult('Error searching sleep sessions: $e');
    }
  }

  // Cleanup test methods
  Future<void> _deleteAllTestData() async {
    _setLoading();
    try {
      // Get all test data
      final sessions = await _sleepService.getSleepSessions();
      final goals = await _sleepService.getSleepGoals();
      final reminders = await _sleepService.getSleepReminders();
      final insights = await _sleepService.getSleepInsights();

      int deletedCount = 0;

      // Delete test sleep sessions
      for (final session in sessions) {
        if (session.id.startsWith('test_session_')) {
          await _sleepService.deleteSleepSession(session.id);
          deletedCount++;
        }
      }

      // Delete test sleep goals
      for (final goal in goals) {
        if (goal.id.startsWith('test_goal_')) {
          await _sleepService.deleteSleepGoal(goal.id);
          deletedCount++;
        }
      }

      // Delete test sleep reminders
      for (final reminder in reminders) {
        if (reminder.id.startsWith('test_reminder_')) {
          await _sleepService.deleteSleepReminder(reminder.id);
          deletedCount++;
        }
      }

      // Delete test sleep insights
      for (final insight in insights) {
        if (insight.id.startsWith('test_insight_')) {
          await _sleepService.deleteSleepInsight(insight.id);
          deletedCount++;
        }
      }

      _updateResult('Cleanup completed! Deleted $deletedCount test items.');
    } catch (e) {
      _updateResult('Error during cleanup: $e');
    }
  }
}
