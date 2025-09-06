import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_models.dart';

class FirestoreWorkoutService {
  static const String _workoutPlansCollectionName = 'workout_plans';
  static const String _completedWorkoutsCollectionName = 'completed_workouts';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's workout plans collection reference
  CollectionReference _getWorkoutPlansCollection() {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('exercise')
        .doc('data')
        .collection(_workoutPlansCollectionName);
  }

  /// Get the current user's completed workouts collection reference
  CollectionReference _getCompletedWorkoutsCollection() {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('exercise')
        .doc('data')
        .collection(_completedWorkoutsCollectionName);
  }

  /// Ensure exercise module document exists
  Future<void> ensureExerciseModuleExists() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final DocumentReference exerciseDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('exercise')
        .doc('data');
    
    final DocumentSnapshot doc = await exerciseDoc.get();
    if (!doc.exists) {
      await exerciseDoc.set(<String, Object>{
        'module': 'exercise',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Save workout plan to Firestore
  Future<String> saveWorkoutPlan(SavedWorkoutPlan workoutPlan) async {
    try {
      // Ensure exercise module exists
      await ensureExerciseModuleExists();
      
      final CollectionReference collection = _getWorkoutPlansCollection();
      
      // Prepare data for Firestore (remove local-only fields)
      final Map<String, dynamic> data = workoutPlan.toJson();
      data.remove('isSynced'); // Don't store sync status in Firestore
      
      DocumentReference docRef;
      
      if (workoutPlan.firestoreId != null) {
        // Update existing document
        docRef = collection.doc(workoutPlan.firestoreId);
        await docRef.update(data);
      } else {
        // Create new document
        docRef = await collection.add(data);
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save workout to Firestore: $e');
    }
  }

  /// Get all workout plans from Firestore
  Future<List<SavedWorkoutPlan>> getAllWorkoutPlans() async {
    try {
      final CollectionReference collection = _getWorkoutPlansCollection();
      final QuerySnapshot snapshot = await collection
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((QueryDocumentSnapshot doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['firestoreId'] = doc.id; // Add Firestore ID
        data['isSynced'] = true; // Mark as synced since it's from Firestore
        
        return SavedWorkoutPlan.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts from Firestore: $e');
    }
  }

  /// Get workout plan by Firestore ID
  Future<SavedWorkoutPlan?> getWorkoutPlan(String firestoreId) async {
    try {
      final CollectionReference collection = _getWorkoutPlansCollection();
      final DocumentSnapshot doc = await collection.doc(firestoreId).get();
      
      if (!doc.exists) return null;
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['firestoreId'] = doc.id;
      data['isSynced'] = true;
      
      return SavedWorkoutPlan.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch workout from Firestore: $e');
    }
  }

  /// Delete workout plan from Firestore
  Future<void> deleteWorkoutPlan(String firestoreId) async {
    try {
      final CollectionReference collection = _getWorkoutPlansCollection();
      await collection.doc(firestoreId).delete();
    } catch (e) {
      throw Exception('Failed to delete workout from Firestore: $e');
    }
  }

  /// Listen to real-time changes for workout plans
  Stream<List<SavedWorkoutPlan>> watchWorkoutPlans() {
    try {
      final CollectionReference collection = _getWorkoutPlansCollection();
      
      return collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((QueryDocumentSnapshot doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['firestoreId'] = doc.id;
          data['isSynced'] = true;
          
          return SavedWorkoutPlan.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to watch workouts from Firestore: $e');
    }
  }

  // ===== COMPLETED WORKOUT SESSIONS METHODS =====

  /// Save completed workout session to Firestore
  Future<String> saveCompletedWorkout(ActiveWorkoutSession workout) async {
    try {
      // Ensure exercise module exists
      await ensureExerciseModuleExists();
      
      final CollectionReference collection = _getCompletedWorkoutsCollection();
      
      // Prepare data for Firestore
      final Map<String, dynamic> data = workout.toJson();
      data['savedAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef;
      
      // Check if workout already exists by ID
      final QuerySnapshot existingDocs = await collection
          .where('id', isEqualTo: workout.id)
          .limit(1)
          .get();
      
      if (existingDocs.docs.isNotEmpty) {
        // Update existing document
        docRef = existingDocs.docs.first.reference;
        await docRef.update(data);
      } else {
        // Create new document
        docRef = await collection.add(data);
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save completed workout to Firestore: $e');
    }
  }

  /// Get all completed workout sessions from Firestore
  Future<List<ActiveWorkoutSession>> getAllCompletedWorkouts() async {
    try {
      final CollectionReference collection = _getCompletedWorkoutsCollection();
      final QuerySnapshot snapshot = await collection
          .orderBy('endTime', descending: true)
          .get();
      
      return snapshot.docs.map((QueryDocumentSnapshot doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ActiveWorkoutSession.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch completed workouts from Firestore: $e');
    }
  }

  /// Get completed workout session by ID
  Future<ActiveWorkoutSession?> getCompletedWorkout(String workoutId) async {
    try {
      final CollectionReference collection = _getCompletedWorkoutsCollection();
      final QuerySnapshot snapshot = await collection
          .where('id', isEqualTo: workoutId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      return ActiveWorkoutSession.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch completed workout from Firestore: $e');
    }
  }

  /// Delete completed workout session from Firestore
  Future<void> deleteCompletedWorkout(String workoutId) async {
    try {
      final CollectionReference collection = _getCompletedWorkoutsCollection();
      final QuerySnapshot snapshot = await collection
          .where('id', isEqualTo: workoutId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete completed workout from Firestore: $e');
    }
  }

  /// Listen to real-time changes for completed workouts
  Stream<List<ActiveWorkoutSession>> watchCompletedWorkouts() {
    try {
      final CollectionReference collection = _getCompletedWorkoutsCollection();
      
      return collection
          .orderBy('endTime', descending: true)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.docs.map((QueryDocumentSnapshot doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return ActiveWorkoutSession.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to watch completed workouts from Firestore: $e');
    }
  }

  /// Sync pending local completed workouts to Firestore
  Future<void> syncCompletedWorkoutsToFirestore(List<ActiveWorkoutSession> unsyncedWorkouts) async {
    for (final ActiveWorkoutSession workout in unsyncedWorkouts) {
      try {
        await saveCompletedWorkout(workout);
      } catch (e) {
        print('Failed to sync completed workout ${workout.id}: $e');
        // Continue with other workouts even if one fails
      }
    }
  }

  // ===== GENERAL METHODS =====

  /// Sync pending local changes to Firestore
  Future<void> syncLocalToFirestore(List<SavedWorkoutPlan> unsyncedWorkouts) async {
    for (final SavedWorkoutPlan workout in unsyncedWorkouts) {
      try {
        await saveWorkoutPlan(workout);
      } catch (e) {
        print('Failed to sync workout ${workout.id}: $e');
        // Continue with other workouts even if one fails
      }
    }
  }

  /// Check if user is authenticated and connected
  bool get isUserAuthenticated => _auth.currentUser != null;

  /// Check internet connectivity (basic check)
  Future<bool> hasInternetConnection() async {
    try {
      // Try to read from Firestore to check connectivity
      await _firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }
}
