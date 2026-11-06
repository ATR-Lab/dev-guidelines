// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

package edu.kent.cs.atr.pepper

import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/** Something the robot can say aloud. The app wraps the robot SDK's text-to-speech call. */
fun interface Speaker {
    suspend fun say(text: String)
}

/**
 * Queues phrases so the robot says them one at a time, in order.
 *
 * Callers on the UI thread call [enqueue]; one coroutine calls [run] and drains the queue.
 */
class SpeechQueue(private val speaker: Speaker, private val maxQueued: Int = DEFAULT_CAPACITY) {
    private val phrases = Channel<String>(capacity = maxQueued)
    private val speaking = MutableStateFlow(false)

    /** True while the robot is speaking. */
    val isSpeaking: StateFlow<Boolean> = speaking.asStateFlow()

    /** Adds a phrase. Returns false, and drops it, when the queue is full or the text is blank. */
    fun enqueue(text: String): Boolean {
        if (text.isBlank()) {
            return false
        }
        return phrases.trySend(text.trim()).isSuccess
    }

    /** Says queued phrases until the queue is closed. */
    suspend fun run() {
        for (phrase in phrases) {
            speaking.value = true
            try {
                speaker.say(phrase)
            } finally {
                speaking.value = false
            }
        }
    }

    /** Stops accepting phrases; [run] returns after the last queued phrase. */
    fun close() {
        phrases.close()
    }

    private companion object {
        const val DEFAULT_CAPACITY = 8
    }
}
