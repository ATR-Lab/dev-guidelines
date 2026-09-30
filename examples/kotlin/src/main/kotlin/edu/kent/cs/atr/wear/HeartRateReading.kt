// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

package edu.kent.cs.atr.wear

/** Heart rate reading shown on the watch face during a session. */
data class HeartRateReading(val beatsPerMinute: Int, val isFresh: Boolean)
