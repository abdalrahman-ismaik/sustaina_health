import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/sleep_colors.dart';
import '../../data/models/sleep_models.dart';

class SleepInsightCard extends ConsumerWidget {
  final SleepInsight insight;
  final VoidCallback? onTap;

  const SleepInsightCard({
    Key? key,
    required this.insight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: SleepColors.backgroundMedium,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getInsightColor(insight.type).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getInsightColor(insight.type).withOpacity(0.1),
                    _getInsightColor(insight.type).withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getInsightColor(insight.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getInsightIcon(insight.type),
                      color: _getInsightColor(insight.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getInsightColor(insight.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(insight.impact * 100).round()}%',
                      style: TextStyle(
                        color: _getInsightColor(insight.type),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...insight.recommendations.map((recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getInsightColor(insight.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getInsightColor(SleepInsightType type) {
    switch (type) {
      case SleepInsightType.quality:
        return SleepColors.accentPurple;
      case SleepInsightType.duration:
        return SleepColors.accentTeal;
      case SleepInsightType.consistency:
        return SleepColors.warningOrange;
      case SleepInsightType.environment:
        return SleepColors.primaryIndigo;
      case SleepInsightType.sustainability:
        return SleepColors.successGreen;
      case SleepInsightType.lifestyle:
        return SleepColors.primaryBlue;
    }
  }

  IconData _getInsightIcon(SleepInsightType type) {
    switch (type) {
      case SleepInsightType.quality:
        return Icons.bedtime;
      case SleepInsightType.duration:
        return Icons.access_time;
      case SleepInsightType.consistency:
        return Icons.trending_up;
      case SleepInsightType.environment:
        return Icons.home;
      case SleepInsightType.sustainability:
        return Icons.eco;
      case SleepInsightType.lifestyle:
        return Icons.fitness_center;
    }
  }
}

class SleepInsightList extends ConsumerWidget {
  final List<SleepInsight> insights;
  final bool isLoading;
  final VoidCallback? onInsightTap;

  const SleepInsightList({
    Key? key,
    required this.insights,
    this.isLoading = false,
    this.onInsightTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryBlue),
        ),
      );
    }

    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No insights available yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your sleep to get personalized insights',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        return SleepInsightCard(
          insight: insights[index],
          onTap: onInsightTap,
        );
      },
    );
  }
}

class SleepInsightSummary extends ConsumerWidget {
  final List<SleepInsight> insights;
  final bool isLoading;

  const SleepInsightSummary({
    Key? key,
    required this.insights,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: SleepColors.backgroundMedium,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryBlue),
          ),
        ),
      );
    }

    if (insights.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: SleepColors.backgroundMedium,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No insights available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final highImpactInsights = insights.where((i) => i.impact >= 0.7).toList();
    final totalImpact = insights.fold<double>(0, (sum, i) => sum + i.impact);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SleepColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: SleepColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sleep Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SleepColors.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${insights.length}',
                  style: TextStyle(
                    color: SleepColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${highImpactInsights.length} high-impact insights available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalImpact / (insights.length * 10),
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            'Average impact: ${(totalImpact / insights.length * 100).round()}%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
