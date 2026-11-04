package dev.kishanr.adaptrise.wear

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class WearDataLayerManagerTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun testPathConstants() {
        assertEquals("/adapt_rise/wake_window/start", WearDataLayerManager.PATH_START_STREAMING)
        assertEquals("/adapt_rise/wake_window/stop", WearDataLayerManager.PATH_STOP_STREAMING)
        assertEquals("/adapt_rise/alarm/fire", WearDataLayerManager.PATH_ALARM_FIRE)
    }

    @Test
    fun testManagerInstantiationAndBroadcastWithoutNodes() = runTest {
        val manager = WearDataLayerManager(context)
        // With no connected nodes in test sandbox, broadcast returns false safely
        val result = manager.sendWakeWindowStart()
        assertFalse(result)
    }
}
