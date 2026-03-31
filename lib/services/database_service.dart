import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/scan_models.dart';

class DatabaseService {
  static late Box<ScanModel> scansBox;

  static Future<void> init() async {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register the manual adapter
    Hive.registerAdapter(ScanModelAdapter());

    // Open scans box
    scansBox = await Hive.openBox<ScanModel>('scans');
  }

  // Add new scan
  static Future<void> addScan(ScanModel scan) async {
    await scansBox.put(scan.id, scan);
  }

  // Get all scans sorted by timestamp (newest first)
  static List<ScanModel> getAllScans() {
    final allScans = scansBox.values.toList();
    allScans.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allScans;
  }

  // Delete scan by id
  static Future<void> deleteScan(String id) async {
    await scansBox.delete(id);
  }

  // Delete all scans
  static Future<void> deleteAllScans() async {
    await scansBox.clear();
  }

  // Close Hive boxes
  static Future<void> close() async {
    await Hive.close();
  }
}