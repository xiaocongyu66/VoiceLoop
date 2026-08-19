import 'dart:io';

import 'package:flutter/services.dart';

import '../core/constants/languages.dart';
import '../core/utils/logger.dart';

class TranslationChannel {
  static const MethodChannel _channel = MethodChannel('com.voiceloop.translation');

  Future<String> translate(String text, String sourceLang, String targetLang) async {
    final srcTag = AppLanguages.mlKitTag(sourceLang);
    final tgtTag = AppLanguages.mlKitTag(targetLang);
    try {
      final result = await _channel.invokeMethod<String>('translate', {
        'text': text,
        'sourceLang': srcTag,
        'targetLang': tgtTag,
      });
      if (result == null) {
        throw PlatformException(code: 'null-result', message: 'Translation returned null');
      }
      return result;
    } on PlatformException catch (e) {
      Logger.e('Translation failed: ${e.code} ${e.message}');
      if (Platform.isAndroid || Platform.isIOS) {
        rethrow;
      }
      return _fallbackTranslate(text, srcTag, tgtTag);
    } on MissingPluginException {
      Logger.w('Translation plugin not available on this platform');
      return _fallbackTranslate(text, srcTag, tgtTag);
    }
  }

  Future<bool> isSupported(String sourceLang, String targetLang) async {
    final srcTag = AppLanguages.mlKitTag(sourceLang);
    final tgtTag = AppLanguages.mlKitTag(targetLang);
    try {
      final result = await _channel.invokeMethod<bool>('isSupported', {
        'sourceLang': srcTag,
        'targetLang': tgtTag,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getSupportedLanguages');
      if (result == null) return const [];
      return result.cast<String>();
    } catch (_) {
      return const [];
    }
  }

  String _fallbackTranslate(String text, String sourceLang, String targetLang) {
    return text;
  }
}
