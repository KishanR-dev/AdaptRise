package dev.kishanr.adaptrise.wear.service

import com.google.android.gms.wearable.MessageEvent
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class WearDataLayerListenerServiceTest {

    @Test
    fun testPathConstants() {
        assertEquals("/adapt_rise/wake_window/start", WearDataLayerListenerService.PATH_START_STREAMING)
        assertEquals("/adapt_rise/wake_window/stop", WearDataLayerListenerService.PATH_STOP_STREAMING)
        assertEquals("/adapt_rise/alarm/fire", WearDataLayerListenerService.PATH_ALARM_FIRE)
    }

    @Test
    fun testOnMessageReceivedHandlesStartAndStopWithoutCrashing() {
        val controller = Robolectric.buildService(WearDataLayerListenerService::class.java)
        val service = controller.create().get()
        val mockEvent = mock(MessageEvent::class.java)

        `when`(mockEvent.path).thenReturn(WearDataLayerListenerService.PATH_START_STREAMING)
        service.onMessageReceived(mockEvent)

        `when`(mockEvent.path).thenReturn(WearDataLayerListenerService.PATH_STOP_STREAMING)
        service.onMessageReceived(mockEvent)

        `when`(mockEvent.path).thenReturn(WearDataLayerListenerService.PATH_ALARM_FIRE)
        service.onMessageReceived(mockEvent)

        controller.destroy()
    }
}
