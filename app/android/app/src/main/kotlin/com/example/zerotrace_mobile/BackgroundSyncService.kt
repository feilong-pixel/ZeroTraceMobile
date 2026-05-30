package com.example.zerotrace_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

class BackgroundSyncService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        ensureNotificationChannel()
        startForeground(notificationId, buildNotification())
        return START_NOT_STICKY
    }

    private fun buildNotification(): Notification {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutablePendingIntentFlag(),
        )

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("ExtraSync")
                .setContentText("Photo sync is running")
                .setSmallIcon(applicationInfo.icon)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("ExtraSync")
                .setContentText("Photo sync is running")
                .setSmallIcon(applicationInfo.icon)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(NotificationManager::class.java)
        val existing = manager.getNotificationChannel(channelId)
        if (existing != null) {
            return
        }
        val channel = NotificationChannel(
            channelId,
            "Photo Sync",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Keeps ExtraSync photo upload active while Auto Sync runs."
        }
        manager.createNotificationChannel(channel)
    }

    private fun immutablePendingIntentFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }

    companion object {
        private const val channelId = "extrasync_photo_sync"
        private const val notificationId = 4301
    }
}
