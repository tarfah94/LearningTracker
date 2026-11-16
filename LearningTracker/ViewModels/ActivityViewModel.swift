//
//  ActivityViewModel.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 01/06/1448 AH.
//


import Foundation

@Observable
class ActivityViewModel {

    
  
    var activities: [DayActivity] = []

    var totalActivities: Int {
        activities.count
    }


    var totalLearnedDays: Int {
        activities.filter { activity in
            activity.status == .learned
        }.count
    }
    
    
    var totalFrozenDays: Int {
        activities.filter { activity in
            activity.status == .frozen
        }.count
    }
    
    var weeklyFrozenDays: Int {
        // Get the current calendar week.
        guard let week = Calendar.current.dateInterval(
            of: .weekOfYear,
            for: Date.now
        ) else {
            return 0
        }

        // Count frozen days in the current week only.
        return activities.filter { activity in
            activity.status == .frozen &&
            week.contains(activity.date)
        }.count
    }

    
   
    var usedFreezes: Int {
        // Count freezes within the current goal period.
        guard let endDate = goalEndDate else {
            return 0
        }

        let calendar = Calendar.current

        let frozenActivities = activities.filter { activity in
            // Count freezes belonging to the current goal only.
            activity.status == .frozen &&
            activity.date >= goalActivityCutoff &&
            activity.date >= goalStartDate &&
            activity.date < endDate
        }


        // Count each frozen calendar day only once.
        let uniqueDays = Set(
            frozenActivities.map { activity in
                calendar.startOfDay(for: activity.date)
            }
        )

        return uniqueDays.count
    }


    
    var sortedActivities: [DayActivity] {
        // Sort activities from newest to oldest.
        activities.sorted { first, second in
            first.date > second.date
        }
    }

    
    
    var todayActivity: DayActivity? {
        // Only find today's activity in the current goal.
        activities.last { activity in
            activity.date >= goalActivityCutoff &&
            Calendar.current.isDateInToday(activity.date)
        }
    }

    
   
    // Returns the status of today's activity.
    var todayStatus: ActivityStatus {

        // Get today's status if an activity exists.
        // Otherwise, return .none.
        todayActivity?.status ?? .none
    }

    
    func status(for date: Date) -> ActivityStatus {
        // Find an activity that matches the given date.
        let activity = activities.first { activity in
            Calendar.current.isDate(
                activity.date,
                inSameDayAs: date
            )
        }

        // Return the activity status, or .none if not found.
        return activity?.status ?? .none
    }

    var selectedDuration = "Week"
    // Store the current learning goal in the ViewModel.
    var learningGoal: String = ""

    
    var maxFreezes: Int {
        switch selectedDuration {
        case "Week":
            return 2
        case "Month":
            return 8
        case "Year":
            return 96
        default:
            return 2
        }
    }
    
    

  
    init(learningGoal: String, selectedDuration: String) {

        // Load the saved learning settings when available.
        let defaults = UserDefaults.standard

        
        // Restore the start of the current goal's activity records.
        self.goalActivityCutoff = defaults.object(
            forKey: "goalActivityCutoff"
        ) as? Date ?? .distantPast

        // Restore the current goal ID or create one if needed.
        if let savedID = defaults.string(forKey: "goalID"),
           let existingID = UUID(uuidString: savedID) {
            self.goalID = existingID
        } else {
            let newID = UUID()
            self.goalID = newID
            defaults.set(newID.uuidString, forKey: "goalID")
        }

        self.learningGoal = defaults.string(
            forKey: "savedLearningGoal"
        ) ?? learningGoal

        self.selectedDuration = defaults.string(
            forKey: "savedLearningDuration"
        ) ?? selectedDuration

        // Restore the original goal start date.
        if let savedDate = defaults.object(
            forKey: "goalStartDate"
        ) as? Date {
           
            self.goalStartDate = Calendar.current.startOfDay(for: savedDate)

        } else {
            // Save today's date if no start date exists.
            self.goalStartDate = Calendar.current.startOfDay(for: Date.now)


            defaults.set(
                self.goalStartDate,
                forKey: "goalStartDate"
            )
        }

        // Restore previously recorded activities.
        loadActivities()
        
        // Check whether the current goal's result was acknowledged.
        let acknowledgedID = defaults.string(
            forKey: "acknowledgedGoalID"
        )

        hasAcknowledgedGoalResult = acknowledgedID == goalID.uuidString


    }

