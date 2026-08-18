import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/record_button.dart' as rb;
import '../widgets/translation_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final pipelineState = ref.watch(pipelineStateProvider);
    final partialText = ref.watch(partialTextProvider);
    final lastTranslation = ref.watch(lastTranslationProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final buttonState = _mapState(pipelineState);
    final sourceLang = AppLanguages.byCode(settings.sourceLanguage);
    final targetLang = AppLanguages.byCode(settings.targetLanguage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceLoop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.go('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: Center(
                  child: SingleChildScrollView(
                    child: TranslationCard(
                      result: lastTranslation,
                      partialText: partialText,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _LanguageBar(
                sourceLang: sourceLang,
                targetLang: targetLang,
                onSourceChanged: (lang) {
                  if (lang != null) {
                    settingsNotifier.updateSourceLang(lang.code.name);
                  }
                },
                onTargetChanged: (lang) {
                  if (lang != null) {
                    settingsNotifier.updateTargetLang(lang.code.name);
                  }
                },
                onSwap: () {
                  settingsNotifier.swapLanguages();
                },
              ),
              const SizedBox(height: 24),
              rb.RecordButton(
                state: buttonState,
                onPressed: () {
                  final notifier = ref.read(pipelineStateProvider.notifier);
                  if (pipelineState == PipelineState.idle) {
                    notifier.start(
                      sourceLang: settings.sourceLanguage,
                      targetLang: settings.targetLanguage,
                    );
                  } else {
                    notifier.stop();
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  rb.RecordButtonState _mapState(PipelineState state) {
    switch (state) {
      case PipelineState.idle:
        return rb.RecordButtonState.idle;
      case PipelineState.listening:
        return rb.RecordButtonState.recording;
      case PipelineState.recognizing:
        return rb.RecordButtonState.recognizing;
      case PipelineState.translating:
        return rb.RecordButtonState.recognizing;
      case PipelineState.speaking:
        return rb.RecordButtonState.speaking;
    }
  }
}

class _LanguageBar extends StatelessWidget {
  final LanguageInfo? sourceLang;
  final LanguageInfo? targetLang;
  final ValueChanged<LanguageInfo?> onSourceChanged;
  final ValueChanged<LanguageInfo?> onTargetChanged;
  final VoidCallback onSwap;

  const _LanguageBar({
    required this.sourceLang,
    required this.targetLang,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LanguageSelector(
            value: sourceLang,
            onChanged: onSourceChanged,
            label: '源语言',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton.filledTonal(
            onPressed: onSwap,
            icon: Transform.rotate(
              angle: pi / 2,
              child: const Icon(Icons.compare_arrows_rounded),
            ),
          ),
        ),
        Expanded(
          child: LanguageSelector(
            value: targetLang,
            onChanged: onTargetChanged,
            label: '目标语言',
          ),
        ),
      ],
    );
  }
}
