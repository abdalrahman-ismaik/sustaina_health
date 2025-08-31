import 'package:flutter/material.dart';
import 'profile_sustainability_screen.dart';

class ProfileHealthGoalsScreen extends StatefulWidget {
  const ProfileHealthGoalsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileHealthGoalsScreen> createState() =>
      _ProfileHealthGoalsScreenState();
}

class _ProfileHealthGoalsScreenState extends State<ProfileHealthGoalsScreen> {
  final List<String> allGoals = <String>[
    'Weight management',
    'Fitness improvement',
    'Better sleep quality',
    'Stress reduction',
    'Sustainable living',
  ];
  final List<String> selectedGoals = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                          color: Theme.of(context).colorScheme.onSurface,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48.0),
                            child: Text(
                              'Goals',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Text(
                        'What are your health goals?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'Select all that apply to tailor your Ghiraas experience.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: allGoals.map((String goal) {
                          return CheckboxListTile(
                            value: selectedGoals.contains(goal),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedGoals.add(goal);
                                } else {
                                  selectedGoals.remove(goal);
                                }
                              });
                            },
                            title: Text(
                              goal,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            activeColor: Theme.of(context).colorScheme.primary,
                            checkColor: Theme.of(context).colorScheme.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (selectedGoals.isNotEmpty) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Text(
                          'Prioritize your goals',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: -0.015,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Drag and drop to rank your goals in order of importance.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final String item =
                                  selectedGoals.removeAt(oldIndex);
                              selectedGoals.insert(newIndex, item);
                            });
                          },
                          children: <Widget>[
                            for (final String goal in selectedGoals)
                ListTile(
                                key: ValueKey(goal),
                                title: Text(
                                  goal,
                  style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                  ),
                                ),
                trailing: Icon(Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: selectedGoals.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const ProfileSustainabilityScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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
