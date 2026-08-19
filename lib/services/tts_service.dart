import 'dart:typed_data';

import 'audio_isolate.dart';

class TtsService {
  final AudioIsolate _isolate;
  TtsService(this._isolate);

  bool get isInitialized => _isolate.isTtsInitialized;

  Future<void> init(
    String modelPath,
    String tokensPath, {
    String? lexiconPath,
    String? dictDirPath,
    int speakerId = 0,
  }) async {
    await _isolate.initTts(
      modelPath,
      tokensPath,
      lexiconPath: lexiconPath,
      dictDirPath: dictDirPath,
      speakerId: speakerId,
    );
  }

  Future<Float32List> synthesize(String text) async {
    if (!_isolate.isTtsInitialized) {
      throw StateError('TtsService not initialized');
    }
    return await _isolate.synthesize(text);
  }

  void dispose() {}
}
