package dev.kishanr.adaptrise.wear.sensor

import kotlin.math.sqrt

class EpochWindowAccumulator(
    val windowDurationSeconds: Int = 5,
    private val onEpochReady: (SensorEpochPacket) -> Unit
) {
    private val accelerometerMagnitudes = mutableListOf<Double>()
    private val heartRateReadings = mutableListOf<Double>()
    private var windowStartEpochMs: Long = 0L

    @Synchronized
    fun addAccelerometerSample(timestampEpochMs: Long, x: Float, y: Float, z: Float) {
        if (windowStartEpochMs == 0L) {
            windowStartEpochMs = timestampEpochMs
        }

        // Check window elapsed BEFORE adding sample if window is already full
        if (timestampEpochMs - windowStartEpochMs >= windowDurationSeconds * 1000L) {
            flush(timestampEpochMs)
            windowStartEpochMs = timestampEpochMs
        }

        val magG = sqrt(x * x + y * y + z * z.toDouble()) / 9.80665
        accelerometerMagnitudes.add(magG)
    }

    @Synchronized
    fun addHeartRateSample(timestampEpochMs: Long, bpm: Float) {
        if (windowStartEpochMs == 0L) {
            windowStartEpochMs = timestampEpochMs
        }

        if (timestampEpochMs - windowStartEpochMs >= windowDurationSeconds * 1000L) {
            flush(timestampEpochMs)
            windowStartEpochMs = timestampEpochMs
        }

        heartRateReadings.add(bpm.toDouble())
    }

    @Synchronized
    fun flush(epochEndTimestampMs: Long = System.currentTimeMillis()) {
        if (accelerometerMagnitudes.isEmpty() && heartRateReadings.isEmpty()) {
            return
        }

        val sampleCount = accelerometerMagnitudes.size + heartRateReadings.size
        val variance = if (accelerometerMagnitudes.size > 1) {
            val mean = accelerometerMagnitudes.average()
            val n = accelerometerMagnitudes.size
            // Sample variance using Bessel's correction (N - 1)
            accelerometerMagnitudes.sumOf { (it - mean) * (it - mean) } / (n - 1)
        } else {
            0.0
        }

        val meanHr = if (heartRateReadings.isNotEmpty()) {
            heartRateReadings.average()
        } else {
            0.0
        }

        val packet = SensorEpochPacket(
            timestampEpochMs = epochEndTimestampMs,
            durationSeconds = windowDurationSeconds,
            sampleCount = sampleCount,
            motionVariance = variance,
            meanHeartRateBpm = meanHr
        )

        accelerometerMagnitudes.clear()
        heartRateReadings.clear()

        onEpochReady(packet)
    }
}
