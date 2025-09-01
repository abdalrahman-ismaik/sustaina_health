import 'package:flutter/material.dart';
import 'profile_health_goals_screen.dart';

class ProfilePersonalInfoScreen extends StatefulWidget {
  const ProfilePersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfilePersonalInfoScreen> createState() => _ProfilePersonalInfoScreenState();
}

class _ProfilePersonalInfoScreenState extends State<ProfilePersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedAge;
  String? _selectedGender;
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String? _height;
  String? _weight;
  String? _selectedActivity;

  final List<String> ageOptions = <String>[
    '16-18', '19-25', '26-35', '36-45', '46-55', '56-65', '65+',
  ];
  final List<String> genderOptions = <String>[
    'Male', 'Female', 'Other', 'Prefer not to say',
  ];
  final List<String> activityOptions = <String>[
    'Sedentary', 'Lightly active', 'Moderately active', 'Very active',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: colorScheme.onSurface,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 48.0),
                          child: Text(
                            'About you',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface,
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
                          .map((String age) => DropdownMenuItem(value: age, child: Text(age)))
                          .toList(),
                      onChanged: (String? val) => setState(() => _selectedAge = val),
                      validator: (String? val) => val == null ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: _inputDecoration('Gender'),
                      items: genderOptions
                          .map((String gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (String? val) => setState(() => _selectedGender = val),
                      validator: (String? val) => val == null ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: <Widget>[
                        _unitToggle('cm', 'ft-in', _heightUnit, (String val) => setState(() => _heightUnit = val)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      decoration: _inputDecoration('Height'),
                      keyboardType: TextInputType.number,
                      onChanged: (String val) => _height = val,
                      validator: (String? val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: <Widget>[
                        _unitToggle('kg', 'lbs', _weightUnit, (String val) => setState(() => _weightUnit = val)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      decoration: _inputDecoration('Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (String val) => _weight = val,
                      validator: (String? val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedActivity,
                      decoration: _inputDecoration('Activity level'),
                      items: activityOptions
                          .map((String activity) => DropdownMenuItem(value: activity, child: Text(activity)))
                          .toList(),
                      onChanged: (String? val) => setState(() => _selectedActivity = val),
                      validator: (String? val) => val == null ? 'Required' : null,
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
                          MaterialPageRoute(builder: (BuildContext context) => const ProfileHealthGoalsScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 16,
      ),
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
      ),
    );
  }

  Widget _unitToggle(String left, String right, String groupValue, ValueChanged<String> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          _toggleButton(left, groupValue == left, () => onChanged(left)),
          _toggleButton(right, groupValue == right, () => onChanged(right)),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool selected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : <BoxShadow>[],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 