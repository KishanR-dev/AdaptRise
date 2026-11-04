package dev.kishanr.adaptrise.alarm

import android.app.AlarmManager
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ExactAlarmSchedulerTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun testSchedulerSchedulesExactAlarmsAtCorrectTimesAndCancels() {
        val scheduler = ExactAlarmScheduler(context)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val shadowAlarmManager = shadowOf(alarmManager)

        val now = System.currentTimeMillis()
        val targetTime = now + 3600000L // 1 hour out
        val windowMinutes = 30
        val expectedWindowTime = targetTime - (30 * 60 * 1000L)

        scheduler.scheduleExactAlarms(targetTime, windowMinutes)

        // ShadowAlarmManager records scheduled alarms
        val scheduledAlarms = shadowAlarmManager.scheduledAlarms
        assertNotNull(scheduledAlarms)
        assertEquals(2, scheduledAlarms.size)

        // Verify scheduled trigger times
        val triggerTimes = scheduledAlarms.map { it.triggerAtTime }
        assertTrue(triggerTimes.contains(expectedWindowTime))
        assertTrue(triggerTimes.contains(targetTime))

        // Verify cancelScheduledAlarms removes alarms
        scheduler.cancelScheduledAlarms()
        assertEquals(0, shadowAlarmManager.scheduledAlarms.size)
    }
}
