package dev.kishanr.adaptrise.wear.communication

import android.content.Context
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.tasks.await

class WearDataLayerSender(private val context: Context) {

    companion object {
        const val PATH_ALARM_DISMISSED = "/adapt_rise/alarm/dismissed"
        const val PATH_ALARM_SNOOZED = "/adapt_rise/alarm/snoozed"
    }

    suspend fun sendDismissed(): Boolean {
        return broadcastMessage(PATH_ALARM_DISMISSED, ByteArray(0))
    }

    suspend fun sendSnoozed(): Boolean {
        return broadcastMessage(PATH_ALARM_SNOOZED, ByteArray(0))
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
