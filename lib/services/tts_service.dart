import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class TtsService {
  sherpa.OfflineTts? _tts;
  int _speakerId = 0;

  bool get isInitialized => _tts != null;

  void init(
    String modelPath,
    String tokensPath, {
    String? lexiconPath,
    String? dictDirPath,
    int speakerId = 0,
  }) {
    final config = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: modelPath,
          lexicon: lexiconPath ?? '',
          tokens: tokensPath,
          dictDir: dictDirPath ?? '',
        ),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      ),
    );
    _tts = sherpa.OfflineTts(config);
    _speakerId = speakerId;
  }

  Float32List synthesize(String text) {
    if (_tts == null) {
      throw StateError('TtsService not initialized');
    }
    final result = _tts!.generate(text: text, sid: _speakerId, speed: 1.0);
    return result.samples;
  }

  int get sampleRate {
    if (_tts == null) return 0;
    final result = _tts!.generate(text: '', sid: _speakerId, speed: 1.0);
    return result.sampleRate;
  }

  void dispose() {
    _tts?.free();
    _tts = null;
  }
}
