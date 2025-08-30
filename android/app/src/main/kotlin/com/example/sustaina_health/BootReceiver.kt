package com.example.sustaina_health

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Simple BootReceiver that starts the MainActivity after device reboot.
 * The Flutter side should initialize the notification service on app start
 * and reschedule any required alarms.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            val action = intent.action
            Log.d("BootReceiver", "Received boot action: $action")
            if (action == Intent.ACTION_BOOT_COMPLETED || action == "android.intent.action.QUICKBOOT_POWERON") {
                val launchIntent = Intent(context, MainActivity::class.java)
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                launchIntent.putExtra("reschedule_on_start", true)
                // On Android 12+ it's recommended to use PendingIntent for some scenarios,
                // but starting the activity directly is acceptable for simple reschedule flows.
                context.startActivity(launchIntent)
            }
        } catch (e: Exception) {
            Log.e("BootReceiver", "Error handling boot completed: ${e.message}")
        }
    }
}
