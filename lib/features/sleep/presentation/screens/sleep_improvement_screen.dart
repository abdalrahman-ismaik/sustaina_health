import 'package:flutter/material.dart';

class SleepImprovementScreen extends StatefulWidget {
  const SleepImprovementScreen({Key? key}) : super(key: key);

  @override
  State<SleepImprovementScreen> createState() => _SleepImprovementScreenState();
}

class _SleepImprovementScreenState extends State<SleepImprovementScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  bool _reminderEnabled = false;

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF94e0b2),
            surface: Color(0xFF2a4133),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _bedtime = picked);
    }
  }

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
          'Sleep Improvement',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalized Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              ...[
                _TipTile(
                  icon: Icons.bedtime,
                  text: 'Stick to a consistent sleep schedule.',
                ),
                _TipTile(
                  icon: Icons.phone_android,
                  text: 'Limit screen time 1 hour before bed.',
                ),
                _TipTile(
                  icon: Icons.spa,
                  text: 'Try relaxation techniques like deep breathing.',
                ),
                _TipTile(
                  icon: Icons.nature,
                  text: 'Get natural sunlight exposure during the day.',
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Bedtime Reminder',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _reminderEnabled,
                    onChanged: (val) => setState(() => _reminderEnabled = val),
                    activeColor: const Color(0xFF94e0b2),
                    inactiveTrackColor: const Color(0xFF2a4133),
                  ),
                  const SizedBox(width: 8),
                  const Text('Enable Reminder', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF94e0b2)),
                    const SizedBox(width: 8),
                    Text(
                      'Bedtime: ${_bedtime.format(context)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2a4133),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: _pickTime,
                      child: const Text('Change', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Eco-Friendly Sleep Improvements',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              ...[
                _TipTile(
                  icon: Icons.eco,
                  text: 'Use organic or bamboo bedding.',
                ),
                _TipTile(
                  icon: Icons.energy_savings_leaf,
                  text: 'Opt for energy-efficient sleep devices.',
                ),
                _TipTile(
                  icon: Icons.air,
                  text: 'Ventilate your room naturally when possible.',
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94e0b2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_reminderEnabled
                            ? 'Bedtime reminder set for ${_bedtime.format(context)}!'
                            : 'Sleep improvement tips saved!'),
                        backgroundColor: const Color(0xFF2a4133),
                      ),
                    );
                  },
                  child: Text(
                    _reminderEnabled ? 'Set Reminder' : 'Save Tips',
                    style: const TextStyle(
                      color: Color(0xFF141f18),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _SleepBottomNavBar(selectedIndex: 3),
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipTile({required this.icon, required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94e0b2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
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