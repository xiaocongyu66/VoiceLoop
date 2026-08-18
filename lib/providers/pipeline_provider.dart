import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/translation_result.dart';
import '../services/audio_pipeline.dart';
import 'service_provider.dart';

export '../services/audio_pipeline.dart' show PipelineState;

final partialTextProvider = StateProvider<String>((ref) => '');

final lastTranslationProvider = StateProvider<TranslationResult?>(
  (ref) => null,
);

class PipelineStateNotifier extends StateNotifier<PipelineState> {
  final Ref _ref;
  AudioPipeline? _pipeline;
  StreamSubscription<PipelineState>? _stateSub;
  StreamSubscription<String>? _partialSub;
  StreamSubscription<TranslationResult>? _translationSub;

  PipelineStateNotifier(this._ref) : super(PipelineState.idle);

  AudioPipeline get _pipelineInstance {
    if (_pipeline != null) return _pipeline!;
    _pipeline = AudioPipeline(
      asrService: _ref.read(asrServiceProvider),
      vadService: _ref.read(vadServiceProvider),
      ttsService: _ref.read(ttsServiceProvider),
    );
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
    return _pipeline!;
  }

  Future<void> start({
    required String sourceLang,
    required String targetLang,
  }) async {
    await _pipelineInstance.start(
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  Future<void> stop() async {
    await _pipeline?.stop();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _partialSub?.cancel();
    _translationSub?.cancel();
    _pipeline?.dispose();
    super.dispose();
  }
}

final pipelineStateProvider =
    StateNotifierProvider<PipelineStateNotifier, PipelineState>(
      (ref) => PipelineStateNotifier(ref),
    );
