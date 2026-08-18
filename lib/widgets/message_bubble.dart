import 'package:flutter/material.dart';

import '../core/extensions/context_extensions.dart';
import '../models/translation_message.dart';

class MessageBubble extends StatelessWidget {
  final TranslationMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isOutgoing = message.direction == MessageDirection.outgoing;
    final align =
        isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isOutgoing
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isOutgoing ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: context.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft:
                    isOutgoing ? const Radius.circular(18) : Radius.zero,
                bottomRight:
                    isOutgoing ? Radius.zero : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isOutgoing
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.originalText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1,
                  color: textColor.withOpacity(0.15),
                ),
                const SizedBox(height: 6),
                Text(
                  message.translatedText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(message.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
