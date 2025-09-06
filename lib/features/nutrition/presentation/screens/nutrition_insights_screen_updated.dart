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
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Daily Summary
              dailySummaryState.when(
                data: (DailyNutritionSummary summary) => _buildDailySummary(summary, cs),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stack) => _buildErrorCard(error.toString(), cs),
              ),
              
              const SizedBox(height: 24),
              
              // Weekly Trends from Food Log Data
              foodLogState.when(
                data: (List<FoodLogEntry> entries) => _buildWeeklyTrends(entries, cs),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stack) => _buildErrorCard(error.toString(), cs),
              ),
              
              const SizedBox(height: 24),
              
              // Food Log Insights
              foodLogState.when(
                data: (List<FoodLogEntry> entries) => _buildFoodLogInsights(entries, cs),
                loading: () => const SizedBox.shrink(),
                error: (Object error, StackTrace stack) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 80), // For bottom nav spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySummary(DailyNutritionSummary summary, ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Today\'s Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildSummaryItem(
                  'Calories',
                  '${summary.totalNutrition.calories}/${summary.targetCalories}',
                  summary.calorieProgress,
                  cs.primary,
                ),
                _buildSummaryItem(
                  'Protein',
                  '${summary.totalNutrition.protein}g',
                  summary.totalNutrition.protein / 100, // Assuming 100g target
                  cs.secondary,
                ),
                _buildSummaryItem(
                  'Eco Score',
                  '${(summary.sustainabilityScore * 100).toInt()}%',
                  summary.sustainabilityScore,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Meals logged today: ${summary.meals.length}',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, double progress, Color color) {
    return Column(
      children: <Widget>[
        CircularProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(color),
          strokeWidth: 6,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrends(List<FoodLogEntry> entries, ColorScheme cs) {
    if (entries.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.trending_up,
                size: 48,
                color: cs.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Food Data Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging meals to see your weekly trends and insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate weekly trends
    final int totalCalories = entries.fold(0, (int sum, FoodLogEntry entry) => sum + entry.nutritionInfo.calories);
    final num avgCaloriesPerMeal = entries.isNotEmpty ? totalCalories / entries.length : 0;
    final double totalProtein = entries.fold(0.0, (double sum, FoodLogEntry entry) => sum + entry.nutritionInfo.protein);
    final double avgSustainabilityScore = entries.isNotEmpty 
        ? entries.where((FoodLogEntry e) => e.sustainabilityScore != null)
            .map((FoodLogEntry e) => double.tryParse(e.sustainabilityScore!) ?? 0.0)
            .fold(0.0, (double a, double b) => a + b) / entries.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Weekly Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildTrendCard('Total Calories', '${totalCalories}', 'from ${entries.length} meals', cs.primary),
        const SizedBox(height: 8),
        _buildTrendCard('Avg per Meal', '${avgCaloriesPerMeal.toInt()} cal', 'calories per meal', cs.secondary),
        const SizedBox(height: 8),
        _buildTrendCard('Total Protein', '${totalProtein.toInt()}g', 'protein consumed', Colors.orange),
        const SizedBox(height: 8),
        _buildTrendCard('Eco Score', '${(avgSustainabilityScore * 100).toInt()}%', 'average sustainability', Colors.green),
      ],
    );
  }

  Widget _buildTrendCard(String title, String value, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up,
              color: color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogInsights(List<FoodLogEntry> entries, ColorScheme cs) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // Analyze meal types
    final Map<String, int> mealTypeCount = <String, int>{};
    for (final FoodLogEntry entry in entries) {
      mealTypeCount[entry.mealType] = (mealTypeCount[entry.mealType] ?? 0) + 1;
    }

    final String mostLoggedMeal = mealTypeCount.entries
        .reduce((MapEntry<String, int> a, MapEntry<String, int> b) => a.value > b.value ? a : b)
        .key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Food Log Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.insights, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Your Patterns',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Most logged meal type: ${mostLoggedMeal.toLowerCase()}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Total meals logged: ${entries.length}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Different meal types: ${mealTypeCount.keys.length}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message, ColorScheme cs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 48,
              color: cs.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
