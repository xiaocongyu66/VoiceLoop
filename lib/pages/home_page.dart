import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../services/overlay_service.dart';
import '../widgets/immersive_record_button.dart';
import '../widgets/immersive_translation_view.dart';
import '../widgets/translation_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final settings = ref.watch(settingsProvider);
    final pipelineState = ref.watch(pipelineStateProvider);
    final partialText = ref.watch(partialTextProvider);
    final lastTranslation = ref.watch(lastTranslationProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final overlayVisible = ref.watch(overlayVisibleProvider);

    final sourceLang = AppLanguages.byCode(settings.sourceLanguage);
    final targetLang = AppLanguages.byCode(settings.targetLanguage);

    final displayState = _mapState(pipelineState);
    final buttonState = _mapButtonState(pipelineState);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: OverlayManager(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0A0E21)
                    : const Color(0xFF1A1A2E),
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0D1117)
                    : const Color(0xFF16213E),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, l, ref, overlayVisible),
                const SizedBox(height: 8),
                ImmersiveTranslationView(
                  result: lastTranslation,
                  partialText: partialText,
                  state: displayState,
                  sourceLang: sourceLang,
                  targetLang: targetLang,
                ),
                const SizedBox(height: 16),
                _buildLanguageBar(
                  context,
                  settings,
                  sourceLang,
                  targetLang,
                  settingsNotifier,
                ),
                const SizedBox(height: 20),
                ImmersiveRecordButton(
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
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLoc l,
    WidgetRef ref,
    bool overlayVisible,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            l.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              overlayVisible
                  ? Icons.close_fullscreen
                  : Icons.picture_in_picture,
              color: Colors.white70,
            ),
            onPressed: () => ref.read(overlayVisibleProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white70),
            onPressed: () => context.go('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(
    BuildContext context,
    AppSettings settings,
    LanguageInfo? sourceLang,
    LanguageInfo? targetLang,
    SettingsNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LanguagePill(
            flag: sourceLang?.flag ?? '🌐',
            name: sourceLang?.name ?? '',
            onTap: () => _showLanguageSheet(context, settings, true, notifier),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => notifier.swapLanguages(),
              child: Transform.rotate(
                angle: 3.14159 / 2,
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ),
          ),
          LanguagePill(
            flag: targetLang?.flag ?? '🌐',
            name: targetLang?.name ?? '',
            onTap: () => _showLanguageSheet(context, settings, false, notifier),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    AppSettings settings,
    bool isSource,
    SettingsNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    AppLoc.of(context)!.selectLanguage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...AppLanguages.all.map((lang) {
                  final currentCode = isSource
                      ? settings.sourceLanguage
                      : settings.targetLanguage;
                  final isSelected = lang.code.name == currentCode;
                  return ListTile(
                    leading: Text(
                      lang.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      lang.nativeName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lang.name,
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      if (isSource) {
                        notifier.updateSourceLang(lang.code.name);
                      } else {
                        notifier.updateTargetLang(lang.code.name);
                      }
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  PipelineDisplayState _mapState(PipelineState state) {
    switch (state) {
      case PipelineState.idle:
        return PipelineDisplayState.idle;
      case PipelineState.listening:
        return PipelineDisplayState.listening;
      case PipelineState.recognizing:
        return PipelineDisplayState.recognizing;
      case PipelineState.translating:
        return PipelineDisplayState.translating;
      case PipelineState.speaking:
        return PipelineDisplayState.speaking;
    }
  }

  ImmersiveButtonState _mapButtonState(PipelineState state) {
    switch (state) {
      case PipelineState.idle:
        return ImmersiveButtonState.idle;
      case PipelineState.listening:
        return ImmersiveButtonState.recording;
      case PipelineState.recognizing:
        return ImmersiveButtonState.recognizing;
      case PipelineState.translating:
        return ImmersiveButtonState.recognizing;
      case PipelineState.speaking:
        return ImmersiveButtonState.speaking;
    }
  }
}
