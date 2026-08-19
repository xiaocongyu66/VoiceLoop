import 'package:flutter/material.dart';

import '../core/constants/languages.dart';
import '../l10n/app_localizations.dart';
import '../models/translation_result.dart';
import 'translation_widgets.dart';

class ImmersiveTranslationView extends StatelessWidget {
  final TranslationResult? result;
  final String? partialText;
  final PipelineDisplayState state;
  final LanguageInfo? sourceLang;
  final LanguageInfo? targetLang;

  const ImmersiveTranslationView({
    super.key,
    this.result,
    this.partialText,
    this.state = PipelineDisplayState.idle,
    this.sourceLang,
    this.targetLang,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLoc.of(context)!;
    final hasResult = result != null;
    final hasPartial = partialText != null && partialText!.isNotEmpty;
    final isActive =
        state == PipelineDisplayState.listening ||
        state == PipelineDisplayState.recognizing;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: _buildSourcePanel(
                context,
                l,
                hasResult,
                hasPartial,
                isActive,
              ),
            ),
            _buildDivider(context, state),
            Expanded(flex: 5, child: _buildTargetPanel(context, l, hasResult)),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcePanel(
    BuildContext context,
    AppLoc l,
    bool hasResult,
    bool hasPartial,
    bool isActive,
  ) {
    final sourceText = hasResult
        ? result!.originalText
        : (hasPartial ? partialText! : '');

    return GlassCard(
      opacity: 0.06,
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sourceLang?.flag ?? '🌐',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sourceLang?.nativeName ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isActive)
                WaveformVisualizer(
                  isActive: isActive,
                  color: Colors.white,
                  height: 24,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sourceText.isEmpty
                ? Center(
                    child: Text(
                      state == PipelineDisplayState.listening
                          ? l.listening
                          : l.tapToStart,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    reverse: true,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SlideInText(
                        text: sourceText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 20,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, PipelineDisplayState state) {
    final color = _stateColor(state, context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    color.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(_stateIcon(state), size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    color.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetPanel(BuildContext context, AppLoc l, bool hasResult) {
    final theme = Theme.of(context);
    final translatedText = hasResult ? result!.translatedText : '';

    return GlassCard(
      opacity: 0.08,
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      targetLang?.flag ?? '🌐',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      targetLang?.nativeName ?? '',
                      style: TextStyle(
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (state == PipelineDisplayState.translating)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                ),
              if (state == PipelineDisplayState.speaking)
                Icon(
                  Icons.volume_up_rounded,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: translatedText.isEmpty
                ? Center(
                    child: Text(
                      l.noTranslationYet,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    reverse: true,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SlideInText(
                        text: translatedText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _stateColor(PipelineDisplayState state, BuildContext context) {
    switch (state) {
      case PipelineDisplayState.idle:
        return Colors.white.withOpacity(0.3);
      case PipelineDisplayState.listening:
        return const Color(0xFF4FC3F7);
      case PipelineDisplayState.recognizing:
        return const Color(0xFFFFB74D);
      case PipelineDisplayState.translating:
        return const Color(0xFF81C784);
      case PipelineDisplayState.speaking:
        return const Color(0xFFCE93D8);
    }
  }

  IconData _stateIcon(PipelineDisplayState state) {
    switch (state) {
      case PipelineDisplayState.idle:
        return Icons.mic_none_rounded;
      case PipelineDisplayState.listening:
        return Icons.mic_rounded;
      case PipelineDisplayState.recognizing:
        return Icons.graphic_eq_rounded;
      case PipelineDisplayState.translating:
        return Icons.translate_rounded;
      case PipelineDisplayState.speaking:
        return Icons.volume_up_rounded;
    }
  }
}

enum PipelineDisplayState {
  idle,
  listening,
  recognizing,
  translating,
  speaking,
}
