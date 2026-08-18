import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    } catch (_) {}
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
