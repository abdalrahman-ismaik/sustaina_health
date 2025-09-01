import 'package:flutter/material.dart';

class ProfileSustainabilityScreen extends StatefulWidget {
  const ProfileSustainabilityScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSustainabilityScreen> createState() => _ProfileSustainabilityScreenState();
}

class _ProfileSustainabilityScreenState extends State<ProfileSustainabilityScreen> {
  final List<String> concerns = <String>[
    'Carbon footprint reduction',
    'Sustainable food choices',
    'Eco-friendly transportation',
    'Waste reduction',
  ];
  final Set<String> selectedConcerns = <String>{};
  double commitmentLevel = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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
                              'Environmental Concerns',
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
                      child: Column(
                        children: concerns.map((String concern) {
                          return CheckboxListTile(
                            value: selectedConcerns.contains(concern),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedConcerns.add(concern);
                                } else {
                                  selectedConcerns.remove(concern);
                                }
                              });
                            },
                            title: Text(
                              concern,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            activeColor: colorScheme.primary,
                            checkColor: colorScheme.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Text(
                        'Commitment Level',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Slider(
                              value: commitmentLevel,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: commitmentLevel.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  commitmentLevel = value;
                                });
                              },
                              activeColor: colorScheme.primary,
                              inactiveColor: colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              commitmentLevel.round().toString(),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save and finish profile setup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 2,
                    shadowColor: colorScheme.shadow.withOpacity(0.2),
                  ),
                  child: Text(
                    'Save',
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
    );
  }
} 