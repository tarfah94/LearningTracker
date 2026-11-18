
import SwiftUI

enum CalendarColors {
    // Colors for recorded learning days.
    static let learned = Color.orange

    // Colors for recorded frozen days.
    static let frozen = Color.cyan

    // Subtle backgrounds for previous activity dates.
    static let learnedPast = learned.opacity(0.18)
    static let frozenPast = frozen.opacity(0.18)
    
    // Default current day
    static let todayBackground = Color(
        red: 255/255,
        green: 146/255,
        blue: 46/255
    )

    // Learned day
    static let learnedBackground = Color(
        red: 74/255,
        green: 38/255,
        blue: 13/255
    )

    // Frozen day
    static let frozenBackground = Color(
        red: 16/255,
        green: 53/255,
        blue: 64/255
    )

    static let learnedText = Color(
        red: 255/255,
        green: 146/255,
        blue: 46/255
    )

    static let frozenText = Color(
        red: 60/255,
        green: 211/255,
        blue: 254/255
    )

}

