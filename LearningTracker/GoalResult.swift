
import Foundation

// Represent the possible states of a learning goal.
enum GoalResult {
    // The learning period is still active.
    case inProgress

    // The goal ended and all required days were covered.
    case completed

    // The goal ended without covering all required days.
    case notMet
}
