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
          style: TextStyle(
            color = Color(0xFF121714),
            fontWeight = FontWeight.bold,
            fontSize = 20,
            letterSpacing = -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Weekly Trends
              const Text(
                'Weekly Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 12),
              _MockChart(title: 'Calories Consumed', color: Color(0xFF94e0b2)),
              const SizedBox(height: 8),
              _MockChart(
                  title: 'Macronutrient Balance', color: Color(0xFF688273)),
              const SizedBox(height: 8),
              _MockChart(
                  title: 'Sustainability Score', color: Color(0xFFdde4e0)),
              const SizedBox(height: 24),
              // AI Recommendations
              const Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 8),
              _AISuggestionCard(
                title: 'Personalized Tip',
                description: 'Increase your fiber intake for better digestion.',
              ),
              _AISuggestionCard(
                title: 'Sustainable Swap',
                description:
                    'Try oat milk instead of dairy for a lower carbon footprint.',
              ),
              _AISuggestionCard(
                title: 'Meal Plan',
                description:
                    'Here’s a 3-day plant-based meal plan tailored for you.',
              ),
              const SizedBox(height: 24),
              // Goals Tracking
              const Text(
                'Goals Tracking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 8),
              _GoalProgress(
                  title: 'Calorie Goal',
                  progress: 0.7,
                  color: Color(0xFF94e0b2)),
              _GoalProgress(
                  title: 'Protein Goal',
                  progress: 0.5,
                  color: Color(0xFF688273)),
              _GoalProgress(
                  title: 'Sustainability',
                  progress: 0.85,
                  color: Color(0xFFdde4e0)),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  _AchievementBadge(label: '7-Day Streak'),
                  const SizedBox(width: 12),
                  _AchievementBadge(label: 'Eco Hero'),
                ],
              ),
              const SizedBox(height: 80), // For bottom nav spacing
            ],
          ),
        ),
      ),
    );
  }
}

class _MockChart extends StatelessWidget {
  final String title;
  final Color color;
  const _MockChart({required this.title, required this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final String title;
  final String description;
  const _AISuggestionCard(
      {required this.title, required this.description, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f4f2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF121714),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF688273),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  const _GoalProgress(
      {required this.title,
      required this.progress,
      required this.color,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;
  const _AchievementBadge({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF94e0b2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF121714),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _NutritionBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _NutritionBottomNavBar({required this.selectedIndex, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.of(context).pushNamed('/home');
            break;
          case 1:
            Navigator.of(context).pushNamed('/exercise');
            break;
          case 2:
            Navigator.of(context).pushNamed('/nutrition');
            break;
          case 3:
            Navigator.of(context).pushNamed('/sleep');
            break;
          case 4:
            Navigator.of(context).pushNamed('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF121714),
      unselectedItemColor: const Color(0xFF688273),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercise',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Nutrition',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.nightlight_round),
          label: 'Sleep',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
