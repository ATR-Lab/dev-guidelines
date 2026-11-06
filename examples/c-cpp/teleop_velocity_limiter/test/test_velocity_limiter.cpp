// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#include <gtest/gtest.h>

#include "teleop_velocity_limiter/velocity_limiter.hpp"

using teleop_velocity_limiter::Limits;
using teleop_velocity_limiter::Velocity;
using teleop_velocity_limiter::VelocityLimiter;

TEST(VelocityLimiter, ClampsToMaxSpeed)
{
  VelocityLimiter limiter(Limits{0.5, 1.0, 100.0, 100.0});
  const Velocity out = limiter.limit(Velocity{3.0, -4.0}, 0.1);
  EXPECT_DOUBLE_EQ(out.linear, 0.5);
  EXPECT_DOUBLE_EQ(out.angular, -1.0);
}

TEST(VelocityLimiter, LimitsAcceleration)
{
  VelocityLimiter limiter(Limits{2.0, 2.0, 1.0, 1.0});
  const Velocity out = limiter.limit(Velocity{2.0, 0.0}, 0.1);
  EXPECT_NEAR(out.linear, 0.1, 1e-9);
}

TEST(VelocityLimiter, IgnoresNonPositiveTimeStep)
{
  VelocityLimiter limiter(Limits{});
  const Velocity out = limiter.limit(Velocity{0.3, 0.0}, 0.0);
  EXPECT_DOUBLE_EQ(out.linear, 0.0);
}
