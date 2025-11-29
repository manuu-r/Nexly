package com.nexly

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Device boot completed, notification listener will restart automatically")
            // The NotificationListenerService will be restarted automatically by the system
            // if it was enabled before the reboot
        }
    }
}
