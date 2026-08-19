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

  static const List<String> _mirrorBases = [
    'https://github.com/k2-fsa/sherpa-onnx/releases/download',
    'https://hf-mirror.com/k2-fsa/sherpa-onnx/resolve',
    'https://huggingface.co/k2-fsa/sherpa-onnx/resolve',
  ];

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
    if (modelId == 'silero-vad') {
      final modelPath = await getModelPath(modelId);
      final file = File(p.join(modelPath, 'silero_vad.onnx'));
      return file.existsSync();
    }
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

  bool get isVadModel => _currentModelId == 'silero-vad';
  String? _currentModelId;

  Future<void> downloadModel(
    String modelId, {
    void Function(double progress)? onProgress,
  }) async {
    _currentModelId = modelId;
    _cancelRequested = false;

    final alreadyDownloaded = await isModelDownloaded(modelId);
    if (alreadyDownloaded) {
      onProgress?.call(1.0);
      return;
    }

    if (modelId == 'silero-vad') {
      await _downloadVadModel(onProgress);
      return;
    }

    final asr = AsrModels.byId(modelId);
    final tts = TtsModels.byId(modelId);
    if (asr == null && tts == null) {
      throw ArgumentError('Unknown model id: $modelId');
    }

    final relativePath = asr != null
        ? 'asr-models/${asr.downloadUrl.split('/').last}'
        : 'tts-models/${tts!.downloadUrl.split('/').last}';

    final tempDir = await getTemporaryDirectory();
    final tarBz2Path = p.join(tempDir.path, '$modelId.tar.bz2');
    final tarBz2File = File(tarBz2Path);
    final extractDir = Directory(p.join(tempDir.path, '$modelId-extract'));
    if (extractDir.existsSync()) {
      await extractDir.delete(recursive: true);
    }
    await extractDir.create(recursive: true);

    Exception? lastError;
    for (final mirror in _mirrorBases) {
      final url = '$mirror/$relativePath';
      try {
        await _downloadWithRetry(url, tarBz2File, onProgress);
        lastError = null;
        break;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (_cancelRequested) {
          if (tarBz2File.existsSync()) await tarBz2File.delete();
          throw CancellationException();
        }
      }
    }
    if (lastError != null) {
      if (tarBz2File.existsSync()) await tarBz2File.delete();
      throw lastError;
    }

    onProgress?.call(1.0);

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

  Future<void> _downloadVadModel(
    void Function(double progress)? onProgress,
  ) async {
    final modelDir = Directory(await getModelPath('silero-vad'));
    if (!modelDir.existsSync()) {
      await modelDir.create(recursive: true);
    }
    final destFile = File(p.join(modelDir.path, 'silero_vad.onnx'));

    final urls = [
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx',
      'https://hf-mirror.com/k2-fsa/sherpa-onnx/resolve/asr-models/silero_vad.onnx',
      'https://huggingface.co/k2-fsa/sherpa-onnx/resolve/asr-models/silero_vad.onnx',
    ];

    Exception? lastError;
    for (final url in urls) {
      try {
        await _downloadWithRetry(url, destFile, onProgress);
        lastError = null;
        break;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (_cancelRequested) {
          if (destFile.existsSync()) await destFile.delete();
          throw CancellationException();
        }
      }
    }
    if (lastError != null) {
      if (destFile.existsSync()) await destFile.delete();
      throw lastError;
    }
    onProgress?.call(1.0);
  }

  Future<void> _downloadWithRetry(
    String url,
    File destFile,
    void Function(double progress)? onProgress, {
    int maxRetries = 3,
  }) async {
    Exception? lastError;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (_cancelRequested) throw CancellationException();
      try {
        final existingLen = destFile.existsSync() ? destFile.lengthSync() : 0;
        _httpClient = HttpClient();
        _httpClient!.connectionTimeout = const Duration(seconds: 30);
        _httpClient!.idleTimeout = const Duration(seconds: 60);

        final request = await _httpClient!.getUrl(Uri.parse(url));
        if (existingLen > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existingLen-');
        }

        final response = await request.close();

        final statusCode = response.statusCode;
        if (statusCode != HttpStatus.ok &&
            statusCode != HttpStatus.partialContent) {
          throw HttpException('HTTP $statusCode for $url');
        }

        final total = response.contentLength > 0
            ? response.contentLength + existingLen
            : 0;
        var received = existingLen;

        final sink = destFile.openWrite(mode: FileMode.append);
        try {
          await for (final chunk in response) {
            if (_cancelRequested) {
              await sink.flush();
              await sink.close();
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
        } finally {
          _httpClient?.close();
          _httpClient = null;
        }
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (e is CancellationException) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw lastError ?? Exception('Download failed');
  }

  Future<void> deleteModel(String modelId) async {
    final modelPath = await getModelPath(modelId);
    final dir = Directory(modelPath);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<String> getVadModelPath() async {
    final modelPath = await getModelPath('silero-vad');
    return p.join(modelPath, 'silero_vad.onnx');
  }
}

class CancellationException implements Exception {}
