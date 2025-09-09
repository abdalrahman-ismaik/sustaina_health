import 'package:flutter/material.dart';
import '../data/repositories/achievement_repository.dart';
import '../data/models/achievement_model.dart';
import '../../../widgets/achievement_popup_widget.dart';

class AchievementService {
  final AchievementRepository _repository = AchievementRepository();
  
  // Track various activities and update achievements
  Future<void> trackSustainableAction(BuildContext context, {
    double carbonSaved = 0.0,
    bool localBusinessSupported = false,
    String? actionType,
  }) async {
    try {
      // Update stats
      final currentStats = await _repository.getStats();
      final updatedStats = currentStats.copyWith(
        sustainableActions: currentStats.sustainableActions + 1,
        carbonSaved: currentStats.carbonSaved + carbonSaved,
        localBrandsSupported: localBusinessSupported 
            ? currentStats.localBrandsSupported + 1 
            : currentStats.localBrandsSupported,
        totalPoints: currentStats.totalPoints + _calculatePoints(actionType, carbonSaved),
        lastActivity: DateTime.now(),
      );
      
      await _repository.updateStats(updatedStats);
      
      // Check and update achievements
      await _checkAndUpdateAchievements(context, updatedStats);
      
    } catch (e) {
      print('Error tracking sustainable action: $e');
    }
  }

  Future<void> trackWorkout(BuildContext context, {
    String? workoutType,
    int duration = 0,
  }) async {
    try {
      final currentStats = await _repository.getStats();
      final points = _calculateWorkoutPoints(workoutType, duration);
      
      final updatedStats = currentStats.copyWith(
        totalPoints: currentStats.totalPoints + points,
        lastActivity: DateTime.now(),
      );
      
      await _repository.updateStats(updatedStats);
      await _checkAndUpdateAchievements(context, updatedStats);
      
      // Show workout completion popup
      AchievementPopupWidget.showExerciseCompletion(context, workoutType ?? 'workout');
      
    } catch (e) {
      print('Error tracking workout: $e');
    }
  }

  Future<void> trackNutritionLog(BuildContext context) async {
    try {
      final currentStats = await _repository.getStats();
      final updatedStats = currentStats.copyWith(
        totalPoints: currentStats.totalPoints + 5, // 5 points for logging nutrition
        lastActivity: DateTime.now(),
      );
      
      await _repository.updateStats(updatedStats);
      await _checkAndUpdateAchievements(context, updatedStats);
      
      AchievementPopupWidget.showNutritionLogged(context);
      
    } catch (e) {
      print('Error tracking nutrition log: $e');
    }
  }

  Future<void> trackSleep(BuildContext context, {
    required double hours,
  }) async {
    try {
      final currentStats = await _repository.getStats();
      final points = hours >= 8 ? 10 : 5; // Bonus points for adequate sleep
      
      final updatedStats = currentStats.copyWith(
        totalPoints: currentStats.totalPoints + points,
        lastActivity: DateTime.now(),
      );
      
      await _repository.updateStats(updatedStats);
      await _checkAndUpdateAchievements(context, updatedStats);
      
      AchievementPopupWidget.showSleepLogged(context, hours.toString());
      
    } catch (e) {
      print('Error tracking sleep: $e');
    }
  }

