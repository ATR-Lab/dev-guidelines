// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#include "ring_buffer.h"

void ring_buffer_init(RingBuffer * buffer)
{
  buffer->head = 0U;
  buffer->tail = 0U;
  buffer->count = 0U;
}

bool ring_buffer_push(RingBuffer * buffer, uint8_t value)
{
  if (buffer->count == RING_BUFFER_CAPACITY) {
    return false;
  }
  buffer->data[buffer->head] = value;
  buffer->head = (buffer->head + 1U) % RING_BUFFER_CAPACITY;
  buffer->count++;
  return true;
}

bool ring_buffer_pop(RingBuffer * buffer, uint8_t * value)
{
  if (buffer->count == 0U) {
    return false;
  }
  *value = buffer->data[buffer->tail];
  buffer->tail = (buffer->tail + 1U) % RING_BUFFER_CAPACITY;
  buffer->count--;
  return true;
}
