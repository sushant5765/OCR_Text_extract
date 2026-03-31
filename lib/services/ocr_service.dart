import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'image_preprocessor.dart';
import '../utils/text_reconstructor.dart';

class OCRService {
  static final TextRecognizer textRecognizer = TextRecognizer();

  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      final processedPath = await ImagePreprocessor.preprocess(imagePath);
      final inputImage = InputImage.fromFilePath(processedPath);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = TextReconstructor.fromRecognizedText(recognizedText);
      await File(processedPath).delete();

      if (extractedText.isEmpty) {
        return 'No text found in the image.';
      }
      return extractedText;
    } on PlatformException catch (e) {
      throw Exception('OCR engine error: ${e.message}');
    } catch (e) {
      throw Exception('Error extracting text: $e');
    }
  }

  static void dispose() {
    textRecognizer.close();
  }
}