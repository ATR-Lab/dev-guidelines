// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#include "teleop_velocity_limiter/velocity_limiter.hpp"

#include <algorithm>

namespace teleop_velocity_limiter
{
namespace
{

double clamp_step(double requested, double previous, double max_value, double max_step)
{
  const double bounded = std::clamp(requested, -max_value, max_value);
  return std::clamp(bounded, previous - max_step, previous + max_step);
}

}  // namespace

VelocityLimiter::VelocityLimiter(const Limits & limits) : limits_(limits) {}

Velocity VelocityLimiter::limit(const Velocity & requested, double dt_seconds)
{
  if (dt_seconds <= 0.0) {
    return last_command_;
  }

  Velocity command;
  command.linear = clamp_step(
    requested.linear, last_command_.linear, limits_.max_linear_speed,
    limits_.max_linear_accel * dt_seconds);
  command.angular = clamp_step(
    requested.angular, last_command_.angular, limits_.max_angular_speed,
    limits_.max_angular_accel * dt_seconds);

  last_command_ = command;
  return command;
}

void VelocityLimiter::reset() { last_command_ = Velocity{}; }

}  // namespace teleop_velocity_limiter
