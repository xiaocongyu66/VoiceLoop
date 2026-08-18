import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'service_provider.dart';

enum DownloadStatus { idle, downloading, completed, failed }

class ModelDownloadState {
  final DownloadStatus status;
  final double progress;
  final String? error;

  const ModelDownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0,
    this.error,
  });

  ModelDownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
  }) {
    return ModelDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

class ModelDownloadNotifier extends StateNotifier<ModelDownloadState> {
  final String _modelId;
  final Ref _ref;

  ModelDownloadNotifier(this._modelId, this._ref)
    : super(const ModelDownloadState());

  Future<void> download() async {
    state = const ModelDownloadState(status: DownloadStatus.downloading);
    try {
      final manager = _ref.read(modelManagerProvider);
      await manager.downloadModel(_modelId, onProgress: (p) {
        state = ModelDownloadState(
          status: DownloadStatus.downloading,
          progress: p,
        );
      });
      state = const ModelDownloadState(
        status: DownloadStatus.completed,
        progress: 1.0,
      );
    } catch (e) {
      state = ModelDownloadState(
        status: DownloadStatus.failed,
        error: e.toString(),
      );
    }
  }

  void cancel() {
    final manager = _ref.read(modelManagerProvider);
    manager.cancelDownload();
    state = const ModelDownloadState(status: DownloadStatus.idle);
  }

  Future<void> delete() async {
    final manager = _ref.read(modelManagerProvider);
    await manager.deleteModel(_modelId);
    state = const ModelDownloadState();
  }

  Future<bool> checkDownloaded() async {
    final manager = _ref.read(modelManagerProvider);
    final downloaded = await manager.isModelDownloaded(_modelId);
    if (downloaded) {
      state = const ModelDownloadState(
        status: DownloadStatus.completed,
        progress: 1.0,
      );
    }
    return downloaded;
  }
}

final modelDownloadProvider =
    StateNotifierProvider.family<ModelDownloadNotifier, ModelDownloadState, String>(
      (ref, modelId) => ModelDownloadNotifier(modelId, ref),
    );
