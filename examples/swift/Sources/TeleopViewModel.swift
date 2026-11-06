// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

import Foundation
import Observation

/// A velocity command for a mobile robot, in SI units (meters per second, radians per second).
struct VelocityCommand: Equatable, Sendable {
    var linear: Double
    var angular: Double

    static let stop = Self(linear: 0, angular: 0)
}

/// Sends commands to the robot.
///
/// The app uses a WebSocket client; tests use a fake.
protocol RobotLink: Sendable {
    func send(_ command: VelocityCommand) async throws
}

/// Drives the teleoperation screen: turns joystick input into limited velocity commands.
@MainActor
@Observable
final class TeleopViewModel {
    enum ConnectionState: Equatable {
        case disconnected
        case connected
        case failed(message: String)
    }

    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var lastCommand: VelocityCommand = .stop

    private let link: any RobotLink
    private let maxLinearSpeed: Double
    private let maxAngularSpeed: Double

    init(link: any RobotLink, maxLinearSpeed: Double = 0.5, maxAngularSpeed: Double = 1.0) {
        self.link = link
        self.maxLinearSpeed = maxLinearSpeed
        self.maxAngularSpeed = maxAngularSpeed
    }

    /// Maps a joystick position (each axis from -1 to 1) to a command and sends it.
    func joystickMoved(x: Double, y: Double) async {
        let command = VelocityCommand(
            linear: clamp(y, limit: 1) * maxLinearSpeed,
            angular: -clamp(x, limit: 1) * maxAngularSpeed
        )
        await send(command)
    }

    /// Stops the robot.
    ///
    /// Called when the operator lets go of the joystick.
    func joystickReleased() async {
        await send(.stop)
    }

    private func send(_ command: VelocityCommand) async {
        do {
            try await link.send(command)
            lastCommand = command
            connectionState = .connected
        } catch {
            connectionState = .failed(message: error.localizedDescription)
        }
    }

    private func clamp(_ value: Double, limit: Double) -> Double {
        min(max(value, -limit), limit)
    }
}
