import 'package:flutter/material.dart';

class SleepHomeScreen extends StatelessWidget {
  const SleepHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141f18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141f18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sleep',
          style: TextStyle(
            color: Colors.white,
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
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Last Night',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  _SleepStatCard(title: 'Sleep Score', value: '85'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Duration', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
                  Text('7h 30m (Target: 8h)', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Sleep Pattern
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _SleepPatternSection(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  _SleepStatCard(title: 'Sustainability Score', value: '92', border: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sleep Stages',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _SleepStagesBreakdown(),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _QuickActions(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const _SleepBottomNavBar(selectedIndex: 3),
    );
  }
}

class _SleepStatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool border;
  const _SleepStatCard({required this.title, required this.value, this.border = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: border ? Colors.transparent : const Color(0xFF2a4133),
          borderRadius: BorderRadius.circular(16),
          border: border ? Border.all(color: const Color(0xFF3c5d49), width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SleepPatternSection extends StatelessWidget {
  const _SleepPatternSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sleep Pattern', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('7h 30m', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Row(
          children: const [
            Text('Last Night', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
            SizedBox(width: 8),
            Text('-6%', style: TextStyle(color: Color(0xFFfa5538), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        // Placeholder for pattern visualization
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2a4133),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('Pattern Visualization', style: TextStyle(color: Color(0xFF9bbfaa))),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('10PM', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 13, fontWeight: FontWeight.bold)),
            Text('12AM', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 13, fontWeight: FontWeight.bold)),
            Text('2AM', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 13, fontWeight: FontWeight.bold)),
            Text('4AM', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 13, fontWeight: FontWeight.bold)),
            Text('6AM', style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _SleepStagesBreakdown extends StatelessWidget {
  const _SleepStagesBreakdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SleepStageRow(stage: 'Light Sleep', value: '4h 15m'),
        _SleepStageRow(stage: 'Deep Sleep', value: '1h 45m'),
        _SleepStageRow(stage: 'REM', value: '1h 30m'),
        _SleepStageRow(stage: 'Awake', value: '15m'),
      ],
    );
  }
}

class _SleepStageRow extends StatelessWidget {
  final String stage;
  final String value;
  const _SleepStageRow({required this.stage, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stage, style: const TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionButton(
          label: 'Log Sleep Manually',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/tracking');
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          label: 'Set Bedtime Reminder',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/improvement');
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          label: 'View Sleep Tips',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/improvement');
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton({required this.label, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a4133),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SleepBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _SleepBottomNavBar({required this.selectedIndex, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1e2f25),
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
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF9bbfaa),
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