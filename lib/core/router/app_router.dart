import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_loop/pages/home_page.dart';
import 'package:voice_loop/pages/mirror_page.dart';
import 'package:voice_loop/pages/history_page.dart';
import 'package:voice_loop/pages/settings_page.dart';
import 'package:voice_loop/pages/session_detail_page.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: const <RouteBase>[],
      ),
      GoRoute(
        path: '/mirror',
        builder: (context, state) => const MirrorPage(),
        routes: const <RouteBase>[],
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
        routes: const <RouteBase>[],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: const <RouteBase>[],
      ),
      GoRoute(
        path: '/session/:id',
        builder: (context, state) =>
            SessionDetailPage(sessionId: state.pathParameters['id']!),
        routes: const <RouteBase>[],
      ),
    ],
  );

  static GoRouter get router => _router;
}

class SlideFadeTransition extends CustomTransitionPage<void> {
  const SlideFadeTransition({required super.child, super.key})
    : super(
        transitionsBuilder: _builder,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      );

  static Widget _builder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curve),
      child: FadeTransition(opacity: curve, child: child),
    );
  }
}
