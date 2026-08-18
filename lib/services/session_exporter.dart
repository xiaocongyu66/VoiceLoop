import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/utils/logger.dart';
import '../models/translation_message.dart';
import '../models/translation_session.dart';

class SessionExporter {
  Future<String> exportToJson(TranslationSession session) async {
    final dir = await getTemporaryDirectory();
    final filePath = p.join(dir.path, 'session_${session.id}.json');

    final data = {
      'id': session.id,
      'title': session.title,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'sourceLang': session.sourceLang,
      'targetLang': session.targetLang,
      'messages': session.messages.map(_messageToJson).toList(),
    };

    final file = File(filePath);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    Logger.i('Exported session to JSON: $filePath');
    return filePath;
  }

  Future<String> exportToZip(
    TranslationSession session, {
    String? audioDirPath,
  }) async {
    final jsonPath = await exportToJson(session);
    final dir = await getTemporaryDirectory();
    final zipPath = p.join(dir.path, 'session_${session.id}.zip');

    final archive = Archive();
    archive.addFile(
      ArchiveFile(
        'session.json',
        File(jsonPath).lengthSync(),
        File(jsonPath).readAsBytesSync(),
      ),
    );

    if (audioDirPath != null) {
      final audioDir = Directory(audioDirPath);
      if (audioDir.existsSync()) {
        await for (final entity in audioDir.list()) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            archive.addFile(
              ArchiveFile('audio/${p.basename(entity.path)}', bytes.length, bytes),
            );
          }
        }
      }
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw StateError('Failed to create ZIP archive');
    }
    await File(zipPath).writeAsBytes(zipBytes);
    Logger.i('Exported session to ZIP: $zipPath');
    return zipPath;
  }

  Future<void> shareFile(String filePath) async {
    Logger.w('share_plus not available, file saved at: $filePath');
  }

  Map<String, dynamic> _messageToJson(TranslationMessage message) {
    return {
      'id': message.id,
      'sessionId': message.sessionId,
      'originalText': message.originalText,
      'translatedText': message.translatedText,
      'sourceLang': message.sourceLang,
      'targetLang': message.targetLang,
      'timestamp': message.timestamp.toIso8601String(),
      'direction': message.direction == MessageDirection.incoming
          ? 'incoming'
          : 'outgoing',
      'audioPath': message.audioPath,
    };
  }
}
