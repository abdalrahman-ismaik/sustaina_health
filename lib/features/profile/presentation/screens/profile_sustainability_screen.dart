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
    return Scaffold(
      backgroundColor: Colors.white,
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
                          color: const Color(0xFF121714),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 48.0),
                            child: Text(
                              'Environmental Concerns',
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
                              style: const TextStyle(
                                color: Color(0xFF121714),
                                fontSize: 16,
                              ),
                            ),
                            activeColor: const Color(0xFF94E0B2),
                            checkColor: const Color(0xFF121714),
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Text(
                        'Commitment Level',
                        style: TextStyle(
                          color: Color(0xFF121714),
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
                              activeColor: const Color(0xFF121714),
                              inactiveColor: const Color(0xFFDDE4E0),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              commitmentLevel.round().toString(),
                              style: const TextStyle(
                                color: Color(0xFF121714),
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
                    backgroundColor: const Color(0xFF94E0B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
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
    );
  }
} 