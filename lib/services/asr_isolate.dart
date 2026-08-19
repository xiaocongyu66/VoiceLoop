import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class _IsolateMessage {
  final String type;
  final dynamic data;
  final SendPort? responsePort;
  _IsolateMessage(this.type, this.data, [this.responsePort]);
}

class _InitPayload {
  final String modelPath;
  final String tokensPath;
  final String? language;
  final String? vadModelPath;
  _InitPayload(
    this.modelPath,
    this.tokensPath,
    this.language,
    this.vadModelPath,
  );
}

class AsrIsolate {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init(
    String modelPath,
    String tokensPath, {
    String? language,
    String? vadModelPath,
  }) async {
    if (_initialized) return;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _entryPoint,
      _receivePort!.sendPort,
      debugName: 'asr-isolate',
    );
    final completer = Completer<SendPort>();
    _receivePort!.listen((msg) {
      if (msg is SendPort && !completer.isCompleted) {
        completer.complete(msg);
      }
    });
    _sendPort = await completer.future;

    final responsePort = ReceivePort();
    _sendPort!.send(
      _IsolateMessage(
        'init',
        _InitPayload(modelPath, tokensPath, language, vadModelPath),
        responsePort.sendPort,
      ),
    );
    final result = await responsePort.first;
    if (result == true) {
      _initialized = true;
    } else {
      throw Exception('ASR isolate init failed: $result');
    }
  }

  Future<String> recognize(Float32List samples) async {
    if (!_initialized || _sendPort == null) {
      throw StateError('AsrIsolate not initialized');
    }
    final responsePort = ReceivePort();
    _sendPort!.send(
      _IsolateMessage('recognize', samples, responsePort.sendPort),
    );
    final result = await responsePort.first;
    return result as String;
  }

  void dispose() {
    _sendPort?.send(_IsolateMessage('dispose', null));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _initialized = false;
  }

  static void _entryPoint(SendPort mainSendPort) {
    try {
      sherpa.initBindings();
    } catch (_) {}
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    sherpa.OfflineRecognizer? recognizer;
    sherpa.VoiceActivityDetector? vad;

    port.listen((message) {
      final msg = message as _IsolateMessage;
      switch (msg.type) {
        case 'init':
          try {
            final payload = msg.data as _InitPayload;
            final config = sherpa.OfflineRecognizerConfig(
              model: sherpa.OfflineModelConfig(
                tokens: payload.tokensPath,
                senseVoice: sherpa.OfflineSenseVoiceModelConfig(
                  model: payload.modelPath,
                  language: payload.language ?? 'auto',
                  useInverseTextNormalization: true,
                ),
                numThreads: 2,
                debug: false,
                provider: 'cpu',
              ),
            );
            recognizer = sherpa.OfflineRecognizer(config);

            if (payload.vadModelPath != null) {
              final vadConfig = sherpa.VadModelConfig(
                sileroVad: sherpa.SileroVadModelConfig(
                  model: payload.vadModelPath!,
                  threshold: 0.5,
                  minSilenceDuration: 0.5,
                  minSpeechDuration: 0.25,
                  windowSize: 512,
                  maxSpeechDuration: 30.0,
                ),
              );
              vad = sherpa.VoiceActivityDetector(
                config: vadConfig,
                bufferSizeInSeconds: 30.0,
              );
            }
            msg.responsePort?.send(true);
          } catch (e) {
            msg.responsePort?.send(e.toString());
          }
          break;
        case 'recognize':
          try {
            final samples = msg.data as Float32List;
            final rec = recognizer;
            if (rec == null) {
              msg.responsePort?.send('');
              return;
            }
            final stream = rec.createStream();
            stream.acceptWaveform(samples: samples, sampleRate: 16000);
            rec.decode(stream);
            final result = rec.getResult(stream);
            stream.free();
            msg.responsePort?.send(result.text);
          } catch (e) {
            msg.responsePort?.send('');
          }
          break;
        case 'dispose':
          recognizer?.free();
          vad?.free();
          port.close();
          break;
      }
    });
  }
}
