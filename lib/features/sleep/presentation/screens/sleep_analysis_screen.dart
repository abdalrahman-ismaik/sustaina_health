import 'package:flutter/material.dart';

class SleepAnalysisScreen extends StatelessWidget {
  const SleepAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
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
          'Sleep Analysis',
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
                'Weekly Trends',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('Sleep Trends Chart',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
              Text(
                'Sleep Stages Breakdown',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('Bar/Pie Chart Placeholder',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
              ),
              const SizedBox(height: 20),
              const _SleepStageBreakdown(),
              const SizedBox(height: 24),
              Text(
                'AI Insights & Recommendations',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Try to maintain a consistent sleep schedule. Reduce screen time before bed for better deep sleep. Consider eco-friendly bedding for improved sustainability.',
                  style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sustainability Impact',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.15),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'You saved 2kWh of energy this week by using energy-efficient sleep devices and natural ventilation.',
                  style: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 16),
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
  const _SummaryStat({required this.title, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: <Widget>[
        Text(title,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
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
  const _SleepStageRow({required this.stage, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(stage,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
          Text(value,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14)),
        ],
      ),
    );
  }
}
