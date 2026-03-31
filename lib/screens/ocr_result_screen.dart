import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_models.dart';
import '../services/database_service.dart';
import '../services/ocr_service.dart';
import '../services/tts_service.dart';
import '../services/ad_service.dart';
import '../services/translation_service.dart';
import 'full_text_screen.dart';

class OCRResultScreen extends StatefulWidget {
  final String imagePath;
  final String source;
  const OCRResultScreen({Key? key, required this.imagePath, required this.source}) : super(key: key);
  @override
  _OCRResultScreenState createState() => _OCRResultScreenState();
}

class _OCRResultScreenState extends State<OCRResultScreen> {
  bool _isLoading = true;
  String _extractedText = '';
  bool _isSaved = false;
  bool _isSpeaking = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Text style controls
  double _fontSize = 16.0;
  double _lineSpacing = 1.5;

  // Translation
  String _translatedText = '';
  bool _isTranslating = false;
  String _selectedLanguage = 'ne';
  final Map<String, String> languages = {
    'ne': '🇳🇵 Nepali',
    'hi': '🇮🇳 Hindi',
    'bn': '🇧🇩 Bengali',
    'es': '🇪🇸 Spanish',
    'fr': '🇫🇷 French',
    'de': '🇩🇪 German',
    'it': '🇮🇹 Italian',
    'pt': '🇵🇹 Portuguese',
    'ru': '🇷🇺 Russian',
    'zh': '🇨🇳 Chinese',
    'ja': '🇯🇵 Japanese',
    'ko': '🇰🇷 Korean',
    'ar': '🇸🇦 Arabic',
    'tr': '🇹🇷 Turkish',
    'vi': '🇻🇳 Vietnamese',
    'th': '🇹🇭 Thai',
  };

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
    _bannerAd?.load().then((_) => setState(() => _isBannerAdReady = true));
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _extractText() async {
    try {
      final text = await OCRService.extractTextFromImage(widget.imagePath);
      setState(() {
        _extractedText = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = 'Error extracting text: $e';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan saved to history'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save scan'), backgroundColor: Colors.red));
    }
  }

  Future<void> _copyToClipboard() async {
    await FlutterClipboard.copy(_extractedText);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Text copied to clipboard'), backgroundColor: Colors.blue));
  }

  Future<void> _shareText() async {
    await Share.share(_extractedText, subject: 'Extracted Text from Textify OCR');
  }

  Future<void> _translateText() async {
    if (_extractedText.isEmpty) return;
    setState(() => _isTranslating = true);
    final translated = await TranslationService.translate(_extractedText, _selectedLanguage);
    setState(() {
      _translatedText = translated;
      _isTranslating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Translation complete'), duration: Duration(seconds: 1)));
  }

  void _navigateToFullTextScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullTextScreen(scan: ScanModel(id: 'temp', extractedText: _extractedText, timestamp: DateTime.now(), source: widget.source))));
    AdService.showInterstitialAd2();
  }

  void _increaseFontSize() => setState(() => _fontSize = (_fontSize + 1).clamp(12, 32));
  void _decreaseFontSize() => setState(() => _fontSize = (_fontSize - 1).clamp(12, 32));
  void _increaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing + 0.1).clamp(1.0, 2.5));
  void _decreaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing - 0.1).clamp(1.0, 2.5));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(padding: EdgeInsets.all(16), child: Row(children: [
              IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Expanded(child: Center(child: Text('9:41', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
              SizedBox(width: 48),
            ])),
            Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Extracted Text', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Extracting text...', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ]))
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _extractedText,
                        style: TextStyle(fontSize: _fontSize, height: _lineSpacing, color: Colors.black87),
                        toolbarOptions: ToolbarOptions(copy: true, selectAll: true, cut: false, paste: false),
                        showCursor: true,
                        cursorColor: Colors.blue,
                        cursorWidth: 2,
                        cursorRadius: Radius.circular(1),
                      ),
                      SizedBox(height: 20),
                      if (_extractedText.length > 200)
                        Center(child: TextButton(onPressed: _navigateToFullTextScreen, child: Text('View Full Text', style: TextStyle(fontSize: 16, color: Colors.blue)))),
                      // Text style controls
                      Card(
                        margin: EdgeInsets.only(top: 16),
                        elevation: 0,
                        color: Colors.grey[50],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Text Size', style: TextStyle(fontWeight: FontWeight.w500)),
                                Row(children: [
                                  IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: _decreaseFontSize),
                                  Text('${_fontSize.toInt()}', style: TextStyle(fontSize: 16)),
                                  IconButton(icon: Icon(Icons.add_circle_outline), onPressed: _increaseFontSize),
                                ]),
                              ]),
                              SizedBox(height: 8),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Line Spacing', style: TextStyle(fontWeight: FontWeight.w500)),
                                Row(children: [
                                  IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: _decreaseLineSpacing),
                                  Text(_lineSpacing.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
                                  IconButton(icon: Icon(Icons.add_circle_outline), onPressed: _increaseLineSpacing),
                                ]),
                              ]),
                            ],
                          ),
                        ),
                      ),
                      // Translation section
                      Divider(height: 32),
                      Row(children: [Icon(Icons.translate, size: 20, color: Colors.teal), SizedBox(width: 8), Text('Translate this text:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.teal))]),
                      SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(labelText: 'Target language', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                            onChanged: (v) => setState(() => _selectedLanguage = v!),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isTranslating ? null : _translateText,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                          child: _isTranslating ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Translate'),
                        ),
                      ]),
                      if (_translatedText.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        SelectableText(_translatedText, style: TextStyle(fontSize: 16, height: 1.5)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_isBannerAdReady) Container(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!)),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _isLoading ? null : _toggleSpeech, icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow, size: 20), label: Text(_isSpeaking ? 'Stop' : 'Play Text'), style: ElevatedButton.styleFrom(backgroundColor: _isSpeaking ? Colors.red : Colors.purple, padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                  SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(onPressed: _isLoading ? null : _copyToClipboard, icon: Icon(Icons.copy, size: 20), label: Text('Copy Text'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                ]),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _isLoading ? null : _shareText, icon: Icon(Icons.share, size: 20), label: Text('Share Text'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                  SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(onPressed: _isLoading || _isSaved ? null : _saveToHistory, icon: Icon(_isSaved ? Icons.check : Icons.save, size: 20), label: Text(_isSaved ? 'Saved' : 'Save'), style: ElevatedButton.styleFrom(backgroundColor: _isSaved ? Colors.grey : Colors.orange, padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}