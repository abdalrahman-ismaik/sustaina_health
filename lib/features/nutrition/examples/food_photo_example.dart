// Example implementation of food photo recognition feature
// Move this file to lib/features/nutrition/examples/food_photo_example.dart
// This example showcases how to use the camera service and photo capture widget for food recognition

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/widgets/photo_capture_widget.dart';

class FoodPhotoExample extends StatefulWidget {
  const FoodPhotoExample({Key? key}) : super(key: key);

  @override
  State<FoodPhotoExample> createState() => _FoodPhotoExampleState();
}

class _FoodPhotoExampleState extends State<FoodPhotoExample> {
  File? _foodImage;

  void _onImageCaptured(File image) {
    setState(() {
      _foodImage = image;
    });
    // TODO: Implement food recognition logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Photo Recognition'),
      ),
      body: Column(
        children: <Widget>[
          PhotoCaptureWidget(
            onImageCaptured: _onImageCaptured,
            placeholder: 'Tap to take a photo of your food',
          ),
          if (_foodImage != null) ...<Widget>[
            const SizedBox(height: 16),
            Image.file(_foodImage!),
          ],
        ],
      ),
    );
  }
}
