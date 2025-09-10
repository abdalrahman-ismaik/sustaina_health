import 'package:flutter/material.dart';
import '../../data/services/carbon_footprint_service.dart';
import '../../../exercise/data/services/hybrid_exercise_service.dart';
import '../../../exercise/data/models/workout_models.dart';
import 'dart:math' as math;

class ProfileSustainabilityDashboardScreen extends StatefulWidget {
  const ProfileSustainabilityDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSustainabilityDashboardScreen> createState() => _ProfileSustainabilityDashboardScreenState();
}

class _ProfileSustainabilityDashboardScreenState extends State<ProfileSustainabilityDashboardScreen> {
  final CarbonFootprintService _carbonService = CarbonFootprintService();
  final HybridExerciseService _exerciseService = HybridExerciseService();
  
  CarbonFootprintData? _carbonData;
  List<ActiveWorkoutSession>? _workouts;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load real carbon footprint data
      final CarbonFootprintData carbonData = await _carbonService.calculateTotalCarbonSaved();
      
      // Load real workout data
      final List<ActiveWorkoutSession> workouts = await _exerciseService.getCompletedWorkouts();
      
      if (mounted) {
        setState(() {
          _carbonData = carbonData;
          _workouts = workouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading sustainability data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

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
          'Impact Metrics',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _loadRealData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRealData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              
              if (_isLoading) 
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRealData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...<Widget>[
                // Real Impact Metrics
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _ImpactMetricCard(
                        title: 'Carbon Footprint Saved', 
                        value: '${_carbonData?.formattedTotal ?? '0.0'} kg',
                        subtitle: 'Based on your activities',
                      ),
                      _ImpactMetricCard(
                        title: 'Sustainable Workouts', 
                        value: _getSustainableWorkoutCount().toString(),
                        subtitle: 'Home & outdoor activities',
                      ),
                      _ImpactMetricCard(
                        title: 'Active Days', 
                        value: _getActiveDaysCount().toString(),
                        subtitle: 'Last 30 days',
                      ),
                      _ImpactMetricCard(
                        title: 'Green Habits', 
                        value: _getGreenHabitsCount().toString(),
                        subtitle: 'Tracked behaviors',
                      ),
                    ],
                  ),
                ),
                
                // Carbon Breakdown
                if (_carbonData != null) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Carbon Savings Breakdown',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RealEcoScoreBar(
                    label: 'Workout Activities',
                    value: _carbonData!.workoutContribution,
                    maxValue: _getMaxCarbonValue(),
                    unit: 'kg CO₂',
                  ),
                  _RealEcoScoreBar(
                    label: 'Food Choices',
                    value: _carbonData!.foodContribution,
                    maxValue: _getMaxCarbonValue(),
                    unit: 'kg CO₂',
                  ),
                  _RealEcoScoreBar(
                    label: 'Energy Efficiency',
                    value: _carbonData!.sleepContribution,
                    maxValue: _getMaxCarbonValue(),
                    unit: 'kg CO₂',
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Real Examples Section
                if (_carbonData?.specificExamples.isNotEmpty ?? false) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Your Specific Impact',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._carbonData!.specificExamples.take(6).map((String example) =>
                    _ExampleTile(
                      icon: _getIconForExample(example),
                      text: example,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Personalized Recommendations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Recommendations for You',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._getPersonalizedRecommendations().map((Map<String, dynamic> rec) =>
                  _RecommendationTile(
                    icon: rec['icon'] as IconData,
                    text: rec['text'] as String,
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Get count of sustainable workouts (home/outdoor)
  int _getSustainableWorkoutCount() {
    if (_workouts == null) return 0;
    
    return _workouts!.where((ActiveWorkoutSession workout) {
      final String workoutName = workout.workoutName.toLowerCase();
      final List<String> sustainableKeywords = [
        'home', 'outdoor', 'bodyweight', 'park', 'running', 'walking', 
        'cycling', 'yoga', 'hiking', 'nature'
      ];
      
      return sustainableKeywords.any((String keyword) => workoutName.contains(keyword));
    }).length;
  }

  /// Get count of active days in last 30 days
  int _getActiveDaysCount() {
    if (_workouts == null) return 0;
    
    final DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final Set<String> activeDays = <String>{};
    
    for (final ActiveWorkoutSession workout in _workouts!) {
      if (workout.endTime != null && workout.endTime!.isAfter(thirtyDaysAgo)) {
        final String dayKey = '${workout.endTime!.year}-${workout.endTime!.month}-${workout.endTime!.day}';
        activeDays.add(dayKey);
      }
    }
    
    return activeDays.length;
  }

  /// Get count of green habits (based on user engagement)
  int _getGreenHabitsCount() {
    int count = 0;
    
    // Count based on data availability and user behaviors
    if (_workouts != null && _workouts!.isNotEmpty) count++; // Exercise tracking
    if (_carbonData != null && _carbonData!.totalKgCO2Saved > 0) count++; // Carbon awareness
    if (_getSustainableWorkoutCount() > 0) count++; // Sustainable workouts
    if (_getActiveDaysCount() >= 7) count++; // Regular activity
    if ((_carbonData?.foodContribution ?? 0) > 0) count++; // Food consciousness
    if ((_carbonData?.sleepContribution ?? 0) > 0) count++; // Energy efficiency
    
    return count;
  }

  /// Get maximum carbon value for scaling bars
  double _getMaxCarbonValue() {
    if (_carbonData == null) return 1.0;
    
    final List<double> values = <double>[
      _carbonData!.workoutContribution,
      _carbonData!.foodContribution,
      _carbonData!.sleepContribution,
    ];
    
    final double maxValue = values.reduce(math.max);
    return maxValue > 0 ? maxValue : 1.0; // Avoid division by zero
  }

  /// Get appropriate icon for example text
  IconData _getIconForExample(String example) {
    final String lower = example.toLowerCase();
    if (lower.contains('workout') || lower.contains('exercise')) return Icons.fitness_center;
    if (lower.contains('transport') || lower.contains('walking') || lower.contains('cycling')) return Icons.directions_walk;
    if (lower.contains('food') || lower.contains('meal')) return Icons.restaurant;
    if (lower.contains('energy') || lower.contains('sleep')) return Icons.bedtime;
    return Icons.eco;
  }

  /// Get personalized recommendations based on user data
  List<Map<String, dynamic>> _getPersonalizedRecommendations() {
    final List<Map<String, dynamic>> recommendations = <Map<String, dynamic>>[];
    
    // Analyze user data to provide relevant recommendations
    final int workoutCount = _workouts?.length ?? 0;
    final int sustainableWorkouts = _getSustainableWorkoutCount();
    final double carbonSaved = _carbonData?.totalKgCO2Saved ?? 0;
    
    if (workoutCount > 0 && sustainableWorkouts < workoutCount / 2) {
      recommendations.add(<String, dynamic>{
        'icon': Icons.home,
        'text': 'Try more home workouts to reduce gym transportation emissions',
      });
    }
    
    if ((_carbonData?.foodContribution ?? 0) < 5.0) {
      recommendations.add(<String, dynamic>{
        'icon': Icons.eco,
        'text': 'Choose more plant-based meals to reduce food carbon footprint',
      });
    }
    
    if (carbonSaved < 10.0) {
      recommendations.add(<String, dynamic>{
        'icon': Icons.track_changes,
        'text': 'Keep tracking activities to see your environmental impact grow',
      });
    }
    
    // Always include some general tips
    recommendations.addAll(<Map<String, dynamic>>[
      <String, dynamic>{
        'icon': Icons.location_on,
        'text': 'Choose local, seasonal produce when possible',
      },
      <String, dynamic>{
        'icon': Icons.recycling,
        'text': 'Use reusable water bottles and containers',
      },
    ]);
    
    return recommendations.take(4).toList(); // Limit to 4 recommendations
  }
}

class _ImpactMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  
  const _ImpactMetricCard({
    required this.title, 
    required this.value, 
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant, 
              fontSize: 14, 
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7), 
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealEcoScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  
  const _RealEcoScoreBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.unit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double percentage = maxValue > 0 ? (value / maxValue) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant, 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 8,
                width: (MediaQuery.of(context).size.width - 32) * math.max(0.0, math.min(1.0, percentage)),
                decoration: BoxDecoration(
                  color: _getColorForValue(percentage, colorScheme),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getColorForValue(double percentage, ColorScheme colorScheme) {
    if (percentage > 0.7) return Colors.green;
    if (percentage > 0.4) return Colors.orange;
    if (percentage > 0.1) return colorScheme.primary;
    return colorScheme.outline;
  }
}

class _ExampleTile extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _ExampleTile({
    required this.icon,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _RecommendationTile({
    required this.icon,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
