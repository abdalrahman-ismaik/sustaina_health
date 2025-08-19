import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';

class AIFoodRecognitionScreen extends ConsumerStatefulWidget {
  final String? mealType;
  const AIFoodRecognitionScreen({Key? key, this.mealType}) : super(key: key);

  @override
  ConsumerState<AIFoodRecognitionScreen> createState() =>
      _AIFoodRecognitionScreenState();
}

class _AIFoodRecognitionScreenState
    extends ConsumerState<AIFoodRecognitionScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImageSimple(ImageSource source) async {
    try {
      print(
          'Attempting to access ${source == ImageSource.camera ? 'camera' : 'gallery'}'); // Debug

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        print('Image selected: ${image.path}'); // Debug
        setState(() {
          _selectedImage = File(image.path);
        });
        _analyzeImage();
      } else {
        print('No image selected by user'); // Debug
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'No ${source == ImageSource.camera ? 'photo taken' : 'image selected'}'),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Image picker error: $e'); // Debug logging
      if (mounted) {
        String errorMessage =
            'Unable to access ${source == ImageSource.camera ? 'camera' : 'gallery'}';

        if (e.toString().toLowerCase().contains('permission')) {
          errorMessage += '. Please check app permissions in Settings.';

          // Show permission dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Permission Needed'),
                content: Text(
                  'Please allow access to ${source == ImageSource.camera ? 'camera' : 'photos'} in your device settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _analyzeImage() {
    if (_selectedImage != null) {
      print(
          'Starting image analysis for file: ${_selectedImage!.path}'); // Debug logging
      try {
        ref.read(mealAnalysisProvider.notifier).analyzeMeal(
              _selectedImage!,
              mealType: widget.mealType,
            );
      } catch (e) {
        print('Error in analyze image: $e'); // Debug logging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to analyze image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('No image selected for analysis'); // Debug logging
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealAnalysisState = ref.watch(mealAnalysisProvider);
    final apiHealthState = ref.watch(nutritionApiHealthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF121714)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Food Analyzer',
          style: TextStyle(
            color: Color(0xFF121714),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // API Status Indicator
          apiHealthState.when(
            data: (isHealthy) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHealthy ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.error,
                    color: isHealthy ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHealthy
                        ? 'AI Analysis Available'
                        : 'AI Service Unavailable - Using Mock Data',
                    style: TextStyle(
                      color: isHealthy
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          Expanded(
            child: mealAnalysisState.when(
              data: (analysis) => analysis != null
                  ? _FoodAnalysisResult(
                      analysis: analysis,
                      image: _selectedImage,
                      onEdit: () {
                        ref.read(mealAnalysisProvider.notifier).clearAnalysis();
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    )
                  : _CameraView(
                      onCapture: () => _captureImageSimple(ImageSource.camera),
                      onGallery: () => _captureImageSimple(ImageSource.gallery),
                      selectedImage: _selectedImage,
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF94e0b2)),
                    SizedBox(height: 16),
                    Text('Analyzing your meal...',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF688273))),
                  ],
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(mealAnalysisProvider.notifier).clearAnalysis();
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final File? selectedImage;

  const _CameraView({
    required this.onCapture,
    required this.onGallery,
    this.selectedImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40), // Top spacing

          // Camera/Image Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFf1f4f2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : const Center(
                    child: Icon(Icons.camera_alt,
                        size: 64, color: Color(0xFF688273)),
                  ),
          ),

          const SizedBox(height: 32),

          // Description Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Take a photo of your meal to get personalized nutrition insights, sustainability analysis, and health recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('Camera button pressed'); // Debug logging
                      onCapture();
                    },
                    icon: const Icon(Icons.camera, color: Color(0xFF121714)),
                    label: const Text('Camera',
                        style: TextStyle(color: Color(0xFF121714))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('Gallery button pressed'); // Debug logging
                      onGallery();
                    },
                    icon: const Icon(Icons.photo_library,
                        color: Color(0xFF688273)),
                    label: const Text('Gallery',
                        style: TextStyle(color: Color(0xFF688273))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFdde4e0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40), // Bottom spacing
        ],
      ),
    );
  }
}

class _FoodAnalysisResult extends ConsumerWidget {
  final MealAnalysisResponse analysis;
  final File? image;
  final VoidCallback onEdit;

  const _FoodAnalysisResult({
    required this.analysis,
    required this.onEdit,
    this.image,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image preview
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFf1f4f2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.fastfood,
                          size: 48, color: Color(0xFF688273)),
                    ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Analysis & Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),

            // Food Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf1f4f2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF94e0b2).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Color(0xFF688273),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysis.foodName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF121714),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NutritionPill(
                        label: 'Calories',
                        value: '${analysis.totalCalories}',
                        unit: 'kcal',
                        color: Colors.orange,
                      ),
                      _NutritionPill(
                        label: 'Protein',
                        value: '${analysis.totalProtein}',
                        unit: 'g',
                        color: Colors.blue,
                      ),
                      _NutritionPill(
                        label: 'Carbs',
                        value: '${analysis.totalCarbohydrates}',
                        unit: 'g',
                        color: Colors.green,
                      ),
                      _NutritionPill(
                        label: 'Fats',
                        value: '${analysis.totalFats}',
                        unit: 'g',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sustainability Analysis Section
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF94e0b2).withOpacity(0.15),
                    const Color(0xFF94e0b2).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF94e0b2).withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF94e0b2).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Color(0xFF688273),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sustainability Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF121714),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SustainabilityMetric(
                    label: 'Overall Sustainability Score',
                    value: '${analysis.sustainability.overallScore}/100',
                    score: analysis.sustainability.overallScore,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SustainabilityRow(
                          label: 'Environmental',
                          value: analysis.sustainability.environmentalImpact
                              .toUpperCase(),
                          impact: analysis.sustainability.environmentalImpact,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SustainabilityRow(
                          label: 'Nutrition',
                          value: analysis.sustainability.nutritionImpact
                              .toUpperCase(),
                          impact: analysis.sustainability.nutritionImpact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Color(0xFF688273),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Recommendation',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF688273),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          analysis.sustainability.description,
                          style: const TextStyle(
                            color: Color(0xFF121714),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ingredients breakdown
            if (analysis.caloriesPerIngredient.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Ingredient Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 12),
              ...analysis.caloriesPerIngredient.entries
                  .map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF94e0b2).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF94e0b2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Color(0xFF121714),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf1f4f2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${entry.value} cal',
                                style: const TextStyle(
                                  color: Color(0xFF688273),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
            ],

            // Health Tips Section
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf1f4f2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Color(0xFF688273),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Health Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF121714),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._getHealthTips(analysis).map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF94e0b2),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  color: Color(0xFF688273),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf1f4f2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    label: const Text('Analyze Another',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    label: const Text('Got It!',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go('/nutrition/brand-recommendations');
                },
                icon: const Icon(Icons.eco, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF40916C),
                  side: const BorderSide(color: Color(0xFF40916C)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                label: Text(
                    'Find Sustainable Brands for "${analysis.foodName}"',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getHealthTips(MealAnalysisResponse analysis) {
    List<String> tips = [];

    // Protein tips
    if (analysis.totalProtein > 40) {
      tips.add(
          'Great protein content! This meal will help with muscle maintenance and satiety.');
    } else if (analysis.totalProtein < 15) {
      tips.add(
          'Consider adding more protein sources like beans, nuts, or lean meats to balance this meal.');
    }

    // Calorie tips
    if (analysis.totalCalories > 700) {
      tips.add(
          'This is a calorie-dense meal. Consider pairing with light sides or saving for post-workout.');
    } else if (analysis.totalCalories < 300) {
      tips.add(
          'This is a light meal. Perfect for a snack or consider adding healthy fats for more energy.');
    }

    // Sustainability tips
    switch (analysis.sustainability.overallScore) {
      case >= 80:
        tips.add(
            'Excellent sustainability choice! This meal has a low environmental impact.');
        break;
      case >= 60:
        tips.add(
            'Good sustainability choice. Small improvements could make it even better.');
        break;
      default:
        tips.add(
            'Consider choosing more plant-based ingredients to improve sustainability.');
    }

    // Carbohydrate tips
    if (analysis.totalCarbohydrates > 60) {
      tips.add(
          'High in carbs - great for energy, especially before or after exercise.');
    }

    return tips.isNotEmpty
        ? tips
        : ['This looks like a balanced meal! Enjoy mindfully.'];
  }
}

class _NutritionPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionPill({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF688273),
          ),
        ),
      ],
    );
  }
}

