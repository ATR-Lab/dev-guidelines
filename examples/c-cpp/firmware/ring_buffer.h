// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

// A fixed-size byte queue for serial links (for example, servo bus packets on a
// microcontroller). No dynamic memory, safe to use from one producer and one consumer.

#ifndef RING_BUFFER_H_
#define RING_BUFFER_H_

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define RING_BUFFER_CAPACITY 64U

typedef struct
{
  uint8_t data[RING_BUFFER_CAPACITY];
  size_t head;   // Next index to write.
  size_t tail;   // Next index to read.
  size_t count;  // Bytes currently stored.
} RingBuffer;

/// Empties the buffer.
void ring_buffer_init(RingBuffer * buffer);

/// Appends one byte. Returns false, and drops the byte, when the buffer is full.
bool ring_buffer_push(RingBuffer * buffer, uint8_t value);

/// Removes the oldest byte into *value. Returns false when the buffer is empty.
bool ring_buffer_pop(RingBuffer * buffer, uint8_t * value);

#endif  // RING_BUFFER_H_
