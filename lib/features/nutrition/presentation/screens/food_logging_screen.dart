import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';

class FoodLoggingScreen extends ConsumerStatefulWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends ConsumerState<FoodLoggingScreen> {
  String selectedMealType = 'breakfast';
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final foodLogState = ref.watch(foodLogProvider);
    final dailySummaryState = ref.watch(dailyNutritionSummaryProvider);

    // Listen to food log changes and refresh daily summary
    ref.listen<AsyncValue<List<FoodLogEntry>>>(foodLogProvider,
        (previous, next) {
      // When food log successfully loads with new data, refresh daily summary
      if (next.hasValue && next.value != null) {
        // Only refresh if the data actually changed
        if (previous?.value?.length != next.value!.length) {
          Future.microtask(() {
            ref.read(dailyNutritionSummaryProvider.notifier).refreshSummary();
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Food Logging',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf1f4f2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatSelectedDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text(
                      'Change Date',
                      style: TextStyle(color: Color(0xFF94e0b2)),
                    ),
                  ),
                ],
              ),
            ),

            // Daily summary
            dailySummaryState.when(
              data: (summary) => _buildDailySummary(summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => const SizedBox(),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Camera logging section
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF94e0b2).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Color(0xFF94e0b2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Log Food with Camera',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF121714),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Take a photo of your meal and let AI analyze the nutrition information automatically',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Meal type selector
                            const Text(
                              'Select meal type:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF121714),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMealTypeSelector(),
                            const SizedBox(height: 24),

                            // Camera button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push(
                                      '/nutrition/ai-recognition?mealType=$selectedMealType');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF94e0b2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF121714),
                                ),
                                label: const Text(
                                  'Start Camera Logging',
                                  style: TextStyle(
                                    color: Color(0xFF121714),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Today's food log
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        constraints: const BoxConstraints(
                            minHeight: 200, maxHeight: 400),
                        child: foodLogState.when(
                          data: (entries) => _buildFoodLogList(entries),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text(
                              'Error loading food log: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Wrap(
      spacing: 8,
      children: ['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
        final isSelected = selectedMealType == type;
        return GestureDetector(
          onTap: () => setState(() => selectedMealType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF94e0b2)
                  : const Color(0xFFf1f4f2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF94e0b2) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              type.substring(0, 1).toUpperCase() + type.substring(1),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF121714)
                    : const Color(0xFF688273),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailySummary(DailyNutritionSummary summary) {
    final calorieProgress = summary.calorieProgress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF94E0B2).withOpacity(0.8),
            const Color(0xFF94E0B2).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              color: Color(0xFF121714),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.totalNutrition.calories} / ${summary.targetCalories} cal',
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: calorieProgress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF121714)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    '${summary.meals.length}',
                    style: const TextStyle(
                      color: Color(0xFF121714),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'meals logged',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogList(List<FoodLogEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_food,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No food logged today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use the camera to log your first meal!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Today\'s Food Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121714),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildFoodLogCard(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodLogCard(FoodLogEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMealTypeColor(entry.mealType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getMealTypeIcon(entry.mealType),
                color: _getMealTypeColor(entry.mealType),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF121714),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMealTypeColor(entry.mealType)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.mealType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getMealTypeColor(entry.mealType),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.nutritionInfo.calories} cal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showFoodLogOptions(context, entry),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.blue;
      case 'dinner':
        return Colors.purple;
      case 'snack':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  void _showFoodLogOptions(BuildContext context, FoodLogEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF94e0b2)),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edit functionality coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Entry'),
              onTap: () {
                Navigator.pop(context);
                _deleteFoodLogEntry(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteFoodLogEntry(FoodLogEntry entry) {
    // Daily summary will be automatically refreshed by the listener
    ref.read(foodLogProvider.notifier).deleteFoodLogEntry(entry.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.foodName} deleted from log'),
        backgroundColor: const Color(0xFF94e0b2),
      ),
    );
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (selectedDate.year == yesterday.year &&
        selectedDate.month == yesterday.month &&
        selectedDate.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      ref.read(foodLogProvider.notifier).changeDate(picked);
      ref.read(dailyNutritionSummaryProvider.notifier).changeDate(picked);
    }
  }
}
