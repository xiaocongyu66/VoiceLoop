class Logger {
  static const String _tag = 'VoiceLoop';

  static void d(String msg) {
    _print('D', msg);
  }

  static void i(String msg) {
    _print('I', msg);
  }

  static void w(String msg) {
    _print('W', msg);
  }

  static void e(String msg) {
    _print('E', msg);
  }

  static void _print(String level, String msg) {
    final now = DateTime.now().toIso8601String();
    print('[$now] [$_tag] [$level] $msg');
  }
}
