import 'package:translator/translator.dart';

class TranslationService {
  static final translator = GoogleTranslator();

  static Future<String> translate(String text, String targetLang) async {
    try {
      final translation = await translator.translate(text, to: targetLang);
      return translation.text;
    } catch (e) {
      return 'Translation failed: $e';
    }
  }
}