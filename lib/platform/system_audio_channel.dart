import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../core/utils/logger.dart';

class SystemAudioChannel {
  static const MethodChannel _channel =
      MethodChannel('com.voiceloop.system_audio');
  static const EventChannel _streamChannel =
      EventChannel('com.voiceloop.system_audio_stream');

  Stream<Float32List>? _audioStream;

  Future<bool> startSystemCapture() async {
    try {
      final result = await _channel.invokeMethod<bool>('startSystemCapture');
      return result ?? false;
    } on PlatformException catch (e) {
      Logger.e('startSystemCapture failed: ${e.code} ${e.message}');
      return false;
    }
  }

  Future<void> stopSystemCapture() async {
    try {
      await _channel.invokeMethod<void>('stopSystemCapture');
    } on PlatformException catch (e) {
      Logger.e('stopSystemCapture failed: ${e.code} ${e.message}');
    }
  }

  Stream<Float32List> get audioStream {
    _audioStream ??= _streamChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Float32List) {
            return event;
          }
          if (event is List) {
            return Float32List.fromList(event.cast<double>());
          }
          throw const FormatException(
              'Unexpected audio stream event type');
        })
        .handleError((Object error) {
          Logger.e('audioStream error: $error');
        });
    return _audioStream!;
  }
}
