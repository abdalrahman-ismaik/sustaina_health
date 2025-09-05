import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

/// Firestore service for profile data with modular users/{userId}/profile structure
class FirestoreProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Collection references - using new modular structure: users/{userId}/profile/data/subcollection
  CollectionReference get _personalInfoCollection =>
      _firestore.collection('users').doc(_userId).collection('profile').doc('data').collection('personal_info');

  CollectionReference get _healthGoalsCollection =>
      _firestore.collection('users').doc(_userId).collection('profile').doc('data').collection('health_goals');

  CollectionReference get _preferencesCollection =>
      _firestore.collection('users').doc(_userId).collection('profile').doc('data').collection('preferences');

  CollectionReference get _achievementsCollection =>
      _firestore.collection('users').doc(_userId).collection('profile').doc('data').collection('achievements');

  /// Ensure profile module document exists
  Future<void> ensureProfileModuleExists() async {
    final DocumentReference profileDoc = _firestore
        .collection('users')
        .doc(_userId)
        .collection('profile')
        .doc('data');
    
    final DocumentSnapshot doc = await profileDoc.get();
    if (!doc.exists) {
      await profileDoc.set({
        'module': 'profile',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Personal Info Operations
  Future<String> savePersonalInfo(UserProfile profile) async {
    try {
      await ensureProfileModuleExists();
      
      final Map<String, dynamic> data = profile.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _personalInfoCollection.doc('current').set(data);
      return 'current';
    } catch (e) {
      throw Exception('Failed to save personal info: $e');
    }
  }

  Future<UserProfile?> getPersonalInfo() async {
    try {
      final DocumentSnapshot doc = await _personalInfoCollection.doc('current').get();
      
      if (!doc.exists) {
        return null;
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return UserProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get personal info: $e');
    }
  }

  // Health Goals Operations
  Future<String> saveHealthGoal(Map<String, dynamic> goal) async {
    try {
      await ensureProfileModuleExists();
      
      final Map<String, dynamic> data = {
        ...goal,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final DocumentReference docRef = await _healthGoalsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save health goal: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHealthGoals() async {
    try {
      final QuerySnapshot snapshot = await _healthGoalsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get health goals: $e');
    }
  }

  Future<void> updateHealthGoal(String goalId, Map<String, dynamic> updates) async {
    try {
      final Map<String, dynamic> data = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _healthGoalsCollection.doc(goalId).update(data);
    } catch (e) {
      throw Exception('Failed to update health goal: $e');
    }
  }

  Future<void> deleteHealthGoal(String goalId) async {
    try {
      await _healthGoalsCollection.doc(goalId).delete();
    } catch (e) {
      throw Exception('Failed to delete health goal: $e');
    }
  }

  // Preferences Operations
  Future<String> savePreferences(Map<String, dynamic> preferences) async {
    try {
      await ensureProfileModuleExists();
      
      final Map<String, dynamic> data = {
        ...preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _preferencesCollection.doc('current').set(data);
      return 'current';
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final DocumentSnapshot doc = await _preferencesCollection.doc('current').get();
      
      if (!doc.exists) {
        return null;
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  // Achievements Operations
  Future<String> saveAchievement(Map<String, dynamic> achievement) async {
    try {
      await ensureProfileModuleExists();
      
      final Map<String, dynamic> data = {
        ...achievement,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final DocumentReference docRef = await _achievementsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save achievement: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final QuerySnapshot snapshot = await _achievementsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get achievements: $e');
    }
  }

  // Real-time streams
  Stream<UserProfile?> watchPersonalInfo() {
    return _personalInfoCollection.doc('current').snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  Stream<List<Map<String, dynamic>>> watchHealthGoals() {
    return _healthGoalsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList());
  }

  Stream<List<Map<String, dynamic>>> watchAchievements() {
    return _achievementsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList());
  }

  // Analytics and reporting
  Future<Map<String, int>> getProfileAnalytics() async {
    try {
      await ensureProfileModuleExists();
      
      final futures = await Future.wait([
        _healthGoalsCollection.get(),
        _achievementsCollection.get(),
      ]);

      return {
        'totalHealthGoals': futures[0].size,
        'totalAchievements': futures[1].size,
        'activeGoals': futures[0].docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'active' || data['isActive'] == true;
        }).length,
        'completedAchievements': futures[1].docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['completed'] == true || data['status'] == 'completed';
        }).length,
      };
    } catch (e) {
      throw Exception('Failed to get profile analytics: $e');
    }
  }
}
