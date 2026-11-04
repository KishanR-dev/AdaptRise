package dev.kishanr.adaptrise.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import dev.kishanr.adaptrise.alarm.detector.SmartWakeDetector

class HardDeadlineReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        SmartWakeDetector.triggerFullScreenAlarm(context, "HARD_DEADLINE")
    }
}
