package dev.kishanr.adaptrise.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import dev.kishanr.adaptrise.wear.WearDataLayerManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class WakeWindowForegroundService : Service() {

    private val serviceScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private var wakeLock: PowerManager.WakeLock? = null
    private lateinit var dataLayerManager: WearDataLayerManager

    companion object {
        const val CHANNEL_ID = "phone_wake_window_channel"
        const val NOTIFICATION_ID = 3001
        const val EXTRA_TIMEOUT_MS = "extra_timeout_ms"
        const val DEFAULT_TIMEOUT_MS = 35 * 60 * 1000L
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        dataLayerManager = WearDataLayerManager(this)

        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AdaptRise::PhoneWakeWindowWakeLock"
        ).apply {
            setReferenceCounted(false)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val timeoutMs = intent?.getLongExtra(EXTRA_TIMEOUT_MS, DEFAULT_TIMEOUT_MS) ?: DEFAULT_TIMEOUT_MS
        wakeLock?.acquire(timeoutMs)

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("AdaptRise Wake Window Active")
            .setContentText("Monitoring live sleep telemetry for optimal wake moment...")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Notify Watch to begin streaming sensor epochs
        serviceScope.launch {
            dataLayerManager.sendWakeWindowStart()
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        // Ensure stop message is sent before cancelling scope
        runBlocking {
            try {
                dataLayerManager.sendWakeWindowStop()
            } catch (_: Exception) {}
        }
        serviceScope.cancel()

        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
        wakeLock = null
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "AdaptRise Wake Window Service",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Active foreground monitoring during smart wake window"
        }
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager?.createNotificationChannel(channel)
    }
}
