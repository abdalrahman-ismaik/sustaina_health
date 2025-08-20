import 'dart:io';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';

class PhotoCaptureWidget extends StatefulWidget {
  final Function(File) onImageCaptured;
  final String? placeholder;
  final double? width;
  final double? height;

  const PhotoCaptureWidget({
    Key? key,
    required this.onImageCaptured,
    this.placeholder,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  File? _imageFile;
  final CameraService _cameraService = CameraService();

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      File? imageFile;
      if (source == ImageSource.camera) {
        imageFile = await _cameraService.takePicture();
      } else {
        imageFile = await _cameraService.pickImageFromGallery();
      }

      if (imageFile != null) {
        setState(() {
          _imageFile = imageFile;
        });
        widget.onImageCaptured(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 200,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _imageFile != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _showImageSourceDialog,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.placeholder ?? 'Add Photo',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// For backward compatibility with the camera package
enum ImageSource { camera, gallery }
