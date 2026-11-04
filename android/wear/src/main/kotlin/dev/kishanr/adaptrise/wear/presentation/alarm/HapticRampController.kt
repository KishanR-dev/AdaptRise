package dev.kishanr.adaptrise.wear.presentation.alarm

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class HapticRampController(private val context: Context) {

    private val vibrator: Vibrator by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    private var rampJob: Job? = null
    var currentIntensity: Float = 0.20f
        private set

    companion object {
        const val RAMP_DURATION_SECONDS = 60
        const val INITIAL_INTENSITY = 0.20f
        const val MAX_INTENSITY = 1.00f
        const val PULSE_INTERVAL_MS = 1000L
        const val PULSE_DURATION_MS = 500L
    }

    fun calculateIntensity(elapsedSeconds: Int): Float {
        val progress = (elapsedSeconds.toFloat() / RAMP_DURATION_SECONDS).coerceIn(0f, 1f)
        return INITIAL_INTENSITY + (MAX_INTENSITY - INITIAL_INTENSITY) * progress
    }

    fun startRamp(scope: CoroutineScope) {
        if (rampJob != null) return

        rampJob = scope.launch {
            var elapsedSeconds = 0
            while (isActive) {
                currentIntensity = calculateIntensity(elapsedSeconds)
                val amplitude = (currentIntensity * 255).toInt().coerceIn(1, 255)

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val effect = if (vibrator.hasAmplitudeControl()) {
                            VibrationEffect.createOneShot(PULSE_DURATION_MS, amplitude)
                        } else {
                            VibrationEffect.createOneShot(PULSE_DURATION_MS, VibrationEffect.DEFAULT_AMPLITUDE)
                        }
                        vibrator.vibrate(effect)
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(PULSE_DURATION_MS)
                    }
                } catch (_: Exception) {}

                delay(PULSE_INTERVAL_MS)
                elapsedSeconds++
            }
        }
    }

    fun stopRamp() {
        rampJob?.cancel()
        rampJob = null
        try {
            vibrator.cancel()
        } catch (_: Exception) {}
        currentIntensity = INITIAL_INTENSITY
    }

    fun isRunning(): Boolean = rampJob != null && rampJob?.isActive == true
}
