import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/asr_model_info.dart';
import '../models/tts_model_info.dart';

class ModelManager {
  static const _modelDirName = 'models';

  HttpClient? _httpClient;
  bool _cancelRequested = false;

  Future<String> getModelDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _modelDirName));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> getModelPath(String modelId) async {
    final dir = await getModelDir();
    return p.join(dir, modelId);
  }

  Future<bool> isModelDownloaded(String modelId) async {
    final asr = AsrModels.byId(modelId);
    if (asr != null) {
      final modelPath = await getModelPath(modelId);
      final modelFile = File(p.join(modelPath, asr.modelFileName));
      final tokensFile = File(p.join(modelPath, asr.tokensFileName));
      return modelFile.existsSync() && tokensFile.existsSync();
    }
    final tts = TtsModels.byId(modelId);
    if (tts != null) {
      final modelPath = await getModelPath(modelId);
      final modelFile = File(p.join(modelPath, tts.modelFileName));
      final tokensFile = File(p.join(modelPath, tts.tokensFileName));
      return modelFile.existsSync() && tokensFile.existsSync();
    }
    return false;
  }

  void cancelDownload() {
    _cancelRequested = true;
    _httpClient?.close(force: true);
  }

  Future<void> downloadModel(
    String modelId, {
    void Function(double progress)? onProgress,
  }) async {
    final asr = AsrModels.byId(modelId);
    final tts = TtsModels.byId(modelId);
    if (asr == null && tts == null) {
      throw ArgumentError('Unknown model id: $modelId');
    }

    _cancelRequested = false;

    final alreadyDownloaded = await isModelDownloaded(modelId);
    if (alreadyDownloaded) {
      onProgress?.call(1.0);
      return;
    }

    final downloadUrl = asr?.downloadUrl ?? tts!.downloadUrl;

    final tempDir = await getTemporaryDirectory();
    final tarBz2Path = p.join(tempDir.path, '$modelId.tar.bz2');
    final tarBz2File = File(tarBz2Path);
    final extractDir = Directory(p.join(tempDir.path, '$modelId-extract'));
    if (extractDir.existsSync()) {
      await extractDir.delete(recursive: true);
    }
    await extractDir.create(recursive: true);

    _httpClient = HttpClient();
    try {
      final request = await _httpClient!.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Download failed: HTTP ${response.statusCode}',
        );
      }

      final total = response.contentLength;
      var received = 0;

      final sink = tarBz2File.openWrite();
      try {
        await for (final chunk in response) {
          if (_cancelRequested) {
            await sink.flush();
            await sink.close();
            await tarBz2File.delete();
            throw CancellationException();
          }
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            onProgress?.call(received / total);
          }
        }
        await sink.flush();
        await sink.close();
      } catch (e) {
        await sink.close();
        rethrow;
      }
    } finally {
      _httpClient?.close();
      _httpClient = null;
    }

    onProgress?.call(1.0);

    if (_cancelRequested) {
      if (tarBz2File.existsSync()) {
        await tarBz2File.delete();
      }
      throw CancellationException();
    }

    if (!tarBz2File.existsSync()) {
      throw FileSystemException('Downloaded file not found', tarBz2Path);
    }

    final bytes = await tarBz2File.readAsBytes();
    final tarBytes = BZip2Decoder().decodeBytes(bytes);
    final archive = TarDecoder().decodeBytes(tarBytes);

    for (final file in archive) {
      final outputPath = p.join(extractDir.path, file.name);
      if (file.isFile) {
        final outFile = File(outputPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        final dir = Directory(outputPath);
        if (!dir.existsSync()) {
          await dir.create(recursive: true);
        }
      }
    }

    await tarBz2File.delete();

    final modelDir = Directory(await getModelPath(modelId));
    if (!modelDir.existsSync()) {
      await modelDir.create(recursive: true);
    }

    final extractedEntries = extractDir.listSync();
    for (final entry in extractedEntries) {
      if (entry is Directory) {
        final innerEntries = entry.listSync(recursive: true);
        for (final inner in innerEntries) {
          if (inner is File) {
            final rel = p.relative(inner.path, from: entry.path);
            final destPath = p.join(modelDir.path, rel);
            final destFile = File(destPath);
            await destFile.parent.create(recursive: true);
            await inner.copy(destPath);
          }
        }
      } else if (entry is File) {
        final rel = p.basename(entry.path);
        final destPath = p.join(modelDir.path, rel);
        await entry.copy(destPath);
      }
    }

    await extractDir.delete(recursive: true);

    final verified = await isModelDownloaded(modelId);
    if (!verified) {
      throw FileSystemException(
        'Model files not found after extraction',
        modelDir.path,
      );
    }
  }

  Future<void> deleteModel(String modelId) async {
    final modelPath = await getModelPath(modelId);
    final dir = Directory(modelPath);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}

class CancellationException implements Exception {}
