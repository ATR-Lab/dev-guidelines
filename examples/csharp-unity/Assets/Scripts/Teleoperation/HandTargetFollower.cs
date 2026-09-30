// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

using UnityEngine;

namespace Atr.Teleoperation
{
    /// <summary>
    /// Moves the robot's end-effector target toward the operator's tracked hand, with a speed
    /// limit so a tracking glitch cannot make the arm jump.
    /// </summary>
    public sealed class HandTargetFollower : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("The tracked hand or controller that the operator moves.")]
        private Transform _hand;

        [SerializeField]
        [Tooltip("Maximum target speed in meters per second.")]
        [Min(0f)]
        private float _maxSpeed = 0.25f;

        [SerializeField]
        [Tooltip("Maximum target rotation speed in degrees per second.")]
        [Min(0f)]
        private float _maxAngularSpeed = 90f;

        private bool _isEngaged;

        /// <summary>Gets the last command sent to the robot bridge.</summary>
        public TeleopCommand LastCommand { get; private set; }

        /// <summary>Starts following the hand, for example when the operator holds the grip button.</summary>
        public void Engage()
        {
            _isEngaged = true;
        }

        /// <summary>Stops following the hand and holds the current target.</summary>
        public void Disengage()
        {
            _isEngaged = false;
        }

        private void Update()
        {
            if (!_isEngaged || _hand == null)
            {
                return;
            }

            float step = _maxSpeed * Time.deltaTime;
            float angleStep = _maxAngularSpeed * Time.deltaTime;
            transform.position = Vector3.MoveTowards(transform.position, _hand.position, step);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, _hand.rotation, angleStep);

            LastCommand = new TeleopCommand(transform.position, transform.rotation);
        }
    }
}
