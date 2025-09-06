import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';

class NutritionInsightsScreen extends ConsumerWidget {
  const NutritionInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FoodLogEntry>> foodLogState = ref.watch(foodLogProvider);
    final AsyncValue<DailyNutritionSummary> dailySummaryState = ref.watch(dailyNutritionSummaryProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Nutrition Insights',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline, color: cs.primary),
            onPressed: () => _showInsightsHelp(context),
          ),
        ],
      ),
      body: foodLogState.when(
        data: (List<FoodLogEntry> entries) => dailySummaryState.when(
          data: (DailyNutritionSummary summary) => _buildInsightsContent(context, entries, summary, cs, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stack) => _buildErrorState(context, 'Failed to load daily summary', cs),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => _buildErrorState(context, 'Failed to load food log data', cs),
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, List<FoodLogEntry> entries, 
      DailyNutritionSummary summary, ColorScheme cs, bool isDark) {
    
    if (entries.isEmpty) {
      return _buildEmptyState(context, cs);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Today's Summary Card
          _buildTodaySummaryCard(summary, cs, isDark),
          const SizedBox(height: 20),
          
          // Nutrition Breakdown
          _buildNutritionBreakdown(summary, cs, isDark),
          const SizedBox(height: 20),
          
          // Meal Distribution
          _buildMealDistribution(entries, cs, isDark),
          const SizedBox(height: 20),
          
          // Weekly Trends (if we have historical data)
          _buildWeeklyTrends(entries, cs, isDark),
          const SizedBox(height: 20),
          
          // Sustainability Insights
          _buildSustainabilityInsights(entries, cs, isDark),
          const SizedBox(height: 20),
          
          // AI-Powered Tips
          _buildAITips(entries, summary, cs, isDark),
          const SizedBox(height: 20),
          
          // Goals Progress
          _buildGoalsProgress(summary, cs, isDark),
          const SizedBox(height: 100), // Extra space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: cs.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Nutrition Data Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging your meals to see personalized insights and recommendations!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Food Logging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 80,
              color: cs.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(DailyNutritionSummary summary, ColorScheme cs, bool isDark) {
    final double calorieProgress = summary.totalNutrition.calories / summary.targetCalories.clamp(1, double.infinity);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Today's Nutrition",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              Icon(
                Icons.today,
                color: cs.primary,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Calorie Progress
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Calories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${summary.totalNutrition.calories} / ${summary.targetCalories}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: calorieProgress.clamp(0.0, 1.0),
                        backgroundColor: cs.outline.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          calorieProgress > 1.0 ? Colors.orange : cs.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Macros Row
          Row(
            children: <Widget>[
              Expanded(
                child: _buildMacroCard('Protein', '${summary.totalNutrition.protein}g', Colors.blue, cs),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard('Carbs', '${summary.totalNutrition.carbohydrates}g', Colors.green, cs),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard('Fat', '${summary.totalNutrition.fat}g', Colors.orange, cs),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBreakdown(DailyNutritionSummary summary, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.pie_chart, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Nutrition Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Detailed nutrition info
          _buildNutritionRow('Fiber', '${summary.totalNutrition.fiber}g', Icons.grass, Colors.green, cs),
          _buildNutritionRow('Sugar', '${summary.totalNutrition.sugar}g', Icons.cookie, Colors.orange, cs),
          _buildNutritionRow('Sodium', '${summary.totalNutrition.sodium}mg', Icons.grain, Colors.red, cs),
          
          const SizedBox(height: 12),
          
          // Sustainability Score
          Row(
            children: <Widget>[
              Icon(Icons.eco, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sustainability Score: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSustainabilityColor(summary.sustainabilityScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${summary.sustainabilityScore.round()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getSustainabilityColor(summary.sustainabilityScore),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon, Color color, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealDistribution(List<FoodLogEntry> entries, ColorScheme cs, bool isDark) {
    final Map<String, List<FoodLogEntry>> mealGroups = <String, List<FoodLogEntry>>{};
    for (final FoodLogEntry entry in entries) {
      mealGroups.putIfAbsent(entry.mealType, () => <FoodLogEntry>[]).add(entry);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.restaurant_menu, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Meal Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...mealGroups.entries.map((MapEntry<String, List<FoodLogEntry>> entry) {
            final String mealType = entry.key;
            final List<FoodLogEntry> mealEntries = entry.value;
            final int totalCalories = mealEntries.fold<int>(0, (int sum, FoodLogEntry e) => sum + e.nutritionInfo.calories);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getMealTypeColor(mealType),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mealType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Text(
                    '${mealEntries.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${totalCalories} cal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrends(List<FoodLogEntry> entries, ColorScheme cs, bool isDark) {
    // For now, we'll show today's trends since we don't have historical data
    // In a real app, you'd fetch data for the past 7 days
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.trending_up, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Weekly Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Since we don't have historical data, show current status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: <Widget>[
                Icon(Icons.calendar_today, color: cs.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Today\'s Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entries.length} meals logged',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Keep logging meals daily to see your weekly nutrition trends!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityInsights(List<FoodLogEntry> entries, ColorScheme cs, bool isDark) {
    final List<FoodLogEntry> sustainableEntries = entries.where((FoodLogEntry e) => e.sustainabilityScore != null).toList();
    final int highSustainabilityCount = sustainableEntries.where((FoodLogEntry e) => 
        e.sustainabilityScore?.toLowerCase() == 'high').length;
    final int totalWithScores = sustainableEntries.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.eco, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Sustainability Impact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (totalWithScores > 0) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildSustainabilityMetric(
                    'High Sustainability', 
                    '$highSustainabilityCount/$totalWithScores', 
                    Colors.green, 
                    cs
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSustainabilityMetric(
                    'Eco Score', 
                    '${((highSustainabilityCount / totalWithScores) * 100).round()}%', 
                    Colors.blue, 
                    cs
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.lightbulb, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSustainabilityTip(highSustainabilityCount, totalWithScores),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...<Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Icon(Icons.eco_outlined, color: cs.outline, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'No Sustainability Data',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use AI food scanning to get sustainability insights!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSustainabilityMetric(String label, String value, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITips(List<FoodLogEntry> entries, DailyNutritionSummary summary, ColorScheme cs, bool isDark) {
    final List<Map<String, dynamic>> tips = _generateAITips(entries, summary);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[cs.secondary.withOpacity(0.1), cs.tertiary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.psychology, color: cs.secondary, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI-Powered Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...tips.asMap().entries.map((MapEntry<int, Map<String, dynamic>> entry) {
            final int index = entry.key;
            final Map<String, dynamic> tip = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < tips.length - 1 ? 12 : 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? cs.surfaceContainer : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: tip['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tip['icon'],
                        size: 14,
                        color: tip['color'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tip['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.7),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress(DailyNutritionSummary summary, ColorScheme cs, bool isDark) {
    final int proteinTarget = (summary.targetCalories * 0.2 / 4).round(); // 20% of calories from protein
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.track_changes, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Goals Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Calorie Goal
          _buildGoalProgressItem(
            'Daily Calories',
            summary.totalNutrition.calories,
            summary.targetCalories,
            'cal',
            cs.primary,
            cs,
          ),
          
          const SizedBox(height: 12),
          
          // Protein Goal (assuming 20% of calories from protein)
          _buildGoalProgressItem(
            'Protein',
            summary.totalNutrition.protein,
            proteinTarget,
            'g',
            Colors.blue,
            cs,
          ),
          
          const SizedBox(height: 12),
          
          // Fiber Goal (assuming 25g daily)
          _buildGoalProgressItem(
            'Fiber',
            summary.totalNutrition.fiber,
            25,
            'g',
            Colors.green,
            cs,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressItem(String label, int current, int target, String unit, Color color, ColorScheme cs) {
    final double progress = (current / target.clamp(1, double.infinity)).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '$current / $target $unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  void _showInsightsHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nutrition Insights Help',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This screen provides comprehensive analysis of your nutrition data:',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            const _HelpItem(
              icon: Icons.today,
              title: 'Today\'s Summary',
              description: 'View your daily calorie and macro progress',
            ),
            const _HelpItem(
              icon: Icons.pie_chart,
              title: 'Nutrition Breakdown',
              description: 'Detailed vitamins, minerals, and sustainability score',
            ),
            const _HelpItem(
              icon: Icons.restaurant_menu,
              title: 'Meal Distribution',
              description: 'See how calories are distributed across meals',
            ),
            const _HelpItem(
              icon: Icons.psychology,
              title: 'AI Tips',
              description: 'Personalized recommendations based on your data',
            ),
            const _HelpItem(
              icon: Icons.track_changes,
              title: 'Goals Progress',
              description: 'Track your progress towards nutrition goals',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSustainabilityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSustainabilityTip(int highCount, int total) {
    final int percentage = (highCount / total * 100).round();
    if (percentage >= 80) {
      return 'Excellent! You\'re making very sustainable food choices.';
    } else if (percentage >= 50) {
      return 'Good progress! Try to choose more plant-based options.';
    } else {
      return 'Consider incorporating more sustainable food choices for a lower environmental impact.';
    }
  }

  List<Map<String, dynamic>> _generateAITips(List<FoodLogEntry> entries, DailyNutritionSummary summary) {
    final List<Map<String, dynamic>> tips = <Map<String, dynamic>>[];
    
    // Calorie tip
    if (summary.totalNutrition.calories < summary.targetCalories * 0.8) {
      tips.add(<String, dynamic>{
        'icon': Icons.add_circle,
        'color': Colors.orange,
        'title': 'Increase Calorie Intake',
        'description': 'You\'re below your daily calorie target. Consider adding a healthy snack or increasing portion sizes.',
      });
    } else if (summary.totalNutrition.calories > summary.targetCalories * 1.2) {
      tips.add(<String, dynamic>{
        'icon': Icons.remove_circle,
        'color': Colors.red,
        'title': 'Monitor Calorie Intake',
        'description': 'You\'ve exceeded your daily calorie goal. Focus on nutrient-dense, lower-calorie foods.',
      });
    }
    
    // Protein tip
    if (summary.totalNutrition.protein < (summary.targetCalories * 0.15 / 4)) {
      tips.add(<String, dynamic>{
        'icon': Icons.fitness_center,
        'color': Colors.blue,
        'title': 'Boost Protein Intake',
        'description': 'Add lean meats, eggs, legumes, or protein powder to reach your protein goals.',
      });
    }
    
    // Fiber tip
    if (summary.totalNutrition.fiber < 20) {
      tips.add(<String, dynamic>{
        'icon': Icons.grass,
        'color': Colors.green,
        'title': 'Increase Fiber',
        'description': 'Add more vegetables, fruits, whole grains, and legumes for better digestion.',
      });
    }
    
    // Sustainability tip
    final int sustainableItems = entries.where((FoodLogEntry e) => 
        e.sustainabilityScore?.toLowerCase() == 'high').length;
    if (sustainableItems < entries.length * 0.5) {
      tips.add(<String, dynamic>{
        'icon': Icons.eco,
        'color': Colors.green,
        'title': 'Choose Sustainable Options',
        'description': 'Consider plant-based alternatives and locally-sourced ingredients to reduce environmental impact.',
      });
    }
    
    // Meal frequency tip
    final int mealsToday = entries.length;
    if (mealsToday < 3) {
      tips.add(<String, dynamic>{
        'icon': Icons.schedule,
        'color': Colors.purple,
        'title': 'Regular Meal Schedule',
        'description': 'Aim for 3 regular meals to maintain stable energy levels throughout the day.',
      });
    }
    
    // Default tip if no specific recommendations
    if (tips.isEmpty) {
      tips.add(<String, dynamic>{
        'icon': Icons.thumb_up,
        'color': Colors.green,
        'title': 'Great Job!',
        'description': 'You\'re doing well with your nutrition goals. Keep up the good work!',
      });
    }
    
    return tips.take(3).toList(); // Limit to 3 tips
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
