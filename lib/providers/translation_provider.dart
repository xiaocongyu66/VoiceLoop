import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/translation_result.dart';
import '../platform/translation_channel.dart';

final translationChannelProvider = Provider<TranslationChannel>(
  (ref) => TranslationChannel(),
);

final translationProvider =
    FutureProvider.family<TranslationResult, (String, String, String)>((
      ref,
      params,
    ) async {
      final (text, sourceLang, targetLang) = params;
      final channel = ref.read(translationChannelProvider);
      try {
        final translated = await channel.translate(
          text,
          sourceLang,
          targetLang,
        );
        return TranslationResult(
          originalText: text,
          translatedText: translated,
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
          timestamp: DateTime.now(),
          confidence: 1.0,
        );
      } catch (e) {
        return TranslationResult(
          originalText: text,
          translatedText: '[Translation failed: $e]',
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
          timestamp: DateTime.now(),
          confidence: 0.0,
        );
      }
    });
