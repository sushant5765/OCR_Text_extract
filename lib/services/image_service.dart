import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image?.path;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  static Future<String?> captureImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image?.path;
    } catch (e) {
      throw Exception('Error capturing image from camera: $e');
    }
  }

  // Simple crop simulation - we'll skip actual cropping for now
  // You can implement actual cropping later with a compatible package version
  static Future<String?> cropImage(String imagePath) async {
    // For now, return the same image path without actual cropping
    // This allows the app to function while we fix the cropping implementation
    return imagePath;
  }
}