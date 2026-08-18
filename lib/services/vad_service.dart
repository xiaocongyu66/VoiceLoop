import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class VadService {
  sherpa.VoiceActivityDetector? _vad;

  bool get isInitialized => _vad != null;

  void init(String modelPath) {
    final config = sherpa.VadModelConfig(
      sileroVad: sherpa.SileroVadModelConfig(
        model: modelPath,
        threshold: 0.5,
        minSilenceDuration: 0.5,
        minSpeechDuration: 0.25,
        windowSize: 512,
        maxSpeechDuration: 30.0,
      ),
    );
    _vad =
        sherpa.VoiceActivityDetector(config: config, bufferSizeInSeconds: 30.0);
  }

  void acceptWaveform(Float32List samples) {
    if (_vad == null) {
      throw StateError('VadService not initialized');
    }
    _vad!.acceptWaveform(samples);
  }

  void flush() {
    _vad?.flush();
  }

  bool isEmpty() {
    if (_vad == null) return true;
    return _vad!.isEmpty();
  }

  sherpa.SpeechSegment front() {
    if (_vad == null) {
      throw StateError('VadService not initialized');
    }
    return _vad!.front();
  }

  void clear() {
    _vad?.clear();
  }

  void dispose() {
    _vad?.free();
    _vad = null;
  }
}
