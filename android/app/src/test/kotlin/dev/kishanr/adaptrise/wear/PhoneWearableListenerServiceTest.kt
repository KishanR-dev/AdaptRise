package dev.kishanr.adaptrise.wear

import com.google.android.gms.wearable.MessageEvent
import dev.kishanr.adaptrise.alarm.detector.SensorEpochPacket
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class PhoneWearableListenerServiceTest {

    @After
    fun tearDown() {
        PhoneWearableListenerService.clearEpochListeners()
    }

    @Test
    fun testEpochPacketNotificationFlow() {
        var notifiedPacket: SensorEpochPacket? = null
        PhoneWearableListenerService.addEpochListener { packet ->
            notifiedPacket = packet
        }

        val service = PhoneWearableListenerService()
        val testPacket = SensorEpochPacket(
            timestampEpochMs = 1730700000000L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.05,
            meanHeartRateBpm = 72.0
        )

        val mockMessageEvent = mock(MessageEvent::class.java)
        `when`(mockMessageEvent.path).thenReturn(PhoneWearableListenerService.PATH_SENSOR_EPOCH)
        `when`(mockMessageEvent.data).thenReturn(testPacket.toJson().toByteArray(Charsets.UTF_8))

        service.onMessageReceived(mockMessageEvent)

        assertNotNull(PhoneWearableListenerService.latestReceivedPacket)
        assertEquals(testPacket.timestampEpochMs, PhoneWearableListenerService.latestReceivedPacket?.timestampEpochMs)
        assertEquals(0.05, PhoneWearableListenerService.latestReceivedPacket?.motionVariance ?: 0.0, 0.0001)

        assertNotNull(notifiedPacket)
        assertEquals(72.0, notifiedPacket?.meanHeartRateBpm ?: 0.0, 0.01)
    }

    @Test
    fun testMalformedJsonDoesNotNotifyOrCrash() {
        var notifiedPacket: SensorEpochPacket? = null
        PhoneWearableListenerService.addEpochListener { packet ->
            notifiedPacket = packet
        }

        val service = PhoneWearableListenerService()
        val mockMessageEvent = mock(MessageEvent::class.java)
        `when`(mockMessageEvent.path).thenReturn(PhoneWearableListenerService.PATH_SENSOR_EPOCH)
        `when`(mockMessageEvent.data).thenReturn("not valid json".toByteArray(Charsets.UTF_8))

        service.onMessageReceived(mockMessageEvent)

        assertNull(PhoneWearableListenerService.latestReceivedPacket)
        assertNull(notifiedPacket)
    }
}
