import 'dart:io';

import 'package:flutter/services.dart';

import '../core/utils/logger.dart';

class SystemOverlayChannel {
  static const MethodChannel _channel = MethodChannel('com.voiceloop.system_overlay');

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('requestOverlayPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> show() async {
    if (!Platform.isAndroid) {
      Logger.w('System overlay not supported on ${Platform.operatingSystem}');
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('showOverlay') ?? false;
    } catch (e) {
      Logger.e('Show overlay failed: $e');
      return false;
    }
  }

  Future<bool> hide() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('hideOverlay') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateText(String sourceText, String translatedText) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('updateOverlayText', {
        'sourceText': sourceText,
        'translatedText': translatedText,
      }) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateState(String state) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('updateOverlayState', {
        'state': state,
      }) ?? false;
    } catch (_) {
      return false;
    }
  }

  bool get isSupported => Platform.isAndroid;
}
