import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_models.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';

class FullTextScreen extends StatefulWidget {
  final ScanModel scan;

  const FullTextScreen({
    Key? key,
    required this.scan,
  }) : super(key: key);

  @override
  _FullTextScreenState createState() => _FullTextScreenState();
}

class _FullTextScreenState extends State<FullTextScreen> {
  bool _isSpeaking = false;
  double _fontSize = 18.0;
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
    TTSService.initTTS();
  }

  @override
  void dispose() {
    TTSService.stop();
    super.dispose();
  }

  // Actions
  Future<void> _toggleSpeech() async {
    if (_isSpeaking) {
      await TTSService.stop();
      setState(() => _isSpeaking = false);
    } else {
      await TTSService.speak(widget.scan.extractedText);
      setState(() => _isSpeaking = true);
    }
  }

  Future<void> _copyToClipboard() async {
    await FlutterClipboard.copy(widget.scan.extractedText);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard'), backgroundColor: Colors.blue),
    );
  }

  Future<void> _shareText() async {
    await Share.share(widget.scan.extractedText, subject: 'Extracted Text from Textify OCR');
  }

  Future<void> _translateText() async {
    if (widget.scan.extractedText.isEmpty) return;
    setState(() => _isTranslating = true);
    final translated = await TranslationService.translate(
      widget.scan.extractedText,
      _selectedLanguage,
    );
    setState(() {
      _translatedText = translated;
      _isTranslating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Translation complete'), duration: Duration(seconds: 1)),
    );
  }

  // Font & spacing controls
  void _increaseFontSize() => setState(() => _fontSize = (_fontSize + 1).clamp(12, 32));
  void _decreaseFontSize() => setState(() => _fontSize = (_fontSize - 1).clamp(12, 32));
  void _increaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing + 0.1).clamp(1.0, 2.5));
  void _decreaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing - 0.1).clamp(1.0, 2.5));

  // Popup menu for sliders
  void _showControlsPopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Text Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: _decreaseFontSize,
                    ),
                    Text('${_fontSize.toInt()}', style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: _increaseFontSize,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Line Spacing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: _decreaseLineSpacing,
                    ),
                    Text(_lineSpacing.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: _increaseLineSpacing,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and menu icon
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Full Text',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.black87),
                    onPressed: _showControlsPopup,
                    tooltip: 'Text controls',
                  ),
                ],
              ),
            ),
            // Scrollable text area (card style)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: SelectableText(
                      widget.scan.extractedText,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: _lineSpacing,
                        color: Colors.black87,
                      ),
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        selectAll: true,
                        cut: false,
                        paste: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Action buttons (TTS, Copy, Share, Translate)
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleSpeech,
                          icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow, size: 20),
                          label: Text(_isSpeaking ? 'Stop' : 'Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSpeaking ? Colors.red : Colors.purple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: Icon(Icons.copy, size: 20),
                          label: Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareText,
                          icon: Icon(Icons.share, size: 20),
                          label: Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Translation section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.translate, size: 20, color: Colors.teal),
                            SizedBox(width: 8),
                            Text('Translate this text:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.teal)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedLanguage,
                                decoration: InputDecoration(
                                  labelText: 'Target language',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                                onChanged: (v) => setState(() => _selectedLanguage = v!),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _isTranslating ? null : _translateText,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isTranslating
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Translate'),
                            ),
                          ],
                        ),
                        if (_translatedText.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 8),
                          SelectableText(
                            _translatedText,
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ],
                    ),
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