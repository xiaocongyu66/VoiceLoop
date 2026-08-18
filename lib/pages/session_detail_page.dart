import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/session_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/message_bubble.dart';

class SessionDetailPage extends ConsumerWidget {
  final String sessionId;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLoc.of(context)!;
    final sessions = ref.watch(sessionProvider);
    final session = sessions.where((s) => s.id == sessionId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(session?.title ?? l.sessionDetail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/history'),
        ),
      ),
      body: session == null || session.messages.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: l.sessionEmpty,
              subtitle: l.sessionEmptyHint,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: session.messages.length,
              itemBuilder: (context, index) {
                final msg = session.messages[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: MessageBubble(message: msg),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
