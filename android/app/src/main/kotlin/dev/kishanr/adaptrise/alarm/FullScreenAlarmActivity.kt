package dev.kishanr.adaptrise.alarm

import android.app.KeyguardManager
import android.content.Context
import android.graphics.Color
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import dev.kishanr.adaptrise.alarm.detector.SmartWakeDetector

class FullScreenAlarmActivity : ComponentActivity() {

    private var ringtone: Ringtone? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        turnScreenOnAndKeyguardDismiss()
        playAlarmRingtone()

        val reason = intent?.getStringExtra(SmartWakeDetector.EXTRA_TRIGGER_REASON) ?: "UNKNOWN"

        val rootLayout = FrameLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.parseColor("#08090C"))
        }

        val contentLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        }

        val textView = TextView(this).apply {
            text = "AdaptRise Alarm\nReason: $reason"
            setTextColor(Color.parseColor("#FF9E3B"))
            textSize = 22f
            gravity = Gravity.CENTER
        }

        val dismissButton = Button(this).apply {
            text = "DISMISS"
            setTextColor(Color.BLACK)
            setBackgroundColor(Color.parseColor("#FF9E3B"))
            setOnClickListener {
                dismissAlarm()
            }
        }

        contentLayout.addView(textView)
        contentLayout.addView(dismissButton)
        rootLayout.addView(contentLayout)
        setContentView(rootLayout)
    }

    private fun playAlarmRingtone() {
        try {
            val ringtoneUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            ringtone = RingtoneManager.getRingtone(this, ringtoneUri)?.apply {
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                play()
            }
        } catch (_: Exception) {}
    }

    private fun dismissAlarm() {
        ringtone?.stop()
        ringtone = null
        SmartWakeDetector.dismissAlarm(this)
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        ringtone?.stop()
        ringtone = null
    }

    private fun turnScreenOnAndKeyguardDismiss() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            try {
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                keyguardManager.requestDismissKeyguard(this, null)
            } catch (_: Exception) {}
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }
}
