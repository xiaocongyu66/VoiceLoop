package com.voiceloop.voice_loop

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            flutterEngine.plugins.add(TranslationPlugin())
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to add TranslationPlugin", e)
        }
        try {
            flutterEngine.plugins.add(SystemAudioPlugin())
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to add SystemAudioPlugin", e)
        }
        try {
            flutterEngine.plugins.add(SystemOverlayPlugin())
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to add SystemOverlayPlugin", e)
        }
    }
}
