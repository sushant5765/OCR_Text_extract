import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_models.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';

class FullTextScreen extends StatefulWidget {
  final ScanModel scan;
  const FullTextScreen({Key? key, required this.scan}) : super(key: key);

  @override
  State<FullTextScreen> createState() => _FullTextScreenState();
}

class _FullTextScreenState extends State<FullTextScreen> {
  bool _isSpeaking = false;
  double _fontSize = 18.0;
  double _lineSpacing = 1.5;
  String _translatedText = '';
  bool _isTranslating = false;
  String _selectedLanguage = 'ne';
  bool _isSaved = false;

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
      const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Colors.blue),
    );
  }

  Future<void> _shareText() async {
    await Share.share(widget.scan.extractedText, subject: 'Extracted Text');
  }

  Future<void> _saveToHistory() async {
    try {
      await DatabaseService.addScan(widget.scan);
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

  Future<void> _translateText() async {
    if (widget.scan.extractedText.isEmpty) return;
    setState(() => _isTranslating = true);
    final translated = await TranslationService.translate(widget.scan.extractedText, _selectedLanguage);
    setState(() {
      _translatedText = translated;
      _isTranslating = false;
    });
  }

  void _increaseFontSize() => setState(() => _fontSize = (_fontSize + 1).clamp(12, 32));
  void _decreaseFontSize() => setState(() => _fontSize = (_fontSize - 1).clamp(12, 32));
  void _increaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing + 0.1).clamp(1.0, 2.5));
  void _decreaseLineSpacing() => setState(() => _lineSpacing = (_lineSpacing - 0.1).clamp(1.0, 2.5));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Full Text', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyToClipboard, tooltip: 'Copy'),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareText, tooltip: 'Share'),
          IconButton(
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            onPressed: _toggleSpeech,
            tooltip: _isSpeaking ? 'Stop' : 'Read aloud',
          ),
          IconButton(
            icon: Icon(_isSaved ? Icons.check : Icons.save),
            onPressed: _isSaved ? null : _saveToHistory,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls for font size and line spacing
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_size, color: Colors.blue),
                      onPressed: _decreaseFontSize,
                      style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                    ),
                    Text('${_fontSize.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.format_size, color: Colors.blue),
                      onPressed: _increaseFontSize,
                      style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1)),
                    ),
                    const Text('Size'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_line_spacing, color: Colors.teal),
                      onPressed: _decreaseLineSpacing,
                      style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.1)),
                    ),
                    Text(_lineSpacing.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.format_line_spacing, color: Colors.teal),
                      onPressed: _increaseLineSpacing,
                      style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.1)),
                    ),
                    const Text('Spacing'),
                  ],
                ),
              ],
            ),
          ),
          // Main text - Use Expanded to take remaining space
          Expanded(
            flex: 3, // Give more weight to main text
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: SelectableText(
                    widget.scan.extractedText,
                    style: TextStyle(fontSize: _fontSize, height: _lineSpacing, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          // Translation section - Now wrapped in SingleChildScrollView
          Expanded(
            flex: 1, // Give less weight to translation section
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.translate, size: 20, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Translate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              labelText: 'Target language',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                            onChanged: (v) => setState(() => _selectedLanguage = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isTranslating ? null : _translateText,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isTranslating
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Translate'),
                        ),
                      ],
                    ),
                    if (_translatedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(
                        _translatedText,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}