  Future<void> _checkAndUpdateAchievements(BuildContext context, SustainabilityStats stats) async {
    try {
      final achievements = await _repository.getAllAchievements();
      
      for (final achievement in achievements) {
        if (achievement.isUnlocked) continue;
        
        final shouldUnlock = _checkAchievementCondition(achievement, stats);
        
        if (shouldUnlock) {
          // Update achievement as unlocked
          final unlockedAchievement = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            currentProgress: achievement.targetValue,
          );
          
          await _repository.saveAchievement(unlockedAchievement);
          
          // Update total points with achievement reward
          final updatedStats = stats.copyWith(
            totalPoints: stats.totalPoints + achievement.rewardPoints,
            totalAchievements: stats.totalAchievements + 1,
          );
          await _repository.updateStats(updatedStats);
          
          // Show achievement popup
          _showAchievementUnlockedPopup(context, unlockedAchievement);
        } else {
          // Update progress if applicable
          final newProgress = _calculateAchievementProgress(achievement, stats);
          if (newProgress != achievement.currentProgress) {
            final updatedAchievement = achievement.copyWith(
              currentProgress: newProgress,
            );
            await _repository.saveAchievement(updatedAchievement);
          }
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  bool _checkAchievementCondition(Achievement achievement, SustainabilityStats stats) {
    switch (achievement.id) {
      case 'first_sustainable_action':
        return stats.sustainableActions >= 1;
      case 'carbon_saver_100':
        return stats.carbonSaved >= 100;
      case 'local_supporter':
        return stats.localBrandsSupported >= 10;
      case 'sustainability_streak_7':
        return stats.consecutiveDays >= 7;
      case 'sustainability_streak_30':
        return stats.consecutiveDays >= 30;
      case 'sustainability_master':
        return stats.totalPoints >= 1000;
      case 'fitness_beginner':
        return (stats.categoryProgress['fitness'] ?? 0) >= 1;
      case 'workout_streak_7':
        return (stats.categoryProgress['workout_streak'] ?? 0) >= 7;
      case 'nutrition_tracker':
        return (stats.categoryProgress['nutrition_days'] ?? 0) >= 14;
      case 'sleep_master':
        return (stats.categoryProgress['sleep_streak'] ?? 0) >= 7;
      default:
        return false;
    }
  }

  int _calculateAchievementProgress(Achievement achievement, SustainabilityStats stats) {
    switch (achievement.id) {
      case 'first_sustainable_action':
        return stats.sustainableActions.clamp(0, achievement.targetValue);
      case 'carbon_saver_100':
        return stats.carbonSaved.round().clamp(0, achievement.targetValue);
      case 'local_supporter':
        return stats.localBrandsSupported.clamp(0, achievement.targetValue);
      case 'sustainability_streak_7':
      case 'sustainability_streak_30':
        return stats.consecutiveDays.clamp(0, achievement.targetValue);
      case 'sustainability_master':
        return stats.totalPoints.clamp(0, achievement.targetValue);
      default:
        return achievement.currentProgress;
    }
  }

  int _calculatePoints(String? actionType, double carbonSaved) {
    switch (actionType) {
      case 'local_business':
        return 15;
      case 'eco_transport':
        return 10;
      case 'sustainable_meal':
        return 8;
      case 'recycling':
        return 5;
      default:
        return 5 + (carbonSaved * 2).round(); // Base points + carbon impact
    }
  }

  int _calculateWorkoutPoints(String? workoutType, int duration) {
    final basePoints = 10;
    final durationBonus = (duration / 15).floor() * 2; // 2 points per 15 minutes
    
    switch (workoutType) {
      case 'cardio':
        return basePoints + durationBonus + 5;
      case 'strength':
        return basePoints + durationBonus + 5;
      case 'yoga':
        return basePoints + durationBonus + 3;
      case 'walking':
        return basePoints + durationBonus;
      default:
        return basePoints + durationBonus;
    }
  }

  void _showAchievementUnlockedPopup(BuildContext context, Achievement achievement) {
    AchievementPopupWidget.show(
      context,
      title: '${achievement.icon} ${achievement.name}',
      message: '${achievement.description}\n\n+${achievement.rewardPoints} points earned!',
    );
  }

  // Utility methods for UI
  Future<List<Achievement>> getAchievements() => _repository.getAllAchievements();
  
  Future<List<SustainabilityReward>> getRewards() => _repository.getAllRewards();
  
  Future<SustainabilityStats> getStats() => _repository.getStats();
  
  Stream<SustainabilityStats> watchStats() => _repository.watchStats();
  
  Stream<List<Achievement>> watchAchievements() => _repository.watchAchievements();
  
  Stream<List<SustainabilityReward>> watchRewards() => _repository.watchRewards();

  Future<void> redeemReward(String rewardId, int cost) async {
    try {
      final stats = await _repository.getStats();
      if (stats.totalPoints >= cost) {
        await _repository.redeemReward(rewardId);
        final updatedStats = stats.copyWith(
          totalPoints: stats.totalPoints - cost,
        );
        await _repository.updateStats(updatedStats);
      } else {
        throw Exception('Insufficient points to redeem reward');
      }
    } catch (e) {
      throw Exception('Failed to redeem reward: $e');
    }
  }

  Future<void> initializeSystem() async {
    try {
      await _repository.initializeDefaultAchievements();
      await _repository.initializeDefaultRewards();
    } catch (e) {
      print('Error initializing achievement system: $e');
    }
  }

  // Convenience methods for common actions
  Future<void> trackLocalBusinessPurchase(BuildContext context, {
    required String businessName,
    double carbonSavedEstimate = 2.0,
  }) async {
    await trackSustainableAction(
      context,
      carbonSaved: carbonSavedEstimate,
      localBusinessSupported: true,
      actionType: 'local_business',
    );
  }

  Future<void> trackEcoTransport(BuildContext context, {
    required String transportType,
    double carbonSaved = 5.0,
  }) async {
    await trackSustainableAction(
      context,
      carbonSaved: carbonSaved,
      actionType: 'eco_transport',
    );
  }

  Future<void> trackSustainableMeal(BuildContext context, {
    double carbonSaved = 3.0,
  }) async {
    await trackSustainableAction(
      context,
      carbonSaved: carbonSaved,
      actionType: 'sustainable_meal',
    );
  }

  Future<void> trackRecycling(BuildContext context) async {
    await trackSustainableAction(
      context,
      carbonSaved: 1.0,
      actionType: 'recycling',
    );
  }
}
