package com.voiceloop.voice_loop

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ModelExtractPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val channelName = "com.voiceloop.model_extract"
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
            "extractTarBz2" -> {
                val tarBz2Path = call.argument<String>("tarBz2Path")
                val destDir = call.argument<String>("destDir")
                if (tarBz2Path == null || destDir == null) {
                    result.error("INVALID_ARGS", "Missing arguments", null)
                    return
                }
                try {
                    val file = File(tarBz2Path)
                    if (!file.exists()) {
                        result.success(false)
                        return
                    }
                    val dest = File(destDir)
                    if (!dest.exists()) dest.mkdirs()

                    val pb = ProcessBuilder("tar", "xjf", tarBz2Path, "-C", destDir)
                    pb.redirectErrorStream(true)
                    val process = pb.start()
                    val exitCode = process.waitFor()
                    val output = process.inputStream.bufferedReader().readText()

                    if (exitCode == 0) {
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }
}
