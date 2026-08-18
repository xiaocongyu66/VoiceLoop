import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLoc
/// returned by `AppLoc.of(context)`.
///
/// Applications need to include `AppLoc.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLoc.localizationsDelegates,
///   supportedLocales: AppLoc.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLoc.supportedLocales
/// property.
abstract class AppLoc {
  AppLoc(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLoc? of(BuildContext context) {
    return Localizations.of<AppLoc>(context, AppLoc);
  }

  static const LocalizationsDelegate<AppLoc> delegate = _AppLocDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('fr'),
    Locale('de'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'VoiceLoop'**
  String get appTitle;

  /// No description provided for @sourceLanguage.
  ///
  /// In zh, this message translates to:
  /// **'源语言'**
  String get sourceLanguage;

  /// No description provided for @targetLanguage.
  ///
  /// In zh, this message translates to:
  /// **'目标语言'**
  String get targetLanguage;

  /// No description provided for @history.
  ///
  /// In zh, this message translates to:
  /// **'历史会话'**
  String get history;

  /// No description provided for @historyEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无历史会话'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'开始录音后，翻译记录会出现在这里'**
  String get historyEmptyHint;

  /// No description provided for @sessionDetail.
  ///
  /// In zh, this message translates to:
  /// **'会话详情'**
  String get sessionDetail;

  /// No description provided for @sessionEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get sessionEmpty;

  /// No description provided for @sessionEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'此会话中还没有翻译消息'**
  String get sessionEmptyHint;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @languageSettings.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get languageSettings;

  /// No description provided for @modelSettings.
  ///
  /// In zh, this message translates to:
  /// **'模型设置'**
  String get modelSettings;

  /// No description provided for @asrModel.
  ///
  /// In zh, this message translates to:
  /// **'ASR 模型'**
  String get asrModel;

  /// No description provided for @ttsModel.
  ///
  /// In zh, this message translates to:
  /// **'TTS 模型'**
  String get ttsModel;

  /// No description provided for @translationEngine.
  ///
  /// In zh, this message translates to:
  /// **'翻译引擎'**
  String get translationEngine;

  /// No description provided for @translationEngineLabel.
  ///
  /// In zh, this message translates to:
  /// **'翻译引擎'**
  String get translationEngineLabel;

  /// No description provided for @behaviorSettings.
  ///
  /// In zh, this message translates to:
  /// **'行为设置'**
  String get behaviorSettings;

  /// No description provided for @autoTranslate.
  ///
  /// In zh, this message translates to:
  /// **'自动翻译'**
  String get autoTranslate;

  /// No description provided for @autoTranslateHint.
  ///
  /// In zh, this message translates to:
  /// **'识别完成后自动翻译'**
  String get autoTranslateHint;

  /// No description provided for @autoSpeak.
  ///
  /// In zh, this message translates to:
  /// **'自动朗读'**
  String get autoSpeak;

  /// No description provided for @autoSpeakHint.
  ///
  /// In zh, this message translates to:
  /// **'翻译完成后自动播放语音'**
  String get autoSpeakHint;

  /// No description provided for @mirrorMode.
  ///
  /// In zh, this message translates to:
  /// **'面对面模式'**
  String get mirrorMode;

  /// No description provided for @mirrorModeHint.
  ///
  /// In zh, this message translates to:
  /// **'启用上下翻转的面对面翻译界面'**
  String get mirrorModeHint;

  /// No description provided for @tapToStart.
  ///
  /// In zh, this message translates to:
  /// **'点击开始录音'**
  String get tapToStart;

  /// No description provided for @listening.
  ///
  /// In zh, this message translates to:
  /// **'正在聆听...'**
  String get listening;

  /// No description provided for @recognizing.
  ///
  /// In zh, this message translates to:
  /// **'识别中...'**
  String get recognizing;

  /// No description provided for @translating.
  ///
  /// In zh, this message translates to:
  /// **'翻译中...'**
  String get translating;

  /// No description provided for @speaking.
  ///
  /// In zh, this message translates to:
  /// **'朗读中...'**
  String get speaking;

  /// No description provided for @originalText.
  ///
  /// In zh, this message translates to:
  /// **'原文'**
  String get originalText;

  /// No description provided for @translatedText.
  ///
  /// In zh, this message translates to:
  /// **'译文'**
  String get translatedText;

  /// No description provided for @noTranslationYet.
  ///
  /// In zh, this message translates to:
  /// **'翻译结果将显示在这里'**
  String get noTranslationYet;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @export.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get export;

  /// No description provided for @share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share;

  /// No description provided for @messages.
  ///
  /// In zh, this message translates to:
  /// **'条消息'**
  String get messages;

  /// No description provided for @swapLanguages.
  ///
  /// In zh, this message translates to:
  /// **'交换语言'**
  String get swapLanguages;

  /// No description provided for @selectLanguage.
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get selectLanguage;

  /// No description provided for @recordPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'需要麦克风权限'**
  String get recordPermissionDenied;

  /// No description provided for @modelNotDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'模型未下载，请先在设置中下载'**
  String get modelNotDownloaded;

  /// No description provided for @initFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败，请检查模型文件'**
  String get initFailed;

  /// No description provided for @exportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'导出成功'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get exportFailed;

  /// No description provided for @deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个会话吗？'**
  String get deleteConfirm;

  /// No description provided for @deleteSessionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已删除会话'**
  String get deleteSessionSuccess;
}

class _AppLocDelegate extends LocalizationsDelegate<AppLoc> {
  const _AppLocDelegate();

  @override
  Future<AppLoc> load(Locale locale) {
    return SynchronousFuture<AppLoc>(lookupAppLoc(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocDelegate old) => false;
}

AppLoc lookupAppLoc(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocDe();
    case 'en':
      return AppLocEn();
    case 'fr':
      return AppLocFr();
    case 'ja':
      return AppLocJa();
    case 'ko':
      return AppLocKo();
    case 'zh':
      return AppLocZh();
  }

  throw FlutterError(
    'AppLoc.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
