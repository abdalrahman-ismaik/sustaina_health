import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';

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
          icon: const Icon(Icons.arrow_back, color: SleepColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Food Logging',
          style: TextStyle(
            color: SleepColors.textPrimary,
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
                color: SleepColors.surfaceGrey,
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
                      color: SleepColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text(
                      'Change Date',
                      style: TextStyle(color: SleepColors.primaryGreen),
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
                                color: SleepColors.primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: SleepColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Log Food with Camera',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: SleepColors.textPrimary,
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
                                color: SleepColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMealTypeSelector(),
                            const SizedBox(height: 24),

                            // Camera button
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                          '/nutrition/ai-recognition?mealType=$selectedMealType');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SleepColors.primaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: SleepColors.textPrimary,
                                    ),
                                    label: const Text(
                                      'Start Camera Logging',
                                      style: TextStyle(
                                        color: SleepColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Manual entry button
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => _ManualFoodEntrySheet(
                                          mealType: selectedMealType,
                                          onSave: (entry) {
                                            ref.read(foodLogProvider.notifier)
                                                .addFoodLogEntry(entry);
                                          },
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: SleepColors.primaryGreen,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                      minimumSize: const Size(double.infinity, 0),
                                    ),
                                    icon: const Icon(
                                      Icons.edit_note,
                                      color: SleepColors.primaryGreen,
                                    ),
                                    label: const Text(
                                      'Manual Entry',
                                      style: TextStyle(
                                        color: SleepColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
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
                  ? SleepColors.primaryGreen
                  : SleepColors.surfaceGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? SleepColors.primaryGreen : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              type.substring(0, 1).toUpperCase() + type.substring(1),
              style: TextStyle(
                color: isSelected
                    ? SleepColors.textPrimary
                    : SleepColors.textSecondary,
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
            SleepColors.primaryGreen.withOpacity(0.8),
            SleepColors.primaryGreen.withOpacity(0.6),
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
              color: SleepColors.textPrimary,
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
                        color: SleepColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: calorieProgress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          SleepColors.textPrimary),
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
                      color: SleepColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'meals logged',
                    style: TextStyle(
                      color: SleepColors.textPrimary,
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
              color: SleepColors.textPrimary,
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
                      color: SleepColors.textPrimary,
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
              leading: const Icon(Icons.edit, color: SleepColors.primaryGreen),
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
        backgroundColor: SleepColors.primaryGreen,
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

class _ManualFoodEntrySheet extends ConsumerStatefulWidget {
  final String mealType;
  final Function(FoodLogEntry) onSave;

  const _ManualFoodEntrySheet({
    Key? key,
    required this.mealType,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<_ManualFoodEntrySheet> createState() => _ManualFoodEntrySheetState();
}

class _ManualFoodEntrySheetState extends ConsumerState<_ManualFoodEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  @override
  void dispose() {
    _foodNameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final entry = FoodLogEntry(
        id: DateTime.now().toString(),
        userId: 'default', // Since we don't have auth yet
        foodName: _foodNameController.text,
        mealType: widget.mealType,
        servingSize: _servingSizeController.text,
        nutritionInfo: NutritionInfo(
          calories: int.parse(_caloriesController.text),
          protein: int.parse(_proteinController.text),
          carbohydrates: int.parse(_carbsController.text),
          fat: int.parse(_fatsController.text),
          fiber: 0, // Default values
          sugar: 0,
          sodium: 0,
        ),
        loggedAt: DateTime.now(),
      );

      widget.onSave(entry);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food logged successfully!'),
          backgroundColor: SleepColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Add ${widget.mealType.substring(0, 1).toUpperCase()}${widget.mealType.substring(1)} Item',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SleepColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Food name
                TextFormField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Serving size
                TextFormField(
                  controller: _servingSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Serving Size',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a serving size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nutrition info
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Carbs (g)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fatsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fats (g)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SleepColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Food Entry',
                      style: TextStyle(
                        color: SleepColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
