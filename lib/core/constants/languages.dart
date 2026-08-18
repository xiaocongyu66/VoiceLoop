enum LanguageCode {
  zh,
  en,
  ja,
  ko,
  yue,
  fr,
  de,
  es,
  ru,
  th,
  vi,
}

class LanguageInfo {
  final LanguageCode code;
  final String name;
  final String nativeName;
  final String flag;
  final bool asrSupported;
  final bool ttsSupported;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.asrSupported,
    required this.ttsSupported,
  });
}

class AppLanguages {
  static const List<LanguageInfo> all = [
    LanguageInfo(code: LanguageCode.zh, name: "中文", nativeName: "中文", flag: "🇨🇳", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.en, name: "英文", nativeName: "English", flag: "🇺🇸", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.ja, name: "日文", nativeName: "日本語", flag: "🇯🇵", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.ko, name: "韩文", nativeName: "한국어", flag: "🇰🇷", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.yue, name: "粤语", nativeName: "粵語", flag: "🇭🇰", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.fr, name: "法语", nativeName: "Français", flag: "🇫🇷", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.de, name: "德语", nativeName: "Deutsch", flag: "🇩🇪", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.es, name: "西语", nativeName: "Español", flag: "🇪🇸", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.ru, name: "俄语", nativeName: "Русский", flag: "🇷🇺", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.th, name: "泰语", nativeName: "ไทย", flag: "🇹🇭", asrSupported: true, ttsSupported: true),
    LanguageInfo(code: LanguageCode.vi, name: "越南语", nativeName: "Tiếng Việt", flag: "🇻🇳", asrSupported: true, ttsSupported: true),
  ];

  static LanguageInfo? byCode(String code) {
    final lc = LanguageCode.values.firstWhere(
      (e) => e.name == code,
      orElse: () => LanguageCode.zh,
    );
    return byLanguageCode(lc);
  }

  static LanguageInfo? byLanguageCode(LanguageCode code) {
    for (final info in all) {
      if (info.code == code) return info;
    }
    return null;
  }
}
