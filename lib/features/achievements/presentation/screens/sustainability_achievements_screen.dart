import 'package:flutter/material.dart';
import '../../data/models/achievement_model.dart';
import '../../services/achievement_service.dart';

class SustainabilityAchievementsScreen extends StatefulWidget {
  const SustainabilityAchievementsScreen({Key? key}) : super(key: key);

  @override
  State<SustainabilityAchievementsScreen> createState() => _SustainabilityAchievementsScreenState();
}

class _SustainabilityAchievementsScreenState extends State<SustainabilityAchievementsScreen>
    with TickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Achievements & Rewards',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Rewards', icon: Icon(Icons.card_giftcard)),
          ],
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(colorScheme),
          _buildAchievementsTab(colorScheme),
          _buildRewardsTab(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatsTab(ColorScheme colorScheme) {
    return StreamBuilder<SustainabilityStats>(
      stream: _achievementService.watchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? const SustainabilityStats();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Progress Card
              _buildOverallProgressCard(stats, colorScheme),
              const SizedBox(height: 20),

              // Stats Grid
              _buildStatsGrid(stats, colorScheme),
              const SizedBox(height: 20),

              // Progress Charts
              _buildProgressCharts(stats, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallProgressCard(SustainabilityStats stats, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.totalPoints}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Points',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.eco,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  '${stats.totalAchievements}',
                  'Achievements',
                  colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  '${stats.consecutiveDays}',
                  'Day Streak',
                  colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  '${stats.carbonSaved.toStringAsFixed(1)}kg',
                  'CO₂ Saved',
                  colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(SustainabilityStats stats, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Sustainable Actions',
          '${stats.sustainableActions}',
          Icons.eco,
          Colors.green,
          colorScheme,
        ),
        _buildStatCard(
          'Local Businesses',
          '${stats.localBrandsSupported}',
          Icons.store,
          Colors.orange,
          colorScheme,
        ),
        _buildStatCard(
          'Carbon Saved',
          '${stats.carbonSaved.toStringAsFixed(1)}kg',
          Icons.cloud,
          Colors.blue,
          colorScheme,
        ),
        _buildStatCard(
          'Current Streak',
          '${stats.consecutiveDays} days',
          Icons.local_fire_department,
          Colors.red,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCharts(SustainabilityStats stats, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Sustainability progress bars
        _buildProgressBar('Eco Actions', stats.sustainableActions, 100, Colors.green, colorScheme),
        const SizedBox(height: 12),
        _buildProgressBar('Local Support', stats.localBrandsSupported, 50, Colors.orange, colorScheme),
        const SizedBox(height: 12),
        _buildProgressBar('Carbon Impact', stats.carbonSaved.round(), 500, Colors.blue, colorScheme),
      ],
    );
  }

  Widget _buildProgressBar(String label, int current, int target, Color color, ColorScheme colorScheme) {
    final progress = (current / target).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(ColorScheme colorScheme) {
    return StreamBuilder<List<Achievement>>(
      stream: _achievementService.watchAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = snapshot.data ?? [];
        final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
        final lockedAchievements = achievements.where((a) => !a.isUnlocked).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unlockedAchievements.isNotEmpty) ...[
                Text(
                  'Unlocked Achievements',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...unlockedAchievements.map((achievement) => 
                    _buildAchievementCard(achievement, colorScheme, isUnlocked: true)),
                const SizedBox(height: 24),
              ],
              
              Text(
                'In Progress',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...lockedAchievements.map((achievement) => 
                  _buildAchievementCard(achievement, colorScheme, isUnlocked: false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, ColorScheme colorScheme, {required bool isUnlocked}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Achievement Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Achievement Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildRarityBadge(achievement.rarity, colorScheme),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (!isUnlocked) ...[
                  // Progress Bar
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.currentProgress} / ${achievement.targetValue}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  // Unlock Date and Points
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${achievement.rewardPoints} pts',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityBadge(AchievementRarity rarity, ColorScheme colorScheme) {
    Color badgeColor;
    String label;
    
    switch (rarity) {
      case AchievementRarity.common:
        badgeColor = Colors.grey;
        label = 'Common';
        break;
      case AchievementRarity.rare:
        badgeColor = Colors.blue;
        label = 'Rare';
        break;
      case AchievementRarity.epic:
        badgeColor = Colors.purple;
        label = 'Epic';
        break;
      case AchievementRarity.legendary:
        badgeColor = Colors.orange;
        label = 'Legendary';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRewardsTab(ColorScheme colorScheme) {
    return StreamBuilder<List<SustainabilityReward>>(
      stream: _achievementService.watchRewards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rewards = snapshot.data ?? [];
        
        return StreamBuilder<SustainabilityStats>(
          stream: _achievementService.watchStats(),
          builder: (context, statsSnapshot) {
            final stats = statsSnapshot.data ?? const SustainabilityStats();
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points Balance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Available Points',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.totalPoints}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Available Rewards',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...rewards.map((reward) => 
                      _buildRewardCard(reward, stats.totalPoints, colorScheme)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardCard(SustainabilityReward reward, int availablePoints, ColorScheme colorScheme) {
    final canAfford = availablePoints >= reward.cost;
    final isRedeemed = reward.isRedeemed;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRedeemed
            ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canAfford && !isRedeemed
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Reward Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: canAfford && !isRedeemed
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                reward.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Reward Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${reward.cost} points',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isRedeemed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Redeemed',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (canAfford)
                      ElevatedButton(
                        onPressed: () => _redeemReward(reward),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Redeem'),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Need ${reward.cost - availablePoints} more',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemReward(SustainabilityReward reward) async {
    try {
      await _achievementService.redeemReward(reward.id, reward.cost);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reward.name} redeemed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to redeem reward: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
