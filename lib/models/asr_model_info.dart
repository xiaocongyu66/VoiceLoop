import 'package:flutter/foundation.dart';

@immutable
class AsrModelInfo {
  final String id;
  final String name;
  final List<String> languages;
  final int sizeMb;
  final String downloadUrl;
  final String modelFileName;
  final String tokensFileName;
  final String? lexiconFileName;

  const AsrModelInfo({
    required this.id,
    required this.name,
    required this.languages,
    required this.sizeMb,
    required this.downloadUrl,
    required this.modelFileName,
    required this.tokensFileName,
    this.lexiconFileName,
  });

  AsrModelInfo copyWith({
    String? id,
    String? name,
    List<String>? languages,
    int? sizeMb,
    String? downloadUrl,
    String? modelFileName,
    String? tokensFileName,
    String? lexiconFileName,
  }) =>
      AsrModelInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        languages: languages ?? this.languages,
        sizeMb: sizeMb ?? this.sizeMb,
        downloadUrl: downloadUrl ?? this.downloadUrl,
        modelFileName: modelFileName ?? this.modelFileName,
        tokensFileName: tokensFileName ?? this.tokensFileName,
        lexiconFileName: lexiconFileName ?? this.lexiconFileName,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'languages': languages,
        'sizeMb': sizeMb,
        'downloadUrl': downloadUrl,
        'modelFileName': modelFileName,
        'tokensFileName': tokensFileName,
        'lexiconFileName': lexiconFileName,
      };

  factory AsrModelInfo.fromJson(Map<String, dynamic> json) => AsrModelInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        languages: (json['languages'] as List).cast<String>(),
        sizeMb: json['sizeMb'] as int,
        downloadUrl: json['downloadUrl'] as String,
        modelFileName: json['modelFileName'] as String,
        tokensFileName: json['tokensFileName'] as String,
        lexiconFileName: json['lexiconFileName'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsrModelInfo &&
          other.id == id &&
          other.name == name &&
          listEquals(other.languages, languages) &&
          other.sizeMb == sizeMb &&
          other.downloadUrl == downloadUrl &&
          other.modelFileName == modelFileName &&
          other.tokensFileName == tokensFileName &&
          other.lexiconFileName == lexiconFileName;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        Object.hashAll(languages),
        sizeMb,
        downloadUrl,
        modelFileName,
        tokensFileName,
        lexiconFileName,
      );
}

class AsrModels {
  const AsrModels._();

  static const _base =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models';

  static List<AsrModelInfo> all() => [
        const AsrModelInfo(
          id: 'sensevoice-small',
          name: 'SenseVoice Small',
          languages: ['zh', 'en', 'ja', 'ko', 'yue'],
          sizeMb: 234,
          downloadUrl:
              '$_base/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2',
          modelFileName: 'sense-voice.onnx',
          tokensFileName: 'tokens.txt',
        ),
        const AsrModelInfo(
          id: 'whisper-tiny-en',
          name: 'Whisper Tiny EN',
          languages: ['en'],
          sizeMb: 75,
          downloadUrl: '$_base/sherpa-onnx-whisper-tiny.en.tar.bz2',
          modelFileName: 'whisper-tiny.onnx',
          tokensFileName: 'tokens.txt',
        ),
        const AsrModelInfo(
          id: 'zipformer-zh-en',
          name: 'Zipformer Bilingual',
          languages: ['zh', 'en'],
          sizeMb: 80,
          downloadUrl: '$_base/sherpa-onnx-zipformer-zh-en-2023-06-21.tar.bz2',
          modelFileName: 'encoder.onnx',
          tokensFileName: 'tokens.txt',
        ),
      ];

  static AsrModelInfo? byId(String id) =>
      all().where((m) => m.id == id).firstOrNull;
}
