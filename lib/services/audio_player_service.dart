import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';

class AudioPlayerService {
  final FlutterTts _tts = FlutterTts();

  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  bool _isPlaying = false;

  Stream<bool> get isPlaying => _playingController.stream;

  AudioPlayerService() {
    _tts.setStartHandler(() {
      _isPlaying = true;
      _playingController.add(true);
    });
    _tts.setCompletionHandler(() {
      _isPlaying = false;
      _playingController.add(false);
    });
    _tts.setErrorHandler((msg) {
      _isPlaying = false;
      _playingController.add(false);
    });
  }

  Future<void> play(
    Float32List samples, {
    double sampleRate = 16000,
    String language = 'en-US',
  }) async {
    final intData = _float32ToInt16(samples);
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.5);
    _isPlaying = true;
    _playingController.add(true);
    await _tts.speak(_float32ToText(intData));
  }

  Int16List _float32ToInt16(Float32List samples) {
    final result = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      final clamped = (samples[i] * 32767).clamp(-32768, 32767).toInt();
      result[i] = clamped;
    }
    return result;
  }

  String _float32ToText(Int16List samples) {
    return String.fromCharCodes(samples.map((e) => e & 0xFFFF));
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
    _playingController.add(false);
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _playingController.close();
  }
}
