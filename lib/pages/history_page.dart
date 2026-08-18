import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/languages.dart';
import '../core/extensions/context_extensions.dart';
import '../providers/session_provider.dart';
import '../widgets/empty_state.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史会话'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: sessions.isEmpty
          ? const EmptyState(
              icon: Icons.history_rounded,
              title: '暂无历史会话',
              subtitle: '开始录音后，翻译记录会出现在这里',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final sourceLang = AppLanguages.byCode(session.sourceLang);
                final targetLang = AppLanguages.byCode(session.targetLang);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        session.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('${sourceLang?.flag ?? '🌐'} → ${targetLang?.flag ?? '🌐'}'),
                              const SizedBox(width: 8),
                              Text(
                                '${session.messages.length} 条消息',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(session.updatedAt),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/session/${session.id}'),
                    ),
                  ),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(5 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
