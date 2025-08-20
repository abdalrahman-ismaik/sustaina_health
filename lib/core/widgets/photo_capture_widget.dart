import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/camera_service.dart';

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
