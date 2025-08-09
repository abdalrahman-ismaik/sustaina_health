import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/nutrition_providers.dart';
import '../../data/models/nutrition_models.dart';

class AIFoodRecognitionScreen extends ConsumerStatefulWidget {
  const AIFoodRecognitionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIFoodRecognitionScreen> createState() =>
      _AIFoodRecognitionScreenState();
}

class _AIFoodRecognitionScreenState extends ConsumerState<AIFoodRecognitionScreen> {
  File? _selectedImage;
  String? _selectedMealType;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _analyzeImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _analyzeImage() {
    if (_selectedImage != null) {
      ref.read(mealAnalysisProvider.notifier).analyzeMeal(
        _selectedImage!,
        mealType: _selectedMealType,
      );
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
          'AI Food Recognition',
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
                        ? 'AI Recognition Available'
                        : 'AI Service Unavailable - Using Mock Data',
                    style: TextStyle(
                      color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
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
                  ? _RecognitionResult(
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
                      onCapture: () => _captureImage(ImageSource.camera),
                      onGallery: () => _captureImage(ImageSource.gallery),
                      selectedImage: _selectedImage,
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF94e0b2)),
                    SizedBox(height: 16),
                    Text('Analyzing your meal...', 
                         style: TextStyle(fontSize: 16, color: Color(0xFF688273))),
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
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(24),
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
                  child: Icon(Icons.camera_alt, size: 64, color: Color(0xFF688273)),
                ),
        ),
        
        // Meal Type Selection
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Select meal type (optional):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF121714),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 8,
            children: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                .map((type) => FilterChip(
                      label: Text(type),
                      selected: false, // You can implement selection logic here
                      onSelected: (selected) {
                        // Handle meal type selection
                      },
                      backgroundColor: const Color(0xFFf1f4f2),
                      selectedColor: const Color(0xFF94e0b2),
                    ))
                .toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera, color: Color(0xFF121714)),
              label: const Text('Camera',
                  style: TextStyle(color: Color(0xFF121714))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94e0b2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: onGallery,
              icon: const Icon(Icons.photo_library, color: Color(0xFF688273)),
              label: const Text('Gallery',
                  style: TextStyle(color: Color(0xFF688273))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFdde4e0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecognitionResult extends ConsumerWidget {
  final MealAnalysisResponse analysis;
  final File? image;
  final VoidCallback onEdit;
  
  const _RecognitionResult({
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
                      child: Icon(Icons.fastfood, size: 48, color: Color(0xFF688273)),
                    ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Recognition Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121714),
              ),
            ),
            const SizedBox(height: 8),
            
            _ResultRow(
              label: 'Identified Foods',
              value: analysis.identifiedFoods.join(', '),
            ),
            _ResultRow(
              label: 'Confidence',
              value: '${(analysis.confidence * 100).round()}%',
            ),
            _ResultRow(
              label: 'Portion Size',
              value: analysis.portionSize,
            ),
            _ResultRow(
              label: 'Calories',
              value: '${analysis.nutritionInfo.calories} kcal',
            ),
            _ResultRow(
              label: 'Macros',
              value: analysis.nutritionInfo.macroString,
            ),
            _ResultRow(
              label: 'Fiber',
              value: '${analysis.nutritionInfo.fiber}g',
            ),
            _ResultRow(
              label: 'Sustainability',
              value: analysis.sustainabilityScore,
            ),
            
            // Suggestions
            if (analysis.suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121714),
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.suggestions.map((suggestion) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf1f4f2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        color: Color(0xFF688273),
                        fontSize: 14,
                      ),
                    ),
                  )),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf1f4f2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Retake Photo',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToFoodLog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94e0b2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Add to Log',
                        style: TextStyle(color: Color(0xFF121714))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToFoodLog(BuildContext context, WidgetRef ref) {
    // Create a food log entry from the analysis
    final entry = FoodLogEntry(
      id: '',
      userId: 'current_user', // TODO: Get from auth
      foodName: analysis.identifiedFoods.join(', '),
      mealType: 'snack', // Default, can be changed in food logging screen
      servingSize: analysis.portionSize,
      nutritionInfo: analysis.nutritionInfo,
      sustainabilityScore: analysis.sustainabilityScore,
      notes: analysis.suggestions.isNotEmpty ? analysis.suggestions.first : null,
      loggedAt: DateTime.now(),
    );

    // Add to food log
    ref.read(foodLogProvider.notifier).addFoodLogEntry(entry);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food added to log successfully!'),
        backgroundColor: Color(0xFF94e0b2),
      ),
    );

    // Navigate to food logging screen for editing
    Navigator.of(context).pushReplacementNamed('/nutrition/log');
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF688273),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF121714),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const _NutritionBottomNavBar({required this.selectedIndex, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.of(context).pushNamed('/home');
            break;
          case 1:
            Navigator.of(context).pushNamed('/exercise');
            break;
          case 2:
            Navigator.of(context).pushNamed('/nutrition');
            break;
          case 3:
            Navigator.of(context).pushNamed('/sleep');
            break;
          case 4:
            Navigator.of(context).pushNamed('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF121714),
      unselectedItemColor: const Color(0xFF688273),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercise',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Nutrition',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.nightlight_round),
          label: 'Sleep',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
