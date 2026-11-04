package dev.kishanr.adaptrise.wear.sensor

import android.hardware.Sensor
import android.hardware.SensorEvent
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowSensorManager

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SensorCollectorTest {

    @Test
    fun testStartAndStopCollector() {
        val context = RuntimeEnvironment.getApplication()
        var accelCount = 0
        var hrCount = 0

        val collector = SensorCollector(
            context = context,
            onAccelerometerSample = { _, _, _, _ -> accelCount++ },
            onHeartRateSample = { _, _ -> hrCount++ }
        )

        collector.startCollecting()
        collector.stopCollecting()

        assertEquals(0, accelCount)
        assertEquals(0, hrCount)
    }
}
