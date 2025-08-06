import 'package:flutter/material.dart';

class AIFoodRecognitionScreen extends StatefulWidget {
  const AIFoodRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<AIFoodRecognitionScreen> createState() =>
      _AIFoodRecognitionScreenState();
}

class _AIFoodRecognitionScreenState extends State<AIFoodRecognitionScreen> {
  bool hasResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Food Recognition',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: hasResult
          ? _RecognitionResult(onEdit: () => setState(() => hasResult = false))
          : _CameraView(onCapture: () => setState(() => hasResult = true)),
    );
  }
}

class _CameraView extends StatelessWidget {
  final VoidCallback onCapture;
  const _CameraView({required this.onCapture, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(24),
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFf1f4f2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(Icons.camera_alt, size: 64, color: Color(0xFF688273)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera, color: Color(0xFF121714)),
              label: const Text('Capture',
                  style: TextStyle(color: Color(0xFF121714))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94e0b2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_library, color: Color(0xFF688273)),
              label: const Text('Gallery',
                  style: TextStyle(color: Color(0xFF688273))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFdde4e0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecognitionResult extends StatelessWidget {
  final VoidCallback onEdit;
  const _RecognitionResult({required this.onEdit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFf1f4f2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.fastfood, size: 48, color: Color(0xFF688273)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recognition Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            _ResultRow(label: 'Identified Items', value: 'Apple, Banana'),
            _ResultRow(label: 'Confidence', value: '92%'),
            _ResultRow(label: 'Portion Size', value: '150g'),
            _ResultRow(label: 'Nutrition', value: 'C 20g | P 1g | F 0g'),
            _ResultRow(label: 'Sustainability', value: 'High'),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf1f4f2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Edit Foods',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/nutrition/log');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Add to Log',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF688273),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _NutritionBottomNavBar({required this.selectedIndex, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (int index) {
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
      items: const <BottomNavigationBarItem>[
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
