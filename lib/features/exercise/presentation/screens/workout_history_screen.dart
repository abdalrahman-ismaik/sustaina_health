import 'package:flutter/material.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _selectedTab = 'Month';
  final List<Map<String, dynamic>> _workoutEntries = [
    {
      'date': 'July 29, 2024',
      'duration': '30 min',
      'ecoScore': 95,
    },
    {
      'date': 'July 28, 2024',
      'duration': '45 min',
      'ecoScore': 88,
    },
    {
      'date': 'July 27, 2024',
      'duration': '60 min',
      'ecoScore': 92,
    },
    {
      'date': 'July 26, 2024',
      'duration': '40 min',
      'ecoScore': 90,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF121714)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 48.0),
                      child: Text(
                        'Exercise',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Month',
                    selected: _selectedTab == 'Month',
                    onTap: () => setState(() => _selectedTab = 'Month'),
                  ),
                  _TabButton(
                    label: 'Week',
                    selected: _selectedTab == 'Week',
                    onTap: () => setState(() => _selectedTab = 'Week'),
                  ),
                ],
              ),
            ),
            // Calendar View (mocked)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: const Color(0xFFF1F4F2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Color(0xFF121714)),
                            onPressed: () {},
                          ),
                          const Text(
                            'July 2024',
                            style: TextStyle(
                              color: Color(0xFF121714),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Color(0xFF121714)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _CalendarGrid(),
                    ],
                  ),
                ),
              ),
            ),
            // Statistics
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Statistics',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _StatCard(title: 'Workouts Completed', value: '25'),
                  _StatCard(title: 'Favorite Workout', value: 'Yoga'),
                  _StatCard(title: 'Avg. Duration', value: '45 min'),
                  _StatCard(title: 'Sustainability Impact', value: '15 kg CO2 saved'),
                ],
              ),
            ),
            // Workout Entries
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Workout Entries',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            ..._workoutEntries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: Color(0xFF121714)),
                      title: Text(
                        entry['date'],
                        style: const TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        entry['duration'],
                        style: const TextStyle(
                          color: Color(0xFF688273),
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        'Eco-Score: ${entry['ecoScore']}',
                        style: const TextStyle(
                          color: Color(0xFF121714),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF121714),
        unselectedItemColor: const Color(0xFF688273),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Exercise'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.nightlight_round), label: 'Sleep'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF121714) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF121714) : const Color(0xFF688273),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mocked calendar grid for July 2024
    final days = List.generate(31, (i) => i + 1);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _CalendarDayLabel('S'),
            _CalendarDayLabel('M'),
            _CalendarDayLabel('T'),
            _CalendarDayLabel('W'),
            _CalendarDayLabel('T'),
            _CalendarDayLabel('F'),
            _CalendarDayLabel('S'),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: days.map((day) {
            final isToday = day == 5; // Highlight 5th as example
            return Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF94E0B2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: const Color(0xFF121714),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CalendarDayLabel extends StatelessWidget {
  final String label;
  const _CalendarDayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE4E0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF121714), fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Color(0xFF121714), fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 