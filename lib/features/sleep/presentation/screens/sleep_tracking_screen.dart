import 'package:flutter/material.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({Key? key}) : super(key: key);

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  bool autoTracking = false;
  double sleepQuality = 5;
  String mood = 'Good';
  double roomTemp = 70;
  String noise = 'Low';
  String light = 'Dark';
  double screenTime = 1;
  bool naturalLight = false;
  bool ecoFriendly = false;
  bool energyEfficient = false;

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
          'Sleep Input',
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
                'How did you sleep?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              _InputOptionTile(
                icon: Icons.nightlight_round,
                title: 'Automatic Tracking',
                subtitle: 'Track your sleep automatically',
                trailing: Switch(
                  value: autoTracking,
                  onChanged: (val) => setState(() => autoTracking = val),
                  activeColor: const Color(0xFF94e0b2),
                  inactiveTrackColor: const Color(0xFF2a4133),
                ),
              ),
              _InputOptionTile(
                icon: Icons.access_time,
                title: 'Manual Time Entry',
                subtitle: 'Enter your sleep time manually',
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {},
              ),
              const SizedBox(height: 20),
              const Text(
                'Rate your sleep quality',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sleep Quality (1-10)', style: TextStyle(color: Colors.white)),
                  Text(sleepQuality.round().toString(), style: const TextStyle(color: Colors.white)),
                ],
              ),
              Slider(
                value: sleepQuality,
                min: 1,
                max: 10,
                divisions: 9,
                label: sleepQuality.round().toString(),
                activeColor: const Color(0xFF94e0b2),
                inactiveColor: const Color(0xFF3c5d49),
                onChanged: (val) => setState(() => sleepQuality = val),
              ),
              const SizedBox(height: 20),
              const Text(
                'How do you feel?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in ['Great', 'Good', 'Okay', 'Not Great', 'Poor'])
                    ChoiceChip(
                      label: Text(m),
                      selected: mood == m,
                      onSelected: (_) => setState(() => mood = m),
                      selectedColor: const Color(0xFF94e0b2),
                      backgroundColor: const Color(0xFF2a4133),
                      labelStyle: TextStyle(color: mood == m ? const Color(0xFF141f18) : Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Environmental Factors',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              _EnvFactorTile(
                icon: Icons.thermostat,
                title: 'Room Temperature',
                value: '${roomTemp.round()}°F',
                child: Slider(
                  value: roomTemp,
                  min: 60,
                  max: 80,
                  divisions: 20,
                  label: roomTemp.round().toString(),
                  activeColor: const Color(0xFF94e0b2),
                  inactiveColor: const Color(0xFF3c5d49),
                  onChanged: (val) => setState(() => roomTemp = val),
                ),
              ),
              _EnvFactorTile(
                icon: Icons.volume_up,
                title: 'Noise Level',
                value: noise,
                child: DropdownButton<String>(
                  value: noise,
                  dropdownColor: const Color(0xFF2a4133),
                  style: const TextStyle(color: Colors.white),
                  items: ['Low', 'Medium', 'High']
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (val) => setState(() => noise = val ?? 'Low'),
                ),
              ),
              _EnvFactorTile(
                icon: Icons.wb_sunny,
                title: 'Light Exposure',
                value: light,
                child: DropdownButton<String>(
                  value: light,
                  dropdownColor: const Color(0xFF2a4133),
                  style: const TextStyle(color: Colors.white),
                  items: ['Dark', 'Dim', 'Bright']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) => setState(() => light = val ?? 'Dark'),
                ),
              ),
              _EnvFactorTile(
                icon: Icons.monitor,
                title: 'Screen Time',
                value: '${screenTime.round()} hour${screenTime == 1 ? '' : 's'}',
                child: Slider(
                  value: screenTime,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: screenTime.round().toString(),
                  activeColor: const Color(0xFF94e0b2),
                  inactiveColor: const Color(0xFF3c5d49),
                  onChanged: (val) => setState(() => screenTime = val),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sustainability Factors',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              _SustainabilityTile(
                icon: Icons.wb_sunny,
                title: 'Natural Light Exposure',
                value: naturalLight,
                onChanged: (val) => setState(() => naturalLight = val ?? false),
              ),
              _SustainabilityTile(
                icon: Icons.eco,
                title: 'Eco-Friendly Sleep Environment',
                value: ecoFriendly,
                onChanged: (val) => setState(() => ecoFriendly = val ?? false),
              ),
              _SustainabilityTile(
                icon: Icons.lightbulb,
                title: 'Energy-Efficient Practices',
                value: energyEfficient,
                onChanged: (val) => setState(() => energyEfficient = val ?? false),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94e0b2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sleep data saved!')),
                    );
                  },
                  child: const Text(
                    'Save Sleep Data',
                    style: TextStyle(
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

class _InputOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  const _InputOptionTile({required this.icon, required this.title, required this.subtitle, required this.trailing, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2a4133),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF9bbfaa))),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }
}

class _EnvFactorTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget child;
  const _EnvFactorTile({required this.icon, required this.title, required this.value, required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2a4133),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(value, style: const TextStyle(color: Colors.white)),
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 56.0, right: 8.0, bottom: 8.0),
          child: child,
        ),
      ],
    );
  }
}

class _SustainabilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _SustainabilityTile({required this.icon, required this.title, required this.value, required this.onChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2a4133),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF94e0b2),
        checkColor: const Color(0xFF141f18),
        side: const BorderSide(color: Color(0xFF3c5d49)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
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