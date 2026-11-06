// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#ifndef TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_NODE_HPP_
#define TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_NODE_HPP_

#include <memory>

#include "geometry_msgs/msg/twist.hpp"
#include "rclcpp/rclcpp.hpp"
#include "teleop_velocity_limiter/velocity_limiter.hpp"

namespace teleop_velocity_limiter
{

/**
 * Subscribes to raw teleoperation commands on `cmd_vel_in`, limits them and
 * publishes the result on `cmd_vel_out`.
 *
 * Parameters (all doubles, SI units): max_linear_speed, max_angular_speed,
 * max_linear_accel, max_angular_accel.
 */
class VelocityLimiterNode : public rclcpp::Node
{
public:
  explicit VelocityLimiterNode(const rclcpp::NodeOptions & options = rclcpp::NodeOptions());

private:
  void on_command(const geometry_msgs::msg::Twist & msg);

  VelocityLimiter limiter_;
  rclcpp::Time last_stamp_;
  rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr subscription_;
  rclcpp::Publisher<geometry_msgs::msg::Twist>::SharedPtr publisher_;
};

}  // namespace teleop_velocity_limiter

#endif  // TELEOP_VELOCITY_LIMITER__VELOCITY_LIMITER_NODE_HPP_
