import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/logger.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    sherpa.initBindings();
    Logger.i('sherpa_onnx bindings initialized');
  } catch (e) {
    Logger.e('Failed to init sherpa_onnx bindings: $e');
  }
  runApp(const ProviderScope(child: VoiceLoopApp()));
}

class VoiceLoopApp extends ConsumerStatefulWidget {
  const VoiceLoopApp({super.key});

  @override
  ConsumerState<VoiceLoopApp> createState() => _VoiceLoopAppState();
}

class _VoiceLoopAppState extends ConsumerState<VoiceLoopApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      await ref.read(settingsProvider.notifier).init();
    } catch (e) {
      Logger.e('Settings init failed: $e');
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VoiceLoop',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLoc.localizationsDelegates,
      supportedLocales: AppLoc.supportedLocales,
      builder: (context, child) {
        if (!_initialized) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return child!;
      },
    );
  }
}
