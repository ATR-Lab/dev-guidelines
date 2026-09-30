// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

using System;
using UnityEngine;

namespace Atr.Teleoperation
{
    /// <summary>
    /// A pose target for the robot arm, in Unity's left-handed, Y-up world frame. The ROS 2 bridge
    /// converts it to the robot's right-handed, Z-up frame (REP 103) before sending it.
    /// </summary>
    public readonly struct TeleopCommand : IEquatable<TeleopCommand>
    {
        /// <summary>Initializes a new instance of the <see cref="TeleopCommand"/> struct.</summary>
        /// <param name="position">Target position in meters.</param>
        /// <param name="rotation">Target orientation.</param>
        public TeleopCommand(Vector3 position, Quaternion rotation)
        {
            Position = position;
            Rotation = rotation;
        }

        /// <summary>Gets the target position in meters.</summary>
        public Vector3 Position { get; }

        /// <summary>Gets the target orientation.</summary>
        public Quaternion Rotation { get; }

        /// <inheritdoc/>
        public bool Equals(TeleopCommand other)
        {
            return Position == other.Position && Rotation == other.Rotation;
        }

        /// <inheritdoc/>
        public override bool Equals(object obj)
        {
            return obj is TeleopCommand other && Equals(other);
        }

        /// <inheritdoc/>
        public override int GetHashCode()
        {
            return HashCode.Combine(Position, Rotation);
        }
    }
}
