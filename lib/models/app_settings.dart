enum TranslationEngine { mlKit, appleTranslation, systemTranslator }

class AppSettings {
  final String sourceLanguage;
  final String targetLanguage;
  final String asrModelId;
  final String? ttsModelId;
  final TranslationEngine translationEngine;
  final bool autoTranslate;
  final bool autoSpeak;
  final bool mirrorMode;

  const AppSettings({
    this.sourceLanguage = 'zh',
    this.targetLanguage = 'en',
    this.asrModelId = 'sensevoice-small',
    this.ttsModelId,
    this.translationEngine = TranslationEngine.mlKit,
    this.autoTranslate = true,
    this.autoSpeak = true,
    this.mirrorMode = false,
  });

  factory AppSettings.defaults() => const AppSettings();

  AppSettings copyWith({
    String? sourceLanguage,
    String? targetLanguage,
    String? asrModelId,
    Object? ttsModelId = _sentinel,
    TranslationEngine? translationEngine,
    bool? autoTranslate,
    bool? autoSpeak,
    bool? mirrorMode,
  }) {
    return AppSettings(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      asrModelId: asrModelId ?? this.asrModelId,
      ttsModelId: ttsModelId == _sentinel
          ? this.ttsModelId
          : ttsModelId as String?,
      translationEngine: translationEngine ?? this.translationEngine,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      mirrorMode: mirrorMode ?? this.mirrorMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          sourceLanguage == other.sourceLanguage &&
          targetLanguage == other.targetLanguage &&
          asrModelId == other.asrModelId &&
          ttsModelId == other.ttsModelId &&
          translationEngine == other.translationEngine &&
          autoTranslate == other.autoTranslate &&
          autoSpeak == other.autoSpeak &&
          mirrorMode == other.mirrorMode;

  @override
  int get hashCode =>
      sourceLanguage.hashCode ^
      targetLanguage.hashCode ^
      asrModelId.hashCode ^
      ttsModelId.hashCode ^
      translationEngine.hashCode ^
      autoTranslate.hashCode ^
      autoSpeak.hashCode ^
      mirrorMode.hashCode;
}

const _sentinel = Object();
