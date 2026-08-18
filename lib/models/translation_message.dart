enum MessageDirection { incoming, outgoing }

class TranslationMessage {
  final String id;
  final String sessionId;
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  final MessageDirection direction;
  final String? audioPath;

  const TranslationMessage({
    required this.id,
    required this.sessionId,
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    required this.direction,
    this.audioPath,
  });

  factory TranslationMessage.fromJson(Map<String, dynamic> json) =>
      TranslationMessage(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        originalText: json['originalText'] as String,
        translatedText: json['translatedText'] as String,
        sourceLang: json['sourceLang'] as String,
        targetLang: json['targetLang'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        direction: (json['direction'] as int) == 0
            ? MessageDirection.incoming
            : MessageDirection.outgoing,
        audioPath: json['audioPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'originalText': originalText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'direction': direction == MessageDirection.incoming ? 0 : 1,
        'audioPath': audioPath,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationMessage && other.id == id;

  @override
  int get hashCode => id.hashCode;

  TranslationMessage copyWith({
    String? id,
    String? sessionId,
    String? originalText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    DateTime? timestamp,
    MessageDirection? direction,
    String? audioPath,
  }) {
    return TranslationMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}
