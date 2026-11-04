package dev.kishanr.adaptrise.wear.presentation

import android.Manifest
import android.os.Build
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

class TestMainActivity : MainActivity() {
    var serviceStarted = false
    override fun startSensorStreamingService() {
        serviceStarted = true
    }
}

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.UPSIDE_DOWN_CAKE])
class MainActivityTest {

    @Test
    fun testActivityCreationAndInitialState() {
        val controller = Robolectric.buildActivity(TestMainActivity::class.java)
        val activity = controller.create().get()

        assertNotNull(activity)
        val status = activity.statusMessage.value
        assertTrue(status == "AdaptRise Watch" || status == "Sensor Streaming Ready")
        controller.destroy()
    }

    @Test
    fun testForegroundPermissionDenials() {
        val controller = Robolectric.buildActivity(TestMainActivity::class.java)
        val activity = controller.create().get()

        // Deny body sensors
        activity.handleForegroundPermissionsResult(mapOf(Manifest.permission.BODY_SENSORS to false))
        assertEquals("Body sensors permission required", activity.statusMessage.value)

        // Deny notifications
        activity.handleForegroundPermissionsResult(
            mapOf(
                Manifest.permission.BODY_SENSORS to true,
                Manifest.permission.POST_NOTIFICATIONS to false
            )
        )
        assertEquals("Notification permission required", activity.statusMessage.value)

        controller.destroy()
    }

    @Test
    fun testForegroundAndBackgroundPermissionHappyPath() {
        val controller = Robolectric.buildActivity(TestMainActivity::class.java)
        val activity = controller.create().get()

        // Grant both foreground permissions
        activity.handleForegroundPermissionsResult(
            mapOf(
                Manifest.permission.BODY_SENSORS to true,
                Manifest.permission.POST_NOTIFICATIONS to true
            )
        )

        // Grant background permission
        activity.handleBackgroundPermissionResult(true)
        assertEquals("Sensor Streaming Ready", activity.statusMessage.value)

        // Explicit service start can be triggered on demand
        activity.startSensorStreamingService()
        assertTrue(activity.serviceStarted)

        controller.destroy()
    }

    @Test
    fun testBackgroundPermissionDenial() {
        val controller = Robolectric.buildActivity(TestMainActivity::class.java)
        val activity = controller.create().get()

        activity.handleBackgroundPermissionResult(false)
        assertEquals("Background sensor access required", activity.statusMessage.value)

        controller.destroy()
    }
}
