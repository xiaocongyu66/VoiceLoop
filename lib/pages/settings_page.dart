import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../core/extensions/context_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../widgets/language_selector.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SettingsSection(
            title: l.languageSettings,
            icon: Icons.language_rounded,
            children: [
              LanguageSelector(
                value: AppLanguages.byCode(settings.sourceLanguage),
                onChanged: (lang) {
                  if (lang != null) notifier.updateSourceLang(lang.code.name);
                },
                label: l.sourceLanguage,
              ),
              const SizedBox(height: 12),
              LanguageSelector(
                value: AppLanguages.byCode(settings.targetLanguage),
                onChanged: (lang) {
                  if (lang != null) notifier.updateTargetLang(lang.code.name);
                },
                label: l.targetLanguage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.modelSettings,
            icon: Icons.model_training_rounded,
            children: [
              _DropdownTile<String>(
                label: l.asrModel,
                value: settings.asrModelId,
                items: const [
                  DropdownMenuItem(
                    value: 'sensevoice-small',
                    child: Text('SenseVoice Small'),
                  ),
                  DropdownMenuItem(
                    value: 'sensevoice-large',
                    child: Text('SenseVoice Large'),
                  ),
                  DropdownMenuItem(
                    value: 'whisper-tiny',
                    child: Text('Whisper Tiny'),
                  ),
                  DropdownMenuItem(
                    value: 'whisper-base',
                    child: Text('Whisper Base'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) notifier.updateAsrModel(v);
                },
              ),
              const SizedBox(height: 12),
              _DropdownTile<String>(
                label: l.ttsModel,
                value: settings.ttsModelId ?? '',
                items: const [
                  DropdownMenuItem(value: 'edge-tts', child: Text('Edge TTS')),
                  DropdownMenuItem(
                    value: 'sherpa-onnx',
                    child: Text('Sherpa-ONNX'),
                  ),
                  DropdownMenuItem(
                    value: 'flutter-tts',
                    child: Text('Flutter TTS'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateAsrModel(v);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.translationEngine,
            icon: Icons.translate_rounded,
            children: [
              _DropdownTile<TranslationEngine>(
                label: l.translationEngineLabel,
                value: settings.translationEngine,
                items: const [
                  DropdownMenuItem(
                    value: TranslationEngine.mlKit,
                    child: Text('ML Kit'),
                  ),
                  DropdownMenuItem(
                    value: TranslationEngine.appleTranslation,
                    child: Text('Apple Translation'),
                  ),
                  DropdownMenuItem(
                    value: TranslationEngine.systemTranslator,
                    child: Text('System Translator'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) notifier.updateTranslationEngine(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l.behaviorSettings,
            icon: Icons.tune_rounded,
            children: [
              SwitchListTile(
                title: Text(l.autoTranslate),
                subtitle: Text(l.autoTranslateHint),
                value: settings.autoTranslate,
                onChanged: (v) => notifier.toggleAutoTranslate(),
              ),
              SwitchListTile(
                title: Text(l.autoSpeak),
                subtitle: Text(l.autoSpeakHint),
                value: settings.autoSpeak,
                onChanged: (v) => notifier.toggleAutoSpeak(),
              ),
              SwitchListTile(
                title: Text(l.mirrorMode),
                subtitle: Text(l.mirrorModeHint),
                value: settings.mirrorMode,
                onChanged: (v) => notifier.toggleMirrorMode(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.expand_more_rounded),
          borderRadius: BorderRadius.circular(16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
