import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/asr_service.dart';
import '../services/audio_player_service.dart';
import '../services/audio_recorder_service.dart';
import '../services/model_manager.dart';
import '../services/tts_service.dart';
import '../services/vad_service.dart';

final asrServiceProvider = Provider<AsrService>((ref) {
  final service = AsrService();
  ref.onDispose(service.dispose);
  return service;
});

final vadServiceProvider = Provider<VadService>((ref) {
  final service = VadService();
  ref.onDispose(service.dispose);
  return service;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final audioRecorderProvider = Provider<AudioRecorderService>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(service.dispose);
  return service;
});

final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

final modelManagerProvider = Provider<ModelManager>((ref) {
  return ModelManager();
});
