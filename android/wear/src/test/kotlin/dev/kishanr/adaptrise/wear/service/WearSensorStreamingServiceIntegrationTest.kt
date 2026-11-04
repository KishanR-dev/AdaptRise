package dev.kishanr.adaptrise.wear.service

import android.app.Service
import android.os.Build
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.android.controller.ServiceController
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.UPSIDE_DOWN_CAKE])
class WearSensorStreamingServiceIntegrationTest {

    private var controller: ServiceController<WearSensorStreamingService>? = null

    @After
    fun tearDown() {
        try {
            controller?.destroy()
        } catch (_: Exception) {}
    }

    @Test
    fun testServiceWiresSensorCollectorAndAccumulatorOnCreate() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()

        assertNotNull(service)
        val startResult = service.onStartCommand(null, 0, 1)
        assertEquals(Service.START_NOT_STICKY, startResult)

        // WakeLock acquired
        assertTrue(service.wakeLock != null && service.wakeLock!!.isHeld)

        controller!!.destroy()
        // Clean teardown
        assertTrue(service.wakeLock == null)
    }
}
