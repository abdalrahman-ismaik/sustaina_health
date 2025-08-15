import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../../domain/repositories/nutrition_repository.dart';

class SavedMealPlansScreen extends ConsumerWidget {
  const SavedMealPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedMealPlansAsync = ref.watch(savedMealPlansProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Meal Plans',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121714)),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/nutrition/ai-meal-plan');
            },
            icon: const Icon(Icons.add, color: Color(0xFF121714)),
            tooltip: 'Generate New Meal Plan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(savedMealPlansProvider.notifier).loadSavedMealPlans();
        },
        child: savedMealPlansAsync.when(
          data: (mealPlans) => mealPlans.isEmpty
              ? _buildEmptyState(context)
              : _buildMealPlanList(context, ref, mealPlans),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF94E0B2),
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(context, ref, error),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/nutrition/ai-meal-plan');
        },
        backgroundColor: const Color(0xFF94E0B2),
        foregroundColor: const Color(0xFF121714),
        label: const Text(
          'Generate Meal Plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF94E0B2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Color(0xFF94E0B2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Meal Plans Yet',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Generate AI meal plans and save your favorites here!\nYour saved plans will appear below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Primary action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/nutrition/ai-meal-plan');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF94E0B2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF121714),
                ),
                label: const Text(
                  'Generate Your First Meal Plan',
                  style: TextStyle(
                    color: Color(0xFF121714),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Pro Tip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF121714),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save generated meal plans by tapping "Save Plan" after viewing the details. Saved plans can be accessed anytime!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Meal Plans',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(savedMealPlansProvider.notifier).loadSavedMealPlans();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94E0B2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanList(
      BuildContext context, WidgetRef ref, List<SavedMealPlan> mealPlans) {
    // Sort meal plans: favorites first, then by last used, then by creation date
    final sortedMealPlans = List<SavedMealPlan>.from(mealPlans);
    sortedMealPlans.sort((a, b) {
      // First priority: favorites
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      // Second priority: last used (most recent first)
      if (a.lastUsed != null && b.lastUsed != null) {
        return b.lastUsed!.compareTo(a.lastUsed!);
      }
      if (a.lastUsed != null && b.lastUsed == null) return -1;
      if (a.lastUsed == null && b.lastUsed != null) return 1;

      // Third priority: creation date (most recent first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Meal Plans',
                      style: TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${mealPlans.length} saved ${mealPlans.length == 1 ? 'plan' : 'plans'}',
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFF121714),
                  size: 24,
                ),
              ),
            ],
          ),
        ),

        // Filter tabs
        if (mealPlans.length > 3) _buildFilterTabs(context, ref, mealPlans),

        // Meal plan list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedMealPlans.length,
            itemBuilder: (context, index) {
              final mealPlan = sortedMealPlans[index];
              return _buildMealPlanCard(context, ref, mealPlan);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(
      BuildContext context, WidgetRef ref, List<SavedMealPlan> mealPlans) {
    final favoriteCount = mealPlans.where((w) => w.isFavorite).length;
    final recentCount = mealPlans.where((w) => w.lastUsed != null).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All (${mealPlans.length})', true),
          const SizedBox(width: 8),
          if (favoriteCount > 0)
            _buildFilterChip('Favorites ($favoriteCount)', false),
          const SizedBox(width: 8),
          if (recentCount > 0) _buildFilterChip('Recent ($recentCount)', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF94E0B2)
            : const Color(0xFF94E0B2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? const Color(0xFF121714)
              : const Color(0xFF121714).withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMealPlanCard(
      BuildContext context, WidgetRef ref, SavedMealPlan mealPlan) {
    final totalDays = mealPlan.mealPlan.totalDays;
    final dailyCalories = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? mealPlan.mealPlan.dailyMealPlans.first.totalDailyCalories
        : 0;
    final totalMeals = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? 3 +
            mealPlan.mealPlan.dailyMealPlans.first.snacks
                .length // breakfast, lunch, dinner + snacks
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: mealPlan.isFavorite
            ? const BorderSide(color: Color(0xFF94E0B2), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to meal plan detail or implement usage tracking
          _showMealPlanDetail(context, mealPlan);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (mealPlan.isFavorite)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF94E0B2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      mealPlan.name,
                      style: const TextStyle(
                        color: Color(0xFF121714),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, mealPlan);
                      } else if (value == 'duplicate') {
                        _duplicateMealPlan(context, ref, mealPlan);
                      } else if (value == 'favorite') {
                        // TODO: Implement favorite toggle when available in provider
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Favorite feature coming soon!'),
                            backgroundColor: Color(0xFF94E0B2),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              mealPlan.isFavorite
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              color: const Color(0xFF94E0B2),
                            ),
                            const SizedBox(width: 8),
                            Text(mealPlan.isFavorite
                                ? 'Remove Favorite'
                                : 'Add to Favorites'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Color(0xFF94E0B2)),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Meal plan stats chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    Icons.calendar_today,
                    '$totalDays days',
                    const Color(0xFF94E0B2),
                  ),
                  _buildStatChip(
                    Icons.local_fire_department,
                    '$dailyCalories cal/day',
                    Colors.orange,
                  ),
                  _buildStatChip(
                    Icons.restaurant,
                    '$totalMeals meals/day',
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(mealPlan.createdAt)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (mealPlan.lastUsed != null)
                        Text(
                          'Last used: ${_formatDate(mealPlan.lastUsed!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF94E0B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap to view',
                      style: TextStyle(
                        color: Color(0xFF94E0B2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _duplicateMealPlan(
      BuildContext context, WidgetRef ref, SavedMealPlan mealPlan) async {
    try {
      final duplicatedName = "${mealPlan.name} (Copy)";
      await ref.read(savedMealPlansProvider.notifier).saveMealPlan(
            mealPlan.mealPlan,
            duplicatedName,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal plan duplicated as "$duplicatedName"'),
            backgroundColor: const Color(0xFF94E0B2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate meal plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, SavedMealPlan mealPlan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Meal Plan',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${mealPlan.name}"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF121714)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(savedMealPlansProvider.notifier)
                      .deleteMealPlan(mealPlan.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Meal plan "${mealPlan.name}" deleted successfully'),
                        backgroundColor: const Color(0xFF94E0B2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete meal plan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMealPlanDetail(BuildContext context, SavedMealPlan mealPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MealPlanDetailScreen(mealPlan: mealPlan),
      ),
    );
  }
}

class _MealPlanDetailScreen extends StatelessWidget {
  final SavedMealPlan mealPlan;

  const _MealPlanDetailScreen({Key? key, required this.mealPlan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          mealPlan.name,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121714)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Overview Card
            Container(
              width: double.infinity,
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
                    'Plan Overview',
                    style: TextStyle(
                      color: Color(0xFF121714),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewStat(
                          icon: Icons.calendar_today,
                          label: 'Duration',
                          value: '${mealPlan.mealPlan.totalDays} days',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewStat(
                          icon: Icons.local_fire_department,
                          label: 'Daily Calories',
                          value: mealPlan.mealPlan.dailyMealPlans.isNotEmpty
                              ? '${mealPlan.mealPlan.dailyMealPlans.first.totalDailyCalories}'
                              : '0',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewStat(
                          icon: Icons.restaurant,
                          label: 'Meals per Day',
                          value: mealPlan.mealPlan.dailyMealPlans.isNotEmpty
                              ? '${3 + mealPlan.mealPlan.dailyMealPlans.first.snacks.length}'
                              : '0',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewStat(
                          icon: Icons.schedule,
                          label: 'Created',
                          value: _formatDate(mealPlan.createdAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition Ranges
            const Text(
              'Nutrition Targets',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildNutritionRange(
                    'Daily Calories',
                    mealPlan.mealPlan.dailyCaloriesRange.min,
                    mealPlan.mealPlan.dailyCaloriesRange.max,
                    'cal',
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionRange(
                    'Protein',
                    mealPlan.mealPlan.macronutrientsRange.protein.min,
                    mealPlan.mealPlan.macronutrientsRange.protein.max,
                    'g',
                    Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRange(
                    'Carbohydrates',
                    mealPlan.mealPlan.macronutrientsRange.carbohydrates.min,
                    mealPlan.mealPlan.macronutrientsRange.carbohydrates.max,
                    'g',
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRange(
                    'Fat',
                    mealPlan.mealPlan.macronutrientsRange.fat.min,
                    mealPlan.mealPlan.macronutrientsRange.fat.max,
                    'g',
                    Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Meal Plans
            const Text(
              'Daily Meal Plans',
              style: TextStyle(
                color: Color(0xFF121714),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...mealPlan.mealPlan.dailyMealPlans.map(
              (daily) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    'Day ${daily.day} - ${daily.date}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF121714),
                    ),
                  ),
                  subtitle: Text(
                    '${daily.totalDailyCalories} total calories',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMealCard('Breakfast', daily.breakfast),
                          const SizedBox(height: 12),
                          _buildMealCard('Lunch', daily.lunch),
                          const SizedBox(height: 12),
                          _buildMealCard('Dinner', daily.dinner),
                          if (daily.snacks.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...daily.snacks.asMap().entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildMealCard(
                                        'Snack ${entry.key + 1}', entry.value),
                                  ),
                                ),
                          ],

                          // Daily Macros Summary
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF94E0B2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Macros',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF121714),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            'Protein: ${daily.dailyMacros.protein}g')),
                                    Expanded(
                                        child: Text(
                                            'Carbs: ${daily.dailyMacros.carbohydrates}g')),
                                    Expanded(
                                        child: Text(
                                            'Fat: ${daily.dailyMacros.fat}g')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF121714), size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF121714),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF121714),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRange(
      String label, int min, int max, String unit, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          '$min - $max $unit',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String mealType, dynamic meal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF94E0B2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mealType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${meal.totalCalories} cal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meal.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF121714),
            ),
          ),
          if (meal.recipe.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meal.recipe,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
          if (meal.ingredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Ingredients:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 4),
            ...meal.ingredients.take(5).map((ingredient) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    '• ${ingredient.ingredient} (${ingredient.quantity})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )),
            if (meal.ingredients.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '... and ${meal.ingredients.length - 5} more ingredients',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
