import 'dart:async';
import 'dart:typed_data';

import '../models/translation_result.dart';
import 'asr_service.dart';
import 'audio_recorder_service.dart';
import 'tts_service.dart';
import 'vad_service.dart';

enum PipelineState { idle, listening, recognizing, translating, speaking }

typedef TranslationCallback =
    Future<String> Function(String text, String sourceLang, String targetLang);

typedef TtsCallback =
    Future<Float32List> Function(String text, String targetLang);

class AudioPipeline {
  final AsrService asrService;
  final VadService vadService;
  final TtsService ttsService;
  AudioRecorderService? _recorder;

  final StreamController<PipelineState> _stateController =
      StreamController<PipelineState>.broadcast();

  final StreamController<String> _partialTextController =
      StreamController<String>.broadcast();

  final StreamController<TranslationResult> _translationController =
      StreamController<TranslationResult>.broadcast();

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final List<double> _buffer = [];

  PipelineState _state = PipelineState.idle;
  bool _running = false;
  StreamSubscription<Float32List>? _audioSub;

  TranslationCallback? onTranslate;
  TtsCallback? onSynthesize;

  AudioPipeline({
    required this.asrService,
    required this.vadService,
    required this.ttsService,
  });

  PipelineState get state => _state;

  Stream<PipelineState> get stateStream => _stateController.stream;

  Stream<String> get partialTextStream => _partialTextController.stream;

  Stream<TranslationResult> get translationStream =>
      _translationController.stream;

  Stream<String> get errorStream => _errorController.stream;

  void _setState(PipelineState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> start({
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_running) return;
    _running = true;

    _setState(PipelineState.listening);

    _recorder ??= AudioRecorderService();
    await _recorder!.start();
    _audioSub = _recorder!.audioStream.listen((samples) {
      _processAudioChunk(samples, sourceLang, targetLang);
    });
  }

  void _processAudioChunk(
    Float32List samples,
    String sourceLang,
    String targetLang,
  ) {
    if (!_running) return;

    _buffer.addAll(samples);

    const int chunkSize = 512;
    while (_buffer.length >= chunkSize) {
      final chunk = Float32List.fromList(_buffer.sublist(0, chunkSize));
      _buffer.removeRange(0, chunkSize);

      if (vadService.isInitialized) {
        vadService.acceptWaveform(chunk);
        vadService.flush();
        while (!vadService.isEmpty()) {
          final segment = vadService.front();
          if (segment.samples.isNotEmpty) {
            _handleSpeechSegment(
              Float32List.fromList(segment.samples),
              sourceLang,
              targetLang,
            );
          }
          vadService.clear();
        }
      } else {
        _handleSpeechSegment(chunk, sourceLang, targetLang);
      }
    }
  }

  Future<void> _handleSpeechSegment(
    Float32List speech,
    String sourceLang,
    String targetLang,
  ) async {
    _setState(PipelineState.recognizing);

    String text = '';
    try {
      text = asrService.recognize(speech);
    } catch (e) {
      _errorController.add('recognitionFailed');
      _setState(PipelineState.listening);
      return;
    }

    if (text.isEmpty) {
      _setState(PipelineState.listening);
      return;
    }

    _partialTextController.add(text);

    if (onTranslate != null) {
      _setState(PipelineState.translating);
      String translated;
      try {
        translated = await onTranslate!(text, sourceLang, targetLang);
      } catch (e) {
        _errorController.add('translationFailed');
        translated = '[Translation failed: $e]';
      }

      final result = TranslationResult(
        originalText: text,
        translatedText: translated,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        timestamp: DateTime.now(),
      );
      _translationController.add(result);

      if (onSynthesize != null) {
        _setState(PipelineState.speaking);
        try {
          await onSynthesize!(translated, targetLang);
        } catch (e) {
          _errorController.add('ttsFailed');
        }
      }
    }

    if (_running) {
      _setState(PipelineState.listening);
    }
  }

  void emitError(String error) {
    _errorController.add(error);
  }

  Future<void> stop() async {
    _running = false;
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder?.stop();
    _buffer.clear();
    _setState(PipelineState.idle);
  }

  Future<void> dispose() async {
    await stop();
    await _stateController.close();
    await _partialTextController.close();
    await _translationController.close();
    await _errorController.close();
    await _recorder?.dispose();
  }
}
