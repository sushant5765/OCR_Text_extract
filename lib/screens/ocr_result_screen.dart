import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_models.dart';
import '../services/database_service.dart';
import '../services/ocr_service.dart';
import '../services/tts_service.dart';
import '../services/ad_service.dart';
import 'full_text_screen.dart';

class OCRResultScreen extends StatefulWidget {
  final String imagePath;
  final String source;
  const OCRResultScreen({Key? key, required this.imagePath, required this.source}) : super(key: key);

  @override
  State<OCRResultScreen> createState() => _OCRResultScreenState();
}

class _OCRResultScreenState extends State<OCRResultScreen> {
  bool _isLoading = true;
  String _extractedText = '';
  bool _isSaved = false;
  bool _isSpeaking = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _extractText();
    TTSService.initTTS();
    _loadBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) => AdService.showInterstitialAd1());
  }

  void _loadBannerAd() {
    _bannerAd = AdService.loadBannerAd();
    _bannerAd?.load().then((_) {
      if (mounted) setState(() => _isBannerAdReady = true);
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    TTSService.stop();
    super.dispose();
  }

  Future<void> _extractText() async {
    setState(() => _isLoading = true);
    try {
      final text = await OCRService.extractTextFromImage(widget.imagePath);
      setState(() {
        _extractedText = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await TTSService.stop();
      setState(() => _isSpeaking = false);
    } else {
      await TTSService.speak(_extractedText);
      setState(() => _isSpeaking = true);
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final scan = ScanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        extractedText: _extractedText,
        timestamp: DateTime.now(),
        source: widget.source,
        imagePath: widget.imagePath,
      );
      await DatabaseService.addScan(scan);
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to history'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    await FlutterClipboard.copy(_extractedText);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Colors.blue),
    );
  }

  Future<void> _shareText() async {
    await Share.share(_extractedText, subject: 'Extracted Text');
  }

  void _navigateToFullTextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullTextScreen(
          scan: ScanModel(
            id: 'temp',
            extractedText: _extractedText,
            timestamp: DateTime.now(),
            source: widget.source,
            imagePath: widget.imagePath,
          ),
        ),
      ),
    );
    AdService.showInterstitialAd2();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('OCR Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Text area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Extracting text...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _extractedText,
                          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton.icon(
                        onPressed: _navigateToFullTextScreen,
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('View Full Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Banner ad
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            // Action buttons: Play, Copy, Share, Save
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _toggleSpeech,
                          icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow, size: 20),
                          label: Text(_isSpeaking ? 'Stop' : 'Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSpeaking ? Colors.red : Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _copyToClipboard,
                          icon: const Icon(Icons.copy, size: 20),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _shareText,
                          icon: const Icon(Icons.share, size: 20),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || _isSaved) ? null : _saveToHistory,
                          icon: Icon(_isSaved ? Icons.check : Icons.save, size: 20),
                          label: Text(_isSaved ? 'Saved' : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaved ? Colors.grey : Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}