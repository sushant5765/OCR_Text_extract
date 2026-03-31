import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/scan_models.dart';
import '../services/database_service.dart';
import '../widgets/history_item.dart';
import 'full_text_screen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with time
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Screen title
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // History list
            Expanded(
              child: ValueListenableBuilder<Box<ScanModel>>(
                valueListenable: DatabaseService.scansBox.listenable(),
                builder: (context, box, widget) {
                  final scans = DatabaseService.getAllScans();

                  if (scans.isEmpty) {
                    return Center(
                      child: Text(
                        'No scans yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: scans.length,
                    itemBuilder: (context, index) {
                      final scan = scans[index];
                      return HistoryItem(
                        scan: scan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullTextScreen(scan: scan),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(context, scan);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Made with love
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Made with 💤',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ScanModel scan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Scan'),
          content: Text('Are you sure you want to delete this scan?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                DatabaseService.deleteScan(scan.id);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}