package dev.kishanr.adaptrise.alarm.detector

data class DetectorConfig(
    val wakeWindowMinutes: Int = 30,
    val quarantineMinutes: Int = 5,
    val motionVarianceThreshold: Float = 0.15f, // Verified against t1_sensor_recording.csv rest vs motion delta
    val hrSpikeRatioThreshold: Float = 1.08f,    // +8% over resting baseline (verified against t1 hr spike 62->74 bpm)
    val consecutiveEpochsRequired: Int = 2      // 10 seconds persistence requirement
) {
    companion object {
        val DEFAULT = DetectorConfig()
    }
}
