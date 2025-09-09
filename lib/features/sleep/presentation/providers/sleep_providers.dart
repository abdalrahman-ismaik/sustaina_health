import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firestore_sleep_service.dart';
import '../../data/models/sleep_models.dart';
import 'package:uuid/uuid.dart';

// Firestore Service Provider
final Provider<FirestoreSleepService> firestoreSleepServiceProvider = Provider<FirestoreSleepService>((ProviderRef<FirestoreSleepService> ref) {
  return FirestoreSleepService();
});

// Sleep Sessions Provider with Real-time Firebase Stream
final StreamProvider<List<SleepSession>> sleepSessionsStreamProvider = StreamProvider<List<SleepSession>>((StreamProviderRef<List<SleepSession>> ref) {
  final FirestoreSleepService sleepService = ref.watch(firestoreSleepServiceProvider);
  return sleepService.watchSleepSessions();
});

// Sleep Sessions State Notifier for write operations
final StateNotifierProvider<SleepSessionsNotifier, AsyncValue<List<SleepSession>>> sleepSessionsProvider = StateNotifierProvider<SleepSessionsNotifier, AsyncValue<List<SleepSession>>>((StateNotifierProviderRef<SleepSessionsNotifier, AsyncValue<List<SleepSession>>> ref) {
  return SleepSessionsNotifier(ref.watch(firestoreSleepServiceProvider), ref);
});

class SleepSessionsNotifier extends StateNotifier<AsyncValue<List<SleepSession>>> {
  final FirestoreSleepService _sleepService;
  final StateNotifierProviderRef<SleepSessionsNotifier, AsyncValue<List<SleepSession>>> _ref;

  SleepSessionsNotifier(this._sleepService, this._ref) : super(const AsyncValue.loading()) {
    // Listen to the stream provider for real-time updates
    _ref.listen<AsyncValue<List<SleepSession>>>(sleepSessionsStreamProvider, (AsyncValue<List<SleepSession>>? previous, AsyncValue<List<SleepSession>> next) {
      state = next;
    });
  }

