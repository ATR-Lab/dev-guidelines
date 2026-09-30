# Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
# SPDX-License-Identifier: MIT

"""Start the velocity limiter between a teleoperation source and the robot."""

from pathlib import Path

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    """Return the launch description for the velocity limiter node."""
    default_params = Path(get_package_share_directory('teleop_velocity_limiter')) / 'config'
    params_file = LaunchConfiguration('params_file')

    return LaunchDescription([
        DeclareLaunchArgument(
            'params_file',
            default_value=str(default_params / 'limits.yaml'),
            description='YAML file with the speed and acceleration limits.',
        ),
        Node(
            package='teleop_velocity_limiter',
            executable='velocity_limiter',
            parameters=[params_file],
            remappings=[('cmd_vel_in', 'teleop/cmd_vel'), ('cmd_vel_out', 'cmd_vel')],
        ),
    ])
