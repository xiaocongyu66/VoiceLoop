import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';
import '../l10n/app_localizations.dart';

final logUpdateProvider = StateProvider<int>((ref) => 0);

class LogPage extends ConsumerStatefulWidget {
  const LogPage({super.key});

  @override
  ConsumerState<LogPage> createState() => _LogPageState();
}

class _LogPageState extends ConsumerState<LogPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Logger.onLog = () {
      if (mounted) {
        ref.read(logUpdateProvider.notifier).state++;
      }
    };
  }

  @override
  void dispose() {
    Logger.onLog = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(logUpdateProvider);
    final logs = Logger.logs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && logs.isNotEmpty) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('日志'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: '复制全部',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: Logger.logsText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空',
            onPressed: () {
              Logger.clear();
              ref.read(logUpdateProvider.notifier).state++;
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('暂无日志'))
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder: (ctx, i) {
                final log = logs[i];
                return _LogTile(entry: log);
              },
            ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntry entry;

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.level) {
      'E' => Colors.red,
      'W' => Colors.orange,
      'I' => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    entry.level,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.time.hour.toString().padLeft(2, '0')}:'
                  '${entry.time.minute.toString().padLeft(2, '0')}:'
                  '${entry.time.second.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              entry.message,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
