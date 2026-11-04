package dev.kishanr.adaptrise.alarm.detector

import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SensorEpochPacketTest {

    @Test
    fun testSerializationRoundTrip() {
        val packet = SensorEpochPacket(
            timestampEpochMs = 1730700000000L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.045,
            meanHeartRateBpm = 68.5
        )

        val json = packet.toJson()
        val parsed = SensorEpochPacket.fromJson(json)

        assertEquals(packet.timestampEpochMs, parsed.timestampEpochMs)
        assertEquals(packet.durationSeconds, parsed.durationSeconds)
        assertEquals(packet.sampleCount, parsed.sampleCount)
        assertEquals(packet.motionVariance, parsed.motionVariance, 0.0001)
        assertEquals(packet.meanHeartRateBpm, parsed.meanHeartRateBpm, 0.01)
    }
}
