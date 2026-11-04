package dev.kishanr.adaptrise.bridge

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.AlarmClock
import android.util.Log
import dev.kishanr.adaptrise.alarm.ExactAlarmScheduler
import dev.kishanr.adaptrise.health.HealthConnectBridge
import kotlinx.coroutines.runBlocking

class AdaptRisePigeonBridge(private val context: Context) : NativeAlarmHostApi {

    companion object {
        private const val TAG = "AdaptRisePigeonBridge"
    }

    private val alarmScheduler = ExactAlarmScheduler(context)
    private val healthBridge = HealthConnectBridge(context)

    override fun scheduleAdaptiveAlarm(request: AlarmScheduleRequest) {
        val targetWakeTimeMs = request.targetWakeTimeEpochMs
        val windowMinutes = request.detectorConfig.wakeWindowMinutes.toInt()

        alarmScheduler.scheduleExactAlarms(targetWakeTimeMs, windowMinutes)

        if (request.enableSystemBackupAlarm) {
            triggerStockBackupAlarm(targetWakeTimeMs)
        }
    }

    override fun cancelScheduledAlarm() {
        alarmScheduler.cancelScheduledAlarms()
    }

    /**
     * Triggers the system clock alarm via ACTION_SET_ALARM as a secondary fail-safe.
     * Note (D-005): Android does not permit third-party applications to cancel or edit
     * system clock alarms once created via ACTION_SET_ALARM. If the user wakes up early,
     * they must dismiss or turn off the stock clock alarm manually.
     */
    override fun triggerStockBackupAlarm(deadlineEpochMs: Long) {
        try {
            val calendar = java.util.Calendar.getInstance().apply {
                timeInMillis = deadlineEpochMs
            }
            val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                putExtra(AlarmClock.EXTRA_MESSAGE, "AdaptRise Backup Alarm")
                putExtra(AlarmClock.EXTRA_HOUR, calendar.get(java.util.Calendar.HOUR_OF_DAY))
                putExtra(AlarmClock.EXTRA_MINUTES, calendar.get(java.util.Calendar.MINUTE))
                putExtra(AlarmClock.EXTRA_SKIP_UI, true)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule system stock backup alarm", e)
        }
    }

    override fun getLastSleepSession(): HealthSleepSession? {
        return runBlocking {
            try {
                val endTime = java.time.Instant.now()
                val startTime = endTime.minus(java.time.Duration.ofDays(1))
                val session = healthBridge.getLastSleepSession(startTime, endTime) ?: return@runBlocking null

                val stages = session.stages.filterNotNull().map { stage ->
                    HealthSleepStage(
                        stageType = stage.stageType,
                        startTimeEpochMs = stage.startTimeEpochMs,
                        endTimeEpochMs = stage.endTimeEpochMs
                    )
                }

                HealthSleepSession(
                    id = session.id,
                    startTimeEpochMs = session.startTimeEpochMs,
                    endTimeEpochMs = session.endTimeEpochMs,
                    durationMinutes = session.durationMinutes,
                    stages = stages
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error querying last sleep session from Health Connect", e)
                null
            }
        }
    }

    override fun checkPermissionsStatus(): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val exactAlarmAllowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
        return exactAlarmAllowed
    }

    override fun requestRequiredPermissions() {
        Log.i(TAG, "requestRequiredPermissions initiated")
    }

    override fun exportT1TelemetryData() {
        Log.i(TAG, "exportT1TelemetryData initiated")
    }
}
