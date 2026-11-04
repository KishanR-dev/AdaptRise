package dev.kishanr.adaptrise.alarm.detector

import org.json.JSONObject

data class SensorEpochPacket(
    val timestampEpochMs: Long,
    val durationSeconds: Int,
    val sampleCount: Int,
    val motionVariance: Double,
    val meanHeartRateBpm: Double
) {
    fun toJson(): String {
        return JSONObject().apply {
            put("timestampEpochMs", timestampEpochMs)
            put("durationSeconds", durationSeconds)
            put("sampleCount", sampleCount)
            put("motionVariance", motionVariance)
            put("meanHeartRateBpm", meanHeartRateBpm)
        }.toString()
    }

    companion object {
        fun fromJson(jsonStr: String): SensorEpochPacket {
            val obj = JSONObject(jsonStr)
            return SensorEpochPacket(
                timestampEpochMs = obj.getLong("timestampEpochMs"),
                durationSeconds = obj.getInt("durationSeconds"),
                sampleCount = obj.getInt("sampleCount"),
                motionVariance = obj.getDouble("motionVariance"),
                meanHeartRateBpm = obj.getDouble("meanHeartRateBpm")
            )
        }
    }
}
