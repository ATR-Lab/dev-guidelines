// Deliberately bad Kotlin: scripts/check-configs.sh expects ktlint AND detekt to reject this
// file. Do not copy it. Each comment names the rule that should fire.
package edu.kent.cs.atr.bad

import kotlin.math.*  // ktlint no-wildcard-imports, detekt WildcardImport

class bad_robot {  // ktlint class-naming, detekt ClassNaming
    var Speed = 0.0  // detekt VariableNaming, ktlint property-naming

    fun Drive(distance: Double) : Double {  // ktlint function-naming, colon spacing
        if (distance > 42.0) return 42.0  // detekt MagicNumber
        try {
            return distance / Speed
        } catch (e: Exception) {  // detekt TooGenericExceptionCaught, SwallowedException
            return 0.0
        }
    }
}
