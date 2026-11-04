package dev.kishanr.adaptrise.wear.presentation

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.core.content.ContextCompat
import androidx.wear.compose.material.Text
import dev.kishanr.adaptrise.wear.service.WearSensorStreamingService

open class MainActivity : ComponentActivity() {

    internal val statusMessage = mutableStateOf("AdaptRise Watch")

    internal val backgroundPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        handleBackgroundPermissionResult(granted)
    }

    internal val foregroundPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { grants ->
        handleForegroundPermissionsResult(grants)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestRequiredPermissions()
        setContent {
            WearApp(statusMessage.value)
        }
    }

    internal fun handleForegroundPermissionsResult(grants: Map<String, Boolean>) {
        val bodySensorsGranted = grants[Manifest.permission.BODY_SENSORS]
            ?: (ContextCompat.checkSelfPermission(this, Manifest.permission.BODY_SENSORS) == PackageManager.PERMISSION_GRANTED)
        val notificationsGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            grants[Manifest.permission.POST_NOTIFICATIONS]
                ?: (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED)
        } else {
            true
        }

        if (!bodySensorsGranted) {
            statusMessage.value = "Body sensors permission required"
        } else if (!notificationsGranted) {
            statusMessage.value = "Notification permission required"
        } else {
            requestBackgroundPermissionIfAvailable()
        }
    }

    internal fun handleBackgroundPermissionResult(granted: Boolean) {
        if (!granted) {
            statusMessage.value = "Background sensor access required"
        } else {
            statusMessage.value = "Sensor Streaming Ready"
            // Service is triggered remotely via Wear Data Layer ingress (PLAN.md Section 6 / D-001)
        }
    }

    internal fun requestRequiredPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.BODY_SENSORS
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            foregroundPermissionLauncher.launch(missing.toTypedArray())
        } else {
            requestBackgroundPermissionIfAvailable()
        }
    }

    internal fun requestBackgroundPermissionIfAvailable() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BODY_SENSORS_BACKGROUND
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                backgroundPermissionLauncher.launch(Manifest.permission.BODY_SENSORS_BACKGROUND)
            } else {
                statusMessage.value = "Sensor Streaming Ready"
            }
        } else {
            statusMessage.value = "Sensor Streaming Ready"
        }
    }

    internal open fun startSensorStreamingService() {
        val intent = Intent(this, WearSensorStreamingService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}

@Composable
fun WearApp(greeting: String) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF08090C)),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = greeting,
            color = Color(0xFFFF9E3B)
        )
    }
}
