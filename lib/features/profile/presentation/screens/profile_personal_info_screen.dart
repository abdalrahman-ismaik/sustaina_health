import 'package:flutter/material.dart';
import 'profile_health_goals_screen.dart';

class ProfilePersonalInfoScreen extends StatefulWidget {
  const ProfilePersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfilePersonalInfoScreen> createState() => _ProfilePersonalInfoScreenState();
}

class _ProfilePersonalInfoScreenState extends State<ProfilePersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAge;
  String? _selectedGender;
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String? _height;
  String? _weight;
  String? _selectedActivity;

  final List<String> ageOptions = [
    '16-18', '19-25', '26-35', '36-45', '46-55', '56-65', '65+',
  ];
  final List<String> genderOptions = [
    'Male', 'Female', 'Other', 'Prefer not to say',
  ];
  final List<String> activityOptions = [
    'Sedentary', 'Lightly active', 'Moderately active', 'Very active',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF121714),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 48.0),
                          child: Text(
                            'About you',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF121714),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: -0.015,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedAge,
                      decoration: _inputDecoration('Age'),
                      items: ageOptions
                          .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedAge = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputDecoration('Gender'),
                      items: genderOptions
                          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _unitToggle('cm', 'ft-in', _heightUnit, (val) => setState(() => _heightUnit = val)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      decoration: _inputDecoration('Height'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _height = val,
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _unitToggle('kg', 'lbs', _weightUnit, (val) => setState(() => _weightUnit = val)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      decoration: _inputDecoration('Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _weight = val,
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedActivity,
                      decoration: _inputDecoration('Activity level'),
                      items: activityOptions
                          .map((activity) => DropdownMenuItem(value: activity, child: Text(activity)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedActivity = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileHealthGoalsScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94E0B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Color(0xFF121714),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.015,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF1F4F2),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF688273),
        fontSize: 16,
      ),
    );
  }

  Widget _unitToggle(String left, String right, String groupValue, ValueChanged<String> onChanged) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _toggleButton(left, groupValue == left, () => onChanged(left)),
          _toggleButton(right, groupValue == right, () => onChanged(right)),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF121714) : const Color(0xFF688273),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 