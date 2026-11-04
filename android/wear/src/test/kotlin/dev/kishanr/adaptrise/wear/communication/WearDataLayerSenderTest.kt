package dev.kishanr.adaptrise.wear.communication

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class WearDataLayerSenderTest {

    private lateinit var context: Context
    private lateinit var sender: WearDataLayerSender

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        sender = WearDataLayerSender(context)
    }

    @Test
    fun testPathsConfiguredCorrectly() {
        assertNotNull(WearDataLayerSender.PATH_ALARM_DISMISSED)
        assertNotNull(WearDataLayerSender.PATH_ALARM_SNOOZED)
    }

    @Test
    fun testSendDismissedAndSnoozed_HandleNoConnectedNodesGracefully() = runTest {
        // Without connected physical watch nodes in Robolectric, should return false gracefully
        val dismissed = sender.sendDismissed()
        org.junit.Assert.assertFalse(dismissed)

        val snoozed = sender.sendSnoozed()
        org.junit.Assert.assertFalse(snoozed)
    }
}
