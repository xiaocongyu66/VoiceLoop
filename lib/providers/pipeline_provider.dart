import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/asr_model_info.dart';
import '../models/translation_result.dart';
import '../models/tts_model_info.dart';
import '../services/audio_pipeline.dart';
import 'service_provider.dart';
import 'settings_provider.dart';
import 'translation_provider.dart';

export '../services/audio_pipeline.dart' show PipelineState;

final partialTextProvider = StateProvider<String>((ref) => '');

final lastTranslationProvider = StateProvider<TranslationResult?>(
  (ref) => null,
);

final pipelineErrorProvider = StateProvider<String?>((ref) => null);

class PipelineStateNotifier extends StateNotifier<PipelineState> {
  final Ref _ref;
  AudioPipeline? _pipeline;
  StreamSubscription<PipelineState>? _stateSub;
  StreamSubscription<String>? _partialSub;
  StreamSubscription<TranslationResult>? _translationSub;
  StreamSubscription<String>? _errorSub;

  PipelineStateNotifier(this._ref) : super(PipelineState.idle);

  AudioPipeline get _pipelineInstance {
    if (_pipeline != null) return _pipeline!;
    _pipeline = AudioPipeline(audioIsolate: _ref.read(audioIsolateProvider));
    _stateSub = _pipeline!.stateStream.listen((s) {
      if (mounted) state = s;
    });
    _partialSub = _pipeline!.partialTextStream.listen((text) {
      if (mounted) {
        _ref.read(partialTextProvider.notifier).state = text;
      }
    });
    _translationSub = _pipeline!.translationStream.listen((result) {
      if (mounted) {
        _ref.read(lastTranslationProvider.notifier).state = result;
      }
    });
    _errorSub = _pipeline!.errorStream.listen((error) {
      if (mounted) {
        _ref.read(pipelineErrorProvider.notifier).state = error;
      }
    });
    return _pipeline!;
  }

  Future<void> start({
    required String sourceLang,
    required String targetLang,
  }) async {
    final settings = _ref.read(settingsProvider);
    final modelManager = _ref.read(modelManagerProvider);

    final asrReady = await modelManager.isModelDownloaded(settings.asrModelId);
    if (!asrReady) {
      if (mounted) {
        _ref.read(pipelineErrorProvider.notifier).state = 'modelNotDownloaded';
      }
      _pipelineInstance.emitError('modelNotDownloaded');
      state = PipelineState.idle;
      return;
    }

    final modelDir = await modelManager.getModelPath(settings.asrModelId);
    final asrModel = AsrModels.byId(settings.asrModelId);
    if (asrModel != null) {
      final asrService = _ref.read(asrServiceProvider);
      final modelPath = p.join(modelDir, asrModel.modelFileName);
      final tokensPath = p.join(modelDir, asrModel.tokensFileName);

      String? vadModelPath;
      final vadReady = await modelManager.isModelDownloaded('silero-vad');
      if (vadReady) {
        vadModelPath = await modelManager.getVadModelPath();
      }

      state = PipelineState.recognizing;
      await asrService.init(
        modelPath,
        tokensPath,
        language: sourceLang,
        vadModelPath: vadModelPath,
      );
    }

    final ttsModelId = settings.ttsModelId;
    final ttsService = _ref.read(ttsServiceProvider);
    if (ttsModelId != null) {
      final ttsReady = await modelManager.isModelDownloaded(ttsModelId);
      if (ttsReady) {
        final ttsModel = TtsModels.byId(ttsModelId);
        if (ttsModel != null) {
          final ttsModelDir = await modelManager.getModelPath(ttsModelId);
          await ttsService.init(
            p.join(ttsModelDir, ttsModel.modelFileName),
            p.join(ttsModelDir, ttsModel.tokensFileName),
            lexiconPath: ttsModel.lexiconPath != null
                ? p.join(ttsModelDir, ttsModel.lexiconPath!)
                : null,
            dictDirPath: ttsModel.dictDirPath != null
                ? p.join(ttsModelDir, ttsModel.dictDirPath!)
                : null,
          );
        }
      }
    }

    final pipeline = _pipelineInstance;

    final channel = _ref.read(translationChannelProvider);
    pipeline.onTranslate = (text, src, tgt) async {
      return channel.translate(text, src, tgt);
    };

    pipeline.onSynthesize = (text, target) async {
      if (!ttsService.isInitialized) {
        throw StateError('TTS service not initialized');
      }
      return ttsService.synthesize(text);
    };

    await pipeline.start(sourceLang: sourceLang, targetLang: targetLang);
  }

  Future<void> stop() async {
    await _pipeline?.stop();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _partialSub?.cancel();
    _translationSub?.cancel();
    _errorSub?.cancel();
    _pipeline?.dispose();
    super.dispose();
  }
}

final pipelineStateProvider =
    StateNotifierProvider<PipelineStateNotifier, PipelineState>(
      (ref) => PipelineStateNotifier(ref),
    );
