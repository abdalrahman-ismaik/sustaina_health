import 'package:flutter/material.dart';

class ProfileSustainabilityDashboardScreen extends StatelessWidget {
  const ProfileSustainabilityDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF141f18) : const Color(0xFFF8FBFA);
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    final Color accentColor = isDark ? const Color(0xFF94e0b2) : const Color(0xFF51946c);
    final Color barBg = isDark ? const Color(0xFF3c5d49) : const Color(0xFFD1E6D9);
    final Color barFg = isDark ? const Color(0xFF94e0b2) : const Color(0xFF38e07b);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Impact Metrics',
          style: TextStyle(
            color: textColor,
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
                  _ImpactMetricCard(title: 'Carbon Footprint Saved', value: '250 kg'),
                  _ImpactMetricCard(title: 'Eco-Friendly Meals', value: '150'),
                  _ImpactMetricCard(title: 'Sustainable Workouts', value: '75'),
                  _ImpactMetricCard(title: 'Green Habits', value: '50'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Eco-Score Breakdown', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            _EcoScoreBar(label: 'Exercise Sustainability', value: 85, barBg: barBg, barFg: barFg, textColor: textColor),
            _EcoScoreBar(label: 'Food Sustainability', value: 90, barBg: barBg, barFg: barFg, textColor: textColor),
            _EcoScoreBar(label: 'Sleep Sustainability', value: 75, barBg: barBg, barFg: barFg, textColor: textColor),
            _EcoScoreBar(label: 'Overall Eco-Impact', value: 80, barBg: barBg, barFg: barFg, textColor: textColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Recommendations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            _RecommendationTile(icon: Icons.eco, text: 'Reduce meat consumption', textColor: textColor, bgColor: cardColor),
            _RecommendationTile(icon: Icons.location_on, text: 'Choose local produce', textColor: textColor, bgColor: cardColor),
            _RecommendationTile(icon: Icons.directions_bike, text: 'Walk or bike more', textColor: textColor, bgColor: cardColor),
            _RecommendationTile(icon: Icons.recycling, text: 'Use eco-friendly products', textColor: textColor, bgColor: cardColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Seasonal Sustainability Tips', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            _RecommendationTile(icon: Icons.wb_sunny, text: 'Summer: Conserve water', textColor: textColor, bgColor: cardColor),
            _RecommendationTile(icon: Icons.ac_unit, text: 'Winter: Reduce energy use', textColor: textColor, bgColor: cardColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Community Challenges', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            _RecommendationTile(icon: Icons.group, text: 'Join a local cleanup', textColor: textColor, bgColor: cardColor),
            _RecommendationTile(icon: Icons.park, text: 'Participate in a tree planting event', textColor: textColor, bgColor: cardColor),
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
  const _ImpactMetricCard({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EcoScoreBar extends StatelessWidget {
  final String label;
  final int value;
  final Color barBg;
  final Color barFg;
  final Color textColor;
  const _EcoScoreBar({required this.label, required this.value, required this.barBg, required this.barFg, required this.textColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('$value/100', style: TextStyle(color: textColor, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: barBg,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * value / 100 - 32,
                decoration: BoxDecoration(
                  color: barFg,
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
  final Color textColor;
  final Color bgColor;
  const _RecommendationTile({required this.icon, required this.text, required this.textColor, required this.bgColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: textColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

 