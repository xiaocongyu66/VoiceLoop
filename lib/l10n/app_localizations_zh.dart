// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocZh extends AppLoc {
  AppLocZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => '源语言';

  @override
  String get targetLanguage => '目标语言';

  @override
  String get history => '历史会话';

  @override
  String get historyEmpty => '暂无历史会话';

  @override
  String get historyEmptyHint => '开始录音后，翻译记录会出现在这里';

  @override
  String get sessionDetail => '会话详情';

  @override
  String get sessionEmpty => '暂无消息';

  @override
  String get sessionEmptyHint => '此会话中还没有翻译消息';

  @override
  String get settings => '设置';

  @override
  String get languageSettings => '语言设置';

  @override
  String get modelSettings => '模型设置';

  @override
  String get asrModel => 'ASR 模型';

  @override
  String get ttsModel => 'TTS 模型';

  @override
  String get translationEngine => '翻译引擎';

  @override
  String get translationEngineLabel => '翻译引擎';

  @override
  String get behaviorSettings => '行为设置';

  @override
  String get autoTranslate => '自动翻译';

  @override
  String get autoTranslateHint => '识别完成后自动翻译';

  @override
  String get autoSpeak => '自动朗读';

  @override
  String get autoSpeakHint => '翻译完成后自动播放语音';

  @override
  String get mirrorMode => '面对面模式';

  @override
  String get mirrorModeHint => '启用上下翻转的面对面翻译界面';

  @override
  String get tapToStart => '点击开始录音';

  @override
  String get listening => '正在聆听...';

  @override
  String get recognizing => '识别中...';

  @override
  String get translating => '翻译中...';

  @override
  String get speaking => '朗读中...';

  @override
  String get originalText => '原文';

  @override
  String get translatedText => '译文';

  @override
  String get noTranslationYet => '翻译结果将显示在这里';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get export => '导出';

  @override
  String get share => '分享';

  @override
  String get messages => '条消息';

  @override
  String get swapLanguages => '交换语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get recordPermissionDenied => '需要麦克风权限';

  @override
  String get modelNotDownloaded => '未下载';

  @override
  String get initFailed => '初始化失败，请检查模型文件';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get exportFailed => '导出失败';

  @override
  String get deleteConfirm => '确定要删除这个会话吗？';

  @override
  String get deleteSessionSuccess => '已删除会话';

  @override
  String get downloadModel => '下载模型';

  @override
  String get deleteModel => '删除模型';

  @override
  String get modelDownloaded => '已下载';

  @override
  String get downloading => '下载中';

  @override
  String get downloadFailed => '下载失败';

  @override
  String get vadModel => 'VAD 模型';

  @override
  String get supportedLanguages => '支持语言';

  @override
  String get modelSize => '大小';

  @override
  String get selectModel => '点击选择';

  @override
  String get currentModel => '当前使用';
}
