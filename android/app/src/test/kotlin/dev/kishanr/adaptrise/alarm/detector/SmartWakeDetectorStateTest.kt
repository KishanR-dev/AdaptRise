package dev.kishanr.adaptrise.alarm.detector

import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartWakeDetectorStateTest {

    @Test
    fun testQuarantineSuppression() {
        val windowStart = 1000L
        val config = DetectorConfig(quarantineMinutes = 5)
        val state = SmartWakeDetectorState(windowStart, config)

        // Establish baseline HR during quarantine
        val hrPacket = SensorEpochPacket(
            timestampEpochMs = 1500L,
            durationSeconds = 5,
            sampleCount = 5,
            motionVariance = 0.0001,
            meanHeartRateBpm = 60.0
        )
        val decisionHr = state.evaluate(hrPacket, 1500L)
        assertEquals(TriggerDecision.SUPPRESSED_QUARANTINE, decisionHr)

        // High motion during quarantine should be suppressed
        val motionPacket = SensorEpochPacket(
            timestampEpochMs = 2000L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.5,
            meanHeartRateBpm = 60.0
        )
        val decisionMotion = state.evaluate(motionPacket, 2000L)
        assertEquals(TriggerDecision.SUPPRESSED_QUARANTINE, decisionMotion)
    }

    @Test
    fun testMotionTriggerAfterQuarantine() {
        val windowStart = 0L
        val config = DetectorConfig(quarantineMinutes = 0, motionVarianceThreshold = 0.15f, consecutiveEpochsRequired = 2)
        val state = SmartWakeDetectorState(windowStart, config)

        // First high motion epoch (persistence = 1 < 2)
        val p1 = SensorEpochPacket(
            timestampEpochMs = 1000L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.20,
            meanHeartRateBpm = 60.0
        )
        assertEquals(TriggerDecision.NO_TRIGGER, state.evaluate(p1, 1000L))

        // Second consecutive high motion epoch (persistence = 2 >= 2) -> Trigger
        val p2 = SensorEpochPacket(
            timestampEpochMs = 2000L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.22,
            meanHeartRateBpm = 60.0
        )
        assertEquals(TriggerDecision.TRIGGER_MOTION, state.evaluate(p2, 2000L))
    }

    @Test
    fun testHrSpikeTriggerAfterQuarantine() {
        val windowStart = 0L
        val config = DetectorConfig(quarantineMinutes = 0, hrSpikeRatioThreshold = 1.08f, consecutiveEpochsRequired = 1)
        val state = SmartWakeDetectorState(windowStart, config)

        // Set baseline HR = 60
        val baseline = SensorEpochPacket(
            timestampEpochMs = 500L,
            durationSeconds = 5,
            sampleCount = 5,
            motionVariance = 0.0001,
            meanHeartRateBpm = 60.0
        )
        state.evaluate(baseline, 500L)

        // Spike HR = 66 (ratio 1.10 >= 1.08) with low motion -> Trigger HR
        val spike = SensorEpochPacket(
            timestampEpochMs = 1500L,
            durationSeconds = 5,
            sampleCount = 5,
            motionVariance = 0.0001,
            meanHeartRateBpm = 66.0
        )
        assertEquals(TriggerDecision.TRIGGER_HR, state.evaluate(spike, 1500L))
    }

    @Test
    fun testCompositeTriggerAfterQuarantine() {
        val windowStart = 0L
        val config = DetectorConfig(
            quarantineMinutes = 0,
            motionVarianceThreshold = 0.15f,
            hrSpikeRatioThreshold = 1.08f,
            consecutiveEpochsRequired = 1
        )
        val state = SmartWakeDetectorState(windowStart, config)

        // Set baseline HR = 60
        val baseline = SensorEpochPacket(
            timestampEpochMs = 500L,
            durationSeconds = 5,
            sampleCount = 5,
            motionVariance = 0.0001,
            meanHeartRateBpm = 60.0
        )
        state.evaluate(baseline, 500L)

        // Both motion and HR spike in the same epoch
        val composite = SensorEpochPacket(
            timestampEpochMs = 1500L,
            durationSeconds = 5,
            sampleCount = 50,
            motionVariance = 0.25,
            meanHeartRateBpm = 70.0
        )
        assertEquals(TriggerDecision.TRIGGER_COMPOSITE, state.evaluate(composite, 1500L))
    }
}
