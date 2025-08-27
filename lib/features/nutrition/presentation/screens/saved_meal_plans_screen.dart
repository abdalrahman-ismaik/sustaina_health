import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/nutrition/data/models/nutrition_models.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../widgets/day_plan_card.dart';
import '../providers/nutrition_providers.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../../../core/widgets/app_background.dart';

class SavedMealPlansScreen extends ConsumerWidget {
  const SavedMealPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SavedMealPlan>> savedMealPlansAsync = ref.watch(savedMealPlansProvider);

    return AppBackground(
      type: BackgroundType.nutrition,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'My Meal Plans',
            style: TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121714)),
        actions: <Widget>[
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
          data: (List<SavedMealPlan> mealPlans) => mealPlans.isEmpty
              ? _buildEmptyState(context)
              : _buildMealPlanList(context, ref, mealPlans),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF94E0B2),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => _buildErrorState(context, ref, error),
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
    ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                children: <Widget>[
                  Row(
                    children: <Widget>[
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
          children: <Widget>[
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
    final List<SavedMealPlan> sortedMealPlans = List<SavedMealPlan>.from(mealPlans);
    sortedMealPlans.sort((SavedMealPlan a, SavedMealPlan b) {
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
      children: <Widget>[
        // Header with stats
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                const Color(0xFF94E0B2).withOpacity(0.8),
                const Color(0xFF94E0B2).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
            itemBuilder: (BuildContext context, int index) {
              final SavedMealPlan mealPlan = sortedMealPlans[index];
              return _buildMealPlanCard(context, ref, mealPlan);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(
      BuildContext context, WidgetRef ref, List<SavedMealPlan> mealPlans) {
    final int favoriteCount = mealPlans.where((SavedMealPlan w) => w.isFavorite).length;
    final int recentCount = mealPlans.where((SavedMealPlan w) => w.lastUsed != null).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
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
    final int totalDays = mealPlan.mealPlan.totalDays;
    final int dailyCalories = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? mealPlan.mealPlan.dailyMealPlans.first.totalDailyCalories
        : 0;
    final int totalMeals = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? 3 +
            mealPlan.mealPlan.dailyMealPlans.first.snacks
                .length // breakfast, lunch, dinner + snacks
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          width: 1,
        ),
      ),
      color: mealPlan.isFavorite 
          ? const Color(0xFFF1F8E9)
          : Colors.white,
      shadowColor: mealPlan.isFavorite
          ? const Color(0xFF2E7D32).withOpacity(0.15)
          : Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: () {
          _showMealPlanDetail(context, mealPlan);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
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
                    onSelected: (String value) async {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, mealPlan);
                      } else if (value == 'duplicate') {
                        _duplicateMealPlan(context, ref, mealPlan);
                      } else if (value == 'favorite') {
                        await ref.read(savedMealPlansProvider.notifier).toggleFavorite(mealPlan.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mealPlan.isFavorite ? 'Removed from favorites' : 'Added to favorites'),
                              backgroundColor: const Color(0xFF94E0B2),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: <Widget>[
                            Icon(
                              mealPlan.isFavorite ? Icons.favorite : Icons.favorite_border,
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
                          children: <Widget>[
                            Icon(Icons.copy, color: Color(0xFF94E0B2)),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
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
                children: <Widget>[
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

              // Mini preview carousel of days with dots
              if (mealPlan.mealPlan.dailyMealPlans.isNotEmpty) ...[
                _MealPlanPreviewCarousel(
                  dailyPlans: mealPlan.mealPlan.dailyMealPlans,
                  onTapDay: (int dayIndex) => _showMealPlanDetail(
                    context,
                    mealPlan,
                    initialIndex: dayIndex,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Date information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
        children: <Widget>[
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
      final String duplicatedName = "${mealPlan.name} (Copy)";
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
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

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
          actions: <Widget>[
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

  void _showMealPlanDetail(
    BuildContext context,
    SavedMealPlan mealPlan, {
    int initialIndex = 0,
  }) {
    final int maxIndex = (mealPlan.mealPlan.dailyMealPlans.length - 1).clamp(0, 1 << 30);
    final int startIndex = initialIndex < 0
        ? 0
        : (initialIndex > maxIndex ? maxIndex : initialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _MealPlanDetailScreen(
          mealPlan: mealPlan,
          initialPage: startIndex,
        ),
      ),
    );
  }
}

class _MealPlanPreviewCarousel extends StatefulWidget {
  final List<DailyMealPlan> dailyPlans;
  final ValueChanged<int>? onTapDay;

  const _MealPlanPreviewCarousel({required this.dailyPlans, this.onTapDay});

  @override
  State<_MealPlanPreviewCarousel> createState() => _MealPlanPreviewCarouselState();
}

class _MealPlanPreviewCarouselState extends State<_MealPlanPreviewCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plans = widget.dailyPlans;
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            itemCount: plans.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final p = plans[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double t = 0.0;
                  if (_controller.position.haveDimensions) {
                    final double current = (_controller.page ?? _current.toDouble());
                    t = current - index.toDouble();
                  } else {
                    t = (_current - index).toDouble();
                  }
                  final double scale = (1 - (t.abs() * 0.06)).clamp(0.92, 1.0);
                  final double opacity = (1 - (t.abs() * 0.3)).clamp(0.5, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.onTapDay?.call(index),
                  child: _MiniDayPreviewCard(plan: p),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(plans.length, (index) {
            final bool selected = index == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D32) : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MiniDayPreviewCard extends StatelessWidget {
  final DailyMealPlan plan;
  const _MiniDayPreviewCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF94E0B2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day ${plan.day}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF121714)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.totalDailyCalories} cal · ${plan.dailyMacros.protein}g P · ${plan.dailyMacros.carbohydrates}g C · ${plan.dailyMacros.fat}g F',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MealPlanDetailScreen extends StatefulWidget {
  final SavedMealPlan mealPlan;

  const _MealPlanDetailScreen({Key? key, required this.mealPlan, this.initialPage = 0}) : super(key: key);
  final int initialPage;

  @override
  State<_MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends State<_MealPlanDetailScreen> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
  final mealPlan = widget.mealPlan;
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
          children: <Widget>[
            // Plan Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
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
                children: <Widget>[
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
                    children: <Widget>[
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
                    children: <Widget>[
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
                children: <Widget>[
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

            // Daily Meal Plans - swipeable full-screen day cards with subtle Lottie particle background
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  // Lottie background (subtle, non-interactive)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.12,
                        child: Lottie.asset(
                          'assets/lottie/particles_green.json',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Swipeable PageView of day cards with transform
                  _TransformedPageView(
                    itemCount: mealPlan.mealPlan.dailyMealPlans.length,
                    initialPage: widget.initialPage,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (BuildContext ctx, int index) {
                      final DailyMealPlan daily = mealPlan.mealPlan.dailyMealPlans[index];
                      return DayPlanCard(dailyPlan: daily, horizontalPadding: 12);
                    },
                  ),

                  // Dots indicator overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(mealPlan.mealPlan.dailyMealPlans.length, (index) {
                        final bool selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFBDBDBD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
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

  Widget _buildOverviewStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
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
      children: <Widget>[
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

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

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

class _TransformedPageView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final int initialPage;

  const _TransformedPageView({
    required this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
    this.initialPage = 0,
  });

  @override
  State<_TransformedPageView> createState() => _TransformedPageViewState();
}

class _TransformedPageViewState extends State<_TransformedPageView> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialPage;
    _controller = PageController(
      viewportFraction: 0.94,
      initialPage: widget.initialPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: (i) {
        setState(() => _current = i);
        widget.onPageChanged?.call(i);
      },
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double t = 0.0;
            if (_controller.position.haveDimensions) {
              final double current = (_controller.page ?? _current.toDouble());
              t = current - index.toDouble();
            } else {
              t = (_current - index).toDouble();
            }
            final double scale = (1 - (t.abs() * 0.06)).clamp(0.92, 1.0);
            final double opacity = (1 - (t.abs() * 0.3)).clamp(0.5, 1.0);
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity, child: child),
            );
          },
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}
