import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_models.dart';

/// Firestore service for nutrition data with consistent users/{userId}/subcollection structure
class FirestoreNutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Collection references
  CollectionReference get _foodLogCollection =>
      _firestore.collection('users').doc(_userId).collection('nutrition').doc('data').collection('food_log_entries');

  CollectionReference get _mealPlansCollection =>
      _firestore.collection('users').doc(_userId).collection('nutrition').doc('data').collection('meal_plans');

  CollectionReference get _nutritionGoalsCollection =>
      _firestore.collection('users').doc(_userId).collection('nutrition').doc('data').collection('nutrition_goals');

  CollectionReference get _nutritionInsightsCollection =>
      _firestore.collection('users').doc(_userId).collection('nutrition').doc('data').collection('nutrition_insights');

  /// Ensure nutrition module document exists
  Future<void> ensureNutritionModuleExists() async {
    final DocumentReference nutritionDoc = _firestore
        .collection('users')
        .doc(_userId)
        .collection('nutrition')
        .doc('data');
    
    final DocumentSnapshot doc = await nutritionDoc.get();
    if (!doc.exists) {
      await nutritionDoc.set({
        'module': 'nutrition',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Food Log Operations
  Future<String> saveFoodLogEntry(FoodLogEntry entry) async {
    try {
      // Ensure nutrition module exists
      await ensureNutritionModuleExists();
      
      final Map<String, dynamic> data = entry.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final DocumentReference docRef = await _foodLogCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save food log entry: $e');
    }
  }

  Future<void> updateFoodLogEntry(FoodLogEntry entry) async {
    try {
      final Map<String, dynamic> data = entry.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _foodLogCollection.doc(entry.id).update(data);
    } catch (e) {
      throw Exception('Failed to update food log entry: $e');
    }
  }

  Future<void> deleteFoodLogEntry(String entryId) async {
    try {
      await _foodLogCollection.doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete food log entry: $e');
    }
  }

  Future<List<FoodLogEntry>> getFoodLogEntriesForDate(DateTime date) async {
    try {
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final QuerySnapshot snapshot = await _foodLogCollection
          .where('loggedAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('loggedAt', isLessThan: endOfDay.toIso8601String())
          .orderBy('loggedAt')
          .get();

      return snapshot.docs
          .map((doc) => FoodLogEntry.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get food log entries: $e');
    }
  }

  Future<List<FoodLogEntry>> getAllFoodLogEntries() async {
    try {
      final QuerySnapshot snapshot = await _foodLogCollection
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodLogEntry.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all food log entries: $e');
    }
  }

  // Meal Plan Operations  
  Future<String> saveMealPlan(String planId, MealPlanResponse mealPlan) async {
    try {
      // Ensure nutrition module exists
      await ensureNutritionModuleExists();
      
      final Map<String, dynamic> data = {
        'id': planId,
        'mealPlan': mealPlan.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _mealPlansCollection.doc(planId).set(data);
      return planId;
    } catch (e) {
      throw Exception('Failed to save meal plan: $e');
    }
  }

  Future<MealPlanResponse?> getMealPlan(String planId) async {
    try {
      final DocumentSnapshot doc = await _mealPlansCollection.doc(planId).get();
      
      if (!doc.exists) {
        return null;
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return MealPlanResponse.fromJson(data['mealPlan'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get meal plan: $e');
    }
  }

  Future<List<String>> getAllMealPlanIds() async {
    try {
      final QuerySnapshot snapshot = await _mealPlansCollection.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get meal plan IDs: $e');
    }
  }

  Future<void> deleteMealPlan(String planId) async {
    try {
      await _mealPlansCollection.doc(planId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal plan: $e');
    }
  }

  // Stream operations for real-time updates
  Stream<List<FoodLogEntry>> streamFoodLogEntriesForDate(DateTime date) {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _foodLogCollection
        .where('loggedAt', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('loggedAt', isLessThan: endOfDay.toIso8601String())
        .orderBy('loggedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodLogEntry.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<String>> streamMealPlanIds() {
    return _mealPlansCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.id).toList());
  }

  // Batch operations
  Future<void> saveFoodLogEntriesBatch(List<FoodLogEntry> entries) async {
    final WriteBatch batch = _firestore.batch();

    for (final FoodLogEntry entry in entries) {
      final Map<String, dynamic> data = entry.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (entry.id.isNotEmpty) {
        batch.set(_foodLogCollection.doc(entry.id), data);
      } else {
        batch.set(_foodLogCollection.doc(), data);
      }
    }

    await batch.commit();
  }

  // Analytics and insights
  Future<Map<String, dynamic>> getNutritionAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _foodLogCollection.orderBy('loggedAt');

      if (startDate != null) {
        query = query.where('loggedAt', 
            isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('loggedAt', 
            isLessThan: endDate.toIso8601String());
      }

      final QuerySnapshot snapshot = await query.get();
      final List<FoodLogEntry> entries = snapshot.docs
          .map((doc) => FoodLogEntry.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Calculate analytics
      int totalCalories = 0;
      int totalProtein = 0;
      int totalCarbs = 0;
      int totalFat = 0;
      Map<String, int> mealTypeCount = {};

      for (final FoodLogEntry entry in entries) {
        totalCalories += entry.nutritionInfo.calories;
        totalProtein += entry.nutritionInfo.protein;
        totalCarbs += entry.nutritionInfo.carbohydrates;
        totalFat += entry.nutritionInfo.fat;
        
        mealTypeCount[entry.mealType] = (mealTypeCount[entry.mealType] ?? 0) + 1;
      }

      return {
        'totalEntries': entries.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbohydrates': totalCarbs,
        'totalFat': totalFat,
        'averageCaloriesPerDay': entries.isNotEmpty 
            ? totalCalories / entries.length 
            : 0,
        'mealTypeDistribution': mealTypeCount,
        'dateRange': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      throw Exception('Failed to get nutrition analytics: $e');
    }
  }

  // Search operations
  Future<List<FoodLogEntry>> searchFoodLogEntries(String searchTerm) async {
    try {
      final QuerySnapshot snapshot = await _foodLogCollection
          .orderBy('loggedAt', descending: true)
          .get();

      final List<FoodLogEntry> allEntries = snapshot.docs
          .map((doc) => FoodLogEntry.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Filter by search term (case-insensitive)
      return allEntries.where((entry) =>
          entry.foodName.toLowerCase().contains(searchTerm.toLowerCase()) ||
          entry.mealType.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    } catch (e) {
      throw Exception('Failed to search food log entries: $e');
    }
  }
}
