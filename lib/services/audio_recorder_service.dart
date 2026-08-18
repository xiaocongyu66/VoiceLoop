import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  final StreamController<Float32List> _audioController =
      StreamController<Float32List>.broadcast();

  StreamSubscription? _recordingSub;

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Stream<Float32List> get audioStream => _audioController.stream;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> start() async {
    if (_isRecording) return;

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );

    _isRecording = true;

    _recordingSub = stream.listen((data) {
      _audioController.add(_pcm16ToFloat32(data));
    });
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final length = bytes.length ~/ 2;
    final result = Float32List(length);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < length; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      result[i] = sample / 32768.0;
    }
    return result;
  }

  Future<void> stop() async {
    if (!_isRecording) return;
    await _recorder.stop();
    await _recordingSub?.cancel();
    _recordingSub = null;
    _isRecording = false;
  }

  Future<void> dispose() async {
    await stop();
    await _audioController.close();
    await _recorder.dispose();
  }
}
