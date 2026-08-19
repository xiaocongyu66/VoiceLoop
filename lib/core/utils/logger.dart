import 'dart:collection';

class LogEntry {
  final DateTime time;
  final String level;
  final String message;

  LogEntry(this.level, this.message)
      : time = DateTime.now();

  String toFormattedString() {
    return '[${time.toIso8601String()}] [$level] $message';
  }
}

class Logger {
  static const String _tag = 'VoiceLoop';
  static final Queue<LogEntry> _logs = Queue();
  static const int _maxLogs = 500;
  static void Function()? onLog;

  static List<LogEntry> get logs => _logs.toList();

  static String get logsText =>
      _logs.map((e) => e.toFormattedString()).join('\n');

  static void clear() {
    _logs.clear();
    onLog?.call();
  }

  static void d(String msg) => _add('D', msg);
  static void i(String msg) => _add('I', msg);
  static void w(String msg) => _add('W', msg);
  static void e(String msg) => _add('E', msg);

  static void _add(String level, String msg) {
    final entry = LogEntry(level, msg);
    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }
    print('[${entry.time.toIso8601String()}] [$_tag] [$level] $msg');
    onLog?.call();
  }
}
