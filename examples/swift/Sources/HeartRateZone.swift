// Copyright 2026 Advanced Telerobotics Research Lab contributors, Kent State University
// SPDX-License-Identifier: MIT

/// Heart-rate zones that a watchOS app can show during a study session.
///
/// The thresholds are fractions of the participant's maximum heart rate and come from the
/// study protocol, not from this code.
enum HeartRateZone: String, CaseIterable, Sendable {
    case resting
    case light
    case moderate
    case vigorous

    /// Returns the zone for a heart rate, given the upper bound of each zone as a fraction of
    /// the maximum heart rate.
    static func zone(
        forBeatsPerMinute bpm: Double,
        maximumBeatsPerMinute maxBPM: Double,
        upperBounds: [Double] = [0.5, 0.64, 0.77]
    ) -> Self {
        guard maxBPM > 0 else {
            return .resting
        }
        let fraction = bpm / maxBPM
        let zones = Self.allCases
        for (index, bound) in upperBounds.enumerated() where fraction < bound {
            return zones[index]
        }
        return .vigorous
    }
}
