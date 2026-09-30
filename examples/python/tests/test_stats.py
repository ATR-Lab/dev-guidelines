# Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
# SPDX-License-Identifier: MIT

import pytest

from teleop_episodes import Frame, is_within_limits, summarize


def test_summary_reports_ranges_and_speed() -> None:
    frames = [
        Frame(stamp=0.0, positions=(0.0, 1.0)),
        Frame(stamp=0.5, positions=(0.5, 1.0)),
        Frame(stamp=1.0, positions=(0.25, 0.0)),
    ]
    summary = summarize(frames)
    assert summary.frame_count == 3
    assert summary.duration_s == pytest.approx(1.0)
    assert summary.joint_ranges == pytest.approx((0.5, 1.0))
    assert summary.max_joint_speed == pytest.approx(2.0)
    assert is_within_limits(summary)


def test_summary_needs_two_frames() -> None:
    with pytest.raises(ValueError, match='at least two frames'):
        summarize([Frame(stamp=0.0, positions=(0.0,))])
