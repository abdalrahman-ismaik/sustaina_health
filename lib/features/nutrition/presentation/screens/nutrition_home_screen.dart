import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/guide_section.dart';

class NutritionHomeScreen extends ConsumerWidget {
  const NutritionHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> apiHealthState = ref.watch(nutritionApiHealthProvider);

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF121714)),
            onPressed: () => _showNutritionGuide(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // API Status Indicator
            apiHealthState.when(
              data: (bool isHealthy) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHealthy ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.error,
                      color: isHealthy ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHealthy
                          ? 'AI Analysis Available'
                          : 'AI Service Unavailable - Using Mock Data',
                      style: TextStyle(
                        color: isHealthy
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Discover Your Food\'s Impact',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analyze your meals for nutrition insights and sustainability recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF688273),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _FeatureCard(
                          title: 'AI Analysis',
                          subtitle: 'Get instant food insights',
                          icon: Icons.psychology,
                          color: const Color(0xFF40916C),
                          onTap: () => context.go('/nutrition/ai-recognition'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Meal Plans',
                          subtitle: 'Personalized recommendations',
                          icon: Icons.restaurant_menu,
                          color: const Color(0xFF40916C),
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
                          title: 'Sustainable Brands',
                          subtitle: 'Find eco-friendly alternatives',
                          icon: Icons.eco,
                          color: const Color(0xFF40916C),
                          onTap: () =>
                              context.go('/nutrition/brand-recommendations'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Food Logging',
                          subtitle: 'Track your meals',
                          icon: Icons.edit_note,
                          color: const Color(0xFF40916C),
                          onTap: () => context.go('/nutrition/food-logging'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nutrition Insights Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Nutrition Insights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InsightCard(
                    icon: Icons.eco,
                    title: 'Sustainability Matters',
                    description:
                        'Learn how your food choices impact the environment and make informed decisions.',
                    color: const Color(0xFF40916C),
                  ),
                  const SizedBox(height: 12),
                  _InsightCard(
                    icon: Icons.store,
                    title: 'Sustainable Brand Recommendations',
                    description:
                        'Discover UAE-based sustainable brands for any product with pricing and eco-ratings.',
                    color: const Color(0xFF40916C),
                  ),
                  const SizedBox(height: 12),
                  _InsightCard(
                    icon: Icons.science,
                    title: 'AI-Powered Analysis',
                    description:
                        'Get detailed nutritional breakdowns and personalized health recommendations.',
                    color: const Color(0xFF40916C),
                  ),
                  const SizedBox(height: 12),
                  _InsightCard(
                    icon: Icons.restaurant_menu,
                    title: 'Smart Meal Planning',
                    description:
                        'Discover balanced meal ideas that fit your lifestyle and preferences.',
                    color: const Color(0xFF40916C),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Featured Food Analysis Action (card style matching Home quick-actions)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => context.go('/nutrition/ai-recognition'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFF40916C).withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                      border: Border.all(color: const Color(0xFF40916C).withOpacity(0.06)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                const Color(0xFF40916C).withOpacity(0.15),
                                const Color(0xFF40916C).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF40916C),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Analyze Food with AI',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF121714),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Snap a photo and get nutrition & sustainability analysis',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF121714),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF121714),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _QuickAction(
                          title: 'Food Analysis',
                          icon: Icons.camera_alt,
                          color: const Color(0xFF40916C),
                          onTap: () => context.go('/nutrition/ai-recognition'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          title: 'Meal Plans',
                          icon: Icons.restaurant_menu,
                          color: const Color(0xFF40916C),
                          onTap: () => context.go('/nutrition/ai-meal-plan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _QuickAction(
              title: 'Sustainable Brands',
              icon: Icons.eco,
              color: const Color(0xFF40916C),
              onTap: () =>
                context.go('/nutrition/brand-recommendations'),
            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          title: 'Food Logging',
                          icon: Icons.edit_note,
                          color: const Color(0xFF40916C),
                          onTap: () => context.go('/nutrition/food-logging'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick link to view saved meal plans
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/nutrition/saved-plans'),
                      icon: const Icon(Icons.bookmark),
                      label: const Text('View Saved Meal Plans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF94e0b2),
                        foregroundColor: const Color(0xFF121714),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/nutrition/ai-recognition'),
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

  void _showNutritionGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: <Widget>[
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.06)),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.18),
                        color.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121714),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF688273),
                  ),
                  maxLines: 1,
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

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.06)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121714),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF688273),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
            child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
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
