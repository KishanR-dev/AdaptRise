package dev.kishanr.adaptrise.wear.sensor

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class RawTelemetryRecorderTest {

    @get:Rule
    val tempFolder = TemporaryFolder()

    @Test
    fun testRawTelemetryRecordingOutputsCsv() {
        val file = File(tempFolder.root, "t1_sensor_recording.csv")
        val recorder = RawTelemetryRecorder(file)

        recorder.startRecording()
        assertTrue(recorder.isRecording())

        recorder.recordAccelerometer(1000L, 0f, 9.80665f, 0f)
        recorder.recordHeartRate(1500L, 65f)
        recorder.stopRecording()

        assertTrue(file.exists())
        val lines = file.readLines()
        assertTrue(lines.size >= 3)
        assertEquals("timestamp_epoch_ms,sensor_type,x,y,z,magnitude_g,heart_rate_bpm", lines[0])
        assertTrue(lines[1].contains("ACCELEROMETER"))
        assertTrue(lines[2].contains("HEART_RATE"))
    }

    @Test
    fun testRawTelemetryRecorderAppendsWithoutHeaderOnExistingFile() {
        val file = File(tempFolder.root, "t1_sensor_recording.csv")
        file.parentFile?.mkdirs()
        file.writeText("timestamp_epoch_ms,sensor_type,x,y,z,magnitude_g,heart_rate_bpm\n")

        val recorder = RawTelemetryRecorder(file)
        recorder.startRecording()
        recorder.recordAccelerometer(2000L, 0f, 9.80665f, 0f)
        recorder.stopRecording()

        val lines = file.readLines()
        // Should have exactly 1 header line and 1 data line, no duplicate headers
        assertEquals(2, lines.size)
        assertEquals("timestamp_epoch_ms,sensor_type,x,y,z,magnitude_g,heart_rate_bpm", lines[0])
        assertTrue(lines[1].contains("2000"))
    }
}
