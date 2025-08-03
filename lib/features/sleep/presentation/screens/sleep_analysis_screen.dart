import 'package:flutter/material.dart';

class SleepAnalysisScreen extends StatelessWidget {
  const SleepAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141f18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141f18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sleep Analysis',
          style: TextStyle(
            color: Colors.white,
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
              const Text(
                'Weekly Trends',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2a4133),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Sleep Trends Chart', style: TextStyle(color: Color(0xFF9bbfaa))),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  _SummaryStat(title: 'Total Hours', value: '52h'),
                  _SummaryStat(title: 'Avg. Quality', value: '8.2/10'),
                  _SummaryStat(title: 'Best Night', value: '9h'),
                  _SummaryStat(title: 'Worst Night', value: '5h'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sleep Stages Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2a4133),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Bar/Pie Chart Placeholder', style: TextStyle(color: Color(0xFF9bbfaa))),
                ),
              ),
              const SizedBox(height: 20),
              const _SleepStageBreakdown(),
              const SizedBox(height: 24),
              const Text(
                'AI Insights & Recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a4133),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Try to maintain a consistent sleep schedule. Reduce screen time before bed for better deep sleep. Consider eco-friendly bedding for improved sustainability.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sustainability Impact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a4133),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'You saved 2kWh of energy this week by using energy-efficient sleep devices and natural ventilation.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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

class _SummaryStat extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryStat({required this.title, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(title, style: const TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SleepStageBreakdown extends StatelessWidget {
  const _SleepStageBreakdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        _SleepStageRow(stage: 'Light Sleep', value: '24h'),
        _SleepStageRow(stage: 'Deep Sleep', value: '12h'),
        _SleepStageRow(stage: 'REM', value: '10h'),
        _SleepStageRow(stage: 'Awake', value: '6h'),
      ],
    );
  }
}

class _SleepStageRow extends StatelessWidget {
  final String stage;
  final String value;
  const _SleepStageRow({required this.stage, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(stage, style: const TextStyle(color: Color(0xFF9bbfaa), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

 