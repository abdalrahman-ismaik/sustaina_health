import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/user_profile_model.dart';
import 'firestore_profile_service.dart';

/// Hybrid profile service that saves to both local storage and Firestore cloud
class HybridProfileService {
  static const String _profileKey = 'user_profile';
  static const String _healthGoalsKey = 'health_goals';
  static const String _preferencesKey = 'user_preferences';
  static const String _achievementsKey = 'user_achievements';
  
  final FirestoreProfileService _firestoreService = FirestoreProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isUserSignedIn => _auth.currentUser != null;

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      // Always save locally first
      await _saveProfileLocally(profile);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureProfileModuleExists();
          await _firestoreService.savePersonalInfo(profile);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Save health goals
  Future<void> saveHealthGoals(Map<String, dynamic> goals) async {
    try {
      // Always save locally first
      await _saveHealthGoalsLocally(goals);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureProfileModuleExists();
          // If goals is a map of individual goals, save each one
          if (goals.containsKey('goals') && goals['goals'] is List) {
            for (final goal in goals['goals']) {
              if (goal is Map<String, dynamic>) {
                await _firestoreService.saveHealthGoal(goal);
              }
            }
          } else {
            // If it's a single goal object, save it directly
            await _firestoreService.saveHealthGoal(goals);
          }
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save health goals: $e');
    }
  }

  /// Save individual health goal to cloud storage
  Future<String?> saveHealthGoal(Map<String, dynamic> goal) async {
    try {
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        await _firestoreService.ensureProfileModuleExists();
        final String goalId = await _firestoreService.saveHealthGoal(goal);
        return goalId;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to save health goal: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      // Always save locally first
      await _savePreferencesLocally(preferences);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureProfileModuleExists();
          await _firestoreService.savePreferences(preferences);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  /// Save achievement
  Future<void> saveAchievement(Map<String, dynamic> achievement) async {
    try {
      // Always save locally first
      await _saveAchievementLocally(achievement);
      
      // Save to cloud if user is signed in
      if (_isUserSignedIn) {
        try {
          await _firestoreService.ensureProfileModuleExists();
          await _firestoreService.saveAchievement(achievement);
        } catch (e) {
          print('Cloud save failed, but local save succeeded: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to save achievement: $e');
    }
  }

  /// Get user profile (prioritizing cloud data if available)
  Future<UserProfile?> getUserProfile() async {
    if (_isUserSignedIn) {
      try {
        final UserProfile? cloudProfile = await _firestoreService.getPersonalInfo();
        if (cloudProfile != null) {
          // Sync cloud data to local storage
          await _saveProfileLocally(cloudProfile);
          return cloudProfile;
        }
      } catch (e) {
        print('Failed to fetch profile from cloud, using local: $e');
      }
    }
    
    // Fallback to local storage
    return await _getProfileLocally();
  }

  /// Get health goals
  Future<Map<String, dynamic>?> getHealthGoals() async {
    if (_isUserSignedIn) {
      try {
        final List<Map<String, dynamic>> cloudGoalsList = await _firestoreService.getHealthGoals();
        if (cloudGoalsList.isNotEmpty) {
          // Convert list to map or take first goal as example
          final Map<String, dynamic> cloudGoals = cloudGoalsList.first;
          await _saveHealthGoalsLocally(cloudGoals);
          return cloudGoals;
        }
      } catch (e) {
        print('Failed to fetch health goals from cloud, using local: $e');
      }
    }
    
    return await _getHealthGoalsLocally();
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (_isUserSignedIn) {
      try {
        final Map<String, dynamic>? cloudPreferences = await _firestoreService.getPreferences();
        if (cloudPreferences != null) {
          await _savePreferencesLocally(cloudPreferences);
          return cloudPreferences;
        }
      } catch (e) {
        print('Failed to fetch preferences from cloud, using local: $e');
      }
    }
    
    return await _getPreferencesLocally();
  }

  /// Sync all local data to cloud
  Future<void> syncToCloud() async {
    if (!_isUserSignedIn) return;
    
    try {
      await _firestoreService.ensureProfileModuleExists();
      
      // Sync profile
      final UserProfile? localProfile = await _getProfileLocally();
      if (localProfile != null) {
        await _firestoreService.savePersonalInfo(localProfile);
      }
      
      // Sync health goals
      final Map<String, dynamic>? localGoals = await _getHealthGoalsLocally();
      if (localGoals != null) {
        // If localGoals contains a list of goals, save each one
        if (localGoals.containsKey('goals') && localGoals['goals'] is List) {
          for (final goal in localGoals['goals']) {
            if (goal is Map<String, dynamic>) {
              await _firestoreService.saveHealthGoal(goal);
            }
          }
        } else {
          // If it's a single goal object, save it directly
          await _firestoreService.saveHealthGoal(localGoals);
        }
      }
      
      // Sync preferences
      final Map<String, dynamic>? localPreferences = await _getPreferencesLocally();
      if (localPreferences != null) {
        await _firestoreService.savePreferences(localPreferences);
      }
      
    } catch (e) {
      print('Failed to sync profile data to cloud: $e');
    }
  }

  // Local storage helper methods
  Future<void> _saveProfileLocally(UserProfile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> _getProfileLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      return UserProfile.fromJson(jsonDecode(profileJson));
    }
    return null;
  }

  Future<void> _saveHealthGoalsLocally(Map<String, dynamic> goals) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_healthGoalsKey, jsonEncode(goals));
  }

  Future<Map<String, dynamic>?> _getHealthGoalsLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString(_healthGoalsKey);
    if (goalsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(goalsJson));
    }
    return null;
  }

  Future<void> _savePreferencesLocally(Map<String, dynamic> preferences) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences));
  }

  Future<Map<String, dynamic>?> _getPreferencesLocally() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? prefsJson = prefs.getString(_preferencesKey);
    if (prefsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(prefsJson));
    }
    return null;
  }

  Future<void> _saveAchievementLocally(Map<String, dynamic> achievement) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> achievements = prefs.getStringList(_achievementsKey) ?? <String>[];
    achievements.add(jsonEncode(achievement));
    await prefs.setStringList(_achievementsKey, achievements);
  }

  /// Get sync status for profile data
  Future<Map<String, int>> getSyncStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    int itemCount = 0;
    
    // Count profile data
    if (await _getProfileLocally() != null) itemCount++;
    if (await _getHealthGoalsLocally() != null) itemCount++;
    if (await _getPreferencesLocally() != null) itemCount++;
    
    // Count achievements
    final List<String> achievements = prefs.getStringList(_achievementsKey) ?? <String>[];
    itemCount += achievements.length;

    return <String, int>{
      'totalItems': itemCount,
      'achievements': achievements.length,
    };
  }
}
