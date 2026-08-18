// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocEn extends AppLoc {
  AppLocEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => 'Source Language';

  @override
  String get targetLanguage => 'Target Language';

  @override
  String get history => 'History';

  @override
  String get historyEmpty => 'No sessions yet';

  @override
  String get historyEmptyHint =>
      'Start recording and translations will appear here';

  @override
  String get sessionDetail => 'Session Details';

  @override
  String get sessionEmpty => 'No messages';

  @override
  String get sessionEmptyHint => 'No translation messages in this session yet';

  @override
  String get settings => 'Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get modelSettings => 'Model Settings';

  @override
  String get asrModel => 'ASR Model';

  @override
  String get ttsModel => 'TTS Model';

  @override
  String get translationEngine => 'Translation Engine';

  @override
  String get translationEngineLabel => 'Translation Engine';

  @override
  String get behaviorSettings => 'Behavior Settings';

  @override
  String get autoTranslate => 'Auto Translate';

  @override
  String get autoTranslateHint => 'Automatically translate after recognition';

  @override
  String get autoSpeak => 'Auto Speak';

  @override
  String get autoSpeakHint => 'Automatically play audio after translation';

  @override
  String get mirrorMode => 'Mirror Mode';

  @override
  String get mirrorModeHint => 'Enable face-to-face translation interface';

  @override
  String get tapToStart => 'Tap to start recording';

  @override
  String get listening => 'Listening...';

  @override
  String get recognizing => 'Recognizing...';

  @override
  String get translating => 'Translating...';

  @override
  String get speaking => 'Speaking...';

  @override
  String get originalText => 'Original';

  @override
  String get translatedText => 'Translation';

  @override
  String get noTranslationYet => 'Translation will appear here';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get export => 'Export';

  @override
  String get share => 'Share';

  @override
  String get messages => 'messages';

  @override
  String get swapLanguages => 'Swap Languages';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get recordPermissionDenied => 'Microphone permission required';

  @override
  String get modelNotDownloaded => 'Not Downloaded';

  @override
  String get initFailed => 'Initialization failed, please check model files';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this session?';

  @override
  String get deleteSessionSuccess => 'Session deleted';

  @override
  String get downloadModel => 'Download Model';

  @override
  String get deleteModel => 'Delete Model';

  @override
  String get modelDownloaded => 'Downloaded';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloadFailed => 'Download Failed';

  @override
  String get vadModel => 'VAD Model';

  @override
  String get supportedLanguages => 'Supported Languages';

  @override
  String get modelSize => 'Size';

  @override
  String get selectModel => 'Tap to select';

  @override
  String get currentModel => 'Current';
}
