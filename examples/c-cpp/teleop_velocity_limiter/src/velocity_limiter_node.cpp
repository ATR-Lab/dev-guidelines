// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

#include "teleop_velocity_limiter/velocity_limiter_node.hpp"

#include "rclcpp_components/register_node_macro.hpp"

namespace teleop_velocity_limiter
{
namespace
{

Limits declare_limits(rclcpp::Node & node)
{
  Limits limits;
  limits.max_linear_speed = node.declare_parameter("max_linear_speed", limits.max_linear_speed);
  limits.max_angular_speed = node.declare_parameter("max_angular_speed", limits.max_angular_speed);
  limits.max_linear_accel = node.declare_parameter("max_linear_accel", limits.max_linear_accel);
  limits.max_angular_accel = node.declare_parameter("max_angular_accel", limits.max_angular_accel);
  return limits;
}

}  // namespace

VelocityLimiterNode::VelocityLimiterNode(const rclcpp::NodeOptions & options)
: rclcpp::Node("velocity_limiter", options), limiter_(declare_limits(*this)), last_stamp_(now())
{
  publisher_ = create_publisher<geometry_msgs::msg::Twist>("cmd_vel_out", rclcpp::QoS(10));
  subscription_ = create_subscription<geometry_msgs::msg::Twist>(
    "cmd_vel_in", rclcpp::QoS(10),
    [this](const geometry_msgs::msg::Twist & msg) { on_command(msg); });

  RCLCPP_INFO(
    get_logger(), "Limiting to %.2f m/s and %.2f rad/s", limiter_.limits().max_linear_speed,
    limiter_.limits().max_angular_speed);
}

void VelocityLimiterNode::on_command(const geometry_msgs::msg::Twist & msg)
{
  const rclcpp::Time stamp = now();
  const double dt_seconds = (stamp - last_stamp_).seconds();
  last_stamp_ = stamp;

  const Velocity command = limiter_.limit(Velocity{msg.linear.x, msg.angular.z}, dt_seconds);

  geometry_msgs::msg::Twist out;
  out.linear.x = command.linear;
  out.angular.z = command.angular;
  publisher_->publish(out);
}

}  // namespace teleop_velocity_limiter

RCLCPP_COMPONENTS_REGISTER_NODE(teleop_velocity_limiter::VelocityLimiterNode)
