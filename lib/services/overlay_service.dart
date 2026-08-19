import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/languages.dart';
import '../l10n/app_localizations.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/translation_widgets.dart';
import '../models/translation_result.dart';

final overlayVisibleProvider =
    StateNotifierProvider<OverlayVisibleNotifier, bool>(
      (ref) => OverlayVisibleNotifier(),
    );

class OverlayVisibleNotifier extends StateNotifier<bool> {
  OverlayVisibleNotifier() : super(false);
  void toggle() => state = !state;
  void show() => state = true;
  void hide() => state = false;
}

class OverlayManager extends ConsumerWidget {
  final Widget child;

  const OverlayManager({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(overlayVisibleProvider);
    return Stack(
      children: [
        child,
        if (visible) const Positioned.fill(child: _FloatingOverlay()),
      ],
    );
  }
}

class _FloatingOverlay extends ConsumerStatefulWidget {
  const _FloatingOverlay();

  @override
  ConsumerState<_FloatingOverlay> createState() => _FloatingOverlayState();
}

class _FloatingOverlayState extends ConsumerState<_FloatingOverlay> {
  Offset _position = const Offset(24, 100);
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLoc.of(context)!;
    final settings = ref.watch(settingsProvider);
    final pipelineState = ref.watch(pipelineStateProvider);
    final partialText = ref.watch(partialTextProvider);
    final lastTranslation = ref.watch(lastTranslationProvider);
    final screen = MediaQuery.of(context).size;

    final sourceLang = AppLanguages.byCode(settings.sourceLanguage);
    final targetLang = AppLanguages.byCode(settings.targetLanguage);

    return Positioned(
      left: _position.dx.clamp(8, screen.width - 300),
      top: _position.dy.clamp(8, screen.height - 260),
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _position = Offset(
              (_position.dx + d.delta.dx).clamp(8, screen.width - 300),
              (_position.dy + d.delta.dy).clamp(8, screen.height - 260),
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _expanded ? 284 : 48,
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.88),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(
                    context,
                    l,
                    pipelineState,
                    sourceLang,
                    targetLang,
                  ),
                  if (_expanded)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: _buildContent(
                          context,
                          l,
                          lastTranslation,
                          partialText,
                          sourceLang,
                          targetLang,
                          pipelineState,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLoc l,
    PipelineState state,
    LanguageInfo? sourceLang,
    LanguageInfo? targetLang,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _stateColor(state),
            ),
          ),
          const SizedBox(width: 8),
          if (_expanded) ...[
            Expanded(
              child: Text(
                _stateText(state, l),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${sourceLang?.flag ?? ''} → ${targetLang?.flag ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Icon(
              _expanded ? Icons.expand_more_rounded : Icons.expand_less_rounded,
              size: 18,
              color: Colors.white38,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => ref.read(overlayVisibleProvider.notifier).hide(),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLoc l,
    TranslationResult? lastTranslation,
    String partialText,
    LanguageInfo? sourceLang,
    LanguageInfo? targetLang,
    PipelineState state,
  ) {
    if (lastTranslation != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverlayLine(
            flag: sourceLang?.flag ?? '',
            label: sourceLang?.nativeName ?? '',
            text: lastTranslation.originalText,
            color: Colors.white.withOpacity(0.75),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _OverlayLine(
            flag: targetLang?.flag ?? '',
            label: targetLang?.nativeName ?? '',
            text: lastTranslation.translatedText,
            color: const Color(0xFF4DB6AC),
            bold: true,
          ),
        ],
      );
    }

    if (partialText.isNotEmpty) {
      return _OverlayLine(
        flag: sourceLang?.flag ?? '',
        label: sourceLang?.nativeName ?? '',
        text: partialText,
        color: Colors.white.withOpacity(0.5),
      );
    }

    if (state == PipelineState.listening) {
      return Center(
        child: WaveformVisualizer(
          isActive: true,
          color: const Color(0xFF4DB6AC),
          height: 30,
        ),
      );
    }

    return Center(
      child: Text(
        l.tapToStart,
        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
      ),
    );
  }

  Color _stateColor(PipelineState s) {
    return switch (s) {
      PipelineState.idle => Colors.white12,
      PipelineState.listening => const Color(0xFF4FC3F7),
      PipelineState.recognizing => const Color(0xFFFFB74D),
      PipelineState.translating => const Color(0xFF81C784),
      PipelineState.speaking => const Color(0xFFCE93D8),
    };
  }

  String _stateText(PipelineState s, AppLoc l) {
    return switch (s) {
      PipelineState.idle => l.tapToStart,
      PipelineState.listening => l.listening,
      PipelineState.recognizing => l.recognizing,
      PipelineState.translating => l.translating,
      PipelineState.speaking => l.speaking,
    };
  }
}

class _OverlayLine extends StatelessWidget {
  final String flag;
  final String label;
  final String text;
  final Color color;
  final bool bold;

  const _OverlayLine({
    required this.flag,
    required this.label,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            height: 1.4,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
