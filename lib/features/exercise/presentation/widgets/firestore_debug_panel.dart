import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/firestore_workout_service.dart';
import '../../data/models/workout_models.dart';
import '../../../../widgets/firestore_nutrition_debug_panel.dart';
import '../../../../widgets/firestore_modular_debug_panel.dart';
import '../../../sleep/presentation/widgets/firestore_sleep_debug_panel_simple.dart';

class FirestoreDebugPanel extends ConsumerStatefulWidget {
  const FirestoreDebugPanel({super.key});

  @override
  ConsumerState<FirestoreDebugPanel> createState() => _FirestoreDebugPanelState();
}

class _FirestoreDebugPanelState extends ConsumerState<FirestoreDebugPanel> {
  String _debugInfo = 'Checking Firestore connection...';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
  }

  Future<void> _checkFirestoreConnection() async {
    setState(() {
      _isChecking = true;
      _debugInfo = 'Checking Firestore connection...';
    });

    try {
      final StringBuffer info = StringBuffer();
      
      // Check Firebase Auth
      final User? user = FirebaseAuth.instance.currentUser;
      info.writeln('🔐 Authentication Status:');
      if (user != null) {
        info.writeln('✅ User authenticated: ${user.uid}');
        info.writeln('📧 Email: ${user.email ?? 'No email'}');
        info.writeln('📱 Provider: ${user.providerData.map((UserInfo p) => p.providerId).join(', ')}');
      } else {
        info.writeln('❌ No user authenticated');
        info.writeln('⚠️  You need to sign in to save to Firestore');
      }
      
      info.writeln('\n🔥 Firestore Connection:');
      
      if (user != null) {
        // Test Firestore read access
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final CollectionReference userCollection = firestore
            .collection('users')
            .doc(user.uid)
            .collection('workout_plans');
        
        // Try to read from Firestore
        final QuerySnapshot snapshot = await userCollection.limit(1).get();
        info.writeln('✅ Firestore connection successful');
        info.writeln('📊 Existing workouts in Firestore: ${snapshot.docs.length}');
        
        // Test write access by creating a test document
        final DocumentReference testDoc = userCollection.doc('connection_test');
        await testDoc.set(<String, Object>{
          'test': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
        info.writeln('✅ Firestore write access confirmed');
        
        // Clean up test document
        await testDoc.delete();
        info.writeln('🧹 Test document cleaned up');
        
        // Check Firestore service
        final FirestoreWorkoutService service = FirestoreWorkoutService();
        final List workouts = await service.getAllWorkoutPlans();
        info.writeln('📋 Workouts via service: ${workouts.length}');
      } else {
        info.writeln('❌ Cannot test Firestore without authentication');
      }
      
      setState(() {
        _debugInfo = info.toString();
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Error checking Firestore: $e';
        _isChecking = false;
      });
    }
  }

  Future<void> _testCreateWorkout() async {
    setState(() => _isChecking = true);
    
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _debugInfo = '❌ Cannot create workout: User not authenticated';
          _isChecking = false;
        });
        return;
      }

      final FirestoreWorkoutService service = FirestoreWorkoutService();
      final DateTime now = DateTime.now();
      
      // Create a test workout plan
      final SavedWorkoutPlan testWorkout = SavedWorkoutPlan(
        id: 'test_${now.millisecondsSinceEpoch}',
        userId: user.uid,
        name: 'Firestore Test Workout ${now.hour}:${now.minute}',
        workoutPlan: WorkoutPlan(
          warmup: const WorkoutComponent(
            description: 'Test warmup',
            duration: 5,
          ),
          cardio: const WorkoutComponent(
            description: 'Test cardio',
            duration: 10,
          ),
          sessionsPerWeek: 3,
          workoutSessions: const <WorkoutSession>[
            WorkoutSession(
              exercises: <Exercise>[
                Exercise(name: 'Test Exercise', sets: 3, reps: '10', rest: 60),
              ],
            ),
          ],
          cooldown: const WorkoutComponent(
            description: 'Test cooldown',
            duration: 5,
          ),
        ),
        createdAt: now,
        isFavorite: false,
        isSynced: false,
        lastUpdated: now,
      );

      final String firestoreId = await service.saveWorkoutPlan(testWorkout);
      
      setState(() {
        _debugInfo = '✅ Test workout saved to Firestore!\n'
                   'Firestore ID: $firestoreId\n'
                   'Workout Name: ${testWorkout.name}\n'
                   'Created At: ${testWorkout.createdAt}\n\n'
                   'You can verify this in Firebase Console:\n'
                   'users/${user.uid}/workout_plans/$firestoreId';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Failed to create test workout: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Firestore Debug Panel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _debugInfo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkFirestoreConnection,
                  icon: _isChecking 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  label: Text(_isChecking ? 'Checking...' : 'Recheck Connection'),
                ),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _testCreateWorkout,
                  icon: const Icon(Icons.add),
                  label: const Text('Test Create Workout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const FirestoreModularDebugPanel(),
                    ),
                  ),
                  icon: const Icon(Icons.architecture),
                  label: const Text('NEW: Modular Architecture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const FirestoreNutritionDebugPanel(),
                    ),
                  ),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Nutrition Debug'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const FirestoreSleepDebugPanel(),
                    ),
                  ),
                  icon: const Icon(Icons.bedtime),
                  label: const Text('Sleep Debug'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '💡 Tip: Check Firebase Console to verify data is actually saved:\n'
              'https://console.firebase.google.com/ → Firestore Database',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
