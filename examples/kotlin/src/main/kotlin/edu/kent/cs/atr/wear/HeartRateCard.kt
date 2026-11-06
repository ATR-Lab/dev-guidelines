// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

package edu.kent.cs.atr.wear

import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.wear.compose.material3.Text

/** Shows the latest heart rate, or a dash when the sensor has not reported recently. */
@Composable
fun HeartRateCard(reading: HeartRateReading?, modifier: Modifier = Modifier) {
    val label = reading?.takeIf { it.isFresh }?.let { "${it.beatsPerMinute} bpm" } ?: "--"
    Column(modifier = modifier.semantics { contentDescription = "Heart rate $label" }) {
        Text(text = label)
    }
}
