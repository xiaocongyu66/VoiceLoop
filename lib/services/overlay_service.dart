import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../core/constants/languages.dart';

class OverlayService {
  OverlayEntry? _entry;
  bool get isVisible => _entry != null;

  void show(BuildContext context, WidgetRef ref) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (ctx) => ProviderScope(
        overrides: const [],
        child: Consumer(
          builder: (ctx2, ref2, _) => _FloatingTranslationOverlay(ref: ref2),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  void toggle(BuildContext context, WidgetRef ref) {
    if (isVisible) {
      hide();
    } else {
      show(context, ref);
    }
  }
}

final overlayProvider = Provider<OverlayService>((ref) => OverlayService());

class _FloatingTranslationOverlay extends ConsumerStatefulWidget {
  const _FloatingTranslationOverlay({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_FloatingTranslationOverlay> createState() =>
      _FloatingTranslationOverlayState();
}

class _FloatingTranslationOverlayState
    extends ConsumerState<_FloatingTranslationOverlay> {
  Offset _position = const Offset(20, 80);
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
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position = Offset(
                _position.dx + details.delta.dx,
                _position.dy + details.delta.dy,
              );
            });
          },
          child: Container(
            width: _expanded ? 280 : 56,
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh
                  .withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _stateIcon(pipelineState),
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      if (_expanded) ...[
                        Expanded(
                          child: Text(
                            _stateText(pipelineState, l),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${sourceLang?.flag ?? ''} → ${targetLang?.flag ?? ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Icon(
                          _expanded ? Icons.expand_more : Icons.expand_less,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lastTranslation != null) ...[
                            _OverlayText(
                              label: sourceLang?.nativeName ?? '',
                              flag: sourceLang?.flag ?? '',
                              text: lastTranslation.originalText,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(height: 6),
                            Container(height: 1, color: Theme.of(context).dividerColor),
                            const SizedBox(height: 6),
                            _OverlayText(
                              label: targetLang?.nativeName ?? '',
                              flag: targetLang?.flag ?? '',
                              text: lastTranslation.translatedText,
                              color: Theme.of(context).colorScheme.primary,
                              bold: true,
                            ),
                          ] else if (partialText.isNotEmpty) ...[
                            _OverlayText(
                              label: sourceLang?.nativeName ?? '',
                              flag: sourceLang?.flag ?? '',
                              text: partialText,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ] else ...[
                            Center(
                              child: Text(
                                l.tapToStart,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _stateIcon(PipelineState s) {
    return switch (s) {
      PipelineState.idle => Icons.mic_none,
      PipelineState.listening => Icons.mic,
      PipelineState.recognizing => Icons.spatial_audio,
      PipelineState.translating => Icons.translate,
      PipelineState.speaking => Icons.volume_up,
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

class _OverlayText extends StatelessWidget {
  final String label;
  final String flag;
  final String text;
  final Color color;
  final bool bold;

  const _OverlayText({
    required this.label,
    required this.flag,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
