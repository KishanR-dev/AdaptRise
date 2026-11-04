package dev.kishanr.adaptrise.wear.sensor

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class EpochWindowAccumulatorTest {

    @Test
    fun testEpochAccumulatorEmptyFlushDoesNotEmit() {
        var receivedPacket: SensorEpochPacket? = null
        val accumulator = EpochWindowAccumulator(windowDurationSeconds = 5) { packet ->
            receivedPacket = packet
        }

        accumulator.flush()
        assertNull(receivedPacket)
    }

    @Test
    fun testEpochAccumulatorVarianceAndHeartRate() {
        var receivedPacket: SensorEpochPacket? = null
        val accumulator = EpochWindowAccumulator(windowDurationSeconds = 5) { packet ->
            receivedPacket = packet
        }

        val start = System.currentTimeMillis()
        // Add varying accelerometer samples: values corresponding to ~1.0g and ~2.0g
        accumulator.addAccelerometerSample(start, 0f, 9.80665f, 0f)
        accumulator.addAccelerometerSample(start + 2000L, 0f, 19.6133f, 0f)

        // Add HR readings: 60 bpm, 80 bpm
        accumulator.addHeartRateSample(start, 60f)
        accumulator.addHeartRateSample(start + 2000L, 80f)

        // Trigger flush at window expiration (5000ms+)
        accumulator.addAccelerometerSample(start + 5000L, 0f, 9.80665f, 0f)

        assertTrue(receivedPacket != null)
        val packet = receivedPacket!!
        assertEquals(5, packet.durationSeconds)
        assertTrue(packet.sampleCount >= 2)
        assertEquals(70.0, packet.meanHeartRateBpm, 0.01)
        assertTrue(packet.motionVariance > 0.0)

        // Verify JSON serialization round-trip
        val json = packet.toJson()
        val parsed = SensorEpochPacket.fromJson(json)
        assertEquals(packet.timestampEpochMs, parsed.timestampEpochMs)
        assertEquals(packet.durationSeconds, parsed.durationSeconds)
        assertEquals(packet.motionVariance, parsed.motionVariance, 0.0001)
        assertEquals(packet.meanHeartRateBpm, parsed.meanHeartRateBpm, 0.01)
    }
}
