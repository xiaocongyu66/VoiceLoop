import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/translation_message.dart';
import '../models/translation_session.dart';

class SessionNotifier extends StateNotifier<List<TranslationSession>> {
  final _uuid = const Uuid();

  SessionNotifier() : super([]);

  TranslationSession createSession({
    required String sourceLang,
    required String targetLang,
  }) {
    final now = DateTime.now();
    final session = TranslationSession(
      id: _uuid.v4(),
      title: 'Session ${state.length + 1}',
      createdAt: now,
      updatedAt: now,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
    state = [session, ...state];
    return session;
  }

  void deleteSession(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void updateSessions(List<TranslationSession> sessions) {
    state = sessions;
  }

  void loadSessions() {}
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, List<TranslationSession>>(
  (ref) => SessionNotifier(),
);

class CurrentSessionNotifier extends StateNotifier<TranslationSession?> {
  final Ref _ref;

  CurrentSessionNotifier(this._ref) : super(null);

  void addMessage(TranslationMessage message) {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(
      messages: [...current.messages, message],
      updatedAt: DateTime.now(),
    );
    state = updated;

    final sessions = _ref.read(sessionProvider);
    final index = sessions.indexWhere((s) => s.id == updated.id);
    if (index >= 0) {
      final newSessions = List<TranslationSession>.from(sessions);
      newSessions[index] = updated;
      _ref.read(sessionProvider.notifier).updateSessions(newSessions);
    }
  }

  void loadSession(TranslationSession session) {
    state = session;
  }

  void clear() {
    state = null;
  }
}

final currentSessionProvider =
    StateNotifierProvider<CurrentSessionNotifier, TranslationSession?>(
  (ref) => CurrentSessionNotifier(ref),
);
