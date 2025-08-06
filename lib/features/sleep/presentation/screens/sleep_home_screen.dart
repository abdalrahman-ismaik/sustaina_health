import 'package:flutter/material.dart';

class SleepHomeScreen extends StatelessWidget {
  const SleepHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF121714)),
          onPressed: () {},
        ),
        title: const Text(
          'Sleep',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Last Night',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const <Widget>[
                  _SleepStatCard(title: 'Sleep Score', value: '85'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text('Duration',
                      style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
                  Text('7h 30m (Target: 8h)',
                      style: TextStyle(color: Color(0xFF121714), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Sleep Pattern
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _SleepPatternSection(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const <Widget>[
                  _SleepStatCard(
                      title: 'Sustainability Score', value: '92', border: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sleep Stages',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _SleepStagesBreakdown(),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _QuickActions(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SleepStatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool border;
  const _SleepStatCard(
      {required this.title, required this.value, this.border = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: border ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: border
              ? Border.all(color: const Color(0xFFD1E6D9), width: 1)
              : Border.all(color: const Color(0xFFD1E6D9), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF121714),
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF121714),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SleepPatternSection extends StatelessWidget {
  const _SleepPatternSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Sleep Pattern',
            style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('7h 30m',
            style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        Row(
          children: const <Widget>[
            Text('Last Night',
                style: TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
            SizedBox(width: 8),
            Text('-6%',
                style: TextStyle(
                    color: Color(0xFFfa5538),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        // Placeholder for pattern visualization
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('Pattern Visualization',
                style: TextStyle(color: Color(0xFF688273))),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const <Widget>[
            Text('10PM',
                style: TextStyle(
                    color: Color(0xFF9bbfaa),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text('12AM',
                style: TextStyle(
                    color: Color(0xFF9bbfaa),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text('2AM',
                style: TextStyle(
                    color: Color(0xFF9bbfaa),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text('4AM',
                style: TextStyle(
                    color: Color(0xFF9bbfaa),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text('6AM',
                style: TextStyle(
                    color: Color(0xFF9bbfaa),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _SleepStagesBreakdown extends StatelessWidget {
  const _SleepStagesBreakdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        _SleepStageRow(stage: 'Light Sleep', value: '4h 15m'),
        _SleepStageRow(stage: 'Deep Sleep', value: '1h 45m'),
        _SleepStageRow(stage: 'REM', value: '1h 30m'),
        _SleepStageRow(stage: 'Awake', value: '15m'),
      ],
    );
  }
}

class _SleepStageRow extends StatelessWidget {
  final String stage;
  final String value;
  const _SleepStageRow({required this.stage, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(stage,
              style: const TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
          Text(value,
              style: const TextStyle(color: Color(0xFF121714), fontSize: 14)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _QuickActionButton(
          label: 'Log Sleep Manually',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/tracking');
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          label: 'Set Bedtime Reminder',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/improvement');
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          label: 'View Sleep Tips',
          onTap: () {
            Navigator.of(context).pushNamed('/sleep/improvement');
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton({required this.label, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF94E0B2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
