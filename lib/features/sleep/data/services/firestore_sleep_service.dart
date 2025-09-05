import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sleep_models.dart';

class FirestoreSleepService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please sign in to access sleep data.');
    }
    return user.uid;
  }

  // Collection references - using new modular structure: users/{userId}/sleep/data/subcollection
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  CollectionReference get _sleepSessionsCollection =>
      _usersCollection.doc(_userId).collection('sleep').doc('data').collection('sleep_sessions');

  CollectionReference get _sleepGoalsCollection =>
      _usersCollection.doc(_userId).collection('sleep').doc('data').collection('sleep_goals');

  CollectionReference get _sleepRemindersCollection =>
      _usersCollection.doc(_userId).collection('sleep').doc('data').collection('sleep_reminders');

  CollectionReference get _sleepInsightsCollection =>
      _usersCollection.doc(_userId).collection('sleep').doc('data').collection('sleep_insights');

  CollectionReference get _sleepStatsCollection =>
      _usersCollection.doc(_userId).collection('sleep').doc('data').collection('sleep_stats');

  /// Ensure sleep module document exists
  Future<void> ensureSleepModuleExists() async {
    final DocumentReference sleepDoc = _usersCollection
        .doc(_userId)
        .collection('sleep')
        .doc('data');
    
    final DocumentSnapshot doc = await sleepDoc.get();
    if (!doc.exists) {
      await sleepDoc.set({
        'module': 'sleep',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Sleep Session methods
  Future<void> saveSleepSession(SleepSession session) async {
    await ensureSleepModuleExists();
    await _sleepSessionsCollection.doc(session.id).set(session.toJson());
  }

  Future<void> updateSleepSession(SleepSession session) async {
    await _sleepSessionsCollection.doc(session.id).update(session.toJson());
  }

  Future<void> deleteSleepSession(String sessionId) async {
    await _sleepSessionsCollection.doc(sessionId).delete();
  }

  Future<SleepSession?> getSleepSession(String sessionId) async {
    final doc = await _sleepSessionsCollection.doc(sessionId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return SleepSession.fromJson(data);
  }

  Future<List<SleepSession>> getSleepSessions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _sleepSessionsCollection.orderBy('startTime', descending: true);

    // Apply date filters
    if (startDate != null) {
      query = query.where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.where('startTime', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SleepSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<SleepSession>> getSleepSessionsForDateRange(DateTime start, DateTime end) async {
    return getSleepSessions(
      startDate: start.subtract(const Duration(days: 1)),
      endDate: end.add(const Duration(days: 1)),
    );
  }

  // Sleep Goal methods
  Future<void> saveSleepGoal(SleepGoal goal) async {
    await ensureSleepModuleExists();
    await _sleepGoalsCollection.doc(goal.id).set(goal.toJson());
  }

  Future<void> updateSleepGoal(SleepGoal goal) async {
    await _sleepGoalsCollection.doc(goal.id).update(goal.toJson());
  }

  Future<void> deleteSleepGoal(String goalId) async {
    await _sleepGoalsCollection.doc(goalId).delete();
  }

  Future<SleepGoal?> getSleepGoal(String goalId) async {
    final doc = await _sleepGoalsCollection.doc(goalId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return SleepGoal.fromJson(data);
  }

  Future<List<SleepGoal>> getSleepGoals({int? limit}) async {
    Query query = _sleepGoalsCollection.orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SleepGoal.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sleep Reminder methods
  Future<void> saveSleepReminder(SleepReminder reminder) async {
    await ensureSleepModuleExists();
    await _sleepRemindersCollection.doc(reminder.id).set(reminder.toJson());
  }

  Future<void> updateSleepReminder(SleepReminder reminder) async {
    await _sleepRemindersCollection.doc(reminder.id).update(reminder.toJson());
  }

  Future<void> deleteSleepReminder(String reminderId) async {
    await _sleepRemindersCollection.doc(reminderId).delete();
  }

  Future<SleepReminder?> getSleepReminder(String reminderId) async {
    final doc = await _sleepRemindersCollection.doc(reminderId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return SleepReminder.fromJson(data);
  }

  Future<List<SleepReminder>> getSleepReminders({int? limit}) async {
    Query query = _sleepRemindersCollection.orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SleepReminder.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sleep Insight methods
  Future<void> saveSleepInsight(SleepInsight insight) async {
    await ensureSleepModuleExists();
    await _sleepInsightsCollection.doc(insight.id).set(insight.toJson());
  }

  Future<void> updateSleepInsight(SleepInsight insight) async {
    await _sleepInsightsCollection.doc(insight.id).update(insight.toJson());
  }

  Future<void> deleteSleepInsight(String insightId) async {
    await _sleepInsightsCollection.doc(insightId).delete();
  }

  Future<SleepInsight?> getSleepInsight(String insightId) async {
    final doc = await _sleepInsightsCollection.doc(insightId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return SleepInsight.fromJson(data);
  }

  Future<List<SleepInsight>> getSleepInsights({
    SleepInsightType? type,
    int? limit,
  }) async {
    Query query = _sleepInsightsCollection.orderBy('createdAt', descending: true);

    // Apply type filter
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SleepInsight.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Sleep Stats methods
  Future<void> saveSleepStats(String statsId, SleepStats stats) async {
    final statsData = {
      'id': statsId,
      'userId': _userId,
      'stats': stats.toJson(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _sleepStatsCollection.doc(statsId).set(statsData);
  }

  Future<SleepStats?> getSleepStats(String statsId) async {
    final doc = await _sleepStatsCollection.doc(statsId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return SleepStats.fromJson(data['stats'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getUserSleepStats({int? limit}) async {
    Query query = _sleepStatsCollection.orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> deleteSleepStats(String statsId) async {
    await _sleepStatsCollection.doc(statsId).delete();
  }

  // Real-time listeners
  Stream<List<SleepSession>> watchSleepSessions({DateTime? date}) {
    Query query = _sleepSessionsCollection.orderBy('startTime', descending: true);

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      query = query
          .where('startTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: endOfDay.toIso8601String());
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => SleepSession.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<SleepGoal>> watchSleepGoals() {
    return _sleepGoalsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => SleepGoal.fromJson(doc.data() as Map<String, dynamic>))
                .toList());
  }

  Stream<List<SleepReminder>> watchSleepReminders() {
    return _sleepRemindersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => SleepReminder.fromJson(doc.data() as Map<String, dynamic>))
                .toList());
  }

  Stream<List<SleepInsight>> watchSleepInsights({SleepInsightType? type}) {
    Query query = _sleepInsightsCollection.orderBy('createdAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => SleepInsight.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Batch operations
  Future<void> batchSaveSleepSessions(List<SleepSession> sessions) async {
    final batch = _firestore.batch();

    for (final session in sessions) {
      final docRef = _sleepSessionsCollection.doc(session.id);
      batch.set(docRef, session.toJson());
    }

    await batch.commit();
  }

  Future<void> batchDeleteSleepSessions(List<String> sessionIds) async {
    final batch = _firestore.batch();

    for (final sessionId in sessionIds) {
      final docRef = _sleepSessionsCollection.doc(sessionId);
      batch.delete(docRef);
    }

    await batch.commit();
  }

  // Search functionality
  Future<List<SleepSession>> searchSleepSessions({
    required String searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    // Note: This is a basic implementation. For advanced search, consider using Algolia or similar
    Query query = _sleepSessionsCollection.orderBy('startTime', descending: true);

    if (startDate != null) {
      query = query.where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.where('startTime', isLessThanOrEqualTo: endDate.toIso8601String());
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    final allSessions = snapshot.docs
        .map((doc) => SleepSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter by search term (case-insensitive)
    final searchTermLower = searchTerm.toLowerCase();
    return allSessions.where((session) =>
        session.mood.toLowerCase().contains(searchTermLower) ||
        (session.notes?.toLowerCase().contains(searchTermLower) ?? false)).toList();
  }

  // Statistics and analytics
  Future<Map<String, dynamic>> getSleepAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sessions = await getSleepSessions(
      startDate: startDate,
      endDate: endDate,
    );

    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'averageDuration': 0.0,
        'averageQuality': 0.0,
        'totalSleepTime': 0.0,
        'consistencyScore': 0.0,
        'sustainabilityScore': 0.0,
        'moodBreakdown': <String, int>{},
      };
    }

    final totalSessions = sessions.length;
    final averageDuration = sessions.fold<double>(0, (sum, session) => sum + session.totalDuration.inHours) / totalSessions;
    final averageQuality = sessions.fold<double>(0, (sum, session) => sum + session.sleepQuality) / totalSessions;
    final totalSleepTime = sessions.fold<double>(0, (sum, session) => sum + session.totalDuration.inHours);

    // Calculate consistency score
    final durations = sessions.map((s) => s.totalDuration.inMinutes).toList();
    final mean = durations.reduce((a, b) => a + b) / durations.length;
    final variance = durations.map((d) => (d - mean) * (d - mean)).reduce((a, b) => a + b) / durations.length;
    final standardDeviation = variance > 0 ? math.sqrt(variance) : 0.0;
    final consistencyScore = mean > 0 ? (1.0 - (standardDeviation / mean)).clamp(0.0, 1.0) : 0.0;

    // Calculate sustainability score
    double totalSustainabilityScore = 0.0;
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
      
      totalSustainabilityScore += sessionScore;
    }
    final sustainabilityScore = totalSustainabilityScore / totalSessions;

    // Mood breakdown
    final moodBreakdown = <String, int>{};
    for (final session in sessions) {
      moodBreakdown[session.mood] = (moodBreakdown[session.mood] ?? 0) + 1;
    }

    return {
      'totalSessions': totalSessions,
      'averageDuration': averageDuration,
      'averageQuality': averageQuality,
      'totalSleepTime': totalSleepTime,
      'consistencyScore': consistencyScore,
      'sustainabilityScore': sustainabilityScore,
      'moodBreakdown': moodBreakdown,
    };
  }

  // Helper methods
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Utility method to ensure user document exists
  Future<void> ensureUserDocumentExists() async {
    final userDoc = _usersCollection.doc(_userId);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'userId': _userId,
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}
