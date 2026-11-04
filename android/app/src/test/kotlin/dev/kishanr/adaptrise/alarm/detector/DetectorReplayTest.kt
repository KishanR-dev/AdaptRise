package dev.kishanr.adaptrise.alarm.detector

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class DetectorReplayTest {

    @Test
    fun testRecordedSampleReplay_ZeroFalseAlarmsDuringQuietSleep() {
        val windowStartEpochMs = 1772780400000L
        val config = DetectorConfig(
            quarantineMinutes = 5,
            motionVarianceThreshold = 0.15f,
            hrSpikeRatioThreshold = 1.08f,
            consecutiveEpochsRequired = 2
        )
        val state = SmartWakeDetectorState(windowStartEpochMs, config)

        // Simulate 60 quiet 5-second epochs (5 minutes of resting baseline)
        for (i in 0 until 60) {
            val epochTimestamp = windowStartEpochMs + (i * 5000L)
            val quietPacket = SensorEpochPacket(
                timestampEpochMs = epochTimestamp,
                durationSeconds = 5,
                sampleCount = 50,
                motionVariance = 0.0002, // Deep sleep resting variance << 0.15
                meanHeartRateBpm = 61.0   // Stable resting heart rate
            )

            val decision = state.evaluate(quietPacket, epochTimestamp)
            assertNotEquals(
                "Quiet sleep epoch $i must never trigger alarm",
                TriggerDecision.TRIGGER_MOTION,
                decision
            )
            assertNotEquals(
                "Quiet sleep epoch $i must never trigger alarm",
                TriggerDecision.TRIGGER_HR,
                decision
            )
            assertNotEquals(
                "Quiet sleep epoch $i must never trigger alarm",
                TriggerDecision.TRIGGER_COMPOSITE,
                decision
            )
        }
    }

    @Test
    fun testRecordedSampleReplay_ReliableTriggerDuringWakeMovement() {
        val windowStartEpochMs = 1772780400000L
        val config = DetectorConfig(
            quarantineMinutes = 2,
            motionVarianceThreshold = 0.15f,
            hrSpikeRatioThreshold = 1.08f,
            consecutiveEpochsRequired = 2
        )
        val state = SmartWakeDetectorState(windowStartEpochMs, config)

        // Epochs 0..24 (2 minutes quarantine with resting baseline HR = 62)
        for (i in 0 until 25) {
            val ts = windowStartEpochMs + (i * 5000L)
            state.evaluate(
                SensorEpochPacket(
                    timestampEpochMs = ts,
                    durationSeconds = 5,
                    sampleCount = 50,
                    motionVariance = 0.0003,
                    meanHeartRateBpm = 62.0
                ),
                ts
            )
        }

        // Epoch 25: First wake movement epoch (elevation = 0.25 > 0.15, persistence 1 < 2)
        val ts25 = windowStartEpochMs + (25 * 5000L)
        val p25 = SensorEpochPacket(
            timestampEpochMs = ts25,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.25,
            meanHeartRateBpm = 75.0 // HR spike 75 / 62 = 1.20 >= 1.08
        )
        val decision25 = state.evaluate(p25, ts25)
        assertEquals(TriggerDecision.NO_TRIGGER, decision25)

        // Epoch 26: Second consecutive wake movement epoch (persistence 2 >= 2) -> Trigger
        val ts26 = windowStartEpochMs + (26 * 5000L)
        val p26 = SensorEpochPacket(
            timestampEpochMs = ts26,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.30,
            meanHeartRateBpm = 76.0
        )
        val decision26 = state.evaluate(p26, ts26)
        assertEquals(TriggerDecision.TRIGGER_COMPOSITE, decision26)
    }
}
