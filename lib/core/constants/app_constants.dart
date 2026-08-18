class AppConstants {
  static const int sampleRate = 16000;
  static const int channels = 1;
  static const int bitsPerSample = 16;
  static const String modelBaseDir = "models";
  static const String senseVoiceModelId = "sensevoice-small";
  static const String sileroVadModelId = "silero-vad";
  static const String defaultSourceLang = "zh";
  static const String defaultTargetLang = "en";
  static const List<String> supportedLanguages = [
    "zh",
    "en",
    "ja",
    "ko",
    "yue",
    "fr",
    "de",
    "es",
    "ru",
    "th",
    "vi",
  ];
  static const int maxRecordingDurationSeconds = 300;
  static const double vadThreshold = 0.5;
  static const int vadMinSilenceMs = 500;
  static const int vadSpeechPadMs = 100;
}
