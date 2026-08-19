import 'package:flutter/services.dart';

import '../core/utils/logger.dart';

class SystemOverlayChannel {
  static const MethodChannel _channel = MethodChannel('com.voiceloop.system_overlay');

  Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    } catch (e) {
      Logger.e('Overlay permission check failed: $e');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestOverlayPermission') ?? false;
    } catch (e) {
      Logger.e('Overlay permission request failed: $e');
      return false;
    }
  }

  Future<bool> show() async {
    try {
      return await _channel.invokeMethod<bool>('showOverlay') ?? false;
    } catch (e) {
      Logger.e('Show overlay failed: $e');
      return false;
    }
  }

  Future<bool> hide() async {
    try {
      return await _channel.invokeMethod<bool>('hideOverlay') ?? false;
    } catch (e) {
      Logger.e('Hide overlay failed: $e');
      return false;
    }
  }

  Future<bool> updateText(String sourceText, String translatedText) async {
    try {
      return await _channel.invokeMethod<bool>('updateOverlayText', {
        'sourceText': sourceText,
        'translatedText': translatedText,
      }) ?? false;
    } catch (e) {
      Logger.e('Update overlay text failed: $e');
      return false;
    }
  }
}