    func freezeToday() {
        // Do not modify activities after the goal ends.
        guard !hasGoalEnded else { return }

        if todayStatus == .frozen {
            activities.removeAll { activity in
                // Remove only today's freeze from the current goal.
                activity.date >= goalActivityCutoff &&
                Calendar.current.isDateInToday(activity.date) &&
                activity.status == .frozen
            }



        } else if todayStatus == .none && usedFreezes < maxFreezes {
            // Use one available freeze.
            activities.append(
                DayActivity(date: Date.now, status: .frozen)
            )
        } else {
            // Prevent freezing when the day is learned
            // or the allowance is exhausted.
            return
        }

        saveActivities()
    }



    
   
   
    func saveActivities() {
        // Create an encoder to convert Swift objects into JSON data.
        let encoder = JSONEncoder()

        // Encode the activities array if possible.
        if let encodedData = try? encoder.encode(activities) {

            // Save the encoded data on the device.
            UserDefaults.standard.set(
                encodedData,
                forKey: "savedActivities"
            )
        }
    }
    
    
   
    func loadActivities() {
        // Create a decoder to convert JSON data into Swift objects.
        let decoder = JSONDecoder()

        // Retrieve the saved data from UserDefaults.
        guard let savedData = UserDefaults.standard.data(
            forKey: "savedActivities"
        ) else {
            return
        }

        // Decode the saved data into an array of DayActivity.
        if let decodedActivities = try? decoder.decode(
            [DayActivity].self,
            from: savedData
        ) {
           
            // Restore the saved activities.
            activities = decodedActivities

           
        }
    }



    func logLearning() {
        // Do not modify activities after the goal ends.
        guard !hasGoalEnded else { return }

        if todayStatus == .learned {
            activities.removeAll { activity in
                // Remove only today's learned activity from the current goal.
                activity.date >= goalActivityCutoff &&
                Calendar.current.isDateInToday(activity.date) &&
                activity.status == .learned
            }

        } else if todayStatus == .none {
            // Record learning when today has no activity.
            activities.append(
                DayActivity(date: Date.now, status: .learned)
            )
        } else {
            // Do not overwrite an existing freeze.
            return
        }

        saveActivities()
    }


  
    

 

    func saveLearningSettings(
        goal: String,
        duration: String
    ) {
        // Save the confirmed learning goal.
        UserDefaults.standard.set(
            goal,
            forKey: "savedLearningGoal"
        )

        // Save the confirmed learning duration.
        UserDefaults.standard.set(
            duration,
            forKey: "savedLearningDuration"
        )
    }

    
    
    func loadLearningSettings() -> (goal: String, duration: String)? {
        // Read the saved learning goal and duration.
        guard let goal = UserDefaults.standard.string(
            forKey: "savedLearningGoal"
        ),
        let duration = UserDefaults.standard.string(
            forKey: "savedLearningDuration"
        ) else {
            return nil
        }

        // Return both values together.
        return (goal: goal, duration: duration)
    }


   

    func updateLearningSettings(goal: String, duration: String) {
        // Restart only when the goal settings change.
        guard goal != learningGoal ||
              duration != selectedDuration else {
            return
        }

        startNewGoal(goal: goal, duration: duration)
    }

    
    

    func isValidLearningGoal(_ goal: String) -> Bool {
        // Remove spaces and newlines before checking the goal.
        let trimmedGoal = goal.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // A learning goal must contain at least one character.
        return !trimmedGoal.isEmpty
    }


    
   

