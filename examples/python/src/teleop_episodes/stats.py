# Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
# SPDX-License-Identifier: MIT

"""Summary statistics for recorded teleoperation episodes."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
import itertools
import json
import math
from pathlib import Path

DEFAULT_RATE_HZ = 30.0


@dataclass(frozen=True)
class Frame:
    """One sample of joint positions, in radians, at a time in seconds."""

    stamp: float
    positions: tuple[float, ...]


@dataclass(frozen=True)
class EpisodeSummary:
    """Numbers we report for each episode before training on it."""

    frame_count: int
    duration_s: float
    joint_ranges: tuple[float, ...]
    max_joint_speed: float


def summarize(frames: Sequence[Frame]) -> EpisodeSummary:
    """Summarize one recorded episode.

    Args:
        frames: Samples in time order. Every frame must have the same number of joints.

    Returns:
        The frame count, the duration, the range of each joint and the fastest joint speed
        seen between two consecutive frames.

    Raises:
        ValueError: If there are fewer than two frames or the joint counts differ.
    """
    if len(frames) < 2:
        raise ValueError('An episode needs at least two frames.')
    joint_count = len(frames[0].positions)
    if any(len(frame.positions) != joint_count for frame in frames):
        raise ValueError('Every frame must have the same number of joints.')

    joint_ranges = tuple(
        max(frame.positions[j] for frame in frames) - min(frame.positions[j] for frame in frames)
        for j in range(joint_count)
    )
    max_speed = 0.0
    for previous, current in itertools.pairwise(frames):
        dt = current.stamp - previous.stamp
        if dt <= 0.0:
            continue
        for a, b in zip(previous.positions, current.positions, strict=True):
            max_speed = max(max_speed, abs(b - a) / dt)

    return EpisodeSummary(
        frame_count=len(frames),
        duration_s=frames[-1].stamp - frames[0].stamp,
        joint_ranges=joint_ranges,
        max_joint_speed=max_speed,
    )


def load_frames(path: Path, rate_hz: float = DEFAULT_RATE_HZ) -> list[Frame]:
    """Load frames from a JSON file that holds a list of joint-position lists.

    Args:
        path: File written by the recorder, one inner list per sample.
        rate_hz: Recording rate, used to rebuild the time stamps.

    Returns:
        The frames, stamped from zero.
    """
    rows = json.loads(path.read_text(encoding='utf-8'))
    return [
        Frame(stamp=index / rate_hz, positions=tuple(float(value) for value in row))
        for index, row in enumerate(rows)
    ]


def is_within_limits(summary: EpisodeSummary, max_speed: float = math.pi) -> bool:
    """Return True when no joint moved faster than max_speed (rad/s)."""
    return summary.max_joint_speed <= max_speed
