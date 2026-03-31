import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'ocr_result_screen.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  final String source;
  const CropScreen({Key? key, required this.imagePath, required this.source}) : super(key: key);

  @override
  _CropScreenState createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Crop Image', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _cropAndProceed,
            child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Center(child: Image.file(File(widget.imagePath))),
    );
  }

  Future<void> _cropAndProceed() async {
    setState(() => _isProcessing = true);
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile == null) {
        // User cancelled – use original image
        _goToOCR(widget.imagePath);
        return;
      }

      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final savedPath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(croppedFile.path).copy(savedPath);
      _goToOCR(savedPath);
    } catch (e) {
      // On any error, still proceed with original image
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cropping failed, using original image'), backgroundColor: Colors.orange),
        );
        _goToOCR(widget.imagePath);
      }
    }
  }

  void _goToOCR(String path) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OCRResultScreen(imagePath: path, source: widget.source)),
      );
    }
    setState(() => _isProcessing = false);
  }
}