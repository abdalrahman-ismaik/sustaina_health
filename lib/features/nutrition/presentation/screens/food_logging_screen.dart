import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';
import '../../domain/repositories/nutrition_repository.dart' show SavedMealPlan;
import '../../../../widgets/achievement_popup_widget.dart';
import 'nutrition_insights_screen.dart';

class FoodLoggingScreen extends ConsumerStatefulWidget {
  const FoodLoggingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends ConsumerState<FoodLoggingScreen> {
  String selectedMealType = 'breakfast';
  DateTime selectedDate = DateTime.now();

  PreferredSizeWidget _buildModernAppBar(BuildContext context, ColorScheme cs, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: cs.surface,
      automaticallyImplyLeading: false, // Remove back arrow
      title: Text(
        'Food Logging',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => const NutritionInsightsScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.analytics_outlined,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FoodLogEntry>> foodLogState =
        ref.watch(foodLogProvider);
    final AsyncValue<DailyNutritionSummary> dailySummaryState =
        ref.watch(dailyNutritionSummaryProvider);
    final AsyncValue<List<SavedMealPlan>> savedPlansState =
        ref.watch(savedMealPlansProvider);

    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to food log changes and refresh daily summary
    ref.listen<AsyncValue<List<FoodLogEntry>>>(foodLogProvider,
        (AsyncValue<List<FoodLogEntry>>? previous,
            AsyncValue<List<FoodLogEntry>> next) {
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
      backgroundColor: cs.surface,
      appBar: _buildModernAppBar(context, cs, isDark),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Date selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                  ? cs.surfaceContainer
                  : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.calendar_today,
                      color: cs.onSurface.withOpacity(0.7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatSelectedDate(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'Change Date',
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Daily summary
            dailySummaryState.when(
              data: (DailyNutritionSummary summary) =>
                  _buildDailySummary(summary, savedPlansState),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => const SizedBox(),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? cs.surfaceContainer 
                      : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Camera logging section
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cs.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Log Food with Camera',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Take a photo of your meal and let AI analyze the nutrition information automatically',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Meal type selector
                            Text(
                              'Select meal type:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMealTypeSelector(),
                            const SizedBox(height: 24),

                            // Camera button
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final bool? result = await context.push<bool>(
                                          '/nutrition/ai-recognition?mealType=$selectedMealType');
                                      
                                      // If food was logged successfully, show achievement popup
                                      if (result == true && mounted) {
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          if (mounted) {
                                            AchievementPopupWidget.showNutritionLogged(context);
                                          }
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: cs.onPrimary,
                                    ),
                                    label: Text(
                                      'Start Camera Logging',
                                      style: TextStyle(
                                        color: cs.onPrimary,
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
                                        builder: (BuildContext context) =>
                                            _ManualFoodEntrySheet(
                                          mealType: selectedMealType,
                                          onSave: (FoodLogEntry entry) {
                                            ref
                                                .read(foodLogProvider.notifier)
                                                .addFoodLogEntry(entry);
                                            // Show achievement popup
                                            AchievementPopupWidget.showNutritionLogged(context);
                                          },
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: cs.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      minimumSize:
                                          const Size(double.infinity, 0),
                                    ),
                                    icon: Icon(
                                      Icons.edit_note,
                                      color: cs.primary,
                                    ),
                                    label: Text(
                                      'Manual Entry',
                                      style: TextStyle(
                                        color: cs.primary,
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
                          data: (List<FoodLogEntry> entries) =>
                              _buildFoodLogList(entries),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (Object error, _) => Center(
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

  Widget _buildMacrosComparison(NutritionInfo logged, DailyMacros plan) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    Widget stat(String label, String left, String right, Color color) {
      return Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label,
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.85),
                    fontSize: 12),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(left,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                Text('/',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.7))),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(right,
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.85)),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.onPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          stat('Protein', '${logged.protein}g', '${plan.protein}g', Colors.red),
          const SizedBox(width: 8),
          stat('Carbs', '${logged.carbohydrates}g', '${plan.carbohydrates}g',
              Colors.blue),
          const SizedBox(width: 8),
          stat('Fat', '${logged.fat}g', '${plan.fat}g', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Wrap(
      spacing: 8,
      children:
          <String>['breakfast', 'lunch', 'dinner', 'snack'].map((String type) {
        final bool isSelected = selectedMealType == type;
        return GestureDetector(
          onTap: () => setState(() => selectedMealType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary
                  : isDark 
                    ? cs.surfaceContainer
                    : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              type.substring(0, 1).toUpperCase() + type.substring(1),
              style: TextStyle(
                color: isSelected
                    ? cs.onPrimary
                    : cs.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailySummary(DailyNutritionSummary summary,
      AsyncValue<List<SavedMealPlan>> savedPlansState) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    // Determine favorite meal plan if available
    final SavedMealPlan? favorite = savedPlansState.maybeWhen(
      data: (List<SavedMealPlan> data) {
        try {
          return data.firstWhere((SavedMealPlan p) => p.isFavorite);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    final bool hasPlan =
        favorite != null && favorite.mealPlan.dailyMealPlans.isNotEmpty;
    final int targetCalories = hasPlan
        ? favorite.mealPlan.dailyMealPlans.first.totalDailyCalories
        : summary.targetCalories;
    final DailyMacros? planMacros =
        hasPlan ? favorite.mealPlan.dailyMealPlans.first.dailyMacros : null;

    final double calorieProgress = (summary.totalNutrition.calories /
            (targetCalories == 0 ? 1 : targetCalories))
        .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            cs.primary.withOpacity(0.8),
            cs.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Today\'s Progress',
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${summary.totalNutrition.calories} / $targetCalories cal',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: calorieProgress,
                      backgroundColor: cs.onPrimary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                    ),
                    const SizedBox(height: 12),
                    if (planMacros != null)
                      _buildMacrosComparison(
                          summary.totalNutrition, planMacros),
                  ],
                ),
              ),
              // removed meals logged count per request
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogList(List<FoodLogEntry> entries) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.no_food,
                size: 64,
                color: cs.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No food logged today',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the camera to log your first meal!',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Today\'s Food Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              final FoodLogEntry entry = entries[index];
              return _buildFoodLogCard(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodLogCard(FoodLogEntry entry) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
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
                children: <Widget>[
                  Text(
                    entry.foodName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
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
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: cs.onSurface.withOpacity(0.6)),
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

  void _showEditFoodEntrySheet(BuildContext context, FoodLogEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _ManualFoodEntrySheet(
        mealType: entry.mealType,
        existingEntry: entry,
        onSave: (FoodLogEntry updatedEntry) {
          ref.read(foodLogProvider.notifier).updateFoodLogEntry(updatedEntry);
          // Show achievement popup for updating nutrition
          AchievementPopupWidget.showNutritionLogged(context);
        },
      ),
    );
  }

  void _showFoodLogOptions(BuildContext context, FoodLogEntry entry) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit, color: cs.primary),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                _showEditFoodEntrySheet(context, entry);
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    // Daily summary will be automatically refreshed by the listener
    ref.read(foodLogProvider.notifier).deleteFoodLogEntry(entry.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.foodName} deleted from log'),
        backgroundColor: cs.primary,
      ),
    );
  }

  String _formatSelectedDate() {
    final DateTime now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return 'Today';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
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
  final FoodLogEntry? existingEntry;

  const _ManualFoodEntrySheet({
    Key? key,
    required this.mealType,
    required this.onSave,
    this.existingEntry,
  }) : super(key: key);

  @override
  ConsumerState<_ManualFoodEntrySheet> createState() =>
      _ManualFoodEntrySheetState();
}

class _ManualFoodEntrySheetState extends ConsumerState<_ManualFoodEntrySheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final FoodLogEntry entry = widget.existingEntry!;
      _foodNameController.text = entry.foodName;
      _servingSizeController.text = entry.servingSize;
      _caloriesController.text = entry.nutritionInfo.calories.toString();
      _proteinController.text = entry.nutritionInfo.protein.toString();
      _carbsController.text = entry.nutritionInfo.carbohydrates.toString();
      _fatsController.text = entry.nutritionInfo.fat.toString();
    }
  }

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
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    if (_formKey.currentState?.validate() ?? false) {
      FoodLogEntry entry;
      if (widget.existingEntry != null) {
        entry = widget.existingEntry!.copyWith(
          foodName: _foodNameController.text,
          mealType: widget.mealType,
          servingSize: _servingSizeController.text,
          nutritionInfo: NutritionInfo(
            calories: int.parse(_caloriesController.text),
            protein: int.parse(_proteinController.text),
            carbohydrates: int.parse(_carbsController.text),
            fat: int.parse(_fatsController.text),
            fiber: 0, // Keeping default values
            sugar: 0,
            sodium: 0,
          ),
        );
      } else {
        entry = FoodLogEntry(
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
      }
      widget.onSave(entry);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingEntry != null
              ? 'Food entry updated!'
              : 'Food logged successfully!'),
          backgroundColor: cs.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
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
              children: <Widget>[
                // Header
                Row(
                  children: <Widget>[
                    Text(
                      '${widget.existingEntry != null ? 'Edit' : 'Add'} ${widget.mealType.substring(0, 1).toUpperCase()}${widget.mealType.substring(1)} Item',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Food name
                TextFormField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Serving size
                TextFormField(
                  controller: _servingSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Serving Size',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a serving size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nutrition info
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
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
                        validator: (String? value) {
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
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Carbs (g)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
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
                        validator: (String? value) {
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
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.existingEntry != null
                          ? 'Update Food Entry'
                          : 'Save Food Entry',
                      style: TextStyle(
                        color: cs.onPrimary,
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
