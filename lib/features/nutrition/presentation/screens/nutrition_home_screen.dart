import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/guide_section.dart';
import '../../../../widgets/achievement_popup_widget.dart';
import '../../data/models/nutrition_models.dart';
import '../../domain/repositories/nutrition_repository.dart';

class NutritionHomeScreen extends ConsumerWidget {
  const NutritionHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> apiHealthState =
        ref.watch(nutritionApiHealthProvider);
    final AsyncValue<List<FoodLogEntry>> foodLogState = ref.watch(foodLogProvider);
    final AsyncValue<List<SavedMealPlan>> savedMealPlansState = ref.watch(savedMealPlansProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildModernAppBar(context, cs, isDark),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // API Status Indicator
            apiHealthState.when(
              data: (bool isHealthy) => _buildApiStatusCard(context, cs, isDark, isHealthy),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => _buildApiStatusCard(context, cs, isDark, false),
            ),

            // Welcome Section with Quick Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your Nutrition Hub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Smart food analysis powered by AI for healthier, sustainable choices',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Today's Quick Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? cs.surfaceContainer
                        : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: _NutritionHomeHelper.buildQuickStats(foodLogState, savedMealPlansState, cs),
                  ),
                  const SizedBox(height: 20),

                  // Primary Actions Grid
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _FeatureCard(
                          title: 'AI Food Analysis',
                          subtitle: 'Instant nutrition insights',
                          icon: Icons.psychology,
                          color: cs.primary,
                          onTap: () async {
                            final bool? result = await context.push<bool>('/nutrition/ai-recognition');
                            if (result == true && context.mounted) {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                AchievementPopupWidget.showNutritionLogged(context);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Meal Planning',
                          subtitle: 'Personalized recommendations',
                          icon: Icons.restaurant_menu,
                          color: cs.primary,
                          onTap: () => context.go('/nutrition/ai-meal-plan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _FeatureCard(
                          title: 'Brand Alternatives',
                          subtitle: 'Eco-friendly options',
                          icon: Icons.eco,
                          color: cs.primary,
                          onTap: () =>
                              context.go('/nutrition/brand-recommendations'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Food Journal',
                          subtitle: 'Track your meals',
                          icon: Icons.edit_note,
                          color: cs.primary,
                          onTap: () => context.go('/nutrition/food-logging'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/nutrition/insights'),
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ActivityCard(
                    title: 'No recent activity',
                    subtitle: 'Start by analyzing your first meal!',
                    icon: Icons.camera_alt,
                    color: cs.primary,
                    onTap: () async {
                      final bool? result = await context.push<bool>('/nutrition/ai-recognition');
                      if (result == true && context.mounted) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          AchievementPopupWidget.showNutritionLogged(context);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Knowledge Hub Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nutrition Knowledge',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _KnowledgeCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Today\'s Tip',
                    description:
                        'Choose foods with shorter ingredient lists - they\'re usually less processed and more nutritious.',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _KnowledgeCard(
                    icon: Icons.eco,
                    title: 'Sustainability Fact',
                    description:
                        'Eating locally grown produce can reduce your carbon footprint by up to 20%.',
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Saved Meal Plans Quick Access
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/nutrition/saved-plans'),
                  icon: const Icon(Icons.bookmark),
                  label: const Text('View Saved Meal Plans'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final bool? result = await context.push<bool>('/nutrition/ai-recognition');
          if (result == true && context.mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              AchievementPopupWidget.showNutritionLogged(context);
            });
          }
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.camera_alt),
        label: const Text(
          'AI Food Scan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, ColorScheme cs, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      automaticallyImplyLeading: false, // Remove back arrow
      title: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant_outlined,
              color: cs.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Nutrition',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: () => _showNutritionGuide(context),
            style: IconButton.styleFrom(
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
              foregroundColor: cs.primary,
              minimumSize: const Size(48, 48),
            ),
            icon: Icon(
              Icons.help_outline,
              color: cs.primary,
              size: 20,
            ),
            tooltip: 'Nutrition Guide',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => context.push('/nutrition/insights'),
            style: IconButton.styleFrom(
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
              foregroundColor: cs.primary,
              minimumSize: const Size(48, 48),
            ),
            icon: Icon(
              Icons.analytics_outlined,
              color: cs.primary,
              size: 20,
            ),
            tooltip: 'Nutrition Insights',
          ),
        ),
      ],
    );
  }

  Widget _buildApiStatusCard(BuildContext context, ColorScheme cs, bool isDark, bool isHealthy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHealthy ? cs.primaryContainer.withValues(alpha: 0.2) : cs.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy ? cs.primary.withValues(alpha: 0.3) : cs.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isHealthy ? cs.primary.withValues(alpha: 0.1) : cs.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isHealthy ? Icons.check_circle_outline : Icons.error_outline,
              color: isHealthy ? cs.primary : cs.error,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isHealthy ? 'Nutrition API is healthy' : 'Nutrition API is unavailable',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isHealthy ? cs.primary : cs.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNutritionGuide(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scrollController) =>
            Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Nutrition Features Guide',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    GuideSection(
                      icon: Icons.camera_alt,
                      title: 'AI Food Scan',
                      description:
                          'Take a photo of your meal and get instant nutrition analysis',
                      features: <String>[
                        'Food identification with AI',
                        'Calorie and macro calculation',
                        'Sustainability scoring',
                        'Detailed ingredient analysis',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.restaurant_menu,
                      title: 'AI Meal Planning',
                      description:
                          'Generate personalized meal plans based on your goals',
                      features: <String>[
                        'Custom calorie targets',
                        'Dietary restrictions support',
                        'Recipe suggestions',
                        'Weekly meal planning',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.eco,
                      title: 'Sustainable Brand Recommendations',
                      description:
                          'Find UAE-based sustainable alternatives for any product',
                      features: <String>[
                        'Search any food product',
                        'Sustainability ratings (A+ to C)',
                        'Competitive pricing information',
                        'Local UAE suppliers',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.analytics,
                      title: 'Nutrition Insights',
                      description: 'Get personalized recommendations and tips',
                      features: <String>[
                        'Sustainability analysis',
                        'Health recommendations',
                        'Ingredient breakdowns',
                        'Smart food choices',
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 140, // Fixed height for equal sizing
      decoration: BoxDecoration(
        color: isDark 
          ? cs.surfaceContainer
          : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? cs.surfaceContainer
          : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _KnowledgeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
          ? cs.surfaceContainer
          : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionHomeHelper {
  static Widget buildQuickStats(
    AsyncValue<List<FoodLogEntry>> foodLogState,
    AsyncValue<List<SavedMealPlan>> savedMealPlansState,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Scans',
            _calculateTotalScans(foodLogState),
            Icons.qr_code_scanner,
            colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Saved Plans',
            _calculateSavedPlansCount(savedMealPlansState),
            Icons.bookmark,
            colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Eco Score',
            '${_calculateEcoScorePercentage(foodLogState)}%',
            Icons.eco,
            Colors.green,
          ),
        ),
      ],
    );
  }

  static String _calculateTotalScans(AsyncValue<List<FoodLogEntry>> foodLogState) {
    return foodLogState.when(
      data: (entries) => entries.length.toString(),
      loading: () => '-',
      error: (error, stack) => '0',
    );
  }

  static String _calculateSavedPlansCount(AsyncValue<List<SavedMealPlan>> savedMealPlansState) {
    return savedMealPlansState.when(
      data: (plans) => plans.length.toString(),
      loading: () => '-',
      error: (error, stack) => '0',
    );
  }

  static int _calculateEcoScorePercentage(AsyncValue<List<FoodLogEntry>> foodLogState) {
    return foodLogState.when(
      data: (entries) {
        if (entries.isEmpty) return 0;
        
        double totalScore = 0;
        int validEntries = 0;
        
        for (final entry in entries) {
          // Calculate average sustainability score if available
          if (entry.sustainabilityScore != null) {
            // Convert string score to numeric value
            switch (entry.sustainabilityScore!.toLowerCase()) {
              case 'high':
                totalScore += 100;
                break;
              case 'medium':
                totalScore += 75;
                break;
              case 'low':
                totalScore += 50;
                break;
              default:
                totalScore += 75; // Default to medium
            }
            validEntries++;
          }
        }
        
        if (validEntries == 0) return 0;
        
        // Return the average score as percentage
        double averageScore = totalScore / validEntries;
        return averageScore.round().clamp(0, 100);
      },
      loading: () => 0,
      error: (error, stack) => 0,
    );
  }

  static Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
