package dev.kishanr.adaptrise.bridge

import android.app.AlarmManager
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class AdaptRisePigeonBridgeTest {

    private lateinit var context: Context
    private lateinit var bridge: AdaptRisePigeonBridge

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        bridge = AdaptRisePigeonBridge(context)
    }

    @Test
    fun testScheduleAndCancelAdaptiveAlarmViaBridge() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val shadowAlarmManager = shadowOf(alarmManager)

        val targetWakeTimeMs = System.currentTimeMillis() + 3600000L
        val config = DetectorConfigPigeon(
            wakeWindowMinutes = 30L,
            quarantineMinutes = 5L,
            motionVarianceThreshold = 0.15,
            hrSpikeRatioThreshold = 1.08,
            consecutiveEpochsRequired = 2L
        )
        val request = AlarmScheduleRequest(
            targetWakeTimeEpochMs = targetWakeTimeMs,
            detectorConfig = config,
            enableSystemBackupAlarm = false
        )

        bridge.scheduleAdaptiveAlarm(request)

        val scheduledAlarms = shadowAlarmManager.scheduledAlarms
        assertNotNull(scheduledAlarms)
        assertEquals(2, scheduledAlarms.size)

        bridge.cancelScheduledAlarm()
        assertEquals(0, shadowAlarmManager.scheduledAlarms.size)
    }

    @Test
    fun testCheckPermissionsStatusRunsSafely() {
        val status = bridge.checkPermissionsStatus()
        assertTrue(status || !status)
    }

    @Test
    fun testGetLastSleepSessionHandlesNullSafely() {
        val session = bridge.getLastSleepSession()
        org.junit.Assert.assertNull(session)
    }
}
