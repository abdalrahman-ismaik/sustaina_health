import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_models.dart';

class FirebaseWorkoutService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseWorkoutService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception(
          'User not authenticated. Please sign in to save workouts.');
    }
    return user.uid;
  }

  CollectionReference get _workoutPlansCollection {
    return _firestore.collection('workout_plans');
  }

  /// Save a workout plan to Firebase
  Future<String> saveWorkoutPlan({
    required String name,
    required WorkoutPlan workoutPlan,
  }) async {
    try {
      print('Attempting to save workout plan: $name');
      print('User ID: $_userId');

      final DocumentReference<Object?> docRef = _workoutPlansCollection.doc();

      final SavedWorkoutPlan savedWorkout = SavedWorkoutPlan(
        id: docRef.id,
        userId: _userId,
        name: name,
        workoutPlan: workoutPlan,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        isFavorite: false,
      );

      print('Saving workout to Firestore...');
      await docRef.set(savedWorkout.toJson());
      print('Workout saved successfully with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error saving workout plan: $e');
      throw Exception('Failed to save workout plan: $e');
    }
  }

  /// Get all saved workout plans for the current user
  Future<List<SavedWorkoutPlan>> getSavedWorkoutPlans() async {
    try {
      print('Fetching saved workout plans for user: $_userId');

      final QuerySnapshot<Object?> querySnapshot = await _workoutPlansCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} workout plans');

      return querySnapshot.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              SavedWorkoutPlan.fromJson(<String, dynamic>{
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error loading saved workout plans: $e');
      throw Exception('Failed to load saved workout plans: $e');
    }
  }

  /// Get a specific saved workout plan by ID
  Future<SavedWorkoutPlan?> getSavedWorkoutPlan(String id) async {
    try {
      final DocumentSnapshot<Object?> doc =
          await _workoutPlansCollection.doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Verify the workout belongs to the current user
      if (data['userId'] != _userId) {
        throw Exception('Unauthorized access to workout plan');
      }

      return SavedWorkoutPlan.fromJson(<String, dynamic>{
        ...data,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to load workout plan: $e');
    }
  }

  /// Update last used timestamp for a workout plan
  Future<void> updateLastUsed(String id) async {
    try {
      await _workoutPlansCollection.doc(id).update(<Object, Object?>{
        'lastUsed': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update last used: $e');
    }
  }

  /// Toggle favorite status of a workout plan
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _workoutPlansCollection.doc(id).update(<Object, Object?>{
        'isFavorite': isFavorite,
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Delete a saved workout plan
  Future<void> deleteWorkoutPlan(String id) async {
    try {
      final DocumentSnapshot<Object?> doc =
          await _workoutPlansCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Workout plan not found');
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Verify the workout belongs to the current user
      if (data['userId'] != _userId) {
        throw Exception('Unauthorized access to workout plan');
      }

      await _workoutPlansCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete workout plan: $e');
    }
  }

  /// Stream of saved workout plans (real-time updates)
  Stream<List<SavedWorkoutPlan>> watchSavedWorkoutPlans() {
    return _workoutPlansCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Object?> snapshot) => snapshot.docs
            .map((QueryDocumentSnapshot<Object?> doc) =>
                SavedWorkoutPlan.fromJson(<String, dynamic>{
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }
}
