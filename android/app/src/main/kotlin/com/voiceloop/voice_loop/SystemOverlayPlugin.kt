package com.voiceloop.voice_loop

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
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
                val ctx = context
                if (ctx != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    result.success(Settings.canDrawOverlays(ctx))
                } else {
                    result.success(true)
                }
            }
            "requestOverlayPermission" -> {
                val ctx = context
                if (ctx == null) {
                    result.success(false)
                    return
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(ctx)) {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        android.net.Uri.parse("package:" + ctx.packageName)
                    )
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    ctx.startActivity(intent)
                    result.success(false)
                } else {
                    result.success(true)
                }
            }
            "showOverlay" -> {
                val ctx = context
                if (ctx == null) {
                    result.error("NO_CONTEXT", "Context is null", null)
                    return
                }
                try {
                    val intent = Intent(ctx, SystemOverlayService::class.java)
                    intent.action = SystemOverlayService.ACTION_SHOW
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        ctx.startForegroundService(intent)
                    } else {
                        ctx.startService(intent)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    Log.e("SystemOverlayPlugin", "showOverlay failed", e)
                    result.error("SHOW_FAILED", e.message, null)
                }
            }
            "hideOverlay" -> {
                val ctx = context
                if (ctx == null) {
                    result.success(false)
                    return
                }
                try {
                    val intent = Intent(ctx, SystemOverlayService::class.java)
                    intent.action = SystemOverlayService.ACTION_HIDE
                    ctx.startService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "updateOverlayText" -> {
                val ctx = context
                if (ctx == null) {
                    result.success(false)
                    return
                }
                val sourceText = call.argument<String>("sourceText") ?: ""
                val translatedText = call.argument<String>("translatedText") ?: ""
                try {
                    val intent = Intent(ctx, SystemOverlayService::class.java)
                    intent.action = SystemOverlayService.ACTION_UPDATE
                    intent.putExtra("sourceText", sourceText)
                    intent.putExtra("translatedText", translatedText)
                    ctx.startService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "updateOverlayState" -> {
                val ctx = context
                if (ctx == null) {
                    result.success(false)
                    return
                }
                val state = call.argument<String>("state") ?: "idle"
                try {
                    val intent = Intent(ctx, SystemOverlayService::class.java)
                    intent.action = SystemOverlayService.ACTION_STATE
                    intent.putExtra("state", state)
                    ctx.startService(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
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
        const val ACTION_STATE = "com.voiceloop.voice_loop.action.STATE_OVERLAY"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var sourceTextView: TextView? = null
    private var translatedTextView: TextView? = null
    private var stateTextView: TextView? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = android.app.Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("VoiceLoop")
            .setContentText("翻译悬浮窗运行中")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
        startForeground(NOTIFICATION_ID, notification)
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
            ACTION_STATE -> {
                val state = intent.getStringExtra("state") ?: "idle"
                updateState(state)
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

        val density = resources.displayMetrics.density
        val dp = { v: Int -> (v * density).toInt() }

        val bgDrawable = GradientDrawable().apply {
            setColor(Color.parseColor("#DD1C1C1E"))
            cornerRadius = dp(18).toFloat()
            setStroke(dp(1), Color.parseColor("#22FFFFFF"))
        }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(12), dp(16), dp(12))
            background = bgDrawable
            minimumWidth = dp(260)
        }

        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, dp(8))
        }

        stateTextView = TextView(this).apply {
            text = "等待翻译"
            setTextColor(Color.parseColor("#88FFFFFF"))
            textSize = 11f
        }

        val closeBtn = TextView(this).apply {
            text = "×"
            setTextColor(Color.parseColor("#66FFFFFF"))
            textSize = 18f
            setPadding(dp(8), 0, 0, 0)
            setOnClickListener {
                hideOverlay()
                stopSelf()
            }
        }

        val headerSpacer = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, 1, 1f)
        }

        headerRow.addView(stateTextView)
        headerRow.addView(headerSpacer)
        headerRow.addView(closeBtn)

        sourceTextView = TextView(this).apply {
            text = ""
            setTextColor(Color.parseColor("#BBFFFFFF"))
            textSize = 13f
            maxLines = 3
            setPadding(0, dp(4), 0, dp(6))
        }

        translatedTextView = TextView(this).apply {
            text = ""
            setTextColor(Color.parseColor("#FF4DB6AC"))
            textSize = 15f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            maxLines = 4
            setPadding(0, 0, 0, 0)
        }

        container.addView(headerRow)
        container.addView(sourceTextView)
        container.addView(translatedTextView)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            android.graphics.PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = dp(16)
        params.y = dp(80)
        params.width = dp(280)

        var initialX = params.x
        var initialY = params.y
        var initialTouchX = 0f
        var initialTouchY = 0f
        var isDragging = false

        container.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isDragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    if (dx > 5 || dy > 5) isDragging = true
                    params.x = initialX + dx.toInt()
                    params.y = initialY + dy.toInt()
                    try {
                        windowManager?.updateViewLayout(container, params)
                    } catch (_: Exception) {}
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val wasDragging = isDragging
                    isDragging = false
                    !wasDragging
                }
                else -> false
            }
        }

        overlayView = container
        layoutParams = params

        try {
            windowManager?.addView(container, params)
            Log.i(TAG, "Overlay view added successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay view", e)
        }
    }

    private fun updateText(source: String, translated: String) {
        sourceTextView?.text = source
        translatedTextView?.text = translated
        if (translated.isNotEmpty()) {
            stateTextView?.text = "翻译完成"
        } else if (source.isNotEmpty()) {
            stateTextView?.text = "翻译中..."
        }
    }

    private fun updateState(state: String) {
        stateTextView?.text = when (state) {
            "listening" -> "聆听中"
            "recognizing" -> "识别中"
            "translating" -> "翻译中"
            "speaking" -> "朗读中"
            else -> "等待翻译"
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
        stateTextView = null
        layoutParams = null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                CHANNEL_ID,
                "VoiceLoop 悬浮窗",
                android.app.NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "系统翻译悬浮窗服务"
            }
            val manager = getSystemService(android.app.NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }
}
