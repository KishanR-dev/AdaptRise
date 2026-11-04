package dev.kishanr.adaptrise.alarm.detector

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartWakeDetectorTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun testTriggerFullScreenAlarmAndPendingIntent() {
        SmartWakeDetector.triggerFullScreenAlarm(context, "TEST_TRIGGER")
        val pendingIntent = SmartWakeDetector.createFullScreenPendingIntent(context, "TEST_PENDING")
        assertNotNull(pendingIntent)
    }
}
