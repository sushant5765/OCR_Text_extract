import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextReconstructor {
  static String fromRecognizedText(RecognizedText recognizedText) {
    final buffer = StringBuffer();
    double previousLineBottom = 0.0;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        // Reconstruct the line text with proper word spacing
        final lineText = _reconstructLine(line);
        buffer.write(lineText);

        // Check vertical gap to next line (if any)
        final currentLineBottom = line.boundingBox.bottom;
        if (previousLineBottom != 0.0) {
          final verticalGap = line.boundingBox.top - previousLineBottom;
          // If gap is more than half the line height, it's a paragraph break
          if (verticalGap > line.boundingBox.height * 0.7) {
            buffer.write('\n\n'); // double newline = paragraph
          } else {
            buffer.write('\n');   // single newline = line break
          }
        } else {
          buffer.write('\n'); // first line
        }
        previousLineBottom = currentLineBottom;
      }
      // Extra newline between blocks (if needed)
      buffer.write('\n');
      previousLineBottom = 0.0; // reset for next block
    }

    return buffer.toString().trim();
  }

  static String _reconstructLine(dynamic line) {
    final elements = line.elements;
    if (elements.isEmpty) return '';

    final output = StringBuffer();
    output.write(elements.first.text);

    for (int i = 1; i < elements.length; i++) {
      final prev = elements[i - 1];
      final curr = elements[i];

      final gap = curr.boundingBox.left - prev.boundingBox.right;

      double avgCharWidth = prev.boundingBox.width / prev.text.length;
      if (avgCharWidth.isNaN || avgCharWidth <= 0) avgCharWidth = 10.0;

      int spacesCount = (gap / avgCharWidth).round();
      spacesCount = spacesCount.clamp(0, 5);

      if (spacesCount > 0) {
        output.write(' ' * spacesCount);
      }
      output.write(curr.text);
    }

    return output.toString();
  }
}