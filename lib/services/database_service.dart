import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/utils/logger.dart';
import '../models/translation_message.dart';
import '../models/translation_session.dart';

class AppDatabase {
  static const _sessionsFile = 'sessions.json';
  static const _messagesFile = 'messages.json';
  File? _sessionsDb;
  File? _messagesDb;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _sessionsDb = File(p.join(dir.path, _sessionsFile));
    _messagesDb = File(p.join(dir.path, _messagesFile));
    if (!_sessionsDb!.existsSync()) {
      _sessionsDb!.writeAsStringSync('[]');
    }
    if (!_messagesDb!.existsSync()) {
      _messagesDb!.writeAsStringSync('[]');
    }
    Logger.i('Database initialized at ${dir.path}');
  }

  Future<String> insertSession(TranslationSession session) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == session.id);
    sessions.insert(0, session);
    await _writeSessions(sessions);
    return session.id;
  }

  Future<String> insertMessage(TranslationMessage message) async {
    final messages = await _readAllMessages();
    messages.add(message);
    await _writeMessages(messages);
    final sessions = await getSessions();
    final idx = sessions.indexWhere((s) => s.id == message.sessionId);
    if (idx >= 0) {
      final updated = sessions[idx].copyWith(
        updatedAt: DateTime.now(),
        messages: [...sessions[idx].messages, message],
      );
      sessions[idx] = updated;
      await _writeSessions(sessions);
    }
    return message.id;
  }

  Future<List<TranslationSession>> getSessions() async {
    if (_sessionsDb == null) await init();
    final raw = jsonDecode(_sessionsDb!.readAsStringSync()) as List;
    return raw
        .map((e) => TranslationSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TranslationMessage>> getSessionMessages(String sessionId) async {
    if (_messagesDb == null) await init();
    final raw = jsonDecode(_messagesDb!.readAsStringSync()) as List;
    return raw
        .map((e) => TranslationMessage.fromJson(e as Map<String, dynamic>))
        .where((m) => m.sessionId == sessionId)
        .toList();
  }

  Future<int> deleteSession(String id) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _writeSessions(sessions);
    final messages = await _readAllMessages();
    messages.removeWhere((m) => m.sessionId == id);
    await _writeMessages(messages);
    return 1;
  }

  Future<int> updateSession(TranslationSession session) async {
    final sessions = await getSessions();
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      sessions[idx] = session.copyWith(updatedAt: DateTime.now());
      await _writeSessions(sessions);
      return 1;
    }
    return 0;
  }

  Future<List<TranslationMessage>> _readAllMessages() async {
    if (_messagesDb == null) await init();
    final raw = jsonDecode(_messagesDb!.readAsStringSync()) as List;
    return raw
        .map((e) => TranslationMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeSessions(List<TranslationSession> sessions) async {
    _sessionsDb!.writeAsStringSync(
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _writeMessages(List<TranslationMessage> messages) async {
    _messagesDb!.writeAsStringSync(
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }
}
