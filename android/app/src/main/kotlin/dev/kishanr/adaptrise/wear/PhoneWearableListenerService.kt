package dev.kishanr.adaptrise.wear

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import dev.kishanr.adaptrise.alarm.detector.SensorEpochPacket
import dev.kishanr.adaptrise.alarm.detector.SmartWakeDetector

class PhoneWearableListenerService : WearableListenerService() {

    companion object {
        const val PATH_SENSOR_EPOCH = "/adapt_rise/sensor/epoch"
        const val PATH_ALARM_DISMISSED = "/adapt_rise/alarm/dismissed"
        const val PATH_ALARM_SNOOZED = "/adapt_rise/alarm/snoozed"

        @Volatile
        var latestReceivedPacket: SensorEpochPacket? = null
            private set

        @Volatile
        var lastAlarmAction: String? = null
            private set

        private val epochListeners = mutableListOf<(SensorEpochPacket) -> Unit>()
        private val alarmActionListeners = mutableListOf<(String) -> Unit>()

        @Synchronized
        fun addEpochListener(listener: (SensorEpochPacket) -> Unit) {
            epochListeners.add(listener)
        }

        @Synchronized
        fun removeEpochListener(listener: (SensorEpochPacket) -> Unit) {
            epochListeners.remove(listener)
        }

        @Synchronized
        fun addAlarmActionListener(listener: (String) -> Unit) {
            alarmActionListeners.add(listener)
        }

        @Synchronized
        fun removeAlarmActionListener(listener: (String) -> Unit) {
            alarmActionListeners.remove(listener)
        }

        @Synchronized
        fun clearEpochListeners() {
            epochListeners.clear()
            alarmActionListeners.clear()
            latestReceivedPacket = null
            lastAlarmAction = null
        }
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        super.onMessageReceived(messageEvent)
        when (messageEvent.path) {
            PATH_SENSOR_EPOCH -> {
                val jsonStr = String(messageEvent.data, Charsets.UTF_8)
                try {
                    val packet = SensorEpochPacket.fromJson(jsonStr)
                    latestReceivedPacket = packet
                    notifyEpochListeners(packet)
                } catch (e: Exception) {
                    latestReceivedPacket = null
                    android.util.Log.e("PhoneWearableListener", "Failed to parse sensor epoch packet", e)
                }
            }
            PATH_ALARM_DISMISSED -> {
                lastAlarmAction = "DISMISSED"
                SmartWakeDetector.dismissAlarm(this)
                notifyAlarmActionListeners("DISMISSED")
            }
            PATH_ALARM_SNOOZED -> {
                lastAlarmAction = "SNOOZED"
                SmartWakeDetector.dismissAlarm(this)
                notifyAlarmActionListeners("SNOOZED")
            }
        }
    }

    @Synchronized
    private fun notifyEpochListeners(packet: SensorEpochPacket) {
        for (listener in epochListeners) {
            listener(packet)
        }
    }

    @Synchronized
    private fun notifyAlarmActionListeners(action: String) {
        for (listener in alarmActionListeners) {
            listener(action)
        }
    }
}
