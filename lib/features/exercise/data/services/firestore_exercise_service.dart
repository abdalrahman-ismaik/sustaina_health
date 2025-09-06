import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_models.dart';

/// Firestore service for exercise/workout data with modular users/{userId}/exercise structure
class FirestoreExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Collection references - using modular structure: users/{userId}/exercise/data/subcollection
  CollectionReference get _completedWorkoutsCollection =>
      _firestore.collection('users').doc(_userId).collection('exercise').doc('data').collection('completed_workouts');

  CollectionReference get _activeWorkoutsCollection =>
      _firestore.collection('users').doc(_userId).collection('exercise').doc('data').collection('active_workouts');

  CollectionReference get _workoutTemplatesCollection =>
      _firestore.collection('users').doc(_userId).collection('exercise').doc('data').collection('workout_templates');

  /// Ensure exercise module document exists
  Future<void> ensureExerciseModuleExists() async {
    final DocumentReference exerciseDoc = _firestore
        .collection('users')
        .doc(_userId)
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

  // Completed Workouts Operations
  Future<String> saveCompletedWorkout(ActiveWorkoutSession workout) async {
    try {
      await ensureExerciseModuleExists();

      final Map<String, dynamic> workoutData = workout.toJson();
      workoutData['createdAt'] = FieldValue.serverTimestamp();
      workoutData['lastUpdated'] = FieldValue.serverTimestamp();

      final DocumentReference docRef = await _completedWorkoutsCollection.add(workoutData);
      
      print('Workout saved to cloud with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving workout to cloud: $e');
      throw Exception('Failed to save workout to cloud: $e');
    }
  }

  Future<void> updateCompletedWorkout(String workoutId, ActiveWorkoutSession workout) async {
    try {
      final Map<String, dynamic> workoutData = workout.toJson();
      workoutData['lastUpdated'] = FieldValue.serverTimestamp();

      await _completedWorkoutsCollection.doc(workoutId).update(workoutData);
      print('Workout updated in cloud: $workoutId');
    } catch (e) {
      print('Error updating workout in cloud: $e');
      throw Exception('Failed to update workout in cloud: $e');
    }
  }

  Future<List<ActiveWorkoutSession>> getCompletedWorkouts() async {
    try {
      final QuerySnapshot snapshot = await _completedWorkoutsCollection
          .orderBy('startTime', descending: true)
          .limit(100) // Limit to last 100 workouts
          .get();

      final List<ActiveWorkoutSession> workouts = <ActiveWorkoutSession>[];
      
      for (final QueryDocumentSnapshot doc in snapshot.docs) {
        try {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Convert Firestore timestamps back to DateTime
          if (data['startTime'] is Timestamp) {
            data['startTime'] = (data['startTime'] as Timestamp).toDate().toIso8601String();
          }
          if (data['endTime'] is Timestamp) {
            data['endTime'] = (data['endTime'] as Timestamp).toDate().toIso8601String();
          }
          
          // Ensure the workout has the cloud document ID
          data['id'] = doc.id;
          
          final ActiveWorkoutSession workout = ActiveWorkoutSession.fromJson(data);
          workouts.add(workout);
        } catch (e) {
          print('Error parsing workout document ${doc.id}: $e');
          // Continue with other workouts if one fails to parse
        }
      }

      print('Loaded ${workouts.length} workouts from cloud');
      return workouts;
    } catch (e) {
      print('Error loading workouts from cloud: $e');
      return <ActiveWorkoutSession>[]; // Return empty list on error
    }
  }

  Future<void> deleteCompletedWorkout(String workoutId) async {
    try {
      await _completedWorkoutsCollection.doc(workoutId).delete();
      print('Workout deleted from cloud: $workoutId');
    } catch (e) {
      print('Error deleting workout from cloud: $e');
      throw Exception('Failed to delete workout from cloud: $e');
    }
  }

  // Active Workout Operations (for ongoing workouts)
  Future<String> saveActiveWorkout(ActiveWorkoutSession workout) async {
    try {
      await ensureExerciseModuleExists();

      final Map<String, dynamic> workoutData = workout.toJson();
      workoutData['createdAt'] = FieldValue.serverTimestamp();
      workoutData['lastUpdated'] = FieldValue.serverTimestamp();

      // Use the workout ID as document ID for active workouts
      await _activeWorkoutsCollection.doc(workout.id).set(workoutData);
      
      print('Active workout saved to cloud: ${workout.id}');
      return workout.id;
    } catch (e) {
      print('Error saving active workout to cloud: $e');
      throw Exception('Failed to save active workout to cloud: $e');
    }
  }

  Future<ActiveWorkoutSession?> getActiveWorkout() async {
    try {
      // Get the most recent active workout
      final QuerySnapshot snapshot = await _activeWorkoutsCollection
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final QueryDocumentSnapshot doc = snapshot.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Convert Firestore timestamps back to DateTime
      if (data['startTime'] is Timestamp) {
        data['startTime'] = (data['startTime'] as Timestamp).toDate().toIso8601String();
      }
      if (data['endTime'] is Timestamp) {
        data['endTime'] = (data['endTime'] as Timestamp).toDate().toIso8601String();
      }
      
      data['id'] = doc.id;
      
      final ActiveWorkoutSession workout = ActiveWorkoutSession.fromJson(data);
      print('Loaded active workout from cloud: ${workout.id}');
      return workout;
    } catch (e) {
      print('Error loading active workout from cloud: $e');
      return null;
    }
  }

  Future<void> clearActiveWorkout(String workoutId) async {
    try {
      await _activeWorkoutsCollection.doc(workoutId).delete();
      print('Active workout cleared from cloud: $workoutId');
    } catch (e) {
      print('Error clearing active workout from cloud: $e');
      throw Exception('Failed to clear active workout from cloud: $e');
    }
  }

  // Workout Templates Operations (for saved custom workouts)
  Future<String> saveWorkoutTemplate(WorkoutSession template, String name) async {
    try {
      await ensureExerciseModuleExists();

      final Map<String, dynamic> templateData = template.toJson();
      templateData['name'] = name;
      templateData['createdAt'] = FieldValue.serverTimestamp();
      templateData['lastUpdated'] = FieldValue.serverTimestamp();

      final DocumentReference docRef = await _workoutTemplatesCollection.add(templateData);
      
      print('Workout template saved to cloud with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving workout template to cloud: $e');
      throw Exception('Failed to save workout template to cloud: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutTemplates() async {
    try {
      final QuerySnapshot snapshot = await _workoutTemplatesCollection
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> templates = <Map<String, dynamic>>[];
      
      for (final QueryDocumentSnapshot doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        templates.add(data);
      }

      print('Loaded ${templates.length} workout templates from cloud');
      return templates;
    } catch (e) {
      print('Error loading workout templates from cloud: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> deleteWorkoutTemplate(String templateId) async {
    try {
      await _workoutTemplatesCollection.doc(templateId).delete();
      print('Workout template deleted from cloud: $templateId');
    } catch (e) {
      print('Error deleting workout template from cloud: $e');
      throw Exception('Failed to delete workout template from cloud: $e');
    }
  }

  // Sync Operations
  Future<void> syncCompletedWorkoutsFromLocal(List<ActiveWorkoutSession> localWorkouts) async {
    try {
      print('Syncing ${localWorkouts.length} local workouts to cloud...');
      
      for (final ActiveWorkoutSession workout in localWorkouts) {
        try {
          // Check if workout already exists in cloud
          final QuerySnapshot existingDocs = await _completedWorkoutsCollection
              .where('startTime', isEqualTo: Timestamp.fromDate(workout.startTime))
              .where('workoutName', isEqualTo: workout.workoutName)
              .limit(1)
              .get();

          if (existingDocs.docs.isEmpty) {
            // Workout doesn't exist in cloud, save it
            await saveCompletedWorkout(workout);
            print('Synced workout to cloud: ${workout.workoutName}');
          } else {
            print('Workout already exists in cloud: ${workout.workoutName}');
          }
        } catch (e) {
          print('Error syncing individual workout: $e');
          // Continue with next workout
        }
      }
      
      print('Sync completed');
    } catch (e) {
      print('Error during sync: $e');
      throw Exception('Failed to sync workouts to cloud: $e');
    }
  }
}
