package dev.kishanr.adaptrise.health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import dev.kishanr.adaptrise.bridge.HealthSleepSession
import dev.kishanr.adaptrise.bridge.HealthSleepStage
import java.time.Duration
import java.time.Instant

class HealthConnectBridge(
    private val context: Context,
    private val clientProvider: () -> HealthConnectClient? = {
        try {
            HealthConnectClient.getOrCreate(context)
        } catch (e: Exception) {
            null
        }
    }
) {

    suspend fun getLastSleepSession(startTime: Instant, endTime: Instant): HealthSleepSession? {
        val client = try {
            clientProvider() ?: return null
        } catch (e: SecurityException) {
            return null
        } catch (e: Exception) {
            return null
        }

        return try {
            val response = client.readRecords(
                ReadRecordsRequest(
                    recordType = SleepSessionRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
                )
            )
            // Select the session with the latest endTime (most recently completed sleep session)
            val session = response.records.maxByOrNull { it.endTime } ?: return null

            val stages = session.stages.map { stage ->
                HealthSleepStage(
                    stageType = mapStageType(stage.stage),
                    startTimeEpochMs = stage.startTime.toEpochMilli(),
                    endTimeEpochMs = stage.endTime.toEpochMilli()
                )
            }

            // Compute net sleep duration by subtracting awake and out-of-bed intervals from total session span
            val totalDurationMs = Duration.between(session.startTime, session.endTime).toMillis()
            val awakeMs = session.stages
                .filter { it.stage == SleepSessionRecord.STAGE_TYPE_AWAKE || it.stage == SleepSessionRecord.STAGE_TYPE_OUT_OF_BED }
                .sumOf { Duration.between(it.startTime, it.endTime).toMillis() }
            val netMs = maxOf(0L, totalDurationMs - awakeMs)
            val durationMinutes = (netMs + 30_000L) / 60_000L // rounded to nearest minute

            HealthSleepSession(
                id = session.metadata.id,
                startTimeEpochMs = session.startTime.toEpochMilli(),
                endTimeEpochMs = session.endTime.toEpochMilli(),
                durationMinutes = durationMinutes,
                stages = stages
            )
        } catch (e: SecurityException) {
            null
        } catch (e: Exception) {
            null
        }
    }

    internal fun mapStageType(stage: Int): Long {
        // Contract matched with Pigeon schema:
        // 0: Unknown, 1: Awake, 2: Sleeping, 3: Out-of-bed, 4: Light, 5: Deep, 6: REM
        return when (stage) {
            SleepSessionRecord.STAGE_TYPE_UNKNOWN -> 0L
            SleepSessionRecord.STAGE_TYPE_AWAKE -> 1L
            SleepSessionRecord.STAGE_TYPE_SLEEPING -> 2L
            SleepSessionRecord.STAGE_TYPE_OUT_OF_BED -> 3L
            SleepSessionRecord.STAGE_TYPE_LIGHT -> 4L
            SleepSessionRecord.STAGE_TYPE_DEEP -> 5L
            SleepSessionRecord.STAGE_TYPE_REM -> 6L
            else -> 0L
        }
    }
}
