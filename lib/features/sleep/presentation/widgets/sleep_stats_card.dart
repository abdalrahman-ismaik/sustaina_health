import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/sleep_colors.dart';

class SleepStatsCard extends ConsumerWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isLoading;

  const SleepStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = color ?? SleepColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
      gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
        accent.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: 0.30), width: 1),
          boxShadow: <BoxShadow>[
            BoxShadow(
        color: accent.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepQualityCard extends ConsumerWidget {
  final double quality;
  final bool isLoading;

  const SleepQualityCard({
    Key? key,
    required this.quality,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color qualityColor = _getQualityColor(quality);
    final String qualityText = _getQualityText(quality);

    return SleepStatsCard(
      title: 'Sleep Quality',
      value: '${quality.toStringAsFixed(1)}/10',
      subtitle: qualityText,
      icon: Icons.bedtime,
      color: qualityColor,
      isLoading: isLoading,
    );
  }

  Color _getQualityColor(double quality) {
    if (quality >= 8.0) return SleepColors.successGreen;
    if (quality >= 6.0) return SleepColors.warningOrange;
    return SleepColors.errorRed;
  }

  String _getQualityText(double quality) {
    if (quality >= 8.0) return 'Excellent';
    if (quality >= 6.0) return 'Good';
    if (quality >= 4.0) return 'Fair';
    return 'Poor';
  }
}

class SleepDurationCard extends ConsumerWidget {
  final Duration duration;
  final bool isLoading;

  const SleepDurationCard({
    Key? key,
    required this.duration,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final String durationText = '${hours}h ${minutes}m';

    return SleepStatsCard(
      title: 'Sleep Duration',
      value: durationText,
      subtitle: _getDurationStatus(hours),
      icon: Icons.access_time,
      color: SleepColors.accentTeal,
      isLoading: isLoading,
    );
  }

  String _getDurationStatus(int hours) {
    if (hours >= 7 && hours <= 9) return 'Optimal';
    if (hours >= 6 && hours < 7) return 'Good';
    if (hours > 9) return 'Too much';
    return 'Too little';
  }
}

class SleepConsistencyCard extends ConsumerWidget {
  final double consistency;
  final bool isLoading;

  const SleepConsistencyCard({
    Key? key,
    required this.consistency,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int consistencyPercent = (consistency * 100).round();
    final Color consistencyColor = _getConsistencyColor(consistency);

    return SleepStatsCard(
      title: 'Consistency',
      value: '$consistencyPercent%',
      subtitle: _getConsistencyText(consistency),
      icon: Icons.trending_up,
      color: consistencyColor,
      isLoading: isLoading,
    );
  }

  Color _getConsistencyColor(double consistency) {
    if (consistency >= 0.8) return SleepColors.successGreen;
    if (consistency >= 0.6) return SleepColors.warningOrange;
    return SleepColors.errorRed;
  }

  String _getConsistencyText(double consistency) {
    if (consistency >= 0.8) return 'Very Consistent';
    if (consistency >= 0.6) return 'Moderate';
    return 'Inconsistent';
  }
}

class SleepSustainabilityCard extends ConsumerWidget {
  final double sustainability;
  final bool isLoading;

  const SleepSustainabilityCard({
    Key? key,
    required this.sustainability,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int sustainabilityPercent = (sustainability * 100).round();
    final Color sustainabilityColor = _getSustainabilityColor(sustainability);

    return SleepStatsCard(
      title: 'Sustainability',
      value: '$sustainabilityPercent%',
      subtitle: _getSustainabilityText(sustainability),
      icon: Icons.eco,
      color: sustainabilityColor,
      isLoading: isLoading,
    );
  }

  Color _getSustainabilityColor(double sustainability) {
    if (sustainability >= 0.7) return SleepColors.successGreen;
    if (sustainability >= 0.4) return SleepColors.warningOrange;
    return SleepColors.errorRed;
  }

  String _getSustainabilityText(double sustainability) {
    if (sustainability >= 0.7) return 'Very Eco-Friendly';
    if (sustainability >= 0.4) return 'Moderate';
    return 'Needs Improvement';
  }
}
