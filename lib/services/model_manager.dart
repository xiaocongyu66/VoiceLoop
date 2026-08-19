import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart' as archive;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/logger.dart';
import '../models/asr_model_info.dart';
import '../models/tts_model_info.dart';

enum DownloadMirror {
  github('GitHub', 'https://github.com/k2-fsa/sherpa-onnx/releases/download'),
  hfMirror('HuggingFace 镜像', 'https://hf-mirror.com/k2-fsa/sherpa-onnx/resolve/main'),
  hf('HuggingFace', 'https://huggingface.co/k2-fsa/sherpa-onnx/resolve/main'),
  modelScope('ModelScope', 'https://modelscope.cn/models/k2-fsa/sherpa-onnx/resolve/master');

  final String label;
  final String baseUrl;
  const DownloadMirror(this.label, this.baseUrl);
}

class ModelManager {
  static const _modelDirName = 'models';
  static const _prefMirrorKey = 'download_mirror';

  HttpClient? _httpClient;
  bool _cancelRequested = false;
  DownloadMirror _mirror = DownloadMirror.hfMirror;

  DownloadMirror get mirror => _mirror;

  Future<void> initMirror() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefMirrorKey);
    if (name != null) {
      _mirror = DownloadMirror.values.firstWhere(
        (m) => m.name == name,
        orElse: () => DownloadMirror.hfMirror,
      );
    }
  }

  Future<void> setMirror(DownloadMirror m) async {
    _mirror = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefMirrorKey, m.name);
  }

  List<DownloadMirror> get availableMirrors => DownloadMirror.values;

  Future<String> getModelDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _modelDirName));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<String> getModelPath(String modelId) async {
    final dir = await getModelDir();
    return p.join(dir, modelId);
  }

  Future<bool> isModelDownloaded(String modelId) async {
    final modelPath = await getModelPath(modelId);
    final dir = Directory(modelPath);
    if (!dir.existsSync()) return false;

    if (modelId == 'silero-vad') {
      return File(p.join(modelPath, 'silero_vad.onnx')).existsSync();
    }

    final hasTokens = File(p.join(modelPath, 'tokens.txt')).existsSync();
    if (!hasTokens) return false;

    final asr = AsrModels.byId(modelId);
    if (asr != null) {
      if (File(p.join(modelPath, asr.modelFileName)).existsSync()) return true;
      final onnxFiles = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.onnx')).toList();
      return onnxFiles.isNotEmpty;
    }

    final tts = TtsModels.byId(modelId);
    if (tts != null) {
      if (File(p.join(modelPath, tts.modelFileName)).existsSync()) return true;
      final onnxFiles = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.onnx')).toList();
      return onnxFiles.isNotEmpty;
    }

    return false;
  }

  Future<String?> findModelFile(String modelId) async {
    final modelPath = await getModelPath(modelId);
    final dir = Directory(modelPath);
    if (!dir.existsSync()) return null;

    final asr = AsrModels.byId(modelId);
    final tts = TtsModels.byId(modelId);
    final expectedName = asr?.modelFileName ?? tts?.modelFileName;

    if (expectedName != null) {
      final f = File(p.join(modelPath, expectedName));
      if (f.existsSync()) return f.path;
    }

    final onnxFiles = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.onnx')).toList();
    if (onnxFiles.isNotEmpty) return onnxFiles.first.path;
    return null;
  }

  Future<String?> findTokensFile(String modelId) async {
    final modelPath = await getModelPath(modelId);
    final f = File(p.join(modelPath, 'tokens.txt'));
    return f.existsSync() ? f.path : null;
  }

  void cancelDownload() {
    _cancelRequested = true;
    _httpClient?.close(force: true);
  }

  Future<void> downloadModel(String modelId, {void Function(double progress)? onProgress}) async {
    _cancelRequested = false;

    final alreadyDownloaded = await isModelDownloaded(modelId);
    if (alreadyDownloaded) {
      Logger.i('Model $modelId already downloaded, skip');
      onProgress?.call(1.0);
      return;
    }

    if (modelId == 'silero-vad') {
      await _downloadVadModel(onProgress);
      return;
    }

    final asr = AsrModels.byId(modelId);
    final tts = TtsModels.byId(modelId);
    if (asr == null && tts == null) throw ArgumentError('Unknown model id: $modelId');

    final fileName = asr != null ? asr.downloadUrl.split('/').last : tts!.downloadUrl.split('/').last;
    final subDir = asr != null ? 'asr-models' : 'tts-models';
    final relativePath = '$subDir/$fileName';

    final tempDir = await getTemporaryDirectory();
    final tarBz2Path = p.join(tempDir.path, '$modelId.tar.bz2');
    final tarBz2File = File(tarBz2Path);
    final extractDir = Directory(p.join(tempDir.path, '$modelId-extract'));
    if (extractDir.existsSync()) await extractDir.delete(recursive: true);
    await extractDir.create(recursive: true);

    final urls = <String>[];
    for (final m in DownloadMirror.values) {
      urls.add('${m.baseUrl}/$relativePath');
    }

    Exception? lastError;
    for (final url in urls) {
      if (_cancelRequested) throw CancellationException();
      try {
        Logger.i('Downloading $modelId from $url');
        await _downloadWithRetry(url, tarBz2File, onProgress);
        lastError = null;
        break;
      } catch (e) {
        if (e is CancellationException) {
          if (tarBz2File.existsSync()) await tarBz2File.delete();
          throw e;
        }
        Logger.w('Download from $url failed: $e');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    if (lastError != null) {
      if (tarBz2File.existsSync()) await tarBz2File.delete();
      throw lastError;
    }

    onProgress?.call(1.0);
    if (!tarBz2File.existsSync()) throw FileSystemException('Downloaded file not found', tarBz2Path);

    Logger.i('Extracting $modelId via native tar...');
    final modelDir = Directory(await getModelPath(modelId));
    if (!modelDir.existsSync()) await modelDir.create(recursive: true);

    final extracted = await _extractNative(tarBz2Path, extractDir.path);
    if (!extracted) {
      Logger.w('Native tar failed, trying Dart archive fallback in isolate');
      await _extractInIsolate(tarBz2Path, extractDir.path);
    }
    Logger.i('Extraction complete');

    await tarBz2File.delete();

    final extractedEntries = extractDir.listSync();
    for (final entry in extractedEntries) {
      if (entry is Directory) {
        final innerEntries = entry.listSync(recursive: true);
        for (final inner in innerEntries) {
          if (inner is File) {
            final rel = p.relative(inner.path, from: entry.path);
            final destPath = p.join(modelDir.path, rel);
            await File(destPath).parent.create(recursive: true);
            await inner.copy(destPath);
          }
        }
      } else if (entry is File) {
        final rel = p.basename(entry.path);
        await entry.copy(p.join(modelDir.path, rel));
      }
    }

    await extractDir.delete(recursive: true);

    final verified = await isModelDownloaded(modelId);
    if (!verified) throw FileSystemException('Model files not found after extraction', modelDir.path);
    Logger.i('Model $modelId ready');
  }

  Future<bool> _extractNative(String tarBz2Path, String destDir) async {
    if (Platform.isAndroid || Platform.isLinux || Platform.isMacOS) {
      try {
        final r = await Process.run('tar', ['xjf', tarBz2Path, '-C', destDir]);
        if (r.exitCode == 0) return true;
      } catch (_) {}
    }
    if (Platform.isWindows) {
      try {
        final r = await Process.run('tar', ['xjf', tarBz2Path, '-C', destDir]);
        if (r.exitCode == 0) return true;
      } catch (_) {}
      try {
        final r = await Process.run('cmd', ['/c', 'tar', 'xjf', tarBz2Path, '-C', destDir]);
        if (r.exitCode == 0) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<void> _extractInIsolate(String tarBz2Path, String extractDirPath) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _extractEntry,
      _ExtractPayload(tarBz2Path, extractDirPath, receivePort.sendPort),
      debugName: 'extract-isolate',
    );

    final completer = Completer<void>();
    receivePort.listen((msg) {
      if (msg == 'done') {
        completer.complete();
      } else if (msg is String && msg.startsWith('error:')) {
        completer.completeError(Exception(msg.substring(6)));
      }
    });

    await completer.future;
    receivePort.close();
  }

  static void _extractEntry(_ExtractPayload payload) {
    try {
      final file = File(payload.tarBz2Path);
      final bytes = file.readAsBytesSync();
      final tarBytes = archive.BZip2Decoder().decodeBytes(bytes);
      final archiveResult = archive.TarDecoder().decodeBytes(tarBytes);

      for (final entry in archiveResult) {
        final outputPath = p.join(payload.extractDirPath, entry.name);
        if (entry.isFile) {
          final outFile = File(outputPath);
          outFile.parent.createSync(recursive: true);
          outFile.writeAsBytesSync(entry.content as List<int>);
        } else {
          final dir = Directory(outputPath);
          if (!dir.existsSync()) dir.createSync(recursive: true);
        }
      }
      payload.sendPort.send('done');
    } catch (e) {
      payload.sendPort.send('error:$e');
    }
  }

  Future<void> _downloadVadModel(void Function(double progress)? onProgress) async {
    final modelDir = Directory(await getModelPath('silero-vad'));
    if (!modelDir.existsSync()) await modelDir.create(recursive: true);
    final destFile = File(p.join(modelDir.path, 'silero_vad.onnx'));

    final urls = <String>[];
    for (final m in DownloadMirror.values) {
      urls.add('${m.baseUrl}/asr-models/silero_vad.onnx');
    }

    Exception? lastError;
    for (final url in urls) {
      if (_cancelRequested) throw CancellationException();
      try {
        await _downloadWithRetry(url, destFile, onProgress);
        lastError = null;
        break;
      } catch (e) {
        if (e is CancellationException) {
          if (destFile.existsSync()) await destFile.delete();
          throw e;
        }
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    if (lastError != null) {
      if (destFile.existsSync()) await destFile.delete();
      throw lastError;
    }
    onProgress?.call(1.0);
  }

  Future<void> _downloadWithRetry(String url, File destFile, void Function(double progress)? onProgress, {int maxRetries = 3}) async {
    Exception? lastError;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (_cancelRequested) throw CancellationException();
      try {
        final existingLen = destFile.existsSync() ? destFile.lengthSync() : 0;
        _httpClient = HttpClient();
        _httpClient!.connectionTimeout = const Duration(seconds: 30);
        _httpClient!.idleTimeout = const Duration(seconds: 120);

        final request = await _httpClient!.getUrl(Uri.parse(url));
        if (existingLen > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existingLen-');

        final response = await request.close();
        final statusCode = response.statusCode;
        if (statusCode != HttpStatus.ok && statusCode != HttpStatus.partialContent) {
          throw HttpException('HTTP $statusCode for $url');
        }

        final total = response.contentLength > 0 ? response.contentLength + existingLen : 0;
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
            if (total > 0) onProgress?.call(received / total);
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
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  Future<String> getVadModelPath() async {
    final modelPath = await getModelPath('silero-vad');
    return p.join(modelPath, 'silero_vad.onnx');
  }
}

class _ExtractPayload {
  final String tarBz2Path;
  final String extractDirPath;
  final SendPort sendPort;
  _ExtractPayload(this.tarBz2Path, this.extractDirPath, this.sendPort);
}

class CancellationException implements Exception {}
