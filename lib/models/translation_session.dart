import 'translation_message.dart';

class TranslationSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationMessage> messages;
  final String sourceLang;
  final String targetLang;

  const TranslationSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    required this.sourceLang,
    required this.targetLang,
  });

  factory TranslationSession.fromJson(Map<String, dynamic> json) =>
      TranslationSession(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
        messages: (json['messages'] as List?)
                ?.map((e) =>
                    TranslationMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        sourceLang: json['sourceLang'] as String,
        targetLang: json['targetLang'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'messages': messages.map((m) => m.toJson()).toList(),
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationSession && other.id == id;

  @override
  int get hashCode => id.hashCode;

  TranslationSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TranslationMessage>? messages,
    String? sourceLang,
    String? targetLang,
  }) {
    return TranslationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
    );
  }
}
