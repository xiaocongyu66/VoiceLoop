import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  final StreamController<Float32List> _audioController =
      StreamController<Float32List>.broadcast();

  StreamSubscription? _recordingSub;

  bool _isRecording = false;
  bool _initialized = false;

  bool get isRecording => _isRecording;

  Stream<Float32List> get audioStream => _audioController.stream;

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _recorder.openRecorder();
    _initialized = true;
  }

  Future<void> start() async {
    if (_isRecording) return;
    await _ensureInit();

    final sink = StreamController<List<Float32List>>.broadcast();

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
      toStreamFloat32: sink.sink,
    );

    _isRecording = true;

    _recordingSub = sink.stream.listen((chunks) {
      for (final chunk in chunks) {
        _audioController.add(chunk);
      }
    });
  }

  Future<void> stop() async {
    if (!_isRecording) return;
    await _recorder.stopRecorder();
    await _recordingSub?.cancel();
    _recordingSub = null;
    _isRecording = false;
  }

  Future<void> dispose() async {
    await stop();
    await _audioController.close();
    if (_initialized) {
      await _recorder.closeRecorder();
    }
  }
}
