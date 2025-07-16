import 'package:flutter/material.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  String inputMethod = 'Manual';
  final _formKey = GlobalKey<FormState>();
  String foodName = '';
  String servingSize = '';
  String nutritionInfo = '';
  String sustainabilityScore = '';
  String notes = '';

  void _clearForm() {
    setState(() {
      foodName = '';
      servingSize = '';
      nutritionInfo = '';
      sustainabilityScore = '';
      notes = '';
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Log Food',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Methods
              const Text(
                'Add Food Using:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InputMethodButton(
                    label: 'Camera',
                    icon: Icons.camera_alt,
                    selected: inputMethod == 'Camera',
                    onTap: () {
                      setState(() => inputMethod = 'Camera');
                      Navigator.of(context).pushNamed('/nutrition/ai-recognition');
                    },
                  ),
                  _InputMethodButton(
                    label: 'Barcode',
                    icon: Icons.qr_code_scanner,
                    selected: inputMethod == 'Barcode',
                    onTap: () {
                      setState(() => inputMethod = 'Barcode');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Barcode scanning coming soon!')),
                      );
                    },
                  ),
                  _InputMethodButton(
                    label: 'Manual',
                    icon: Icons.edit,
                    selected: inputMethod == 'Manual',
                    onTap: () {
                      setState(() => inputMethod = 'Manual');
                    },
                  ),
                  _InputMethodButton(
                    label: 'Recent',
                    icon: Icons.history,
                    selected: inputMethod == 'Recent',
                    onTap: () {
                      setState(() => inputMethod = 'Recent');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recent foods coming soon!')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Food Details Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF121714),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => foodName = val,
                      validator: (val) => val == null || val.isEmpty ? 'Enter food name' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFf1f4f2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image, size: 32, color: Color(0xFF688273)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Serving Size',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => servingSize = val,
                            validator: (val) => val == null || val.isEmpty ? 'Enter serving size' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nutrition Info (C/P/F)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => nutritionInfo = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Sustainability Score',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => sustainabilityScore = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => notes = val,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                    if (_formKey.currentState?.validate() ?? false) {
                      // Save food log (mock)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Food logged!')),
                      );
                      _clearForm();
                    }
                  },
                  child: const Text(
                    'Save & Add Another',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _NutritionBottomNavBar(selectedIndex: 2),
    );
  }
}

class _InputMethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _InputMethodButton({required this.label, required this.icon, required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF94e0b2) : const Color(0xFFf1f4f2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF94e0b2) : const Color(0xFFdde4e0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF121714) : const Color(0xFF688273)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF121714) : const Color(0xFF688273),
                fontWeight: FontWeight.bold,
                fontSize: 12,
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