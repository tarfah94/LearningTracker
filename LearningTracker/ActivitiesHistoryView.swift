//
//  ActivitiesHistoryView.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 30/05/1448 AH.
//

import SwiftUI


struct ActivitiesHistoryView: View {
    // Receive the same ViewModel used by ActivityView.
    let viewModel: ActivityViewModel

    private var months: [Date] {
        // Get the first day of the current month.
        let calendar = Calendar.current

        guard let currentMonth = calendar.dateInterval(
            of: .month,
            for: Date.now
        )?.start else {
            return []
        }

        // Generate the current month and previous 11 months.
        return (0..<12).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: -offset,
                to: currentMonth
            )
        }.reversed()
    }

    
    
    
    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    
                    // Display each month with its own calendar.
                    ForEach(months, id: \.self) { month in
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Month title.
                            Text(month, format: .dateTime.month(.wide).year())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            // Weekday labels.
                            HStack(spacing: 0) {
                                ForEach(0..<7, id: \.self) { index in
                                    Text(["S", "M", "T", "W", "T", "F", "S"][index])
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.gray)
                                        .frame(height: 36)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Monthly calendar grid.
                            LazyVGrid(columns: calendarColumns, spacing: 12) {
                                
                                // Empty cells before the first day.
                                ForEach(0..<firstWeekdayOffset(for: month), id: \.self) { _ in
                                    Color.clear
                                        .frame(height: 36)
                                }
                                
                                // Display all days of the month.
                                ForEach(daysInMonth(for: month), id: \.self) { day in
                                    
                                    // Create the actual date for this day of the month.
                                    let date = Calendar.current.date(
                                        byAdding: .day,
                                        value: day - 1,
                                        to: month
                                    ) ?? month
                                    
                                    // Get the saved activity status for this date.
                                    let status = viewModel.status(for: date)
                                

                                    Text("\(day)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(
                                            // Use white text for today and unrecorded dates.
                                            Calendar.current.isDateInToday(date) || status == .none
                                            ? Color.white
                                            : status == .learned
                                            ? CalendarColors.learned
                                            : CalendarColors.frozen
                                        )
                                        .frame(width: 36, height: 36)
                                    
                                        .background {
                                            Circle()
                                                .fill(
                                                    // Use a solid color for today's recorded activity.
                                                    Calendar.current.isDateInToday(date)
                                                    ? (status == .learned
                                                       ? CalendarColors.learned
                                                       : status == .frozen
                                                       ? CalendarColors.frozen
                                                       : Color.clear)
                                                    
                                                    // Use subtle colors for previous activities.
                                                    : (status == .learned
                                                       ? CalendarColors.learnedPast
                                                       : status == .frozen
                                                       ? CalendarColors.frozenPast
                                                       : Color.clear)
                                                )
                                        }
                                    
                                        .overlay {
                                            Circle()
                                            // Outline today only when no activity is recorded.
                                                .stroke(
                                                    Calendar.current.isDateInToday(date) &&
                                                    status == .none
                                                    ? Color.gray
                                                    : Color.clear,
                                                    lineWidth: 1
                                                )
                                        }
                                    // Center the 36-point circle inside its calendar column.
                                    .frame(maxWidth: .infinity)
                                    
                                    
                                }
                            }
                        }
                        
                        // Identify each month for programmatic scrolling.
                        .id(month)
                        
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onAppear {
                // Scroll to the current month when the screen opens.
                if let currentMonth = months.last {
                    proxy.scrollTo(currentMonth, anchor: .top)
                }
            }
        }
        .background(Color.black)
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)

        // Show the default back button on the history screen.
        .navigationBarBackButtonHidden(false)
    }

    
    
    private func daysInMonth(for month: Date) -> [Int] {
        // Find the range of days in the selected month.
        guard let range = Calendar.current.range(
            of: .day,
            in: .month,
            for: month
        ) else {
            return []
        }

        // Convert the range into an array of day numbers.
        return Array(range)
    }

   
    private func firstWeekdayOffset(for month: Date) -> Int {
        // Get the weekday of the first day of the month.
        let weekday = Calendar.current.component(
            .weekday,
            from: month
        )

        // Convert Sunday = 1 into offset = 0.
        return weekday - 1
    }

    private let calendarColumns: [GridItem] = Array(
        // Create seven equally sized calendar columns.
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

}



#Preview {
    // Create the ViewModel and pass it to the History View.
    ActivitiesHistoryView(
        viewModel: ActivityViewModel(
            learningGoal: "Learn SwiftUI",
            selectedDuration: "Week"
        )
    )
}
