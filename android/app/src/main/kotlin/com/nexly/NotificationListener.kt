package com.nexly

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import com.nexly.nexly.MainActivity
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {

    companion object {
        var channel: MethodChannel? = null
        private const val FOREGROUND_ID = 1
        private const val CHANNEL_ID = "nexly_service"
    }

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
    }

    private fun startForegroundService() {
        createNotificationChannel()

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Nexly")
            .setContentText("Monitoring notifications")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .setSilent(true)
            .build()

        startForeground(FOREGROUND_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Nexly Service",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                description = "Notification monitoring service"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        // Filter out ongoing and system notifications
        if (sbn.isOngoing) return
        if (sbn.packageName == packageName) return // Ignore self

        val notification = sbn.notification
        val extras = notification.extras
        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()
        val packageName = sbn.packageName
        val timestamp = sbn.postTime
        val category = notification.category

        // Extract action button titles if available
        val actions = notification.actions?.map { it.title.toString() } ?: emptyList()

        val notificationData = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to text,
            "timestamp" to timestamp,
            "category" to category,
            "actions" to actions
        )

        channel?.invokeMethod("onNotificationPosted", notificationData)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        val packageName = sbn.packageName

        val notificationData = mapOf(
            "packageName" to packageName,
        )

        channel?.invokeMethod("onNotificationRemoved", notificationData)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopForeground(true)
    }
}
