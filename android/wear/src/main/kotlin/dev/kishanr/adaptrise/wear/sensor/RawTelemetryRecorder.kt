package dev.kishanr.adaptrise.wear.sensor

import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import java.io.PrintWriter
import kotlin.math.sqrt

class RawTelemetryRecorder(private val outputFile: File) {

    private var writer: PrintWriter? = null
    private var sampleCounter = 0

    companion object {
        private const val FLUSH_INTERVAL_SAMPLES = 50
    }

    @Synchronized
    fun startRecording() {
        if (writer != null) return
        val isNew = !outputFile.exists() || outputFile.length() == 0L
        outputFile.parentFile?.mkdirs()
        writer = PrintWriter(BufferedWriter(FileWriter(outputFile, true)))
        if (isNew) {
            writer?.println("timestamp_epoch_ms,sensor_type,x,y,z,magnitude_g,heart_rate_bpm")
            writer?.flush()
        }
    }

    @Synchronized
    fun recordAccelerometer(timestampEpochMs: Long, x: Float, y: Float, z: Float) {
        val writer = this.writer ?: return
        val magG = sqrt(x * x + y * y + z * z.toDouble()) / 9.80665
        writer.println("$timestampEpochMs,ACCELEROMETER,$x,$y,$z,$magG,")
        checkFlush()
    }

    @Synchronized
    fun recordHeartRate(timestampEpochMs: Long, bpm: Float) {
        val writer = this.writer ?: return
        writer.println("$timestampEpochMs,HEART_RATE,,,,,$bpm")
        checkFlush()
    }

    private fun checkFlush() {
        sampleCounter++
        if (sampleCounter >= FLUSH_INTERVAL_SAMPLES) {
            writer?.flush()
            sampleCounter = 0
        }
    }

    @Synchronized
    fun stopRecording() {
        writer?.flush()
        writer?.close()
        writer = null
        sampleCounter = 0
    }

    @Synchronized
    fun isRecording(): Boolean = writer != null
}
