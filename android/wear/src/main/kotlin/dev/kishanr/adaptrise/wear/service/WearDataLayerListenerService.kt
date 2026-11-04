package dev.kishanr.adaptrise.wear.service

import android.content.Intent
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import dev.kishanr.adaptrise.wear.presentation.alarm.WearAlarmActivity

class WearDataLayerListenerService : WearableListenerService() {

    companion object {
        const val PATH_START_STREAMING = "/adapt_rise/wake_window/start"
        const val PATH_STOP_STREAMING = "/adapt_rise/wake_window/stop"
        const val PATH_ALARM_FIRE = "/adapt_rise/alarm/fire"
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        super.onMessageReceived(messageEvent)
        when (messageEvent.path) {
            PATH_START_STREAMING -> {
                val serviceIntent = Intent(this, WearSensorStreamingService::class.java)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
            }
            PATH_STOP_STREAMING -> {
                val serviceIntent = Intent(this, WearSensorStreamingService::class.java)
                stopService(serviceIntent)
            }
            PATH_ALARM_FIRE -> {
                // Stop streaming when alarm fires
                val serviceIntent = Intent(this, WearSensorStreamingService::class.java)
                stopService(serviceIntent)

                // Launch alarm activity with progressive haptics
                val alarmIntent = Intent(this, WearAlarmActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(alarmIntent)
            }
        }
    }
}