class _SustainabilityMetric extends StatelessWidget {
  final String label;
  final String value;
  final int score;

  const _SustainabilityMetric({
    required this.label,
    required this.value,
    required this.score,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (score >= 70) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF688273),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: scoreColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SustainabilityRow extends StatelessWidget {
  final String label;
  final String value;
  final String impact;

  const _SustainabilityRow({
    required this.label,
    required this.value,
    required this.impact,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color impactColor;
    IconData impactIcon;

    // Different color logic for environmental vs nutrition impact
    // Environmental impact: low = good (green), high = bad (red)
    // Nutrition impact: high = good (green), low = bad (red)
    bool isNutritionImpact = label.toLowerCase().contains('nutrition');

    switch (impact.toLowerCase()) {
      case 'high':
        if (isNutritionImpact) {
          impactColor = Colors.green;
          impactIcon = Icons.trending_up;
        } else {
          impactColor = Colors.red;
          impactIcon = Icons.trending_up;
        }
        break;
      case 'medium':
        impactColor = Colors.orange;
        impactIcon = Icons.trending_flat;
        break;
      case 'low':
        if (isNutritionImpact) {
          impactColor = Colors.red;
          impactIcon = Icons.trending_down;
        } else {
          impactColor = Colors.green;
          impactIcon = Icons.trending_down;
        }
        break;
      default:
        impactColor = Colors.grey;
        impactIcon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF688273),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  impactIcon,
                  color: impactColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: impactColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
