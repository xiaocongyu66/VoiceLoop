import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/languages.dart';
import '../core/extensions/context_extensions.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/record_button.dart' as rb;

class MirrorPage extends ConsumerWidget {
  const MirrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final pipelineState = ref.watch(pipelineStateProvider);
    final partialText = ref.watch(partialTextProvider);
    final lastTranslation = ref.watch(lastTranslationProvider);

    final sourceLang = AppLanguages.byCode(settings.sourceLanguage);
    final targetLang = AppLanguages.byCode(settings.targetLanguage);
    final buttonState = _mapState(pipelineState);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _MirrorHalf(
                flag: sourceLang?.flag ?? '🌐',
                langName: sourceLang?.nativeName ?? settings.sourceLanguage,
                originalText: lastTranslation?.originalText ?? partialText ?? '',
                translatedText: lastTranslation?.translatedText ?? '',
                isSource: true,
              ),
            ),
            Container(
              height: 1,
              color: context.colorScheme.outlineVariant,
            ),
            Expanded(
              child: Transform.rotate(
                angle: pi,
                child: _MirrorHalf(
                  flag: targetLang?.flag ?? '🌐',
                  langName: targetLang?.nativeName ?? settings.targetLanguage,
                  originalText: lastTranslation?.translatedText ?? '',
                  translatedText: lastTranslation?.originalText ?? '',
                  isSource: false,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: rb.RecordButton(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

class _MirrorHalf extends StatelessWidget {
  final String flag;
  final String langName;
  final String originalText;
  final String translatedText;
  final bool isSource;

  const _MirrorHalf({
    required this.flag,
    required this.langName,
    required this.originalText,
    required this.translatedText,
    required this.isSource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isSource ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Text(
                langName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (originalText.isNotEmpty)
            Text(
              originalText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: isSource ? TextAlign.start : TextAlign.end,
            ),
          const SizedBox(height: 12),
          if (translatedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                translatedText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: isSource ? TextAlign.start : TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }
}
