package dev.kishanr.adaptrise.alarm.detector

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import dev.kishanr.adaptrise.alarm.FullScreenAlarmActivity

object SmartWakeDetector {

    const val EXTRA_TRIGGER_REASON = "extra_trigger_reason"
    const val ALARM_NOTIFICATION_CHANNEL_ID = "phone_alarm_channel"
    const val ALARM_NOTIFICATION_ID = 3003

    fun triggerFullScreenAlarm(context: Context, reason: String) {
        val pendingIntent = createFullScreenPendingIntent(context, reason)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                ALARM_NOTIFICATION_CHANNEL_ID,
                "AdaptRise Alarm Ringing Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High priority full-screen alarm channel"
                setSound(ringtoneUri, audioAttributes)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, ALARM_NOTIFICATION_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        val notification = notificationBuilder
            .setContentTitle("AdaptRise Alarm Ringing")
            .setContentText("Wake moment reached ($reason)")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setFullScreenIntent(pendingIntent, true)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()

        notificationManager.notify(ALARM_NOTIFICATION_ID, notification)

        // Also launch directly if device is interactive or permitted
        try {
            val directIntent = Intent(context, FullScreenAlarmActivity::class.java).apply {
                putExtra(EXTRA_TRIGGER_REASON, reason)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            context.startActivity(directIntent)
        } catch (_: Exception) {}
    }

    fun createFullScreenPendingIntent(context: Context, reason: String): PendingIntent {
        val alarmIntent = Intent(context, FullScreenAlarmActivity::class.java).apply {
            putExtra(EXTRA_TRIGGER_REASON, reason)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            3002,
            alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun dismissAlarm(context: Context) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(ALARM_NOTIFICATION_ID)
    }
}
