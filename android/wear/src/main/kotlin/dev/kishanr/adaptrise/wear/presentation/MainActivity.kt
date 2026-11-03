package dev.kishanr.adaptrise.wear.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.wear.compose.material.Text

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            WearApp("AdaptRise Watch")
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