    var coveredDays: Int {
        // Get the end date of the current goal.
        guard let endDate = goalEndDate else {
            return 0
        }

        let calendar = Calendar.current

        // Keep only learned or frozen activities within the goal period.
        let validActivities = activities.filter { activity in
            // Include activities from the current goal only.
            activity.date >= goalActivityCutoff &&
            activity.date >= goalStartDate &&
            activity.date < endDate &&
            (activity.status == .learned ||
             activity.status == .frozen)
        }


        // Count each calendar day only once.
        let uniqueDays = Set(
            validActivities.map { activity in
                calendar.startOfDay(for: activity.date)
            }
        )

        return uniqueDays.count
    }


    
    
    // Store the date when the current learning goal started.
    var goalStartDate: Date = Date.now

    
    
    var goalEndDate: Date? {
        // Determine the goal duration.
        let component: Calendar.Component

        switch selectedDuration {
        case "Week":
            component = .weekOfYear
        case "Month":
            component = .month
        case "Year":
            component = .year
        default:
            component = .weekOfYear
        }

        // Calculate the end date from the goal's start date.
        return Calendar.current.date(
            byAdding: component,
            value: 1,
            to: goalStartDate
        )
    }
    
    
    
    var hasGoalEnded: Bool {
        // Check whether the goal has reached its end date.
        guard let endDate = goalEndDate else {
            return false
        }

        // The goal ends when the current time reaches its end date.
        return Date.now >= endDate
    }

    
    
    var requiredDays: Int {
        // Get the end date of the current goal.
        guard let endDate = goalEndDate else {
            return 0
        }

        let calendar = Calendar.current

        // Compare the calendar days, ignoring the time.
        let start = calendar.startOfDay(for: goalStartDate)
        let end = calendar.startOfDay(for: endDate)

        // Calculate the number of days in the goal period.
        return calendar.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0
    }

    
    
    var isGoalCompleted: Bool {
        // A goal can only be completed after its duration ends.
        guard hasGoalEnded else {
            return false
        }

        // Both learned and frozen days count toward the goal.
        return requiredDays > 0 && coveredDays >= requiredDays
    }

    
    
    var goalResult: GoalResult {
        // Keep the goal active until its duration ends.
        guard hasGoalEnded else {
            return .inProgress
        }

        // Determine the result after the goal ends.
        return isGoalCompleted ? .completed : .notMet
    }

    
   
    var shouldShowGoalResult: Bool {
        // Show the result only if the goal ended
        // and the user has not acknowledged it.
        return goalResult != .inProgress &&
               !hasAcknowledgedGoalResult
    }

    
    var goalResultMessage: String {
        // Provide the message for the current goal result.
        switch goalResult {
        case .completed:
            return "Well done!"

        case .notMet:
            return "You didn't reach your goal this time."

        case .inProgress:
            return ""
        }
    }

    
    var hasAcknowledgedGoalResult = false
    
    var goalID: UUID




    
    
    func acknowledgeGoalResult() {
        // Acknowledge the result only after the goal ends.
        guard hasGoalEnded else {
            return
        }

        hasAcknowledgedGoalResult = true

        // Persist the acknowledgment across app launches.
        UserDefaults.standard.set(
            goalID.uuidString,
            forKey: "acknowledgedGoalID"
        )

    }

    
    // Separate current-goal activities from previous goal records.
    var goalActivityCutoff: Date = .distantPast

    
    
    func startNewGoal(goal: String, duration: String) {
        // Validate the new goal.
        guard isValidLearningGoal(goal),
              ["Week", "Month", "Year"].contains(duration) else {
            return
        }

        let defaults = UserDefaults.standard
        let now = Date.now

        // Create a new goal identity and activity scope.
        goalID = UUID()
        goalStartDate = Calendar.current.startOfDay(for: now)
        goalActivityCutoff = now

        learningGoal = goal
        selectedDuration = duration
        hasAcknowledgedGoalResult = false

        // Persist the new goal without deleting activity history.
        defaults.set(goalID.uuidString, forKey: "goalID")
        defaults.set(goalStartDate, forKey: "goalStartDate")
        defaults.set(goalActivityCutoff, forKey: "goalActivityCutoff")

        saveLearningSettings(goal: goal, duration: duration)
    }


}

