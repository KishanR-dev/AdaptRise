package dev.kishanr.adaptrise.wear

import android.content.Context
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.tasks.await

class WearDataLayerManager(private val context: Context) {

    companion object {
        const val PATH_START_STREAMING = "/adapt_rise/wake_window/start"
        const val PATH_STOP_STREAMING = "/adapt_rise/wake_window/stop"
        const val PATH_ALARM_FIRE = "/adapt_rise/alarm/fire"
    }

    suspend fun sendWakeWindowStart(): Boolean {
        return broadcastMessage(PATH_START_STREAMING, ByteArray(0))
    }

    suspend fun sendWakeWindowStop(): Boolean {
        return broadcastMessage(PATH_STOP_STREAMING, ByteArray(0))
    }

    suspend fun sendAlarmFire(): Boolean {
        return broadcastMessage(PATH_ALARM_FIRE, ByteArray(0))
    }

    private suspend fun broadcastMessage(path: String, data: ByteArray): Boolean {
        return try {
            val nodeClient = Wearable.getNodeClient(context)
            val messageClient = Wearable.getMessageClient(context)
            val nodes = nodeClient.connectedNodes.await()
            var sentAny = false
            for (node in nodes) {
                messageClient.sendMessage(node.id, path, data).await()
                sentAny = true
            }
            sentAny
        } catch (e: Exception) {
            false
        }
    }
}
