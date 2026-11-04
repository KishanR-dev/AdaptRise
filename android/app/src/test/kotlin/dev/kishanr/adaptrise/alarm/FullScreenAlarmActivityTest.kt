package dev.kishanr.adaptrise.alarm

import android.content.Intent
import dev.kishanr.adaptrise.alarm.detector.SmartWakeDetector
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class FullScreenAlarmActivityTest {

    @Test
    fun testActivityLaunchAndLayout() {
        val intent = Intent().apply {
            putExtra(SmartWakeDetector.EXTRA_TRIGGER_REASON, "TEST_EARLY_WAKE")
        }
        val controller = Robolectric.buildActivity(FullScreenAlarmActivity::class.java, intent)
        val activity = controller.create().get()

        assertNotNull(activity)
        controller.destroy()
    }
}
