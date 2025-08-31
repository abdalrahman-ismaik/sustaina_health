import 'package:flutter/material.dart';
import '../../data/models/nutrition_models.dart';
import '../../../sleep/presentation/theme/sleep_colors.dart';

class DayPlanCard extends StatelessWidget {
  final DailyMealPlan dailyPlan;
  final double horizontalPadding;

  const DayPlanCard({
    super.key,
    required this.dailyPlan,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        SleepColors.primaryGreen.withValues(alpha: 0.95),
                        SleepColors.primaryGreen.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Day ${dailyPlan.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${dailyPlan.totalDailyCalories} calories · ${dailyPlan.dailyMacros.protein}g P · ${dailyPlan.dailyMacros.carbohydrates}g C · ${dailyPlan.dailyMacros.fat}g F',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildMealItem(context, 'Breakfast', dailyPlan.breakfast),
                        const SizedBox(height: 12),
                        _buildMealItem(context, 'Lunch', dailyPlan.lunch),
                        const SizedBox(height: 12),
                        _buildMealItem(context, 'Dinner', dailyPlan.dinner),
                        const SizedBox(height: 12),
                        ...dailyPlan.snacks.map((MealOption snack) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildMealItem(context, 'Snack', snack),
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, String mealType, MealOption meal) {
    final IconData iconData;
    final Color iconBg;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        iconData = Icons.free_breakfast;
        iconBg = Colors.orange.shade100;
        break;
      case 'lunch':
        iconData = Icons.lunch_dining;
        iconBg = Colors.lightGreen.shade100;
        break;
      case 'dinner':
        iconData = Icons.dinner_dining;
        iconBg = Colors.blue.shade100;
        break;
      default:
        iconData = Icons.fastfood;
        iconBg = Colors.grey.shade200;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showMealDetails(context, mealType, meal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 36, color: Colors.grey[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mealType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SleepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${meal.calories} calories',
                  style: TextStyle(color: SleepColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetails(BuildContext context, String mealType, MealOption meal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      meal.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$mealType · ${meal.calories} calories',
                      style: TextStyle(color: SleepColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    if (meal.description.isNotEmpty) ...<Widget>[
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(meal.description),
                      const SizedBox(height: 12),
                    ],
                    if (meal.ingredients.isNotEmpty) ...<Widget>[
                      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ...meal.ingredients.map((Ingredient ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(child: Text(ing.ingredient)),
                                const SizedBox(width: 8),
                                Text(ing.quantity, style: TextStyle(color: SleepColors.textSecondary)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                    ],
                    if (meal.recipe.isNotEmpty) ...<Widget>[
                      const Text('Recipe', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(meal.recipe),
                      const SizedBox(height: 12),
                    ],
                    if (meal.suggestedBrands.isNotEmpty) ...<Widget>[
                      const Text('Suggested Brands', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ...meal.suggestedBrands.map((String b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('• $b'),
                          )),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
