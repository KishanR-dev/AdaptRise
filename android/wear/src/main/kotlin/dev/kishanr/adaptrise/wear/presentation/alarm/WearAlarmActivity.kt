package dev.kishanr.adaptrise.wear.presentation.alarm

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.lifecycle.lifecycleScope
import dev.kishanr.adaptrise.wear.communication.WearDataLayerSender
import kotlinx.coroutines.launch

class WearAlarmActivity : ComponentActivity() {

    private lateinit var hapticController: HapticRampController
    private lateinit var dataLayerSender: WearDataLayerSender

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        turnScreenOnAndKeyguardDismiss()

        hapticController = HapticRampController(this)
        dataLayerSender = WearDataLayerSender(this)

        // Start progressive haptic ramp (20% -> 100% over 60s)
        hapticController.startRamp(lifecycleScope)

        setContent {
            AlarmScreen(
                onDismiss = {
                    hapticController.stopRamp()
                    lifecycleScope.launch {
                        try {
                            dataLayerSender.sendDismissed()
                        } finally {
                            finish()
                        }
                    }
                },
                onSnooze = {
                    hapticController.stopRamp()
                    lifecycleScope.launch {
                        try {
                            dataLayerSender.sendSnoozed()
                        } finally {
                            finish()
                        }
                    }
                }
            )
        }
    }

    private fun turnScreenOnAndKeyguardDismiss() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        hapticController.stopRamp()
    }
}
