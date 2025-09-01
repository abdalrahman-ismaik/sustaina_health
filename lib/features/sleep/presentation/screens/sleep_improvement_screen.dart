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
    final colorScheme = Theme.of(context).colorScheme;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: colorScheme.copyWith(
            primary: colorScheme.primary,
            surface: colorScheme.surface,
            onSurface: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sleep Improvement',
          style: TextStyle(
            color: colorScheme.onSurface,
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
            children: <Widget>[
              Text(
                'Personalized Tips',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              ...<Widget>[
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
              Text(
                'Bedtime Reminder',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Switch(
                    value: _reminderEnabled,
                    onChanged: (bool val) =>
                        setState(() => _reminderEnabled = val),
                    activeColor: colorScheme.primary,
                    inactiveTrackColor: colorScheme.surfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text('Enable Reminder',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16)),
                ],
              ),
              if (_reminderEnabled) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(Icons.access_time, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Bedtime: ${_bedtime.format(context)}',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: _pickTime,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Eco-Friendly Sleep Improvements',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              ...<Widget>[
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_reminderEnabled
                            ? 'Bedtime reminder set for ${_bedtime.format(context)}!'
                            : 'Sleep improvement tips saved!'),
                        backgroundColor: colorScheme.surfaceVariant,
                      ),
                    );
                  },
                  child: Text(
                    _reminderEnabled ? 'Set Reminder' : 'Save Tips',
                    style: const TextStyle(
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
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipTile({required this.icon, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
