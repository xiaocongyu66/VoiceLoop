import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../platform/system_overlay_channel.dart';
import '../providers/pipeline_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/immersive_record_button.dart';
import '../widgets/immersive_translation_view.dart';

final systemOverlayChannelProvider = Provider<SystemOverlayChannel>(
  (ref) => SystemOverlayChannel(),
);

final systemOverlayActiveProvider = StateNotifierProvider<SystemOverlayNotifier, bool>(
  (ref) => SystemOverlayNotifier(ref),
);

class SystemOverlayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  SystemOverlayNotifier(this._ref) : super(false);

  Future<void> toggle() async {
    if (state) {
      await hide();
    } else {
      await show();
    }
  }

  Future<void> show() async {
    final channel = _ref.read(systemOverlayChannelProvider);
    final hasPermission = await channel.hasPermission();
    if (!hasPermission) {
      await channel.requestPermission();
      return;
    }
    final ok = await channel.show();
    if (ok) state = true;
  }

  Future<void> hide() async {
    final channel = _ref.read(systemOverlayChannelProvider);
    await channel.hide();
    state = false;
  }
}

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
    final overlayActive = ref.watch(systemOverlayActiveProvider);

    final sourceLang = AppLanguages.byCode(settings.sourceLanguage);
    final targetLang = AppLanguages.byCode(settings.targetLanguage);

    final displayState = _mapState(pipelineState);
    final buttonState = _mapButtonState(pipelineState);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
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
              _buildTopBar(context, l, ref, overlayActive),
              const SizedBox(height: 8),
              ImmersiveTranslationView(
                result: lastTranslation,
                partialText: partialText,
                state: displayState,
                sourceLang: sourceLang,
                targetLang: targetLang,
              ),
              const SizedBox(height: 16),
              _buildLanguageBar(context, settings, sourceLang, targetLang, settingsNotifier),
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
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLoc l,
    WidgetRef ref,
    bool overlayActive,
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
              overlayActive ? Icons.close_fullscreen : Icons.picture_in_picture,
              color: overlayActive ? const Color(0xFF4DB6AC) : Colors.white70,
            ),
            tooltip: '系统悬浮窗',
            onPressed: () => ref.read(systemOverlayActiveProvider.notifier).toggle(),
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
          _LanguagePill(
            flag: sourceLang?.flag ?? '',
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
          _LanguagePill(
            flag: targetLang?.flag ?? '',
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
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx2, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx2).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLoc.of(context)!.selectLanguage,
                style: Theme.of(ctx2).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: AppLanguages.all.length,
                itemBuilder: (ctx3, index) {
                  final lang = AppLanguages.all[index];
                  final currentCode =
                      isSource ? settings.sourceLanguage : settings.targetLanguage;
                  final isSelected = lang.code.name == currentCode;
                  return ListTile(
                    leading: Text(lang.flag, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(lang.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(ctx3).colorScheme.primary)
                        : null,
                    onTap: () {
                      if (isSource) {
                        notifier.updateSourceLang(lang.code.name);
                      } else {
                        notifier.updateTargetLang(lang.code.name);
                      }
                      Navigator.pop(ctx3);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PipelineDisplayState _mapState(PipelineState state) {
    return switch (state) {
      PipelineState.idle => PipelineDisplayState.idle,
      PipelineState.listening => PipelineDisplayState.listening,
      PipelineState.recognizing => PipelineDisplayState.recognizing,
      PipelineState.translating => PipelineDisplayState.translating,
      PipelineState.speaking => PipelineDisplayState.speaking,
    };
  }

  ImmersiveButtonState _mapButtonState(PipelineState state) {
    return switch (state) {
      PipelineState.idle => ImmersiveButtonState.idle,
      PipelineState.listening => ImmersiveButtonState.recording,
      PipelineState.recognizing => ImmersiveButtonState.recognizing,
      PipelineState.translating => ImmersiveButtonState.recognizing,
      PipelineState.speaking => ImmersiveButtonState.speaking,
    };
  }
}

class _LanguagePill extends StatelessWidget {
  final String flag;
  final String name;
  final VoidCallback onTap;

  const _LanguagePill({
    required this.flag,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              name,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
