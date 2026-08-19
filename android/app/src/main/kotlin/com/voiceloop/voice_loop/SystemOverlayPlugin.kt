package com.voiceloop.voice_loop

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SystemOverlayPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val channelName = "com.voiceloop.system_overlay"
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasOverlayPermission" -> {
                result.hasOverlayPermission()
            }
            "requestOverlayPermission" -> {
                result.requestOverlayPermission()
            }
            "showOverlay" -> {
                val ctx = context ?: run {
                    result.error("NO_CONTEXT", "Context is null", null)
                    return
                }
                val intent = Intent(ctx, SystemOverlayService::class.java)
                intent.action = SystemOverlayService.ACTION_SHOW
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(intent)
                } else {
                    ctx.startService(intent)
                }
                result.success(true)
            }
            "hideOverlay" -> {
                val ctx = context ?: run {
                    result.error("NO_CONTEXT", "Context is null", null)
                    return
                }
                val intent = Intent(ctx, SystemOverlayService::class.java)
                intent.action = SystemOverlayService.ACTION_HIDE
                ctx.startService(intent)
                result.success(true)
            }
            "updateOverlayText" -> {
                val ctx = context ?: run {
                    result.error("NO_CONTEXT", "Context is null", null)
                    return
                }
                val sourceText = call.argument<String>("sourceText") ?: ""
                val translatedText = call.argument<String>("translatedText") ?: ""
                val intent = Intent(ctx, SystemOverlayService::class.java)
                intent.action = SystemOverlayService.ACTION_UPDATE
                intent.putExtra("sourceText", sourceText)
                intent.putExtra("translatedText", translatedText)
                ctx.startService(intent)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun MethodChannel.Result.hasOverlayPermission() {
        val ctx = context
        if (ctx == null) {
            success(false)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            success(Settings.canDrawOverlays(ctx))
        } else {
            success(true)
        }
    }

    private fun MethodChannel.Result.requestOverlayPermission() {
        val ctx = context
        if (ctx == null) {
            success(false)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(ctx)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:" + ctx.packageName)
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            ctx.startActivity(intent)
            success(false)
        } else {
            success(true)
        }
    }
}

class SystemOverlayService : Service() {
    companion object {
        private const val TAG = "SystemOverlayService"
        private const val NOTIFICATION_ID = 3001
        private const val CHANNEL_ID = "voiceloop_overlay_channel"
        const val ACTION_SHOW = "com.voiceloop.voice_loop.action.SHOW_OVERLAY"
        const val ACTION_HIDE = "com.voiceloop.voice_loop.action.HIDE_OVERLAY"
        const val ACTION_UPDATE = "com.voiceloop.voice_loop.action.UPDATE_OVERLAY"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var sourceTextView: TextView? = null
    private var translatedTextView: TextView? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForegroundCompat()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> showOverlay()
            ACTION_HIDE -> {
                hideOverlay()
                stopSelf()
            }
            ACTION_UPDATE -> {
                val source = intent.getStringExtra("sourceText") ?: ""
                val translated = intent.getStringExtra("translatedText") ?: ""
                updateText(source, translated)
            }
        }
        return START_NOT_STICKY
    }

    private fun showOverlay() {
        if (overlayView != null) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Log.e(TAG, "No overlay permission")
            return
        }

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 20, 24, 20)
            setBackgroundColor(0xDD1C1C1E.toInt())
        }
        layout.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )

        sourceTextView = TextView(this).apply {
            text = ""
            setTextColor(0xCCFFFFFF.toInt())
            textSize = 13f
            maxLines = 3
            setPadding(0, 0, 0, 8)
        }
        translatedTextView = TextView(this).apply {
            text = ""
            setTextColor(0xFF4DB6AC.toInt())
            textSize = 15f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            maxLines = 4
        }
        layout.addView(sourceTextView)
        layout.addView(translatedTextView)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 24
        params.y = 100

        var initialX = params.x
        var initialY = params.y
        var initialTouchX = 0f
        var initialTouchY = 0f

        layout.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(layout, params)
                    true
                }
                else -> false
            }
        }

        overlayView = layout
        try {
            windowManager?.addView(layout, params)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay view", e)
        }
    }

    private fun hideOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to remove overlay view", e)
            }
        }
        overlayView = null
        sourceTextView = null
        translatedTextView = null
    }

    private fun updateText(source: String, translated: String) {
        sourceTextView?.text = source
        translatedTextView?.text = translated
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                CHANNEL_ID,
                "VoiceLoop Overlay",
                android.app.NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "System overlay for translation"
            }
            val manager = getSystemService(android.app.NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundCompat() {
        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            android.app.Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("VoiceLoop")
                .setContentText("Translation overlay active")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(this)
                .setContentTitle("VoiceLoop")
                .setContentText("Translation overlay active")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .build()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }
}
