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
        title: const Text('Sleep Cloud Storage Debug'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test buttons
            _buildTestButton('Create Test Sleep Session', _createTestSleepSession),
            _buildTestButton('Get All Sleep Sessions', _getAllSleepSessions),
            _buildTestButton('Create Test Sleep Goal', _createTestSleepGoal),
            _buildTestButton('Get All Sleep Goals', _getAllSleepGoals),
            _buildTestButton('Create Test Sleep Reminder', _createTestSleepReminder),
            _buildTestButton('Get All Sleep Reminders', _getAllSleepReminders),
            _buildTestButton('Get Sleep Analytics', _getSleepAnalytics),
            _buildTestButton('Delete All Test Data', _deleteAllTestData, color: Colors.red),
            
            const SizedBox(height: 20),
            
            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            
            // Results
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Result:', style: Theme.of(context).textTheme.titleMedium),
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
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color != null ? Colors.white : null,
        ),
        child: Text(label),
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

  // Test Methods
  Future<void> _createTestSleepSession() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final now = DateTime.now();
      final startTime = now.subtract(const Duration(hours: 8));
      final testSession = SleepSession(
        id: 'test_session_${now.millisecondsSinceEpoch}',
        startTime: startTime,
        endTime: now,
        totalDuration: now.difference(startTime),
        sleepQuality: 8.0,
        mood: 'refreshed',
        environment: const SleepEnvironment(
          roomTemperature: 22.0,
          noiseLevel: 'low',
          lightExposure: 'minimal',
          screenTime: 0.5,
          naturalLight: false,
          ecoFriendly: true,
          energyEfficient: true,
        ),
        stages: const SleepStages(
          lightSleep: Duration(hours: 3),
          deepSleep: Duration(hours: 2, minutes: 30),
          remSleep: Duration(hours: 2),
          awakeTime: Duration(minutes: 30),
        ),
        sustainability: const SleepSustainability(
          energySaved: 5.2,
          carbonFootprintReduction: 2.1,
          usedEcoFriendlyBedding: true,
          usedNaturalVentilation: true,
          usedEnergyEfficientDevices: true,
        ),
        createdAt: now,
        notes: 'Test sleep session from debug panel',
      );

      await _sleepService.saveSleepSession(testSession);
      _updateResult('✅ Sleep session created! ID: ${testSession.id}');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _getAllSleepSessions() async {
    _setLoading();
    try {
      final sessions = await _sleepService.getSleepSessions(limit: 10);
      _updateResult('Found ${sessions.length} sleep sessions:\n\n${sessions.map((s) => 'ID: ${s.id}\nDate: ${s.startTime}\nQuality: ${s.sleepQuality}/10').join('\n\n')}');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _createTestSleepGoal() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testGoal = SleepGoal(
        id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
        targetBedtime: const TimeOfDay(hour: 22, minute: 30),
        targetWakeTime: const TimeOfDay(hour: 6, minute: 30),
        targetDuration: const Duration(hours: 8),
        targetQuality: 7.0,
        reminderEnabled: true,
        createdAt: DateTime.now(),
      );

      await _sleepService.saveSleepGoal(testGoal);
      _updateResult('✅ Sleep goal created! Target: 8 hours (22:30 - 06:30)');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _getAllSleepGoals() async {
    _setLoading();
    try {
      final goals = await _sleepService.getSleepGoals();
      _updateResult('Found ${goals.length} sleep goals:\n\n${goals.map((g) => 'ID: ${g.id}\nTarget: ${g.targetDuration.inHours}h\nQuality target: ${g.targetQuality}/10\nReminder: ${g.reminderEnabled}').join('\n\n')}');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _createTestSleepReminder() async {
    _setLoading();
    try {
      await _sleepService.ensureUserDocumentExists();

      final testReminder = SleepReminder(
        id: 'test_reminder_${DateTime.now().millisecondsSinceEpoch}',
        time: const TimeOfDay(hour: 21, minute: 30),
        enabled: true,
        days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        message: 'Time to wind down for bed!',
        createdAt: DateTime.now(),
      );

      await _sleepService.saveSleepReminder(testReminder);
      _updateResult('✅ Sleep reminder created! Time: 21:30 (weekdays)');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _getAllSleepReminders() async {
    _setLoading();
    try {
      final reminders = await _sleepService.getSleepReminders();
      _updateResult('Found ${reminders.length} sleep reminders:\n\n${reminders.map((r) => 'Message: ${r.message}\nTime: ${r.time.format(context)}\nEnabled: ${r.enabled}').join('\n\n')}');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

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
      result.writeln('Average Duration: ${analytics['averageDuration'].toStringAsFixed(1)}h');
      result.writeln('Average Quality: ${analytics['averageQuality'].toStringAsFixed(1)}/10');
      result.writeln('Consistency Score: ${(analytics['consistencyScore'] * 100).toStringAsFixed(1)}%');

      _updateResult(result.toString());
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }

  Future<void> _deleteAllTestData() async {
    _setLoading();
    try {
      final sessions = await _sleepService.getSleepSessions();
      final goals = await _sleepService.getSleepGoals();
      final reminders = await _sleepService.getSleepReminders();

      int deletedCount = 0;

      for (final session in sessions) {
        if (session.id.startsWith('test_session_')) {
          await _sleepService.deleteSleepSession(session.id);
          deletedCount++;
        }
      }

      for (final goal in goals) {
        if (goal.id.startsWith('test_goal_')) {
          await _sleepService.deleteSleepGoal(goal.id);
          deletedCount++;
        }
      }

      for (final reminder in reminders) {
        if (reminder.id.startsWith('test_reminder_')) {
          await _sleepService.deleteSleepReminder(reminder.id);
          deletedCount++;
        }
      }

      _updateResult('✅ Cleanup completed! Deleted $deletedCount test items.');
    } catch (e) {
      _updateResult('❌ Error: $e');
    }
  }
}
