package dev.kishanr.adaptrise.wear.presentation.alarm

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class HapticRampControllerTest {

    private lateinit var context: Context
    private lateinit var controller: HapticRampController

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        controller = HapticRampController(context)
    }

    @Test
    fun testIntensityCalculation() {
        // 0s -> 20%
        assertEquals(0.20f, controller.calculateIntensity(0), 0.001f)

        // 30s -> 60% (halfway between 20% and 100%)
        assertEquals(0.60f, controller.calculateIntensity(30), 0.001f)

        // 60s -> 100%
        assertEquals(1.00f, controller.calculateIntensity(60), 0.001f)

        // Past 60s -> Clamped to 100%
        assertEquals(1.00f, controller.calculateIntensity(90), 0.001f)
    }

    @Test
    fun testRampLifecycle() = runTest {
        val testDispatcher = StandardTestDispatcher(testScheduler)
        val testScope = TestScope(testDispatcher)

        assertFalse(controller.isRunning())

        controller.startRamp(testScope)
        assertTrue(controller.isRunning())

        testDispatcher.scheduler.advanceTimeBy(30_000)
        assertEquals(0.60f, controller.currentIntensity, 0.05f)

        controller.stopRamp()
        assertFalse(controller.isRunning())
        assertEquals(0.20f, controller.currentIntensity, 0.001f)
    }
}
