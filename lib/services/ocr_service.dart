import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'image_preprocessor.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from an image using ML Kit with preprocessing
  static Future<String> extractTextFromImage(String imagePath) async {
    try {
      // Step 1: Preprocess the image
      final processedPath = await ImagePreprocessor.preprocess(imagePath);

      // Step 2: Create input for ML Kit
      final inputImage = InputImage.fromFilePath(processedPath);

      // Step 3: Run text recognition
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Step 4: Clean up temporary file if it's different from original
      if (processedPath != imagePath) {
        await File(processedPath).delete();
      }

      // Step 5: Return the extracted text
      final extractedText = recognizedText.text;
      return extractedText.isEmpty ? "No text found in the image." : extractedText;
    } catch (e) {
      throw Exception("OCR failed: $e");
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}