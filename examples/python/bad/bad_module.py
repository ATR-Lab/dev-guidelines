# Deliberately bad Python: scripts/check-configs.sh expects ruff (lint and format) and mypy to
# reject this file. Do not copy it. Each comment names the rule that should fire.
import os, sys  # E401 (two imports on one line), F401 (unused)
from typing import List  # UP035 (use list), F401


def ComputeSpeed(distance, time):  # N802 (function name), D103 (no docstring), untyped (mypy)
    if time == 0: return None  # E701 (statement on same line), format
    speed = distance / time
    l = [x for x in [speed]]  # E741 (ambiguous name), C416 (unnecessary comprehension)
    return l[0]


def total(values: list[int]) -> int:
    """Add the values."""
    return sum(values) + "0"  # mypy: int + str
