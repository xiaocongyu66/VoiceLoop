import 'dart:typed_data';

import 'asr_isolate.dart';

class AsrService {
  final AsrIsolate _isolate = AsrIsolate();

  bool get isInitialized => _isolate.isInitialized;

  Future<void> init(
    String modelPath,
    String tokensPath, {
    String? language,
    String? vadModelPath,
  }) async {
    await _isolate.init(
      modelPath,
      tokensPath,
      language: language,
      vadModelPath: vadModelPath,
    );
  }

  Future<String> recognize(Float32List samples, {int sampleRate = 16000}) async {
    if (!_isolate.isInitialized) {
      throw StateError('AsrService not initialized');
    }
    return await _isolate.recognize(samples);
  }

  void dispose() {
    _isolate.dispose();
  }
}
