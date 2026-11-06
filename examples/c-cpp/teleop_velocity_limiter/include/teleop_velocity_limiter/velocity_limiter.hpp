// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#ifndef TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_HPP_
#define TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_HPP_

namespace teleop_velocity_limiter
{

/// Speed and acceleration limits for a mobile base, in SI units (REP 103).
struct Limits
{
  double max_linear_speed{0.5};   ///< Meters per second.
  double max_angular_speed{1.0};  ///< Radians per second.
  double max_linear_accel{1.0};   ///< Meters per second squared.
  double max_angular_accel{2.0};  ///< Radians per second squared.
};

/// A planar velocity command: forward speed and yaw rate in the robot's base_link frame.
struct Velocity
{
  double linear{0.0};   ///< Meters per second, positive forward (x).
  double angular{0.0};  ///< Radians per second, positive counterclockwise (z).
};

/**
 * Clamps teleoperation commands so the robot never exceeds its speed and
 * acceleration limits.
 *
 * The class holds no ROS types, so it can be unit tested without a running node.
 */
class VelocityLimiter
{
public:
  explicit VelocityLimiter(const Limits & limits);

  /// Returns the command to send, given the requested command and the time since the last one.
  Velocity limit(const Velocity & requested, double dt_seconds);

  /// Forgets the previous command, for example after the operator releases the dead-man switch.
  void reset();

  const Limits & limits() const { return limits_; }

private:
  Limits limits_;
  Velocity last_command_;
};

}  // namespace teleop_velocity_limiter

#endif  // TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_HPP_
