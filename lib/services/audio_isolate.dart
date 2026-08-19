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
  _InitPayload(this.modelPath, this.tokensPath, this.language, this.vadModelPath);
}

class _TtsInitPayload {
  final String modelPath;
  final String tokensPath;
  final String? lexiconPath;
  final String? dictDirPath;
  final int speakerId;
  _TtsInitPayload(this.modelPath, this.tokensPath, this.lexiconPath,
      this.dictDirPath, this.speakerId);
}

class AudioIsolate {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool _initialized = false;
  bool _ttsInitialized = false;

  bool get isInitialized => _initialized;
  bool get isTtsInitialized => _ttsInitialized;

  final _buffer = <double>[];

  Future<void> initAsr(
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
      debugName: 'audio-isolate',
    );
    final completer = Completer<SendPort>();
    _receivePort!.listen((msg) {
      if (msg is SendPort && !completer.isCompleted) {
        completer.complete(msg);
      }
    });
    _sendPort = await completer.future;

    final responsePort = ReceivePort();
    _sendPort!.send(_IsolateMessage(
      'initAsr',
      _InitPayload(modelPath, tokensPath, language, vadModelPath),
      responsePort.sendPort,
    ));
    final result = await responsePort.first;
    if (result == true) {
      _initialized = true;
    } else {
      throw Exception('ASR isolate init failed: $result');
    }
  }

  Future<void> initTts(
    String modelPath,
    String tokensPath, {
    String? lexiconPath,
    String? dictDirPath,
    int speakerId = 0,
  }) async {
    if (!_initialized) {
      throw StateError('ASR must be initialized first');
    }
    final responsePort = ReceivePort();
    _sendPort!.send(_IsolateMessage(
      'initTts',
      _TtsInitPayload(
          modelPath, tokensPath, lexiconPath, dictDirPath, speakerId),
      responsePort.sendPort,
    ));
    final result = await responsePort.first;
    if (result == true) {
      _ttsInitialized = true;
    } else {
      throw Exception('TTS isolate init failed: $result');
    }
  }

  void feedAudio(Float32List samples) {
    if (!_initialized || _sendPort == null) return;
    _sendPort!.send(_IsolateMessage('feedAudio', samples));
  }

  Future<String> recognizeSegment(Float32List samples) async {
    if (!_initialized || _sendPort == null) {
      throw StateError('AudioIsolate not initialized');
    }
    final responsePort = ReceivePort();
    _sendPort!.send(_IsolateMessage('recognize', samples, responsePort.sendPort));
    final result = await responsePort.first;
    return result as String;
  }

  Future<Float32List> synthesize(String text) async {
    if (!_ttsInitialized || _sendPort == null) {
      throw StateError('TTS not initialized');
    }
    final responsePort = ReceivePort();
    _sendPort!.send(_IsolateMessage('synthesize', text, responsePort.sendPort));
    final result = await responsePort.first;
    if (result is Float32List) return result;
    throw Exception('TTS synthesis failed: $result');
  }

  void dispose() {
    _sendPort?.send(_IsolateMessage('dispose', null));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _initialized = false;
    _ttsInitialized = false;
  }

  static void _entryPoint(SendPort mainSendPort) {
    try {
      sherpa.initBindings();
    } catch (_) {}
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    sherpa.OfflineRecognizer? recognizer;
    sherpa.VoiceActivityDetector? vad;
    sherpa.OfflineTts? tts;
    int speakerId = 0;

    port.listen((message) {
      final msg = message as _IsolateMessage;
      switch (msg.type) {
        case 'initAsr':
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

        case 'initTts':
          try {
            final payload = msg.data as _TtsInitPayload;
            speakerId = payload.speakerId;
            final config = sherpa.OfflineTtsConfig(
              model: sherpa.OfflineTtsModelConfig(
                vits: sherpa.OfflineTtsVitsModelConfig(
                  model: payload.modelPath,
                  lexicon: payload.lexiconPath ?? '',
                  tokens: payload.tokensPath,
                  dictDir: payload.dictDirPath ?? '',
                ),
                numThreads: 1,
                debug: false,
                provider: 'cpu',
              ),
            );
            tts = sherpa.OfflineTts(config);
            msg.responsePort?.send(true);
          } catch (e) {
            msg.responsePort?.send(e.toString());
          }
          break;

        case 'feedAudio':
          try {
            final samples = msg.data as Float32List;
            final v = vad;
            if (v != null) {
              v.acceptWaveform(samples);
              v.flush();
            }
          } catch (_) {}
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

        case 'synthesize':
          try {
            final text = msg.data as String;
            final t = tts;
            if (t == null) {
              msg.responsePort?.send('TTS not initialized');
              return;
            }
            final result = t.generate(text: text, sid: speakerId, speed: 1.0);
            msg.responsePort?.send(result.samples);
          } catch (e) {
            msg.responsePort?.send(e.toString());
          }
          break;

        case 'dispose':
          recognizer?.free();
          vad?.free();
          tts?.free();
          port.close();
          break;
      }
    });
  }
}
