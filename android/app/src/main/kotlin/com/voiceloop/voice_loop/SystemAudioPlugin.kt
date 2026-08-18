package com.voiceloop.voice_loop

import android.app.Activity
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.concurrent.thread

class SystemAudioPlugin :
    FlutterPlugin,
    ActivityAware,
    PluginRegistry.ActivityResultListener,
    EventChannel.StreamHandler {

    private val methodChannelName = "com.voiceloop.system_audio"
    private val eventChannelName = "com.voiceloop.system_audio_stream"
    private val tag = "SystemAudioPlugin"
    private val mediaProjectionRequestCode = 1001

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var activity: Activity? = null
    private var projectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null

    private var eventSink: EventChannel.EventSink? = null
    private var captureThread: Thread? = null
    @Volatile private var isCapturing = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, methodChannelName)
        methodChannel.setMethodCallHandler(::onMethodCall)

        eventChannel = EventChannel(binding.binaryMessenger, eventChannelName)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        stopSystemCapture()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        projectionManager =
            binding.activity.getSystemService(MediaProjectionManager::class.java)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        stopSystemCapture()
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != mediaProjectionRequestCode) return false
        if (resultCode == Activity.RESULT_OK && data != null) {
            try {
                startCapture(resultCode, data)
            } catch (e: Exception) {
                Log.e(tag, "onActivityResult startCapture failed", e)
            }
            return true
        }
        return false
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startSystemCapture" -> {
                try {
                    requestProjectionPermission()
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(tag, "startSystemCapture failed", e)
                    result.error("START_FAILED", e.message, null)
                }
            }
            "stopSystemCapture" -> {
                try {
                    stopSystemCapture()
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(tag, "stopSystemCapture failed", e)
                    result.error("STOP_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun requestProjectionPermission() {
        val mgr = projectionManager ?: throw IllegalStateException("projectionManager not available")
        val act = activity ?: throw IllegalStateException("activity not attached")
        act.startActivityForResult(mgr.createScreenCaptureIntent(), mediaProjectionRequestCode)
    }

    private fun startCapture(resultCode: Int, data: Intent) {
        if (isCapturing) stopSystemCapture()

        val mgr = projectionManager ?: return
        mediaProjection = mgr.getMediaProjection(resultCode, data)
        val projection = mediaProjection ?: return

        isCapturing = true
        captureThread = thread(start = true) {
            try {
                captureLoop(projection)
            } catch (e: Exception) {
                Log.e(tag, "captureLoop error", e)
                activity?.runOnUiThread {
                    eventSink?.error("CAPTURE_ERROR", e.message, null)
                }
            }
        }
    }

    private fun captureLoop(projection: MediaProjection) {
        val sampleRate = 16000
        val channelMask = AudioFormat.CHANNEL_IN_MONO
        val encoding = AudioFormat.ENCODING_PCM_16BIT

        val captureConfig = AudioPlaybackCaptureConfiguration.Builder(projection)
            .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
            .addMatchingUsage(AudioAttributes.USAGE_GAME)
            .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
            .build()

        val audioFormat = AudioFormat.Builder()
            .setSampleRate(sampleRate)
            .setChannelMask(channelMask)
            .setEncoding(encoding)
            .build()

        val minBuf = AudioRecord.getMinBufferSize(sampleRate, channelMask, encoding)
        val bufferSize = maxOf(minBuf, 4096)

        val audioRecord = AudioRecord.Builder()
            .setAudioFormat(audioFormat)
            .setBufferSizeInBytes(bufferSize)
            .setAudioPlaybackCaptureConfig(captureConfig)
            .build()

        if (audioRecord.state != AudioRecord.STATE_INITIALIZED) {
            audioRecord.release()
            Log.e(tag, "AudioRecord not initialized")
            return
        }

        try {
            audioRecord.startRecording()
            val shortBuffer = ShortArray(bufferSize / 2)
            while (isCapturing) {
                val read = audioRecord.read(shortBuffer, 0, shortBuffer.size)
                if (read > 0) {
                    val floatData = FloatArray(read)
                    for (i in 0 until read) {
                        floatData[i] = shortBuffer[i].toFloat() / Short.MAX_VALUE
                    }
                    val byteBuffer = ByteBuffer.allocateDirect(floatData.size * 4)
                        .order(ByteOrder.LITTLE_ENDIAN)
                    byteBuffer.asFloatBuffer().put(floatData)
                    val bytes = ByteArray(byteBuffer.remaining())
                    byteBuffer.get(bytes)
                    val sink = eventSink
                    if (sink != null) {
                        activity?.runOnUiThread {
                            sink.success(bytes)
                        }
                    }
                }
            }
        } finally {
            try {
                audioRecord.stop()
            } catch (_: Exception) {
            }
            audioRecord.release()
        }
    }

    private fun stopSystemCapture() {
        isCapturing = false
        captureThread?.join(2000)
        captureThread = null
        try {
            mediaProjection?.stop()
        } catch (e: Exception) {
            Log.w(tag, "mediaProjection.stop() error", e)
        }
        mediaProjection = null
    }
}
