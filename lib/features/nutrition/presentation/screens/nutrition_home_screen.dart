import 'package:flutter/material.dart';

class NutritionHomeScreen extends StatelessWidget {
  const NutritionHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Overview
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _OverviewCard(
                        title: 'Calories',
                        value: '1,350/2,000 kcal',
                        icon: Icons.local_fire_department,
                        color: const Color(0xFF94e0b2),
                      ),
                      _OverviewCard(
                        title: 'Macros',
                        value: 'C 150g | P 80g | F 50g',
                        icon: Icons.pie_chart,
                        color: const Color(0xFFdde4e0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _OverviewCard(
                        title: 'Water',
                        value: '1.5L',
                        icon: Icons.water_drop,
                        color: const Color(0xFFdde4e0),
                      ),
                      _OverviewCard(
                        title: 'Sustainability',
                        value: '82/100',
                        icon: Icons.eco,
                        color: const Color(0xFF94e0b2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Meal Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MealSection(meal: 'Breakfast'),
                  _MealSection(meal: 'Lunch'),
                  _MealSection(meal: 'Dinner'),
                  _MealSection(meal: 'Snacks'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // AI Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Suggestions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AISuggestionCard(
                    title: 'Meal Recommendation',
                    description: 'Try a quinoa salad with seasonal veggies for lunch!',
                  ),
                  _AISuggestionCard(
                    title: 'Sustainable Alternative',
                    description: 'Swap beef for lentils to reduce your carbon footprint.',
                  ),
                  _AISuggestionCard(
                    title: 'Seasonal Produce',
                    description: 'Strawberries, spinach, and asparagus are in season!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // For bottom nav spacing
          ],
        ),
      ),
      bottomNavigationBar: _NutritionBottomNavBar(selectedIndex: 2),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          children: [
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
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String meal;
  const _MealSection({required this.meal, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            meal,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121714),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Navigate to Food Logging
              Navigator.of(context).pushNamed('/nutrition/log');
            },
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
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final String title;
  final String description;
  const _AISuggestionCard({required this.title, required this.description, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Meal Recommendation') {
          Navigator.of(context).pushNamed('/nutrition/insights');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFf1f4f2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }
}

class _NutritionBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _NutritionBottomNavBar({required this.selectedIndex, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
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
      items: const [
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