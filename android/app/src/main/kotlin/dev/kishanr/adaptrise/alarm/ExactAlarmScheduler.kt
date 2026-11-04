package dev.kishanr.adaptrise.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

class ExactAlarmScheduler(private val context: Context) {

    companion object {
        const val ACTION_WAKE_WINDOW = "dev.kishanr.adaptrise.ACTION_WAKE_WINDOW"
        const val ACTION_HARD_DEADLINE = "dev.kishanr.adaptrise.ACTION_HARD_DEADLINE"
        const val REQUEST_CODE_WINDOW = 2001
        const val REQUEST_CODE_DEADLINE = 2002
    }

    fun scheduleExactAlarms(targetWakeTimeEpochMs: Long, wakeWindowMinutes: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val windowStartEpochMs = targetWakeTimeEpochMs - (wakeWindowMinutes.toLong() * 60L * 1000L)

        // 1. Schedule Wake Window Trigger Alarm
        val windowIntent = Intent(context, WakeWindowReceiver::class.java).apply {
            action = ACTION_WAKE_WINDOW
        }
        val windowPendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_WINDOW,
            windowIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // 2. Schedule Guaranteed Hard Deadline Alarm
        val deadlineIntent = Intent(context, HardDeadlineReceiver::class.java).apply {
            action = ACTION_HARD_DEADLINE
        }
        val deadlinePendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_DEADLINE,
            deadlineIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        scheduleExact(alarmManager, windowStartEpochMs, windowPendingIntent)
        scheduleExact(alarmManager, targetWakeTimeEpochMs, deadlinePendingIntent)
    }

    private fun scheduleExact(alarmManager: AlarmManager, triggerAtMs: Long, pendingIntent: PendingIntent) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pendingIntent)
                } else {
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pendingIntent)
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pendingIntent)
        }
    }

    fun cancelScheduledAlarms() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val windowIntent = Intent(context, WakeWindowReceiver::class.java).apply {
            action = ACTION_WAKE_WINDOW
        }
        val windowPendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_WINDOW,
            windowIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(windowPendingIntent)

        val deadlineIntent = Intent(context, HardDeadlineReceiver::class.java).apply {
            action = ACTION_HARD_DEADLINE
        }
        val deadlinePendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_DEADLINE,
            deadlineIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(deadlinePendingIntent)
    }

    fun cancelHardDeadline() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val deadlineIntent = Intent(context, HardDeadlineReceiver::class.java).apply {
            action = ACTION_HARD_DEADLINE
        }
        val deadlinePendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_DEADLINE,
            deadlineIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(deadlinePendingIntent)
    }
}
