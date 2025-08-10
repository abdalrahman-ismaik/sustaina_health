import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/guide_section.dart';

class NutritionHomeScreen extends ConsumerWidget {
  const NutritionHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyNutritionState = ref.watch(dailyNutritionSummaryProvider);
    final apiHealthState = ref.watch(nutritionApiHealthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF121714)),
          onPressed: () {},
        ),
        title: const Text(
          'Your Nutrition Journey',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF121714)),
            onPressed: () => _showNutritionGuide(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF121714)),
            onPressed: () {
              ref.read(dailyNutritionSummaryProvider.notifier).refreshSummary();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Welcome Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF94e0b2), Color(0xFF688273)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI-Powered Nutrition',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan food with your camera, get personalized meal plans, and track your nutrition journey with AI assistance.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // API Status Indicator
            apiHealthState.when(
              data: (isHealthy) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHealthy ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.error,
                      color: isHealthy ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHealthy
                          ? 'AI Services Online'
                          : 'AI Services Offline - Demo Mode Active',
                      style: TextStyle(
                        color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // Daily Overview
            dailyNutritionState.when(
              data: (summary) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Today - ${_formatDate(summary.date)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF121714),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _OverviewCard(
                          title: 'Calories',
                          value: '${summary.totalNutrition.calories}/${summary.targetCalories} kcal',
                          icon: Icons.local_fire_department,
                          color: const Color(0xFF94e0b2),
                          progress: summary.calorieProgress,
                        ),
                        _OverviewCard(
                          title: 'Macros',
                          value: summary.totalNutrition.macroString,
                          icon: Icons.pie_chart,
                          color: const Color(0xFFdde4e0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _OverviewCard(
                          title: 'Fiber',
                          value: '${summary.totalNutrition.fiber}g',
                          icon: Icons.grass,
                          color: const Color(0xFFdde4e0),
                        ),
                        _OverviewCard(
                          title: 'Sustainability',
                          value: '${summary.sustainabilityScore.round()}/100',
                          icon: Icons.eco,
                          color: const Color(0xFF94e0b2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF94e0b2))),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading nutrition data: $error',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
            // Meal Sections
            dailyNutritionState.when(
              data: (summary) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _MealSection(
                      meal: 'Breakfast',
                      entries: summary.getMealsByType('breakfast'),
                      onAddFood: () => Navigator.of(context).pushNamed('/nutrition/log'),
                    ),
                    _MealSection(
                      meal: 'Lunch',
                      entries: summary.getMealsByType('lunch'),
                      onAddFood: () => Navigator.of(context).pushNamed('/nutrition/log'),
                    ),
                    _MealSection(
                      meal: 'Dinner',
                      entries: summary.getMealsByType('dinner'),
                      onAddFood: () => Navigator.of(context).pushNamed('/nutrition/log'),
                    ),
                    _MealSection(
                      meal: 'Snacks',
                      entries: summary.getMealsByType('snack'),
                      onAddFood: () => Navigator.of(context).pushNamed('/nutrition/log'),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Action Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          title: 'AI Food Scan',
                          subtitle: 'Photo → Nutrition',
                          icon: Icons.camera_alt,
                          color: const Color(0xFF94e0b2),
                          onTap: () => Navigator.of(context).pushNamed('/nutrition/ai-recognition'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'AI Meal Plan',
                          subtitle: 'Smart Planning',
                          icon: Icons.restaurant_menu,
                          color: const Color(0xFF688273),
                          onTap: () => Navigator.of(context).pushNamed('/nutrition/ai-meal-plan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Secondary Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Log Food',
                          subtitle: 'Manual Entry',
                          icon: Icons.edit,
                          color: const Color(0xFFdde4e0),
                          onTap: () => Navigator.of(context).pushNamed('/nutrition/food-logging'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Insights',
                          subtitle: 'Trends & Analytics',
                          icon: Icons.analytics,
                          color: const Color(0xFFdde4e0),
                          onTap: () => Navigator.of(context).pushNamed('/nutrition/insights'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Suggestions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'AI Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AISuggestionCard(
                    title: 'Meal Recommendation',
                    description: 'Try a quinoa salad with seasonal veggies for lunch!',
                    icon: Icons.lightbulb_outline,
                  ),
                  _AISuggestionCard(
                    title: 'Sustainable Alternative',
                    description: 'Swap beef for lentils to reduce your carbon footprint.',
                    icon: Icons.eco,
                  ),
                  _AISuggestionCard(
                    title: 'Seasonal Produce',
                    description: 'Strawberries, spinach, and asparagus are in season!',
                    icon: Icons.local_florist,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Extra space for bottom navigation
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/nutrition/ai-recognition'),
        backgroundColor: const Color(0xFF94e0b2),
        foregroundColor: const Color(0xFF121714),
        icon: const Icon(Icons.camera_alt),
        label: const Text(
          'AI Food Scan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNutritionGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Nutrition Features Guide',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121714),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    GuideSection(
                      icon: Icons.camera_alt,
                      title: 'AI Food Scan',
                      description: 'Take a photo of your meal and get instant nutrition analysis',
                      features: [
                        'Food identification with AI',
                        'Calorie and macro calculation',
                        'Sustainability scoring',
                        'Automatic food logging',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.restaurant_menu,
                      title: 'AI Meal Planning',
                      description: 'Generate personalized meal plans based on your goals',
                      features: [
                        'Custom calorie targets',
                        'Dietary restrictions support',
                        'Recipe suggestions',
                        'Weekly meal planning',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.edit,
                      title: 'Manual Food Logging',
                      description: 'Log your meals manually with detailed nutrition info',
                      features: [
                        'Search food database',
                        'Custom portion sizes',
                        'Meal categorization',
                        'Notes and comments',
                      ],
                    ),
                    GuideSection(
                      icon: Icons.analytics,
                      title: 'Nutrition Insights',
                      description: 'Track your progress with detailed analytics',
                      features: [
                        'Daily nutrition summaries',
                        'Weekly trend analysis',
                        'Goal progress tracking',
                        'Achievement badges',
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

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress! > 1 ? 1 : progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String meal;
  final List<dynamic> entries; // FoodLogEntry list
  final VoidCallback onAddFood;
  
  const _MealSection({
    required this.meal,
    required this.entries,
    required this.onAddFood,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                meal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              TextButton.icon(
                onPressed: onAddFood,
                icon: const Icon(Icons.add, color: Color(0xFF94e0b2)),
                label: const Text(
                  'Add Food',
                  style: TextStyle(
                    color: Color(0xFF94e0b2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFFdde4e0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
          
          // Show food entries if any
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f4f2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.foodName ?? 'Unknown Food',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF121714),
                          ),
                        ),
                      ),
                      Text(
                        '${entry.nutritionInfo?.calories ?? 0} kcal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF688273),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'No ${meal.toLowerCase()} logged yet',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF688273),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
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
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF688273),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  
  const _AISuggestionCard({
    required this.title,
    required this.description,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Meal Recommendation') {
          Navigator.of(context).pushNamed('/nutrition/insights');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFf1f4f2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe8ebe9), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF94e0b2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF688273),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF688273),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF688273),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
