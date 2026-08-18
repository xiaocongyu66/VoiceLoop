import 'package:flutter/foundation.dart';

@immutable
class TtsModelInfo {
  final String id;
  final String name;
  final String language;
  final int sizeMb;
  final String downloadUrl;
  final String modelFileName;
  final String tokensFileName;
  final String? lexiconPath;
  final String? dictDirPath;
  final int numSpeakers;

  const TtsModelInfo({
    required this.id,
    required this.name,
    required this.language,
    required this.sizeMb,
    required this.downloadUrl,
    required this.modelFileName,
    required this.tokensFileName,
    this.lexiconPath,
    this.dictDirPath,
    this.numSpeakers = 1,
  });

  TtsModelInfo copyWith({
    String? id,
    String? name,
    String? language,
    int? sizeMb,
    String? downloadUrl,
    String? modelFileName,
    String? tokensFileName,
    String? lexiconPath,
    String? dictDirPath,
    int? numSpeakers,
  }) => TtsModelInfo(
    id: id ?? this.id,
    name: name ?? this.name,
    language: language ?? this.language,
    sizeMb: sizeMb ?? this.sizeMb,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    modelFileName: modelFileName ?? this.modelFileName,
    tokensFileName: tokensFileName ?? this.tokensFileName,
    lexiconPath: lexiconPath ?? this.lexiconPath,
    dictDirPath: dictDirPath ?? this.dictDirPath,
    numSpeakers: numSpeakers ?? this.numSpeakers,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'language': language,
    'sizeMb': sizeMb,
    'downloadUrl': downloadUrl,
    'modelFileName': modelFileName,
    'tokensFileName': tokensFileName,
    'lexiconPath': lexiconPath,
    'dictDirPath': dictDirPath,
    'numSpeakers': numSpeakers,
  };

  factory TtsModelInfo.fromJson(Map<String, dynamic> json) => TtsModelInfo(
    id: json['id'] as String,
    name: json['name'] as String,
    language: json['language'] as String,
    sizeMb: json['sizeMb'] as int,
    downloadUrl: json['downloadUrl'] as String,
    modelFileName: json['modelFileName'] as String,
    tokensFileName: json['tokensFileName'] as String,
    lexiconPath: json['lexiconPath'] as String?,
    dictDirPath: json['dictDirPath'] as String?,
    numSpeakers: json['numSpeakers'] as int? ?? 1,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsModelInfo &&
          other.id == id &&
          other.name == name &&
          other.language == language &&
          other.sizeMb == sizeMb &&
          other.downloadUrl == downloadUrl &&
          other.modelFileName == modelFileName &&
          other.tokensFileName == tokensFileName &&
          other.lexiconPath == lexiconPath &&
          other.dictDirPath == dictDirPath &&
          other.numSpeakers == numSpeakers;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    language,
    sizeMb,
    downloadUrl,
    modelFileName,
    tokensFileName,
    lexiconPath,
    dictDirPath,
    numSpeakers,
  );
}

class TtsModels {
  const TtsModels._();

  static const _base =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';

  static List<TtsModelInfo> all() => [
    const TtsModelInfo(
      id: 'piper-en',
      name: 'Piper EN',
      language: 'en',
      sizeMb: 65,
      downloadUrl: '$_base/vits-piper-en_US-amy-low.tar.bz2',
      modelFileName: 'en_US-amy-low.onnx',
      tokensFileName: 'tokens.txt',
    ),
    const TtsModelInfo(
      id: 'piper-zh',
      name: 'Piper ZH',
      language: 'zh',
      sizeMb: 65,
      downloadUrl: '$_base/vits-piper-zh_CN-huayan-medium.tar.bz2',
      modelFileName: 'zh_CN-huayan-medium.onnx',
      tokensFileName: 'tokens.txt',
    ),
    const TtsModelInfo(
      id: 'matcha-zh',
      name: 'Matcha ZH',
      language: 'zh',
      sizeMb: 100,
      downloadUrl: '$_base/matcha-icefall-zh-baker-zh.tar.bz2',
      modelFileName: 'model-steps-3k.onnx',
      tokensFileName: 'tokens.txt',
      lexiconPath: 'lexicon.txt',
      dictDirPath: 'dict',
    ),
    const TtsModelInfo(
      id: 'matcha-en',
      name: 'Matcha EN',
      language: 'en',
      sizeMb: 100,
      downloadUrl: '$_base/matcha-icefall-en_US-ljspeech.tar.bz2',
      modelFileName: 'model-steps-3k.onnx',
      tokensFileName: 'tokens.txt',
      lexiconPath: 'lexicon.txt',
      dictDirPath: 'dict',
    ),
  ];

  static TtsModelInfo? byId(String id) =>
      all().where((m) => m.id == id).firstOrNull;
}
