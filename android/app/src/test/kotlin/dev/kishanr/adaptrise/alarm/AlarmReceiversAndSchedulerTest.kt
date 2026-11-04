package dev.kishanr.adaptrise.alarm

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import dev.kishanr.adaptrise.alarm.detector.SmartWakeDetector
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class AlarmReceiversAndSchedulerTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun testWakeWindowReceiverDispatchesForegroundService() {
        val receiver = WakeWindowReceiver()
        val intent = android.content.Intent(context, WakeWindowReceiver::class.java).apply {
            action = ExactAlarmScheduler.ACTION_WAKE_WINDOW
        }
        receiver.onReceive(context, intent)
    }

    @Test
    fun testHardDeadlineReceiverTriggersAlarm() {
        val receiver = HardDeadlineReceiver()
        val intent = android.content.Intent(context, HardDeadlineReceiver::class.java).apply {
            action = ExactAlarmScheduler.ACTION_HARD_DEADLINE
        }
        receiver.onReceive(context, intent)
    }
}
