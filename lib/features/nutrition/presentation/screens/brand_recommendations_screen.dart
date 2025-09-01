import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghiraas/features/nutrition/data/models/nutrition_models.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import 'package:ghiraas/widgets/interactive_loading.dart';

class BrandRecommendationsScreen extends ConsumerStatefulWidget {
  const BrandRecommendationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BrandRecommendationsScreen> createState() =>
      _BrandRecommendationsScreenState();
}

class _BrandRecommendationsScreenState
    extends ConsumerState<BrandRecommendationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchBrands() {
    final String product = _searchController.text.trim();
    if (product.isNotEmpty) {
      ref
          .read(brandRecommendationsProvider.notifier)
          .getBrandRecommendations(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AsyncValue<RecommendedBrands?> brandRecommendationsState =
        ref.watch(brandRecommendationsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Sustainable Brands',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF94e0b2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Find Sustainable Brands',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121714),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Discover UAE-based sustainable alternatives',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF121714),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search
            Container(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a product...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _searchBrands(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchBrands,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF94e0b2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results
            Expanded(
              child: brandRecommendationsState.when(
                data: (RecommendedBrands? recommendations) {
                  if (recommendations == null ||
                      recommendations.brands.isEmpty) {
                    return const Center(
                      child: Text(
                        'Search for a product to get recommendations',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: recommendations.brands.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (BuildContext context, int index) {
                      final RecommendedBrand brand =
                          recommendations.brands[index];
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              brand.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF121714),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AED ${brand.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94e0b2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rating: ${brand.sustainabilityRating}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              brand.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => InteractiveLoading(
                  title: 'Searching brands',
                  subtitle: 'Finding sustainable alternatives…',
                  onCancel: () => ref
                      .read(brandRecommendationsProvider.notifier)
                      .clearRecommendations(),
                  color: const Color(0xFF40916C),
                ),
                error: (Object error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load recommendations',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _searchBrands,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94e0b2),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Color(0xFF121714)),
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
}
