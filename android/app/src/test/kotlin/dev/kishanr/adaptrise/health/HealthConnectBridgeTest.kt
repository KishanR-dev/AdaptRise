package dev.kishanr.adaptrise.health

import android.content.Context
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.test.core.app.ApplicationProvider
import java.time.Instant
import java.time.temporal.ChronoUnit
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class HealthConnectBridgeTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun testNullClientReturnsNullGracefully() = runTest {
        val bridge = HealthConnectBridge(context, clientProvider = { null })
        val now = Instant.now()
        val result = bridge.getLastSleepSession(now.minus(8, ChronoUnit.HOURS), now)
        assertNull(result)
    }

    @Test
    fun testClientCreationExceptionReturnsNullGracefully() = runTest {
        val bridge = HealthConnectBridge(context, clientProvider = {
            throw SecurityException("Health Connect permissions missing")
        })
        val now = Instant.now()
        val result = bridge.getLastSleepSession(now.minus(8, ChronoUnit.HOURS), now)
        assertNull(result)
    }

    @Test
    fun testMapStageTypes() {
        val bridge = HealthConnectBridge(context, clientProvider = { null })
        assertEquals(0L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_UNKNOWN))
        assertEquals(1L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_AWAKE))
        assertEquals(2L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_SLEEPING))
        assertEquals(3L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_OUT_OF_BED))
        assertEquals(4L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_LIGHT))
        assertEquals(5L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_DEEP))
        assertEquals(6L, bridge.mapStageType(SleepSessionRecord.STAGE_TYPE_REM))
        assertEquals(0L, bridge.mapStageType(999))
        assertEquals(0L, bridge.mapStageType(-1))
    }
}
