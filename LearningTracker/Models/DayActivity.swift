//
//  DayActivity.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 02/06/1448 AH.
//


import Foundation




// Defines the possible activity statuses.
enum ActivityStatus: String, Codable {
    case none
    case learned
    case frozen
}




// Represents a single day's learning activity.
struct DayActivity: Codable {

    // Stores the date of the activity.
    var date: Date

    // Stores whether the day was learned or frozen.
    var status: ActivityStatus
}

