import 'dart:typed_data';

import 'audio_isolate.dart';

class AsrService {
  final AudioIsolate _isolate;
  AsrService(this._isolate);

  bool get isInitialized => _isolate.isInitialized;

  Future<void> init(
    String modelPath,
    String tokensPath, {
    String? language,
    String? vadModelPath,
  }) async {
    await _isolate.initAsr(
      modelPath,
      tokensPath,
      language: language,
      vadModelPath: vadModelPath,
    );
  }

  Future<String> recognize(
    Float32List samples, {
    int sampleRate = 16000,
  }) async {
    if (!_isolate.isInitialized) {
      throw StateError('AsrService not initialized');
    }
    return await _isolate.recognizeSegment(samples);
  }

  void dispose() {}
}
