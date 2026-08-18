import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/asr_model_info.dart';
import '../models/tts_model_info.dart';

class ModelManager {
  static const _modelDirName = 'models';

  Future<String> getModelDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _modelDirName));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
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

  Future<String> getModelPath(String modelId) async {
    final dir = await getModelDir();
    return p.join(dir, modelId);
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

    final downloadUrl = asr?.downloadUrl ?? tts!.downloadUrl;
    final modelFileName = asr?.modelFileName ?? tts!.modelFileName;
    final tokensFileName = asr?.tokensFileName ?? tts!.tokensFileName;

    final modelDir = await getModelPath(modelId);
    final dir = Directory(modelDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final modelPath = p.join(modelDir, modelFileName);
    final tokensPath = p.join(modelDir, tokensFileName);

    final modelFile = File(modelPath);
    final tokensFile = File(tokensPath);

    if (modelFile.existsSync() && tokensFile.existsSync()) {
      onProgress?.call(1.0);
      return;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      final total = response.contentLength;
      var received = 0;

      final sink = modelFile.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          onProgress?.call(received / total);
        }
      }
      await sink.flush();
      await sink.close();
    } finally {
      client.close();
    }

    onProgress?.call(1.0);
  }

  Future<void> deleteModel(String modelId) async {
    final modelDir = await getModelPath(modelId);
    final dir = Directory(modelDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
