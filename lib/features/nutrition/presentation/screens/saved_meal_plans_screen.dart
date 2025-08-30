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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<List<SavedMealPlan>> savedMealPlansAsync =
        ref.watch(savedMealPlansProvider);

    return AppBackground(
      type: BackgroundType.nutrition,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'My Meal Plans',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: cs.onSurface),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                context.go('/nutrition/ai-meal-plan');
              },
              icon: Icon(Icons.add, color: cs.onSurface),
              tooltip: 'Generate New Meal Plan',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(savedMealPlansProvider.notifier)
                .loadSavedMealPlans();
          },
          child: savedMealPlansAsync.when(
            data: (List<SavedMealPlan> mealPlans) => mealPlans.isEmpty
                ? _buildEmptyState(context)
                : _buildMealPlanList(context, ref, mealPlans),
            loading: () => Center(
              child: CircularProgressIndicator(color: cs.primary),
            ),
            error: (Object error, StackTrace stackTrace) =>
                _buildErrorState(context, ref, error),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.go('/nutrition/ai-meal-plan');
          },
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 80,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Meal Plans Yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Generate AI meal plans and save your favorites here!\nYour saved plans will appear below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
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
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.auto_awesome,
                  color: cs.onPrimary,
                ),
                label: Text(
                  'Generate Your First Meal Plan',
                  style: TextStyle(
                    color: cs.onPrimary,
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
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.info_outline,
                          color: cs.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pro Tip',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save generated meal plans by tapping "Save Plan" after viewing the details. Saved plans can be accessed anytime!',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 80,
              color: cs.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Meal Plans',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(savedMealPlansProvider.notifier).loadSavedMealPlans();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: cs.onPrimary,
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    // Sort meal plans: favorites first, then by last used, then by creation date
    final List<SavedMealPlan> sortedMealPlans =
        List<SavedMealPlan>.from(mealPlans);
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
                cs.primary.withValues(alpha: 0.28),
                cs.primary.withValues(alpha: 0.18),
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
                    Text(
                      'Your Meal Plans',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${mealPlans.length} saved ${mealPlans.length == 1 ? 'plan' : 'plans'}',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: cs.onPrimary,
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
    final int favoriteCount =
        mealPlans.where((SavedMealPlan w) => w.isFavorite).length;
    final int recentCount =
        mealPlans.where((SavedMealPlan w) => w.lastUsed != null).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          _buildFilterChip(context, 'All (${mealPlans.length})', true),
          const SizedBox(width: 8),
          if (favoriteCount > 0)
            _buildFilterChip(context, 'Favorites ($favoriteCount)', false),
          const SizedBox(width: 8),
          if (recentCount > 0)
            _buildFilterChip(context, 'Recent ($recentCount)', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext ctx, String label, bool isSelected) {
    final ColorScheme cs = Theme.of(ctx).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary
            : cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMealPlanCard(
      BuildContext context, WidgetRef ref, SavedMealPlan mealPlan) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final int totalDays = mealPlan.mealPlan.totalDays;
    final int dailyCalories = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? mealPlan.mealPlan.dailyMealPlans.first.totalDailyCalories
        : 0;
    final int totalMeals = mealPlan.mealPlan.dailyMealPlans.isNotEmpty
        ? 3 + mealPlan.mealPlan.dailyMealPlans.first.snacks.length
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      color:
          mealPlan.isFavorite ? cs.primary.withValues(alpha: 0.08) : cs.surface,
      shadowColor: cs.onSurface.withValues(alpha: 0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showMealPlanDetail(context, mealPlan),
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
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite, color: cs.onPrimary, size: 12),
                    ),
                  Expanded(
                    child: Text(
                      mealPlan.name,
                      style: TextStyle(
                        color: cs.onSurface,
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
                        await ref
                            .read(savedMealPlansProvider.notifier)
                            .toggleFavorite(mealPlan.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mealPlan.isFavorite
                                  ? 'Removed from favorites'
                                  : 'Added to favorites'),
                              backgroundColor: cs.primary,
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: <Widget>[
                            Icon(
                              mealPlan.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(mealPlan.isFavorite
                                ? 'Remove Favorite'
                                : 'Add to Favorites'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: const <Widget>[
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete, color: cs.error),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _buildStatChip(Icons.calendar_today, '$totalDays days',
                      cs.primary),
                  _buildStatChip(Icons.local_fire_department,
                      '$dailyCalories cal/day', cs.secondary),
                  _buildStatChip(
                      Icons.restaurant, '$totalMeals meals/day', cs.tertiary),
                ],
              ),

              const SizedBox(height: 12),

              if (mealPlan.mealPlan.dailyMealPlans.isNotEmpty) ...<Widget>[
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Created: ${_formatDate(mealPlan.createdAt)}',
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                      if (mealPlan.lastUsed != null)
                        Text(
                          'Last used: ${_formatDate(mealPlan.lastUsed!)}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap to view',
                      style: TextStyle(
                        color: cs.primary,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    final ColorScheme cs = Theme.of(context).colorScheme;
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
            backgroundColor: cs.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate meal plan: $e'),
            backgroundColor: cs.error,
          ),
        );
      }
    }
  }

  // removed duplicate _formatDate (kept a single definition below)

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, SavedMealPlan mealPlan) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Meal Plan',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${mealPlan.name}"? This action cannot be undone.',
            style: TextStyle(color: cs.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant),
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
                        backgroundColor: cs.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete meal plan: $e'),
                        backgroundColor: cs.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: cs.onError,
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
    final int maxIndex =
        (mealPlan.mealPlan.dailyMealPlans.length - 1).clamp(0, 1 << 30);
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

class _MealPlanPreviewCarousel extends StatefulWidget {
  final List<DailyMealPlan> dailyPlans;
  final ValueChanged<int>? onTapDay;

  const _MealPlanPreviewCarousel({required this.dailyPlans, this.onTapDay});

  @override
  State<_MealPlanPreviewCarousel> createState() =>
      _MealPlanPreviewCarouselState();
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<DailyMealPlan> plans = widget.dailyPlans;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            itemCount: plans.length,
            onPageChanged: (int i) => setState(() => _current = i),
            itemBuilder: (BuildContext context, int index) {
              final DailyMealPlan p = plans[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  double t = 0.0;
                  if (_controller.position.haveDimensions) {
                    final double current =
                        (_controller.page ?? _current.toDouble());
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
          children: List.generate(plans.length, (int index) {
            final bool selected = index == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected ? cs.primary : cs.onSurfaceVariant,
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Day ${plan.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.totalDailyCalories} cal \u00b7 ${plan.dailyMacros.protein}g P \u00b7 ${plan.dailyMacros.carbohydrates}g C \u00b7 ${plan.dailyMacros.fat}g F',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
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

  const _MealPlanDetailScreen(
      {Key? key, required this.mealPlan, this.initialPage = 0})
      : super(key: key);
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final SavedMealPlan mealPlan = widget.mealPlan;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          mealPlan.name,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
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
                    cs.primary.withValues(alpha: 0.28),
                    cs.primary.withValues(alpha: 0.18),
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
                    'Plan Overview',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildOverviewStat(
                          context: context,
                          icon: Icons.calendar_today,
                          label: 'Duration',
                          stat: '${mealPlan.mealPlan.totalDays} days',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewStat(
                          context: context,
                          icon: Icons.local_fire_department,
                          label: 'Daily Calories',
                          stat: mealPlan.mealPlan.dailyMealPlans.isNotEmpty
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
                          context: context,
                          icon: Icons.restaurant,
                          label: 'Meals per Day',
                          stat: mealPlan.mealPlan.dailyMealPlans.isNotEmpty
                              ? '${3 + mealPlan.mealPlan.dailyMealPlans.first.snacks.length}'
                              : '0',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewStat(
                          context: context,
                          icon: Icons.schedule,
                          label: 'Created',
                          stat: _formatDate(mealPlan.createdAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition Ranges
            Text(
              'Nutrition Targets',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: <Widget>[
                  _buildNutritionRange(
                    context,
                    'Daily Calories',
                    mealPlan.mealPlan.dailyCaloriesRange.min,
                    mealPlan.mealPlan.dailyCaloriesRange.max,
                    'cal',
                    cs.secondary,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionRange(
                    context,
                    'Protein',
                    mealPlan.mealPlan.macronutrientsRange.protein.min,
                    mealPlan.mealPlan.macronutrientsRange.protein.max,
                    'g',
                    cs.error,
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRange(
                    context,
                    'Carbohydrates',
                    mealPlan.mealPlan.macronutrientsRange.carbohydrates.min,
                    mealPlan.mealPlan.macronutrientsRange.carbohydrates.max,
                    'g',
                    cs.tertiary,
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRange(
                    context,
                    'Fat',
                    mealPlan.mealPlan.macronutrientsRange.fat.min,
                    mealPlan.mealPlan.macronutrientsRange.fat.max,
                    'g',
                    cs.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Meal Plans - swipeable full-screen day cards with subtle Lottie particle background
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: <Widget>[
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
                    onPageChanged: (int i) => setState(() => _currentPage = i),
                    itemBuilder: (BuildContext ctx, int index) {
                      final DailyMealPlan daily =
                          mealPlan.mealPlan.dailyMealPlans[index];
                      return DayPlanCard(
                          dailyPlan: daily, horizontalPadding: 12);
                    },
                  ),

                  // Dots indicator overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          mealPlan.mealPlan.dailyMealPlans.length, (int index) {
                        final bool selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? cs.primary
                                : cs.onSurfaceVariant,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required String stat,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: cs.onPrimary, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          stat,
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRange(
      BuildContext context, String label, int min, int max, String unit, Color color) {
    final ColorScheme cs = Theme.of(context).colorScheme;
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
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: cs.onSurface,
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
      onPageChanged: (int i) {
        setState(() => _current = i);
        widget.onPageChanged?.call(i);
      },
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
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
