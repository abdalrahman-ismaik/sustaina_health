import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sleep_providers.dart';
import '../theme/sleep_colors.dart';
import '../../data/models/sleep_models.dart';

class SleepHomeScreen extends ConsumerWidget {
  const SleepHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SleepSession?> latestSessionAsync = ref.watch(latestSleepSessionProvider);
    final AsyncValue<SleepStats> sleepStatsAsync = ref.watch(sleepStatsProvider);
    final AsyncValue<List<SleepSession>> sleepSessionsAsync = ref.watch(sleepSessionsProvider);

    return Scaffold(
      backgroundColor: SleepColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Sleep',
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SleepColors.surfaceGrey,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline, color: SleepColors.primaryGreen),
            onPressed: () => _showSleepGuide(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(sleepSessionsProvider.notifier).loadSleepSessions();
          ref.read(sleepStatsProvider.notifier).refreshStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Welcome Card
                _buildWelcomeCard(context),
                const SizedBox(height: 24),

                // Quick Start Button
                _buildQuickStartButton(context),
                const SizedBox(height: 24),

                // Sleep Time Graph
                _buildSleepTimeGraph(context, ref, sleepSessionsAsync),
                const SizedBox(height: 24),

                // Latest Sleep Session
                _buildLatestSleepCard(context, ref, latestSessionAsync),
                const SizedBox(height: 24),

                // Basic Stats
                _buildBasicStats(context, ref, sleepStatsAsync),
                const SizedBox(height: 24),

                // Sleep Advice Section (moved to end)
                _buildSleepAdviceSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sleep/tracking'),
        backgroundColor: SleepColors.primaryGreen,
        icon: const Icon(Icons.bedtime, color: Colors.white),
        label: const Text(
          'Track Sleep',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            SleepColors.primaryGreen,
            SleepColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SleepColors.primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your sleep to improve your rest and well-being',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/sleep/tracking'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SleepColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bedtime,
                    color: SleepColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Start Sleep Tracking',
                        style: TextStyle(
                          color: SleepColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Begin tracking your sleep session',
                        style: TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: SleepColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleepAdviceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Advice',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdviceItem(
            '🌙 Maintain a consistent sleep schedule',
            'Go to bed and wake up at the same time every day, even on weekends.',
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            '📱 Avoid screens 1 hour before bedtime',
            'Blue light from devices can interfere with your natural sleep cycle.',
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            '🌡️ Keep your bedroom cool and dark',
            'A temperature of 18-20°C (65-68°F) is ideal for sleep.',
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: SleepColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepTimeGraph(BuildContext context, WidgetRef ref, AsyncValue<List<SleepSession>> sessionsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.show_chart,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Time Trend',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          sessionsAsync.when(
            data: (List<SleepSession> sessions) {
              if (sessions.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: SleepColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: SleepColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sleep data yet',
                          style: TextStyle(
                            color: SleepColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking to see your sleep trends',
                          style: TextStyle(
                            color: SleepColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Get last 7 days of sleep data
              final List<double> last7Days = _getLast7DaysData(sessions);
              return SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value >= 0 && value < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  color: SleepColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              '${value.toInt()}h',
                              style: TextStyle(
                                color: SleepColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: last7Days.asMap().entries.map((MapEntry<int, double> entry) {
                      final int index = entry.key;
                      final double hours = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: hours,
                            color: hours >= 7 ? SleepColors.primaryGreen : SleepColors.warningOrange,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 2,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (double value) {
                        return FlLine(
                          color: SleepColors.textTertiary.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            loading: () => Container(
              height: 200,
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryGreen),
                ),
              ),
            ),
            error: (Object error, StackTrace stack) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: SleepColors.errorRed,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load sleep data',
                      style: TextStyle(
                        color: SleepColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getLast7DaysData(List<SleepSession> sessions) {
    final DateTime now = DateTime.now();
    final List<double> last7Days = List.filled(7, 0.0);
    
    for (int i = 0; i < 7; i++) {
      final DateTime date = now.subtract(Duration(days: i));
      final List<SleepSession> daySessions = sessions.where((SleepSession session) {
        final DateTime sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        final DateTime targetDate = DateTime(date.year, date.month, date.day);
        return sessionDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      if (daySessions.isNotEmpty) {
        final double totalHours = daySessions.fold<double>(
          0.0,
          (double sum, SleepSession session) => sum + session.totalDuration.inMinutes / 60.0,
        );
        last7Days[6 - i] = totalHours;
      }
    }
    
    return last7Days;
  }

  Widget _buildLatestSleepCard(BuildContext context, WidgetRef ref, AsyncValue<SleepSession?> latestSessionAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.bedtime,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Latest Sleep',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          latestSessionAsync.when(
            data: (SleepSession? session) {
              if (session == null) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: SleepColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.bedtime_outlined,
                        size: 48,
                        color: SleepColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sleep sessions yet',
                        style: TextStyle(
                          color: SleepColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking to see your sleep data here',
                        style: TextStyle(
                          color: SleepColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SleepColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SleepColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Last Night',
                          style: TextStyle(
                            color: SleepColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: SleepColors.getSleepQualityColor(session.sleepQuality).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${session.sleepQuality.toStringAsFixed(1)}/10',
                            style: TextStyle(
                              color: SleepColors.getSleepQualityColor(session.sleepQuality),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildSessionDetail(
                            'Duration',
                            '${session.totalDuration.inHours}h ${session.totalDuration.inMinutes % 60}m',
                            Icons.access_time,
                          ),
                        ),
                        Expanded(
                          child: _buildSessionDetail(
                            'Mood',
                            session.mood,
                            Icons.mood,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryGreen),
                ),
              ),
            ),
            error: (Object error, StackTrace stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: SleepColors.errorRed,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load sleep data',
                    style: TextStyle(
                      color: SleepColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              color: SleepColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicStats(BuildContext context, WidgetRef ref, AsyncValue<SleepStats> statsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.analytics_outlined,
                color: SleepColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sleep Overview',
                style: TextStyle(
                  color: SleepColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (SleepStats stats) => Row(
              children: <Widget>[
                Expanded(
                  child: _buildStatCard(
                    'Average Quality',
                    '${stats.averageQuality.toStringAsFixed(1)}/10',
                    Icons.star,
                    SleepColors.getSleepQualityColor(stats.averageQuality),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Average Duration',
                    '${stats.averageDuration.inHours}h ${stats.averageDuration.inMinutes % 60}m',
                    Icons.access_time,
                    SleepColors.getSleepDurationColor(stats.averageDuration),
                  ),
                ),
              ],
            ),
            loading: () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SleepColors.primaryGreen),
                ),
              ),
            ),
            error: (Object error, StackTrace stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: SleepColors.errorRed,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load stats',
                    style: TextStyle(
                      color: SleepColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: SleepColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSleepGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Sleep Tracking Guide',
          style: TextStyle(color: SleepColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'How to use the sleep module:',
              style: TextStyle(
                color: SleepColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildGuideItem('1. Tap "Track Sleep" to start a new sleep session'),
            _buildGuideItem('2. Set your bedtime and wake time'),
            _buildGuideItem('3. Rate your sleep quality and mood'),
            _buildGuideItem('4. View your sleep statistics and trends'),
            _buildGuideItem('5. Set goals to improve your sleep habits'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: SleepColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: SleepColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
