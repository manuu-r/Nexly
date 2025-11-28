package com.nexly

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {

    companion object {
        var channel: MethodChannel? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val notification = sbn.notification
        val extras = notification.extras
        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()
        val packageName = sbn.packageName

        val notificationData = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to text
        )

        channel?.invokeMethod("onNotificationPosted", notificationData)
    }

    override fun onNotificationRemoved(sbn
: StatusBarNotification) {
        val packageName = sbn.packageName

        val notificationData = mapOf(
            "packageName" to packageName,
        )

        channel?.invokeMethod("onNotificationRemoved", notificationData)
    }
}