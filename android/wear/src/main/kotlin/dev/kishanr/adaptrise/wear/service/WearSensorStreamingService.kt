package dev.kishanr.adaptrise.wear.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import com.google.android.gms.wearable.Wearable
import dev.kishanr.adaptrise.wear.R
import dev.kishanr.adaptrise.wear.sensor.EpochWindowAccumulator
import dev.kishanr.adaptrise.wear.sensor.RawTelemetryRecorder
import dev.kishanr.adaptrise.wear.sensor.SensorCollector
import java.io.File
import java.nio.charset.StandardCharsets

class WearSensorStreamingService : Service() {

    internal var wakeLock: PowerManager.WakeLock? = null
    private var stopHandler: Handler? = null
    private var stopRunnable: Runnable? = null

    private var sensorCollector: SensorCollector? = null
    private var epochAccumulator: EpochWindowAccumulator? = null
    private var rawTelemetryRecorder: RawTelemetryRecorder? = null

    companion object {
        const val CHANNEL_ID = "wear_sensor_streaming_channel"
        const val NOTIFICATION_ID = 1001
        const val EXTRA_TIMEOUT_MS = "extra_timeout_ms"
        const val PATH_SENSOR_EPOCH = "/adapt_rise/sensor/epoch"
        const val WAKE_WINDOW_DURATION_MINUTES = 30
        const val SAFETY_BUFFER_MINUTES = 5
        const val DEFAULT_TIMEOUT_MS = (WAKE_WINDOW_DURATION_MINUTES + SAFETY_BUFFER_MINUTES).toLong() * 60L * 1000L
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        epochAccumulator = EpochWindowAccumulator(windowDurationSeconds = 5) { packet ->
            sendEpochPacketToPhone(packet.toJson())
        }

        val logFile = File(getExternalFilesDir(null), "t1_sensor_recording.csv")
        rawTelemetryRecorder = RawTelemetryRecorder(logFile).apply {
            startRecording()
        }

        sensorCollector = SensorCollector(
            context = this,
            onAccelerometerSample = { timestamp, x, y, z ->
                epochAccumulator?.addAccelerometerSample(timestamp, x, y, z)
                rawTelemetryRecorder?.recordAccelerometer(timestamp, x, y, z)
            },
            onHeartRateSample = { timestamp, bpm ->
                epochAccumulator?.addHeartRateSample(timestamp, bpm)
                rawTelemetryRecorder?.recordHeartRate(timestamp, bpm)
            }
        ).apply {
            startCollecting()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val timeoutMs = intent?.getLongExtra(EXTRA_TIMEOUT_MS, DEFAULT_TIMEOUT_MS) ?: DEFAULT_TIMEOUT_MS

        if (wakeLock == null) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "AdaptRise::SensorStreamingWakeLock"
            ).apply {
                setReferenceCounted(false)
            }
        }
        wakeLock?.acquire(timeoutMs)

        // Schedule automatic service self-termination when wake window timeout expires
        stopRunnable?.let { stopHandler?.removeCallbacks(it) }
        stopHandler = Handler(Looper.getMainLooper())
        stopRunnable = Runnable { stopSelf() }
        stopHandler?.postDelayed(stopRunnable!!, timeoutMs)

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("AdaptRise Active")
            .setContentText("Awaiting wake window telemetry...")
            .setSmallIcon(R.drawable.ic_sensor_streaming)
            .setColor(0xFFFF9E3B.toInt())
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        sensorCollector?.stopCollecting()
        sensorCollector = null

        epochAccumulator?.flush()
        epochAccumulator = null

        rawTelemetryRecorder?.stopRecording()
        rawTelemetryRecorder = null

        stopRunnable?.let { stopHandler?.removeCallbacks(it) }
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
        wakeLock = null
    }

    private fun sendEpochPacketToPhone(jsonPayload: String) {
        val bytes = jsonPayload.toByteArray(StandardCharsets.UTF_8)
        try {
            val messageClient = Wearable.getMessageClient(this)
            val nodeClient = Wearable.getNodeClient(this)
            nodeClient.connectedNodes.addOnSuccessListener { nodes ->
                for (node in nodes) {
                    messageClient.sendMessage(node.id, PATH_SENSOR_EPOCH, bytes)
                }
            }
        } catch (_: Exception) {}
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Wake Window Streaming Channel",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Channel for active wake window telemetry streaming"
        }
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager?.createNotificationChannel(channel)
    }
}
