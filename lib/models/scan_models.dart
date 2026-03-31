import 'package:hive/hive.dart';

class ScanModel {
  final String id;
  final String extractedText;
  final DateTime timestamp;
  final String source;
  final String? imagePath;

  ScanModel({
    required this.id,
    required this.extractedText,
    required this.timestamp,
    required this.source,
    this.imagePath,
  });

  // Helper method to get preview text (first few words)
  String get previewText {
    if (extractedText.length <= 50) {
      return extractedText;
    }
    return '${extractedText.substring(0, 50)}...';
  }

  // Format date for display
  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour < 12 ? 'AM' : 'PM'}';
  }

  // Convert to Map for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'extractedText': extractedText,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source,
      'imagePath': imagePath,
    };
  }

  // Create from Map for Hive
  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      extractedText: map['extractedText'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      source: map['source'],
      imagePath: map['imagePath'],
    );
  }
}

// Hive TypeAdapter without code generation
class ScanModelAdapter extends TypeAdapter<ScanModel> {
  @override
  final int typeId = 0;

  @override
  ScanModel read(BinaryReader reader) {
    final map = reader.readMap().map((key, value) => MapEntry(key as String, value));
    return ScanModel.fromMap(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, ScanModel obj) {
    writer.writeMap(obj.toMap());
  }
}