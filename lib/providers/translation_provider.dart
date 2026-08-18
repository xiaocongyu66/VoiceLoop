import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/translation_result.dart';

final translationProvider =
    FutureProvider.family<TranslationResult, (String, String, String)>((
      ref,
      params,
    ) async {
      final (text, sourceLang, targetLang) = params;
      await Future.delayed(const Duration(milliseconds: 100));
      return TranslationResult(
        originalText: text,
        translatedText: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        timestamp: DateTime.now(),
        confidence: 0.0,
      );
    });
