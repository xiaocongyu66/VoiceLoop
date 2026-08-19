package com.voiceloop.voice_loop

import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TranslationPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private val channelName = "com.voiceloop.translation"
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "translate" -> {
                val text = call.argument<String>("text") ?: ""
                val sourceLang = call.argument<String>("sourceLang") ?: ""
                val targetLang = call.argument<String>("targetLang") ?: ""
                translate(text, sourceLang, targetLang, result)
            }
            "getSupportedLanguages" -> getSupportedLanguages(result)
            "isSupported" -> {
                val sourceLang = call.argument<String>("sourceLang") ?: ""
                val targetLang = call.argument<String>("targetLang") ?: ""
                isSupported(sourceLang, targetLang, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun translate(
        text: String,
        sourceLang: String,
        targetLang: String,
        result: MethodChannel.Result
    ) {
        try {
            val source = TranslateLanguage.fromLanguageTag(sourceLang)
            val target = TranslateLanguage.fromLanguageTag(targetLang)
            if (source == null || target == null) {
                result.error("UNSUPPORTED_LANG", "Unsupported language tag", null)
                return
            }
            val options = TranslatorOptions.Builder()
                .setSourceLanguage(source)
                .setTargetLanguage(target)
                .build()
            val translator: Translator = Translation.getClient(options)
            translator.downloadModelIfNeeded()
                .addOnSuccessListener {
                    translator.translate(text)
                        .addOnSuccessListener { translated ->
                            result.success(translated)
                            translator.close()
                        }
                        .addOnFailureListener { e ->
                            result.error("TRANSLATE_FAILED", e.message, null)
                            translator.close()
                        }
                }
                .addOnFailureListener { e ->
                    result.error("MODEL_DOWNLOAD_FAILED", e.message, null)
                    translator.close()
                }
        } catch (e: Exception) {
            result.error("TRANSLATE_ERROR", e.message, null)
        }
    }

    private fun getSupportedLanguages(result: MethodChannel.Result) {
        try {
            val languages = TranslateLanguage.getAllLanguages().map { it.toString() }
            result.success(languages)
        } catch (e: Exception) {
            result.error("LIST_FAILED", e.message, null)
        }
    }

    private fun isSupported(
        sourceLang: String,
        targetLang: String,
        result: MethodChannel.Result
    ) {
        try {
            val source = TranslateLanguage.fromLanguageTag(sourceLang)
            val target = TranslateLanguage.fromLanguageTag(targetLang)
            result.success(source != null && target != null)
        } catch (e: Exception) {
            result.error("CHECK_FAILED", e.message, null)
        }
    }
}
