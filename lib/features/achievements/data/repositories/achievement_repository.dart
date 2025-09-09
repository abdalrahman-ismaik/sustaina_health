import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String get _userId => 'current_user'; // Replace with actual user ID

  CollectionReference get _achievementsCollection =>
      _firestore.collection('users').doc(_userId).collection('achievements');

  CollectionReference get _rewardsCollection =>
      _firestore.collection('users').doc(_userId).collection('rewards');

  CollectionReference get _statsCollection =>
      _firestore.collection('users').doc(_userId).collection('stats');

  // Achievement methods
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final QuerySnapshot snapshot = await _achievementsCollection.get();
      return snapshot.docs
          .map((doc) => Achievement.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get achievements: $e');
    }
  }

  Future<void> saveAchievement(Achievement achievement) async {
    try {
      await _achievementsCollection.doc(achievement.id).set(achievement.toJson());
    } catch (e) {
      throw Exception('Failed to save achievement: $e');
    }
  }

  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    try {
      await _achievementsCollection.doc(achievementId).update({
        'currentProgress': progress,
        'isUnlocked': progress >= 1, // Assuming target is reached
        'unlockedAt': progress >= 1 ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }

  Stream<List<Achievement>> watchAchievements() {
    return _achievementsCollection.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Achievement.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Rewards methods
  Future<List<SustainabilityReward>> getAllRewards() async {
    try {
      final QuerySnapshot snapshot = await _rewardsCollection.get();
      return snapshot.docs
          .map((doc) => SustainabilityReward.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get rewards: $e');
    }
  }

  Future<void> saveReward(SustainabilityReward reward) async {
    try {
      await _rewardsCollection.doc(reward.id).set(reward.toJson());
    } catch (e) {
      throw Exception('Failed to save reward: $e');
    }
  }

  Future<void> redeemReward(String rewardId) async {
    try {
      await _rewardsCollection.doc(rewardId).update({
        'isRedeemed': true,
        'redeemedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to redeem reward: $e');
    }
  }

  Stream<List<SustainabilityReward>> watchRewards() {
    return _rewardsCollection.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => SustainabilityReward.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Stats methods
  Future<SustainabilityStats> getStats() async {
    try {
      final DocumentSnapshot doc = await _statsCollection.doc('current').get();
      if (doc.exists) {
        return SustainabilityStats.fromJson(doc.data() as Map<String, dynamic>);
      }
      return const SustainabilityStats();
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  Future<void> updateStats(SustainabilityStats stats) async {
    try {
      await _statsCollection.doc('current').set(stats.toJson());
    } catch (e) {
      throw Exception('Failed to update stats: $e');
    }
  }

  Stream<SustainabilityStats> watchStats() {
    return _statsCollection.doc('current').snapshots().map((doc) {
      if (doc.exists) {
        return SustainabilityStats.fromJson(doc.data() as Map<String, dynamic>);
      }
      return const SustainabilityStats();
    });
  }

  // Batch operations for initial setup
  Future<void> initializeDefaultAchievements() async {
    final List<Achievement> defaultAchievements = _getDefaultAchievements();
    
    for (final achievement in defaultAchievements) {
      await saveAchievement(achievement);
    }
  }

  Future<void> initializeDefaultRewards() async {
    final List<SustainabilityReward> defaultRewards = _getDefaultRewards();
    
    for (final reward in defaultRewards) {
      await saveReward(reward);
    }
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      // Sustainability Achievements
      Achievement(
        id: 'first_sustainable_action',
        name: 'Eco Beginner',
        description: 'Complete your first sustainable action',
        icon: '🌱',
        category: AchievementCategory.sustainability,
        type: AchievementType.milestone,
        targetValue: 1,
        rewardPoints: 10,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'carbon_saver_100',
        name: 'Carbon Saver',
        description: 'Save 100kg of CO2 through sustainable choices',
        icon: '🌍',
        category: AchievementCategory.sustainability,
        type: AchievementType.threshold,
        targetValue: 100,
        rewardPoints: 50,
        rarity: AchievementRarity.rare,
      ),
      Achievement(
        id: 'local_supporter',
        name: 'Local Hero',
        description: 'Support 10 local UAE businesses',
        icon: '🇦🇪',
        category: AchievementCategory.localSupport,
        type: AchievementType.accumulative,
        targetValue: 10,
        rewardPoints: 75,
        rarity: AchievementRarity.rare,
      ),
      Achievement(
        id: 'sustainability_streak_7',
        name: 'Week Warrior',
        description: 'Maintain sustainable habits for 7 consecutive days',
        icon: '🔥',
        category: AchievementCategory.sustainability,
        type: AchievementType.streak,
        targetValue: 7,
        rewardPoints: 30,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'sustainability_streak_30',
        name: 'Sustainability Champion',
        description: 'Maintain sustainable habits for 30 consecutive days',
        icon: '🏆',
        category: AchievementCategory.sustainability,
        type: AchievementType.streak,
        targetValue: 30,
        rewardPoints: 100,
        rarity: AchievementRarity.epic,
      ),
      
      // Health Achievements
      Achievement(
        id: 'fitness_beginner',
        name: 'Fitness Starter',
        description: 'Complete your first workout',
        icon: '💪',
        category: AchievementCategory.fitness,
        type: AchievementType.milestone,
        targetValue: 1,
        rewardPoints: 10,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'workout_streak_7',
        name: 'Workout Warrior',
        description: 'Exercise for 7 consecutive days',
        icon: '🏃‍♀️',
        category: AchievementCategory.fitness,
        type: AchievementType.streak,
        targetValue: 7,
        rewardPoints: 25,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'nutrition_tracker',
        name: 'Nutrition Tracker',
        description: 'Log your meals for 14 days',
        icon: '🥗',
        category: AchievementCategory.nutrition,
        type: AchievementType.streak,
        targetValue: 14,
        rewardPoints: 40,
        rarity: AchievementRarity.rare,
      ),
      Achievement(
        id: 'sleep_master',
        name: 'Sleep Master',
        description: 'Maintain 8+ hours of sleep for 7 nights',
        icon: '😴',
        category: AchievementCategory.sleep,
        type: AchievementType.streak,
        targetValue: 7,
        rewardPoints: 35,
        rarity: AchievementRarity.rare,
      ),
      
      // Legendary Achievements
      Achievement(
        id: 'sustainability_master',
        name: 'Sustainability Master',
        description: 'Achieve 1000 sustainability points',
        icon: '🌟',
        category: AchievementCategory.sustainability,
        type: AchievementType.threshold,
        targetValue: 1000,
        rewardPoints: 200,
        rarity: AchievementRarity.legendary,
      ),
    ];
  }

  List<SustainabilityReward> _getDefaultRewards() {
    return [
      // Virtual Rewards
      SustainabilityReward(
        id: 'eco_badge_bronze',
        name: 'Bronze Eco Badge',
        description: 'Show your environmental commitment',
        icon: '🥉',
        type: RewardType.badge,
        cost: 50,
      ),
      SustainabilityReward(
        id: 'eco_badge_silver',
        name: 'Silver Eco Badge',
        description: 'Advanced environmental advocate',
        icon: '🥈',
        type: RewardType.badge,
        cost: 150,
      ),
      SustainabilityReward(
        id: 'eco_badge_gold',
        name: 'Gold Eco Badge',
        description: 'Master of sustainability',
        icon: '🥇',
        type: RewardType.badge,
        cost: 300,
      ),
      
      // Feature Unlocks
      SustainabilityReward(
        id: 'advanced_analytics',
        name: 'Advanced Analytics',
        description: 'Unlock detailed sustainability insights',
        icon: '📊',
        type: RewardType.featureUnlock,
        cost: 100,
      ),
      SustainabilityReward(
        id: 'custom_themes',
        name: 'Custom Themes',
        description: 'Personalize your app experience',
        icon: '🎨',
        type: RewardType.featureUnlock,
        cost: 75,
      ),
      
      // Local Business Offers
      SustainabilityReward(
        id: 'local_restaurant_discount',
        name: '10% Off Local Restaurants',
        description: 'Discount at participating sustainable restaurants',
        icon: '🍽️',
        type: RewardType.localBusinessOffer,
        cost: 200,
        metadata: {
          'discount_percentage': 10,
          'category': 'restaurants',
          'validity_days': 30,
        },
      ),
      SustainabilityReward(
        id: 'eco_product_discount',
        name: '15% Off Eco Products',
        description: 'Discount on sustainable products',
        icon: '♻️',
        type: RewardType.localBusinessOffer,
        cost: 250,
        metadata: {
          'discount_percentage': 15,
          'category': 'eco_products',
          'validity_days': 30,
        },
      ),
    ];
  }
}
