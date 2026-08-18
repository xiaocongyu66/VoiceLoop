import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: VoiceLoopApp()));
}

class VoiceLoopApp extends StatelessWidget {
  const VoiceLoopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VoiceLoop',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
