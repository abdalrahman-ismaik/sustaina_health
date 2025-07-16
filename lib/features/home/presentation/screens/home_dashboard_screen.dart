import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBbMPNPoDJYRmGhiSiLcBUy7iaIrueGkMwr1g-E_TMeDL2ZglWXus-L-IStzb_2xPNyGSAxIdzKXWPDheMkf2uUhXif-dHU_NNYr8BbeywOJKrcnOhZx_YjYC0ndS6x2Wipoje7o5A4EFW73AtlmwdDXpkU2n1B9QrIjcvkuJdgLQUlWwacXOF9FFSyveX3lDdJKl2cqAjofJgvIpiAfXb3Gm4YCM7uGisgQV4o7uWB9Z__tFg5CmrqCzZKeds7nD63GvPVeVaJWSqz'),
                    radius: 20,
                  ),
                  const Text(
                    'SustainaHealth',
                    style: TextStyle(
                      color: Color(0xFF111714),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: -0.015,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF111714)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Welcome back, Olivia',
                style: TextStyle(
                  color: Color(0xFF111714),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Today, July 26 · 22°C',
                style: TextStyle(
                  color: Color(0xFF648772),
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFDCE5DF)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Sustainability Score', style: TextStyle(color: Color(0xFF111714), fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),
                          Text('85', style: TextStyle(color: Color(0xFF111714), fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Quick Stats',
                style: TextStyle(
                  color: Color(0xFF111714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(title: 'Steps', value: '7,234', change: '+15%'),
                  const SizedBox(width: 8),
                  _StatCard(title: 'Water', value: '2L', change: '+10%'),
                  const SizedBox(width: 8),
                  _StatCard(title: 'Sleep', value: '8.5h', change: '+5%'),
                  const SizedBox(width: 8),
                  _StatCard(title: 'Points', value: '120', change: '+20%'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'AI Insights',
                style: TextStyle(
                  color: Color(0xFF111714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            _InsightCard(
              title: 'Personalized Recommendation',
              description: 'Try a 30-minute yoga session to improve flexibility and reduce stress.',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAN8tJnzpGuNSKc3ud4WgNYqhpIqu_ip3H_COmOKPKlfCcLPMyxh8SrcJjVp5aAsSySDKT_0nPrcH3GhOg3daTSahLZSiroKxiNsxiJtfEL9WP_ONHguYZZgbFHbZbK8FW6RA07WH58c4-sT2VifqeRIOCbH6pmW9l7IepgjYOWMLoVkNwACAoKqod3VwFvTyCZL9LpfnDM1costlueX8yUb4yKqvBRE_2KSTLDHT_0E0qW49BeVRZBZ5HOVjRvcmhc8HCLou2Evw-c',
            ),
            _InsightCard(
              title: 'Progress Highlights',
              description: "You've maintained a consistent sleep schedule for the past week. Keep it up!",
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAIuGzQreUW19QGoBqDbfYbdTaVZ-RLL08y3_MCnS525Iu_9ky3RJ03EJ5ZaOJQyQl33xhkoMvLyqBpOJ5Aghg6KHA9Lt422Am55me1A83pqgWzT-t0ItXIOi-CH5FXndonTRghYKEaOy1h9pUXy_WS8WlvWYLz9nRBb2r_Lga9s4ADnFFyut_niSVUOSqn8pj0CLNfhWOlMK6Tu8u2YtIbgX8oIpoOCMj0PWMhPUXLsCOKz7V6Tpcc8wXP5YvfK8CKzj6R9mF8_wtL',
            ),
            _InsightCard(
              title: 'Eco-Tip of the Day',
              description: 'Reduce your carbon footprint by opting for plant-based meals today.',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAoxTI4wExdaChZHR_Kqq0GiugZjr-i_tlNr_mdvMJ0C5Vp2pfqti6EAFzODY1ypeHQDlta6AyMdA2RFweDiEzLtNQjk9UML5Fyx9Uh_c_0yNbw3olecmCbOcFECWkeetvZY_dKnKBLh8NCmq27ikZQoZzeuprYUK1tM7l9HYIhkOj9ghPC8iCy-KdEzadB45rvWaHfw-_yLfzGaJzh2IRH-WhHnEuICz3pD-tPO2EKqtf1f99HbMPMQnNxFHUx8vxGeFIHddYxpzrz',
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: Color(0xFF111714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionButton(label: 'Log Meal', icon: Icons.camera_alt, onTap: () {}),
                  _QuickActionButton(label: 'Start Workout', icon: Icons.fitness_center, onTap: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionButton(label: 'Log Sleep', icon: Icons.nightlight_round, onTap: () {}),
                  _QuickActionButton(label: 'View Challenges', icon: Icons.emoji_events, onTap: () {}),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  color: Color(0xFF111714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            _ActivityFeedItem(
              icon: Icons.directions_run,
              title: 'Exercise',
              subtitle: 'Morning Run',
            ),
            _ActivityFeedItem(
              icon: Icons.restaurant,
              title: 'Nutrition',
              subtitle: 'Vegan Lunch',
            ),
            _ActivityFeedItem(
              icon: Icons.nightlight_round,
              title: 'Sleep',
              subtitle: '8 hours of sleep',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF111714),
        unselectedItemColor: const Color(0xFF648772),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  const _StatCard({required this.title, required this.value, required this.change});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF111714), fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Color(0xFF111714), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(change, style: const TextStyle(color: Color(0xFF078829), fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  const _InsightCard({required this.title, required this.description, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF111714)),
        label: Text(label, style: const TextStyle(color: Color(0xFF111714), fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF38E07B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ActivityFeedItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ActivityFeedItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F2),
              borderRadius: BorderRadius.circular(12),
            ),
            width: 48,
            height: 48,
            child: Icon(icon, color: const Color(0xFF111714)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF111714), fontSize: 16, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF648772), fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
} 