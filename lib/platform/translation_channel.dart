import 'package:flutter/services.dart';

import '../core/utils/logger.dart';

class TranslationChannel {
  static const MethodChannel _channel =
      MethodChannel('com.voiceloop.translation');

  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>('translate', {
        'text': text,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      });
      if (result == null) {
        throw PlatformException(
          code: 'null-result',
          message: 'Translation returned null result',
        );
      }
      return result;
    } on PlatformException catch (e) {
      Logger.e('Translation failed: ${e.code} ${e.message}');
      rethrow;
    }
  }

  Future<bool> isSupported(String sourceLang, String targetLang) async {
    try {
      final result = await _channel.invokeMethod<bool>('isSupported', {
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      Logger.w('isSupported check failed: ${e.code} ${e.message}');
      return false;
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('getSupportedLanguages');
      if (result == null) {
        return const [];
      }
      return result.cast<String>();
    } on PlatformException catch (e) {
      Logger.w('getSupportedLanguages failed: ${e.code} ${e.message}');
      return const [];
    }
  }
}
