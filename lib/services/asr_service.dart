import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class AsrService {
  sherpa.OfflineRecognizer? _recognizer;

  bool get isInitialized => _recognizer != null;

  void init(String modelPath, String tokensPath, {String? language}) {
    final config = sherpa.OfflineRecognizerConfig(
      model: sherpa.OfflineModelConfig(
        tokens: tokensPath,
        senseVoice: sherpa.OfflineSenseVoiceModelConfig(
          model: modelPath,
          language: language ?? 'auto',
          useInverseTextNormalization: true,
        ),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      ),
    );
    _recognizer = sherpa.OfflineRecognizer(config);
  }

  String recognize(Float32List samples, {int sampleRate = 16000}) {
    if (_recognizer == null) {
      throw StateError('AsrService not initialized');
    }
    final stream = _recognizer!.createStream();
    stream.acceptWaveform(samples: samples, sampleRate: sampleRate);
    _recognizer!.decode(stream);
    final result = _recognizer!.getResult(stream);
    stream.free();
    return result.text;
  }

  void dispose() {
    _recognizer?.free();
    _recognizer = null;
  }
}
