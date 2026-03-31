import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocessor {
  static Future<String> preprocess(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) {
      throw Exception('Could not decode image: $imagePath');
    }

    // Convert to grayscale only – this always exists
    img.Image grayscale = img.grayscale(original);

    final tempDir = await getTemporaryDirectory();
    final processedPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';
    final processedFile = File(processedPath);
    await processedFile.writeAsBytes(img.encodePng(grayscale));

    return processedPath;
  }
}