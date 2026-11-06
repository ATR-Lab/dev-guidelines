// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

import SwiftUI

/// Shows whether the robot is connected and what it was last told to do.
struct RobotStatusView: View {
    let viewModel: TeleopViewModel

    @State private var showsDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(statusText, systemImage: statusSymbol)
                .font(.headline)
                .accessibilityLabel("Robot connection: \(statusText)")

            if showsDetails {
                Text(
                    String(
                        format: "%.2f m/s, %.2f rad/s",
                        viewModel.lastCommand.linear,
                        viewModel.lastCommand.angular
                    )
                )
                .font(.caption.monospacedDigit())
            }

            Button(showsDetails ? "Hide details" : "Show details") {
                showsDetails.toggle()
            }
        }
        .padding()
    }

    private var statusText: String {
        switch viewModel.connectionState {
        case .disconnected:
            "Disconnected"
        case .connected:
            "Connected"
        case .failed(let message):
            "Error: \(message)"
        }
    }

    private var statusSymbol: String {
        viewModel.connectionState == .connected ? "wifi" : "wifi.slash"
    }
}
