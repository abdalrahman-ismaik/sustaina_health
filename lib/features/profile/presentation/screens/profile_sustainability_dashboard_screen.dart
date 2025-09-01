import 'package:flutter/material.dart';

class ProfileSustainabilityDashboardScreen extends StatelessWidget {
  const ProfileSustainabilityDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Impact Metrics',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            // Impact Metrics
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const <Widget>[
                  _ImpactMetricCard(
                      title: 'Carbon Footprint Saved', value: '250 kg'),
                  _ImpactMetricCard(title: 'Eco-Friendly Meals', value: '150'),
                  _ImpactMetricCard(title: 'Sustainable Workouts', value: '75'),
                  _ImpactMetricCard(title: 'Green Habits', value: '50'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Eco-Score Breakdown',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 8),
            const _EcoScoreBar(
                label: 'Exercise Sustainability',
                value: 85),
            const _EcoScoreBar(
                label: 'Food Sustainability',
                value: 90),
            const _EcoScoreBar(
                label: 'Sleep Sustainability',
                value: 75),
            const _EcoScoreBar(
                label: 'Overall Eco-Impact',
                value: 80),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Recommendations',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 8),
            const _RecommendationTile(
                icon: Icons.eco,
                text: 'Reduce meat consumption'),
            const _RecommendationTile(
                icon: Icons.location_on,
                text: 'Choose local produce'),
            const _RecommendationTile(
                icon: Icons.directions_bike,
                text: 'Walk or bike more'),
            const _RecommendationTile(
                icon: Icons.recycling,
                text: 'Use eco-friendly products'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Seasonal Sustainability Tips',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 8),
            const _RecommendationTile(
                icon: Icons.wb_sunny,
                text: 'Summer: Conserve water'),
            const _RecommendationTile(
                icon: Icons.ac_unit,
                text: 'Winter: Reduce energy use'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Community Challenges',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 8),
            const _RecommendationTile(
                icon: Icons.group,
                text: 'Join a local cleanup'),
            const _RecommendationTile(
                icon: Icons.park,
                text: 'Participate in a tree planting event'),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ImpactMetricCard extends StatelessWidget {
  final String title;
  final String value;
  const _ImpactMetricCard({required this.title, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EcoScoreBar extends StatelessWidget {
  final String label;
  final int value;
  
  const _EcoScoreBar({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label,
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              Text('$value/100',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * value / 100 - 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _RecommendationTile({
    required this.icon,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
