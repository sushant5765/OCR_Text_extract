import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts flutterTts = FlutterTts();
  static bool _isSpeaking = false;

  static Future<void> initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);

    // Handle speech completion
    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    // Handle errors
    flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
    });
  }

  static Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.speak(text);
    _isSpeaking = true;
  }

  static Future<void> stop() async {
    await flutterTts.stop();
    _isSpeaking = false;
  }

  static bool isSpeaking() {
    return _isSpeaking;
  }
}