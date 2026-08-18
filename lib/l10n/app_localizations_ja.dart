// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocJa extends AppLoc {
  AppLocJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => 'ソース言語';

  @override
  String get targetLanguage => 'ターゲット言語';

  @override
  String get history => '履歴';

  @override
  String get historyEmpty => '履歴がありません';

  @override
  String get historyEmptyHint => '録音を開始すると翻訳記録がここに表示されます';

  @override
  String get sessionDetail => 'セッション詳細';

  @override
  String get sessionEmpty => 'メッセージなし';

  @override
  String get sessionEmptyHint => 'このセッションにはまだ翻訳メッセージがありません';

  @override
  String get settings => '設定';

  @override
  String get languageSettings => '言語設定';

  @override
  String get modelSettings => 'モデル設定';

  @override
  String get asrModel => 'ASRモデル';

  @override
  String get ttsModel => 'TTSモデル';

  @override
  String get translationEngine => '翻訳エンジン';

  @override
  String get translationEngineLabel => '翻訳エンジン';

  @override
  String get behaviorSettings => '動作設定';

  @override
  String get autoTranslate => '自動翻訳';

  @override
  String get autoTranslateHint => '認識完了後に自動的に翻訳';

  @override
  String get autoSpeak => '自動音読';

  @override
  String get autoSpeakHint => '翻訳完了後に自動的に音声を再生';

  @override
  String get mirrorMode => 'ミラーモード';

  @override
  String get mirrorModeHint => '上下反転の対面翻訳インターフェースを有効化';

  @override
  String get tapToStart => 'タップして録音開始';

  @override
  String get listening => '聞いています...';

  @override
  String get recognizing => '認識中...';

  @override
  String get translating => '翻訳中...';

  @override
  String get speaking => '読み上げ中...';

  @override
  String get originalText => '原文';

  @override
  String get translatedText => '訳文';

  @override
  String get noTranslationYet => '翻訳結果がここに表示されます';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get delete => '削除';

  @override
  String get export => 'エクスポート';

  @override
  String get share => '共有';

  @override
  String get messages => '件のメッセージ';

  @override
  String get swapLanguages => '言語を交換';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get recordPermissionDenied => 'マイクの権限が必要です';

  @override
  String get modelNotDownloaded => '未ダウンロード';

  @override
  String get initFailed => '初期化に失敗しました。モデルファイルを確認してください';

  @override
  String get exportSuccess => 'エクスポート成功';

  @override
  String get exportFailed => 'エクスポート失敗';

  @override
  String get deleteConfirm => 'このセッションを削除しますか？';

  @override
  String get deleteSessionSuccess => 'セッションを削除しました';

  @override
  String get downloadModel => 'モデルをダウンロード';

  @override
  String get deleteModel => 'モデルを削除';

  @override
  String get modelDownloaded => 'ダウンロード済み';

  @override
  String get downloading => 'ダウンロード中';

  @override
  String get downloadFailed => 'ダウンロード失敗';

  @override
  String get vadModel => 'VADモデル';

  @override
  String get supportedLanguages => '対応言語';

  @override
  String get modelSize => 'サイズ';

  @override
  String get selectModel => 'タップして選択';

  @override
  String get currentModel => '現在使用中';
}
