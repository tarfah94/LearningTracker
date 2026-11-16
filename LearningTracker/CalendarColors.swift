
import SwiftUI

enum CalendarColors {
    // Colors for recorded learning days.
    static let learned = Color.orange

    // Colors for recorded frozen days.
    static let frozen = Color.cyan

    // Subtle backgrounds for previous activity dates.
    static let learnedPast = learned.opacity(0.18)
    static let frozenPast = frozen.opacity(0.18)
}
