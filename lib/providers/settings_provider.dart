import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const _prefix = 'settings_';
  SharedPreferences? _prefs;

  SettingsNotifier() : super(AppSettings.defaults());

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    state = AppSettings(
      sourceLanguage: p.getString('${_prefix}sourceLang') ?? 'zh',
      targetLanguage: p.getString('${_prefix}targetLang') ?? 'en',
      asrModelId: p.getString('${_prefix}asrModelId') ?? 'sensevoice-small',
      ttsModelId: p.getString('${_prefix}ttsModelId'),
      translationEngine: TranslationEngine.values.firstWhere(
        (e) =>
            e.name == (p.getString('${_prefix}translationEngine') ?? 'mlKit'),
        orElse: () => TranslationEngine.mlKit,
      ),
      autoTranslate: p.getBool('${_prefix}autoTranslate') ?? true,
      autoSpeak: p.getBool('${_prefix}autoSpeak') ?? true,
      mirrorMode: p.getBool('${_prefix}mirrorMode') ?? false,
    );
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString('${_prefix}sourceLang', state.sourceLanguage);
    await prefs.setString('${_prefix}targetLang', state.targetLanguage);
    await prefs.setString('${_prefix}asrModelId', state.asrModelId);
    if (state.ttsModelId != null) {
      await prefs.setString('${_prefix}ttsModelId', state.ttsModelId!);
    }
    await prefs.setString(
        '${_prefix}translationEngine', state.translationEngine.name);
    await prefs.setBool('${_prefix}autoTranslate', state.autoTranslate);
    await prefs.setBool('${_prefix}autoSpeak', state.autoSpeak);
    await prefs.setBool('${_prefix}mirrorMode', state.mirrorMode);
  }

  Future<void> updateSourceLang(String lang) async {
    state = state.copyWith(sourceLanguage: lang);
    await _persist();
  }

  Future<void> updateTargetLang(String lang) async {
    state = state.copyWith(targetLanguage: lang);
    await _persist();
  }

  Future<void> toggleAutoTranslate() async {
    state = state.copyWith(autoTranslate: !state.autoTranslate);
    await _persist();
  }

  Future<void> toggleAutoSpeak() async {
    state = state.copyWith(autoSpeak: !state.autoSpeak);
    await _persist();
  }

  Future<void> toggleMirrorMode() async {
    state = state.copyWith(mirrorMode: !state.mirrorMode);
    await _persist();
  }

  Future<void> updateAsrModel(String modelId) async {
    state = state.copyWith(asrModelId: modelId);
    await _persist();
  }

  Future<void> updateTranslationEngine(TranslationEngine engine) async {
    state = state.copyWith(translationEngine: engine);
    await _persist();
  }

  Future<void> swapLanguages() async {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
    );
    await _persist();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
