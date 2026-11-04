package dev.kishanr.adaptrise.wear.service

import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.android.controller.ServiceController
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLooper

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [Build.VERSION_CODES.UPSIDE_DOWN_CAKE])
class WearSensorStreamingServiceTest {

    private var controller: ServiceController<WearSensorStreamingService>? = null

    @After
    fun tearDown() {
        try {
            controller?.destroy()
        } catch (_: Exception) {}
    }

    @Test
    fun testServiceConstants() {
        assertEquals("wear_sensor_streaming_channel", WearSensorStreamingService.CHANNEL_ID)
        assertEquals(1001, WearSensorStreamingService.NOTIFICATION_ID)
        assertEquals(35 * 60 * 1000L, WearSensorStreamingService.DEFAULT_TIMEOUT_MS)
        assertEquals("extra_timeout_ms", WearSensorStreamingService.EXTRA_TIMEOUT_MS)
    }

    @Test
    fun testOnBindReturnsNull() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()
        assertNull(service.onBind(Intent()))
    }

    @Test
    fun testDestroyWithoutStartCommandDoesNotThrow() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()
        assertNull(service.wakeLock)
        controller!!.destroy()
        assertNull(service.wakeLock)
    }

    @Test
    fun testDestroyWhenWakeLockNotHeld() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()
        service.onStartCommand(null, 0, 1)
        service.wakeLock?.release() // explicitly release before destroy
        controller!!.destroy()
        assertNull(service.wakeLock)
    }

    @Test
    fun testNotificationChannelCreatedOnCreate() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()

        val notificationManager = service.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        val channel = notificationManager?.getNotificationChannel(WearSensorStreamingService.CHANNEL_ID)
        assertNotNull(channel)
        assertEquals("Wake Window Streaming Channel", channel?.name)
    }

    @Test
    fun testServiceFirstStartWithCustomTimeout() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()

        val startResult = service.onStartCommand(
            Intent().putExtra(WearSensorStreamingService.EXTRA_TIMEOUT_MS, 10000L),
            0,
            1
        )
        assertEquals(Service.START_NOT_STICKY, startResult)
        assertNotNull(service.wakeLock)
        assertTrue(service.wakeLock!!.isHeld)
    }

    @Test
    fun testServiceSelfTerminationOnTimeout() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()

        service.onStartCommand(
            Intent().putExtra(WearSensorStreamingService.EXTRA_TIMEOUT_MS, 1000L),
            0,
            1
        )
        val shadowService = shadowOf(service)
        org.junit.Assert.assertFalse(shadowService.isStoppedBySelf)

        ShadowLooper.runUiThreadTasksIncludingDelayedTasks()
        assertTrue(shadowService.isStoppedBySelf)
        controller!!.destroy()
    }

    @Test
    fun testServiceLifecycleAndWakeLock() {
        controller = Robolectric.buildService(WearSensorStreamingService::class.java)
        val service = controller!!.create().get()

        val startResult = service.onStartCommand(null, 0, 1)
        assertEquals(Service.START_NOT_STICKY, startResult)

        // Verify wake lock acquired
        val wakeLock = service.wakeLock
        assertNotNull(wakeLock)
        assertTrue(wakeLock!!.isHeld)

        // Verify foreground notification and its contents
        val shadowService = shadowOf(service)
        assertEquals(WearSensorStreamingService.NOTIFICATION_ID, shadowService.lastForegroundNotificationId)
        val notification = shadowService.lastForegroundNotification
        assertNotNull(notification)
        assertEquals(WearSensorStreamingService.CHANNEL_ID, notification.channelId)
        assertEquals(dev.kishanr.adaptrise.wear.R.drawable.ic_sensor_streaming, notification.smallIcon.resId)
        assertEquals(0xFFFF9E3B.toInt(), notification.color)
        assertEquals("AdaptRise Active", notification.extras.getCharSequence(Notification.EXTRA_TITLE)?.toString())
        assertEquals("Awaiting wake window telemetry...", notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString())

        // Test repeated onStartCommand resets timeout without throwing
        val secondResult = service.onStartCommand(
            Intent().putExtra(WearSensorStreamingService.EXTRA_TIMEOUT_MS, 5000L),
            0,
            2
        )
        assertEquals(Service.START_NOT_STICKY, secondResult)
        assertTrue(service.wakeLock!!.isHeld)

        controller!!.destroy()
        // Verify wake lock released and nulled out on destroy
        org.junit.Assert.assertFalse(wakeLock.isHeld)
        assertNull(service.wakeLock)
    }
}
