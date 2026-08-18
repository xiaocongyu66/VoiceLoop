package com.voiceloop.voice_loop

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import android.util.Log

class MediaProjectionService : Service() {

    companion object {
        private const val TAG = "MediaProjectionService"
        private const val CHANNEL_ID = "voiceloop_projection_channel"
        private const val NOTIFICATION_ID = 2001

        const val ACTION_START = "com.voiceloop.voice_loop.action.START"
        const val ACTION_STOP = "com.voiceloop.voice_loop.action.STOP"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"

        @Volatile
        var mediaProjection: MediaProjection? = null
            private set
    }

    private var projectionManager: MediaProjectionManager? = null

    override fun onCreate() {
        super.onCreate()
        projectionManager = getSystemService(MediaProjectionManager::class.java)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, 0)
                val resultData: Intent? = intent.getParcelableExtra(EXTRA_RESULT_DATA)
                if (resultData != null) {
                    startProjection(resultCode, resultData)
                }
                startForegroundCompat()
            }
            ACTION_STOP -> {
                stopProjection()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
            else -> {
                stopProjection()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun startProjection(resultCode: Int, data: Intent) {
        try {
            stopProjection()
            mediaProjection = projectionManager?.getMediaProjection(resultCode, data)
            mediaProjection?.let {
                it.registerCallback(object : MediaProjection.Callback() {
                    override fun onStop() {
                        Log.i(TAG, "MediaProjection stopped")
                        mediaProjection = null
                        stopForeground(STOP_FOREGROUND_REMOVE)
                        stopSelf()
                    }
                }, null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "startProjection failed", e)
        }
    }

    private fun stopProjection() {
        try {
            mediaProjection?.stop()
        } catch (e: Exception) {
            Log.w(TAG, "stopProjection error", e)
        }
        mediaProjection = null
    }

    private fun createNotificationChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VoiceLoop Screen Capture",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "MediaProjection for system audio capture"
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundCompat() {
        val notification: Notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("VoiceLoop")
                .setContentText("Capturing system audio")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("VoiceLoop")
                .setContentText("Capturing system audio")
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .build()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopProjection()
        super.onDestroy()
    }
}
