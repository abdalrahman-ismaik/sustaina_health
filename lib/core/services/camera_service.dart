import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Take a photo using the camera
  Future<File?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } on PlatformException catch (e) {
      throw CameraException('Failed to take picture: ${e.message}');
    } catch (e) {
      throw CameraException('Unexpected error: $e');
    }
  }

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } on PlatformException catch (e) {
      throw CameraException('Failed to pick image: ${e.message}');
    } catch (e) {
      throw CameraException('Unexpected error: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        return images.map((image) => File(image.path)).toList();
      }
      return null;
    } on PlatformException catch (e) {
      throw CameraException('Failed to pick images: ${e.message}');
    } catch (e) {
      throw CameraException('Unexpected error: $e');
    }
  }

  /// Show options to either take photo or pick from gallery
  Future<File?> showImageSourceOptions() async {
    // This method would typically show a dialog in the UI layer
    // For now, it defaults to camera
    return takePicture();
  }
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);

  @override
  String toString() => 'CameraException: $message';
}
