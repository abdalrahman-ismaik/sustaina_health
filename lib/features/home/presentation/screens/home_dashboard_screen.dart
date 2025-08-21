import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserEntity?> userAsyncValue = ref.watch(currentUserProvider);
    final UserEntity? user = userAsyncValue.value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              _buildHeader(context, user),
              const SizedBox(height: 32),

              // Quick Access Features
              Text(
                'Quick Access',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickAccessGrid(context),
              const SizedBox(height: 32),

              // Today's Focus
              Text(
                'Today\'s Focus',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildTodaysFocusCard(context),
              const SizedBox(height: 32),

              // Implementation Status
              Text(
                'Features Status',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildImplementationStatus(context),
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.eco_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.displayName?.split(' ').first ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready for a sustainable day?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final List<Map<String, Object>> quickActions = <Map<String, Object>>[
      <String, Object>{
        'title': 'Exercise',
        'subtitle': 'AI Workouts',
        'icon': Icons.fitness_center_outlined,
        'route': '/exercise',
        'implemented': true,
      },
      <String, Object>{
        'title': 'Nutrition',
        'subtitle': 'Meal Tracking',
        'icon': Icons.restaurant_outlined,
        'route': '/nutrition',
        'implemented': true,
      },
      <String, Object>{
        'title': 'Sleep',
        'subtitle': 'Sleep Tracking',
        'icon': Icons.bedtime_outlined,
        'route': '/sleep',
        'implemented': false,
      },
      <String, Object>{
        'title': 'Profile',
        'subtitle': 'Your Progress',
        'icon': Icons.person_outline,
        'route': '/profile',
        'implemented': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: quickActions.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, Object> action = quickActions[index];
        return _buildQuickActionCard(context, action);
      },
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, Map<String, dynamic> action) {
    final bool isImplemented = action['implemented'] as bool;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            isImplemented ? () => context.go(action['route'] as String) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isImplemented
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  size: 28,
                  color: isImplemented
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isImplemented
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                action['subtitle'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isImplemented
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                    ),
                textAlign: TextAlign.center,
              ),
              if (!isImplemented) ...<Widget>[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysFocusCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.today_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sustainability Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey towards a healthier you and a healthier planet. Track your daily activities and see your positive impact grow.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/exercise'),
                    icon: const Icon(Icons.fitness_center_outlined, size: 18),
                    label: const Text('Start Workout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/nutrition'),
                    icon: const Icon(Icons.restaurant_outlined, size: 18),
                    label: const Text('Log Meal'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationStatus(BuildContext context) {
    final List<Map<String, Object>> features = <Map<String, Object>>[
      <String, Object>{
        'name': 'AI Workout Generation',
        'status': 'Implemented',
        'description': 'Generate personalized workout plans',
        'color': Theme.of(context).colorScheme.primary,
      },
      <String, Object>{
        'name': 'Food Recognition',
        'status': 'Implemented',
        'description': 'AI-powered meal analysis',
        'color': Theme.of(context).colorScheme.primary,
      },
      <String, Object>{
        'name': 'Meal Planning',
        'status': 'Implemented',
        'description': 'Sustainable meal recommendations',
        'color': Theme.of(context).colorScheme.primary,
      },
      <String, Object>{
        'name': 'Sleep Tracking',
        'status': 'To Be Implemented',
        'description': 'Monitor sleep patterns and quality',
        'color': Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      },
      <String, Object>{
        'name': 'Carbon Footprint',
        'status': 'To Be Implemented',
        'description': 'Track environmental impact',
        'color': Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      },
      <String, Object>{
        'name': 'Social Features',
        'status': 'To Be Implemented',
        'description': 'Connect with eco-conscious community',
        'color': Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      },
    ];

    return Column(
      children: features
          .map((Map<String, Object> feature) => _buildStatusItem(context, feature))
          .toList(),
    );
  }

  Widget _buildStatusItem(BuildContext context, Map<String, dynamic> feature) {
    final bool isImplemented = feature['status'] == 'Implemented';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImplemented
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: feature['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  feature['name'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isImplemented
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isImplemented
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isImplemented
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feature['status'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isImplemented
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
