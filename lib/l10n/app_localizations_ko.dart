// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocKo extends AppLoc {
  AppLocKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'VoiceLoop';

  @override
  String get sourceLanguage => '원본 언어';

  @override
  String get targetLanguage => '대상 언어';

  @override
  String get history => '기록';

  @override
  String get historyEmpty => '기록이 없습니다';

  @override
  String get historyEmptyHint => '녹음을 시작하면 번역 기록이 여기에 표시됩니다';

  @override
  String get sessionDetail => '세션 상세';

  @override
  String get sessionEmpty => '메시지 없음';

  @override
  String get sessionEmptyHint => '이 세션에는 아직 번역 메시지가 없습니다';

  @override
  String get settings => '설정';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get modelSettings => '모델 설정';

  @override
  String get asrModel => 'ASR 모델';

  @override
  String get ttsModel => 'TTS 모델';

  @override
  String get translationEngine => '번역 엔진';

  @override
  String get translationEngineLabel => '번역 엔진';

  @override
  String get behaviorSettings => '동작 설정';

  @override
  String get autoTranslate => '자동 번역';

  @override
  String get autoTranslateHint => '인식 완료 후 자동으로 번역';

  @override
  String get autoSpeak => '자동 읽기';

  @override
  String get autoSpeakHint => '번역 완료 후 자동으로 음성 재생';

  @override
  String get mirrorMode => '미러 모드';

  @override
  String get mirrorModeHint => '상하 반전된 대면 번역 인터페이스 활성화';

  @override
  String get tapToStart => '탭하여 녹음 시작';

  @override
  String get listening => '듣고 있습니다...';

  @override
  String get recognizing => '인식 중...';

  @override
  String get translating => '번역 중...';

  @override
  String get speaking => '읽는 중...';

  @override
  String get originalText => '원문';

  @override
  String get translatedText => '번역문';

  @override
  String get noTranslationYet => '번역 결과가 여기에 표시됩니다';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get delete => '삭제';

  @override
  String get export => '내보내기';

  @override
  String get share => '공유';

  @override
  String get messages => '개 메시지';

  @override
  String get swapLanguages => '언어 교환';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get recordPermissionDenied => '마이크 권한이 필요합니다';

  @override
  String get modelNotDownloaded => '모델이 다운로드되지 않았습니다. 설정에서 먼저 다운로드하세요';

  @override
  String get initFailed => '초기화 실패. 모델 파일을 확인하세요';

  @override
  String get exportSuccess => '내보내기 성공';

  @override
  String get exportFailed => '내보내기 실패';

  @override
  String get deleteConfirm => '이 세션을 삭제하시겠습니까?';

  @override
  String get deleteSessionSuccess => '세션이 삭제되었습니다';
}
