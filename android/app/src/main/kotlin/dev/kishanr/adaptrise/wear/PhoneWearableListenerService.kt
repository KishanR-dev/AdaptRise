package dev.kishanr.adaptrise.wear

import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import dev.kishanr.adaptrise.alarm.detector.SensorEpochPacket

class PhoneWearableListenerService : WearableListenerService() {

    companion object {
        const val PATH_SENSOR_EPOCH = "/adapt_rise/sensor/epoch"
        const val PATH_ALARM_DISMISSED = "/adapt_rise/alarm/dismissed"
        const val PATH_ALARM_SNOOZED = "/adapt_rise/alarm/snoozed"

        @Volatile
        var latestReceivedPacket: SensorEpochPacket? = null
            private set

        private val epochListeners = mutableListOf<(SensorEpochPacket) -> Unit>()

        @Synchronized
        fun addEpochListener(listener: (SensorEpochPacket) -> Unit) {
            epochListeners.add(listener)
        }

        @Synchronized
        fun removeEpochListener(listener: (SensorEpochPacket) -> Unit) {
            epochListeners.remove(listener)
        }

        @Synchronized
        fun clearEpochListeners() {
            epochListeners.clear()
            latestReceivedPacket = null
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
        }
    }

    @Synchronized
    private fun notifyEpochListeners(packet: SensorEpochPacket) {
        for (listener in epochListeners) {
            listener(packet)
        }
    }
}
