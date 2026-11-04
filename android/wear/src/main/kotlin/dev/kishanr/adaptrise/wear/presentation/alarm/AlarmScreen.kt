package dev.kishanr.adaptrise.wear.presentation.alarm

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.foundation.rememberSwipeToDismissBoxState
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.SwipeToDismissBox
import androidx.wear.compose.material.Text
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun AlarmScreen(
    onDismiss: () -> Unit,
    onSnooze: () -> Unit
) {
    val currentTimeStr = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
    val dismissState = rememberSwipeToDismissBoxState()

    SwipeToDismissBox(
        state = dismissState,
        onDismissed = onDismiss
    ) { isBackground ->
        if (isBackground) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0xFFFF5376)),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(
                    text = "Dismiss",
                    color = Color.White,
                    modifier = Modifier.padding(16.dp),
                    fontWeight = FontWeight.Bold
                )
            }
        } else {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                Color(0xFFFF9E3B).copy(alpha = 0.25f), // Ambient amber glow center
                                Color(0xFF08090C) // Obsidian void edge
                            ),
                            radius = 400f
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = "ADAPTRISE",
                        color = Color(0xFF8A91A0),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = currentTimeStr,
                        color = Color(0xFFFF9E3B), // Amber Dawn primary accent
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Button(
                        onClick = onSnooze,
                        colors = ButtonDefaults.buttonColors(
                            backgroundColor = Color(0xFF1C1F26),
                            contentColor = Color(0xFFF2F4F8)
                        ),
                        modifier = Modifier
                            .fillMaxWidth(0.8f)
                            .height(36.dp)
                    ) {
                        Text(text = "Snooze 9m", fontSize = 12.sp)
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Button(
                        onClick = onDismiss,
                        colors = ButtonDefaults.buttonColors(
                            backgroundColor = Color(0xFFFF9E3B),
                            contentColor = Color(0xFF08090C)
                        ),
                        modifier = Modifier
                            .fillMaxWidth(0.8f)
                            .height(36.dp)
                    ) {
                        Text(text = "Dismiss", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}
