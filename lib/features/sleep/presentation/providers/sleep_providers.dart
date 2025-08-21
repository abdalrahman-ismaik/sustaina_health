import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/sleep_service.dart';
import '../../data/models/sleep_models.dart';

// Service Provider
final Provider<SleepService> sleepServiceProvider = Provider<SleepService>((ProviderRef<SleepService> ref) {
  return SleepService();
});

// Sleep Sessions Provider
final StateNotifierProvider<SleepSessionsNotifier, AsyncValue<List<SleepSession>>> sleepSessionsProvider = StateNotifierProvider<SleepSessionsNotifier, AsyncValue<List<SleepSession>>>((StateNotifierProviderRef<SleepSessionsNotifier, AsyncValue<List<SleepSession>>> ref) {
  return SleepSessionsNotifier(ref.watch(sleepServiceProvider));
});

class SleepSessionsNotifier extends StateNotifier<AsyncValue<List<SleepSession>>> {
  final SleepService _sleepService;

  SleepSessionsNotifier(this._sleepService) : super(const AsyncValue.loading()) {
    loadSleepSessions();
  }

  Future<void> loadSleepSessions() async {
    state = const AsyncValue.loading();
    try {
      final List<SleepSession> sessions = await _sleepService.getSleepSessions();
      state = AsyncValue.data(sessions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSleepSession(SleepSession session) async {
    try {
      await _sleepService.saveSleepSession(session);
      await loadSleepSessions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteSleepSession(String sessionId) async {
    try {
      await _sleepService.deleteSleepSession(sessionId);
      await loadSleepSessions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<SleepSession>> getSleepSessionsForDate(DateTime date) async {
    try {
      final List<SleepSession> sessions = await _sleepService.getSleepSessions();
      return sessions.where((SleepSession session) {
        final DateTime sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        final DateTime targetDate = DateTime(date.year, date.month, date.day);
        return sessionDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return <SleepSession>[];
    }
  }
}

// Latest Sleep Session Provider
final Provider<AsyncValue<SleepSession?>> latestSleepSessionProvider = Provider<AsyncValue<SleepSession?>>((ProviderRef<AsyncValue<SleepSession?>> ref) {
  final AsyncValue<List<SleepSession>> sessionsAsync = ref.watch(sleepSessionsProvider);
  return sessionsAsync.when(
    data: (List<SleepSession> sessions) => AsyncValue.data(sessions.isNotEmpty ? sessions.first : null),
    loading: () => const AsyncValue.loading(),
    error: (Object error, StackTrace stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Sleep Stats Provider
final StateNotifierProvider<SleepStatsNotifier, AsyncValue<SleepStats>> sleepStatsProvider = StateNotifierProvider<SleepStatsNotifier, AsyncValue<SleepStats>>((StateNotifierProviderRef<SleepStatsNotifier, AsyncValue<SleepStats>> ref) {
  return SleepStatsNotifier(ref.watch(sleepServiceProvider));
});

class SleepStatsNotifier extends StateNotifier<AsyncValue<SleepStats>> {
  final SleepService _sleepService;

  SleepStatsNotifier(this._sleepService) : super(const AsyncValue.loading()) {
    loadSleepStats();
  }

  Future<void> loadSleepStats() async {
    state = const AsyncValue.loading();
    try {
      final SleepStats stats = await _sleepService.calculateSleepStats();
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshStats() async {
    await loadSleepStats();
  }
}

// Sleep Goals Provider
final StateNotifierProvider<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>> sleepGoalsProvider = StateNotifierProvider<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>>((StateNotifierProviderRef<SleepGoalsNotifier, AsyncValue<List<SleepGoal>>> ref) {
  return SleepGoalsNotifier(ref.watch(sleepServiceProvider));
});

class SleepGoalsNotifier extends StateNotifier<AsyncValue<List<SleepGoal>>> {
  final SleepService _sleepService;

  SleepGoalsNotifier(this._sleepService) : super(const AsyncValue.loading()) {
    loadSleepGoals();
  }

  Future<void> loadSleepGoals() async {
    state = const AsyncValue.loading();
    try {
      final List<SleepGoal> goals = await _sleepService.getSleepGoals();
      state = AsyncValue.data(goals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSleepGoal(SleepGoal goal) async {
    try {
      await _sleepService.saveSleepGoal(goal);
      await loadSleepGoals();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createDefaultGoal() async {
    try {
      await _sleepService.createDefaultSleepGoal();
      await loadSleepGoals();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Sleep Reminders Provider
final StateNotifierProvider<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>> sleepRemindersProvider = StateNotifierProvider<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>>((StateNotifierProviderRef<SleepRemindersNotifier, AsyncValue<List<SleepReminder>>> ref) {
  return SleepRemindersNotifier(ref.watch(sleepServiceProvider));
});

class SleepRemindersNotifier extends StateNotifier<AsyncValue<List<SleepReminder>>> {
  final SleepService _sleepService;

  SleepRemindersNotifier(this._sleepService) : super(const AsyncValue.loading()) {
    loadSleepReminders();
  }

  Future<void> loadSleepReminders() async {
    state = const AsyncValue.loading();
    try {
      final List<SleepReminder> reminders = await _sleepService.getSleepReminders();
      state = AsyncValue.data(reminders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSleepReminder(SleepReminder reminder) async {
    try {
      await _sleepService.saveSleepReminder(reminder);
      await loadSleepReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createDefaultReminder() async {
    try {
      await _sleepService.createDefaultSleepReminder();
      await loadSleepReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Sleep Insights Provider
final StateNotifierProvider<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>> sleepInsightsProvider = StateNotifierProvider<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>>((StateNotifierProviderRef<SleepInsightsNotifier, AsyncValue<List<SleepInsight>>> ref) {
  return SleepInsightsNotifier(ref.watch(sleepServiceProvider));
});

class SleepInsightsNotifier extends StateNotifier<AsyncValue<List<SleepInsight>>> {
  final SleepService _sleepService;

  SleepInsightsNotifier(this._sleepService) : super(const AsyncValue.loading()) {
    loadSleepInsights();
  }

  Future<void> loadSleepInsights() async {
    state = const AsyncValue.loading();
    try {
      final List<SleepInsight> insights = await _sleepService.generateSleepInsights();
      state = AsyncValue.data(insights);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshInsights() async {
    await loadSleepInsights();
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

// Sleep Session Creation Provider
final StateNotifierProvider<SleepSessionCreationNotifier, AsyncValue<SleepSession?>> sleepSessionCreationProvider = StateNotifierProvider<SleepSessionCreationNotifier, AsyncValue<SleepSession?>>((StateNotifierProviderRef<SleepSessionCreationNotifier, AsyncValue<SleepSession?>> ref) {
  return SleepSessionCreationNotifier(ref.watch(sleepServiceProvider));
});

class SleepSessionCreationNotifier extends StateNotifier<AsyncValue<SleepSession?>> {
  final SleepService _sleepService;

  SleepSessionCreationNotifier(this._sleepService) : super(const AsyncValue.data(null));

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
      final SleepSession session = await _sleepService.createSleepSession(
        startTime: startTime,
        endTime: endTime,
        sleepQuality: sleepQuality,
        mood: mood,
        environment: environment,
        stages: stages,
        sustainability: sustainability,
        notes: notes,
      );
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