  Future<void> addSleepSession(SleepSession session) async {
    try {
      await _sleepService.saveSleepSession(session);
      // State will update automatically via stream
      print('✅ Sleep session saved to Firebase successfully');
      
      // Refresh all related providers
      _ref.invalidate(sleepStatsProvider);
      _ref.invalidate(sleepInsightsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error saving sleep session: $error');
    }
  }

  Future<void> updateSleepSession(SleepSession session) async {
    try {
      await _sleepService.updateSleepSession(session);
      print('✅ Sleep session updated in Firebase successfully');
      
      // Refresh all related providers
      _ref.invalidate(sleepStatsProvider);
      _ref.invalidate(sleepInsightsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error updating sleep session: $error');
    }
  }

  Future<void> deleteSleepSession(String sessionId) async {
    try {
      await _sleepService.deleteSleepSession(sessionId);
      print('✅ Sleep session deleted from Firebase successfully');
      
      // Refresh all related providers
      _ref.invalidate(sleepStatsProvider);
      _ref.invalidate(sleepInsightsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error deleting sleep session: $error');
    }
  }

  Future<List<SleepSession>> getSleepSessionsForDate(DateTime date) async {
    try {
      final List<SleepSession> sessions = await _sleepService.getSleepSessions(
        startDate: DateTime(date.year, date.month, date.day),
        endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
      );
      return sessions;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return <SleepSession>[];
    }
  }
}

// Latest Sleep Session Provider
final Provider<AsyncValue<SleepSession?>> latestSleepSessionProvider = Provider<AsyncValue<SleepSession?>>((ProviderRef<AsyncValue<SleepSession?>> ref) {
  final AsyncValue<List<SleepSession>> sessionsAsync = ref.watch(sleepSessionsStreamProvider);
  return sessionsAsync.when(
    data: (List<SleepSession> sessions) => AsyncValue.data(sessions.isNotEmpty ? sessions.first : null),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Stats Provider with Firebase - Auto-refreshes when sessions change
final FutureProvider<SleepStats> sleepStatsProvider = FutureProvider<SleepStats>((FutureProviderRef<SleepStats> ref) async {
  // This provider depends on the sessions stream, so it will refresh when sessions change
  final AsyncValue<List<SleepSession>> sessionsAsync = ref.watch(sleepSessionsStreamProvider);
  final FirestoreSleepService sleepService = ref.watch(firestoreSleepServiceProvider);
  
  // If sessions are still loading, return default stats
  if (sessionsAsync.isLoading) {
    print('⏳ Sessions still loading, returning default stats');
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
  
  if (sessionsAsync.hasError) {
    print('❌ Error in sessions, throwing error for stats');
    throw sessionsAsync.error!;
  }
  
  final List<SleepSession> sessions = sessionsAsync.value ?? <SleepSession>[];
  print('🔄 Calculating stats for ${sessions.length} sessions');
  
  try {
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 7));
    print('📅 Loading stats for date range: ${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}');
    
    final Map<String, dynamic> analytics = await sleepService.getSleepAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
    
    print('📊 Analytics data: $analytics');
    
    final SleepStats stats = SleepStats(
      averageDuration: Duration(minutes: ((analytics['averageDuration'] as num).toDouble() * 60).round()),
      averageQuality: (analytics['averageQuality'] as num).toDouble(),
      totalSleepTime: Duration(minutes: ((analytics['totalSleepTime'] as num).toDouble() * 60).round()),
      totalSessions: analytics['totalSessions'] as int,
      bestSleep: Duration(hours: 8), // You may want to calculate this from sessions
      worstSleep: Duration(hours: 4), // You may want to calculate this from sessions
      consistencyScore: (analytics['consistencyScore'] as num).toDouble(),
      sustainabilityScore: (analytics['sustainabilityScore'] as num).toDouble(),
      weeklyTrends: (analytics['moodBreakdown'] as Map<String, dynamic>).map((String key, dynamic value) => MapEntry<String, double>(key, (value as num).toDouble())),
    );
    
    print('✅ Sleep stats calculated successfully: ${stats.totalSessions} sessions, avg duration: ${stats.averageDuration.inHours}h${stats.averageDuration.inMinutes % 60}m');
    return stats;
  } catch (error) {
    print('❌ Error calculating sleep stats: $error');
    rethrow;
  }
});

// Sleep Goals Provider with Firebase and Real-time updates
final StreamProvider<List<SleepGoal>> sleepGoalsStreamProvider = StreamProvider<List<SleepGoal>>((StreamProviderRef<List<SleepGoal>> ref) {
  final FirestoreSleepService sleepService = ref.watch(firestoreSleepServiceProvider);
  return sleepService.watchSleepGoals();
});

final StateNotifierProvider<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>> sleepGoalsProvider = StateNotifierProvider<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>>((StateNotifierProviderRef<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>> ref) {
  return SleepGoalsNotifier(ref.watch(firestoreSleepServiceProvider), ref);
});

class SleepGoalsNotifier extends StateNotifier<AsyncValue<List<SleepGoal>>> {
  final FirestoreSleepService _sleepService;
  final StateNotifierProviderRef<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>> _ref;

  SleepGoalsNotifier(this._sleepService, this._ref) : super(const AsyncValue.loading()) {
    // Listen to the stream provider for real-time updates
    _ref.listen<AsyncValue<List<SleepGoal>>>(sleepGoalsStreamProvider, (AsyncValue<List<SleepGoal>>? previous, AsyncValue<List<SleepGoal>> next) {
      state = next;
    });
  }

  Future<void> addSleepGoal(SleepGoal goal) async {
    try {
      await _sleepService.saveSleepGoal(goal);
      print('✅ Sleep goal saved to Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error saving sleep goal: $error');
    }
  }

  Future<void> updateSleepGoal(SleepGoal goal) async {
    try {
      await _sleepService.updateSleepGoal(goal);
      print('✅ Sleep goal updated in Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error updating sleep goal: $error');
    }
  }

  Future<void> deleteSleepGoal(String goalId) async {
    try {
      await _sleepService.deleteSleepGoal(goalId);
      print('✅ Sleep goal deleted from Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error deleting sleep goal: $error');
    }
  }

  Future<void> createDefaultGoal() async {
    try {
      const Duration targetDuration = Duration(hours: 8);
      const String targetQuality = '8.0';
      
      final SleepGoal goal = SleepGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetDuration: targetDuration,
        targetBedtime: const TimeOfDay(hour: 22, minute: 0),
        targetWakeTime: const TimeOfDay(hour: 6, minute: 0),
        targetQuality: double.parse(targetQuality),
        reminderEnabled: true,
        createdAt: DateTime.now(),
      );
      
      await _sleepService.saveSleepGoal(goal);
      print('✅ Default sleep goal created successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error creating default sleep goal: $error');
    }
  }
}

// Sleep Reminders Provider with Firebase and Real-time updates
final StreamProvider<List<SleepReminder>> sleepRemindersStreamProvider = StreamProvider<List<SleepReminder>>((StreamProviderRef<List<SleepReminder>> ref) {
  final FirestoreSleepService sleepService = ref.watch(firestoreSleepServiceProvider);
  return sleepService.watchSleepReminders();
});

final StateNotifierProvider<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>> sleepRemindersProvider = StateNotifierProvider<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>>((StateNotifierProviderRef<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>> ref) {
  return SleepRemindersNotifier(ref.watch(firestoreSleepServiceProvider), ref);
});

class SleepRemindersNotifier extends StateNotifier<AsyncValue<List<SleepReminder>>> {
  final FirestoreSleepService _sleepService;
  final StateNotifierProviderRef<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>> _ref;

  SleepRemindersNotifier(this._sleepService, this._ref) : super(const AsyncValue.loading()) {
    // Listen to the stream provider for real-time updates
    _ref.listen<AsyncValue<List<SleepReminder>>>(sleepRemindersStreamProvider, (AsyncValue<List<SleepReminder>>? previous, AsyncValue<List<SleepReminder>> next) {
      state = next;
    });
  }

  Future<void> addSleepReminder(SleepReminder reminder) async {
    try {
      await _sleepService.saveSleepReminder(reminder);
      print('✅ Sleep reminder saved to Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error saving sleep reminder: $error');
    }
  }

  Future<void> updateSleepReminder(SleepReminder reminder) async {
    try {
      await _sleepService.updateSleepReminder(reminder);
      print('✅ Sleep reminder updated in Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error updating sleep reminder: $error');
    }
  }

  Future<void> deleteSleepReminder(String reminderId) async {
    try {
      await _sleepService.deleteSleepReminder(reminderId);
      print('✅ Sleep reminder deleted from Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error deleting sleep reminder: $error');
    }
  }

  Future<void> createDefaultReminder() async {
    try {
      const Uuid uuid = Uuid();
      final SleepReminder reminder = SleepReminder(
        id: uuid.v4(),
        time: const TimeOfDay(hour: 21, minute: 30),
        enabled: true,
        days: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
        message: 'Time to prepare for bed!',
        createdAt: DateTime.now(),
      );
      
      await _sleepService.saveSleepReminder(reminder);
      print('✅ Default sleep reminder created successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error creating default sleep reminder: $error');
    }
  }
}

// Sleep Insights Provider with Firebase and Real-time updates
final StreamProvider<List<SleepInsight>> sleepInsightsStreamProvider = StreamProvider<List<SleepInsight>>((StreamProviderRef<List<SleepInsight>> ref) {
  final FirestoreSleepService sleepService = ref.watch(firestoreSleepServiceProvider);
  return sleepService.watchSleepInsights();
});

final StateNotifierProvider<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>> sleepInsightsProvider = StateNotifierProvider<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>>((StateNotifierProviderRef<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>> ref) {
  return SleepInsightsNotifier(ref.watch(firestoreSleepServiceProvider), ref);
});

class SleepInsightsNotifier extends StateNotifier<AsyncValue<List<SleepInsight>>> {
  final FirestoreSleepService _sleepService;
  final StateNotifierProviderRef<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>> _ref;

  SleepInsightsNotifier(this._sleepService, this._ref) : super(const AsyncValue.loading()) {
    // Listen to the stream provider for real-time updates
    _ref.listen<AsyncValue<List<SleepInsight>>>(sleepInsightsStreamProvider, (AsyncValue<List<SleepInsight>>? previous, AsyncValue<List<SleepInsight>> next) {
      state = next;
    });
    
    // Also listen to sleep sessions changes to generate new insights
    _ref.listen<AsyncValue<List<SleepSession>>>(sleepSessionsStreamProvider, (AsyncValue<List<SleepSession>>? previous, AsyncValue<List<SleepSession>> next) {
      if (next.hasValue) {
        generateInsightsFromSessions(next.value!);
      }
    });
  }

  Future<void> generateInsightsFromSessions(List<SleepSession> sessions) async {
    try {
      const Uuid uuid = Uuid();
      final List<SleepInsight> insights = <SleepInsight>[];
      
      if (sessions.isEmpty) {
        final SleepInsight welcomeInsight = SleepInsight(
          id: uuid.v4(),
          title: 'Start Tracking Your Sleep',
          description: 'Begin your sleep journey by tracking your first sleep session.',
          type: SleepInsightType.quality,
          impact: 0.0,
          recommendations: <String>[
            'Set up your sleep environment',
            'Create a bedtime routine',
            'Track your first sleep session',
          ],
          createdAt: DateTime.now(),
        );
        insights.add(welcomeInsight);
      } else {
        // Calculate averages for insights
        final double avgQuality = sessions.fold<double>(0, (double sum, SleepSession session) => sum + session.sleepQuality) / sessions.length;
        final Duration avgDuration = Duration(
          milliseconds: sessions.fold<int>(0, (int sum, SleepSession session) => sum + session.totalDuration.inMilliseconds) ~/ sessions.length,
        );
        
        // Quality insights
        if (avgQuality < 7.0) {
          final SleepInsight qualityInsight = SleepInsight(
            id: uuid.v4(),
            title: 'Improve Sleep Quality',
            description: 'Your average sleep quality is below optimal levels (${avgQuality.toStringAsFixed(1)}/10).',
            type: SleepInsightType.quality,
            impact: 0.8,
            recommendations: <String>[
              'Maintain a consistent sleep schedule',
              'Create a relaxing bedtime routine',
              'Optimize your sleep environment',
              'Limit screen time before bed',
            ],
            createdAt: DateTime.now(),
          );
          insights.add(qualityInsight);
        }
        
        // Duration insights
        if (avgDuration.inHours < 7) {
          final SleepInsight durationInsight = SleepInsight(
            id: uuid.v4(),
            title: 'Increase Sleep Duration',
            description: 'You\'re averaging ${avgDuration.inHours}h ${avgDuration.inMinutes % 60}m, less than the recommended 7-9 hours.',
            type: SleepInsightType.duration,
            impact: 0.9,
            recommendations: <String>[
              'Go to bed 30 minutes earlier',
              'Avoid caffeine after 2 PM',
              'Create a wind-down routine',
              'Set a consistent wake-up time',
            ],
            createdAt: DateTime.now(),
          );
          insights.add(durationInsight);
        }
      }
      
      // Save insights to Firebase
      for (final SleepInsight insight in insights) {
        await _sleepService.saveSleepInsight(insight);
      }
      
      print('✅ Generated ${insights.length} sleep insights');
    } catch (error) {
      print('❌ Error generating sleep insights: $error');
    }
  }

  Future<void> refreshInsights() async {
    // Insights are automatically generated when sleep sessions change
    final AsyncValue<List<SleepSession>> sessionsAsync = _ref.read(sleepSessionsStreamProvider);
    if (sessionsAsync.hasValue) {
      await generateInsightsFromSessions(sessionsAsync.value!);
    }
  }
}

// Sleep Tracking State Provider
final StateNotifierProvider<SleepTrackingStateNotifier, SleepTrackingState> sleepTrackingStateProvider = StateNotifierProvider<SleepTrackingStateNotifier, SleepTrackingState>((StateNotifierProviderRef<SleepTrackingStateNotifier, SleepTrackingState> ref) {
  return SleepTrackingStateNotifier();
});

enum SleepTrackingState {
  notTracking,
  tracking,
  paused,
  completed
}

class SleepTrackingStateNotifier extends StateNotifier<SleepTrackingState> {
  SleepTrackingStateNotifier() : super(SleepTrackingState.notTracking);

  void startTracking() {
    state = SleepTrackingState.tracking;
  }

  void pauseTracking() {
    state = SleepTrackingState.paused;
  }

  void resumeTracking() {
    state = SleepTrackingState.tracking;
  }

  void stopTracking() {
    state = SleepTrackingState.completed;
  }

  void reset() {
    state = SleepTrackingState.notTracking;
  }
}

// Sleep Session Creation Provider with Firebase
final StateNotifierProvider<SleepSessionCreationNotifier, AsyncValue<SleepSession?>> sleepSessionCreationProvider = StateNotifierProvider<SleepSessionCreationNotifier, AsyncValue<SleepSession?>>((StateNotifierProviderRef<SleepSessionCreationNotifier, AsyncValue<SleepSession?>> ref) {
  return SleepSessionCreationNotifier(ref.watch(firestoreSleepServiceProvider), ref);
});

class SleepSessionCreationNotifier extends StateNotifier<AsyncValue<SleepSession?>> {
  final FirestoreSleepService _sleepService;
  final StateNotifierProviderRef<SleepSessionCreationNotifier, AsyncValue<SleepSession?>> _ref;

  SleepSessionCreationNotifier(this._sleepService, this._ref) : super(const AsyncValue.data(null));

  Future<void> createSleepSession({
    required DateTime startTime,
    required DateTime endTime,
    required double sleepQuality,
    required String mood,
    required SleepEnvironment environment,
    required SleepStages stages,
    required SleepSustainability sustainability,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      const Uuid uuid = Uuid();
      final SleepSession session = SleepSession(
        id: uuid.v4(),
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
      
      await _sleepService.saveSleepSession(session);
      state = AsyncValue.data(session);
      
      // Refresh related providers
      _ref.invalidate(sleepStatsProvider);
      _ref.invalidate(sleepInsightsProvider);
      
      print('✅ Sleep session created and saved to Firebase successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('❌ Error creating sleep session: $error');
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Weekly Sleep Trends Provider
final Provider<AsyncValue<Map<String, double>>> weeklySleepTrendsProvider = Provider<AsyncValue<Map<String, double>>>((ProviderRef<AsyncValue<Map<String, double>>> ref) {
  final AsyncValue<SleepStats> statsAsync = ref.watch(sleepStatsProvider);
  return statsAsync.when(
    data: (SleepStats stats) => AsyncValue.data(stats.weeklyTrends),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Quality Score Provider
final Provider<AsyncValue<double>> sleepQualityScoreProvider = Provider<AsyncValue<double>>((ProviderRef<AsyncValue<double>> ref) {
  final AsyncValue<SleepStats> statsAsync = ref.watch(sleepStatsProvider);
  return statsAsync.when(
    data: (SleepStats stats) => AsyncValue.data(stats.averageQuality),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Duration Provider
final Provider<AsyncValue<Duration>> sleepDurationProvider = Provider<AsyncValue<Duration>>((ProviderRef<AsyncValue<Duration>> ref) {
  final AsyncValue<SleepStats> statsAsync = ref.watch(sleepStatsProvider);
  return statsAsync.when(
    data: (SleepStats stats) => AsyncValue.data(stats.averageDuration),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Consistency Score Provider
final Provider<AsyncValue<double>> sleepConsistencyScoreProvider = Provider<AsyncValue<double>>((ProviderRef<AsyncValue<double>> ref) {
  final AsyncValue<SleepStats> statsAsync = ref.watch(sleepStatsProvider);
  return statsAsync.when(
    data: (SleepStats stats) => AsyncValue.data(stats.consistencyScore),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Sustainability Score Provider
final Provider<AsyncValue<double>> sleepSustainabilityScoreProvider = Provider<AsyncValue<double>>((ProviderRef<AsyncValue<double>> ref) {
  final AsyncValue<SleepStats> statsAsync = ref.watch(sleepStatsProvider);
  return statsAsync.when(
    data: (SleepStats stats) => AsyncValue.data(stats.sustainabilityScore),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Additional Real-time Providers
// Sleep Sessions for Today Provider
final Provider<AsyncValue<List<SleepSession>>> todaySleepSessionsProvider = Provider<AsyncValue<List<SleepSession>>>((ProviderRef<AsyncValue<List<SleepSession>>> ref) {
  final AsyncValue<List<SleepSession>> sessionsAsync = ref.watch(sleepSessionsStreamProvider);
  final DateTime today = DateTime.now();
  
  return sessionsAsync.when(
    data: (List<SleepSession> sessions) {
      final List<SleepSession> todaySessions = sessions.where((SleepSession session) {
        final DateTime sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        final DateTime targetDate = DateTime(today.year, today.month, today.day);
        return sessionDate.isAtSameMomentAs(targetDate);
      }).toList();
      return AsyncValue.data(todaySessions);
    },
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Active Sleep Goals Provider
final Provider<AsyncValue<List<SleepGoal>>> activeSleepGoalsProvider = Provider<AsyncValue<List<SleepGoal>>>((ProviderRef<AsyncValue<List<SleepGoal>>> ref) {
  final AsyncValue<List<SleepGoal>> goalsAsync = ref.watch(sleepGoalsStreamProvider);
  
  return goalsAsync.when(
    data: (List<SleepGoal> goals) {
      final List<SleepGoal> activeGoals = goals.where((SleepGoal goal) => goal.reminderEnabled).toList();
      return AsyncValue.data(activeGoals);
    },
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Enabled Sleep Reminders Provider
final Provider<AsyncValue<List<SleepReminder>>> enabledSleepRemindersProvider = Provider<AsyncValue<List<SleepReminder>>>((ProviderRef<AsyncValue<List<SleepReminder>>> ref) {
  final AsyncValue<List<SleepReminder>> remindersAsync = ref.watch(sleepRemindersStreamProvider);
  
  return remindersAsync.when(
    data: (List<SleepReminder> reminders) {
      final List<SleepReminder> enabledReminders = reminders.where((SleepReminder reminder) => reminder.enabled).toList();
      return AsyncValue.data(enabledReminders);
    },
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
