//
//  ActivityView.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 29/05/1448 AH.
//

import SwiftUI

struct ActivityView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date.now
        
        let weekday = calendar.component(.weekday, from: today)
        
        let sunday = calendar.date(
            byAdding: .day,
            value: 1 - weekday,
            to: calendar.startOfDay(for: today)
        ) ?? today
        
        return (0..<7).compactMap { index in
            calendar.date(byAdding: .day, value: index, to: sunday)
        }
    }
    
    
    
    
    let viewModel: ActivityViewModel
    
    // Callback to return to the goal creation screen.
    let onSetGoal: () -> Void
    
    
    
    private func calendarBackground(
        for state: ActivityViewModel.CalendarDayState
    ) -> Color {
        switch state {
        case .today:
            return CalendarColors.todayBackground
        case .learned:
            return CalendarColors.learnedBackground
        case .frozen:
            return CalendarColors.frozenBackground
        case .normal:
            return .clear
        }
    }

    private func calendarTextColor(
        for state: ActivityViewModel.CalendarDayState
    ) -> Color {
        switch state {
        case .today:
            return .white
        case .learned:
            return CalendarColors.learnedText
        case .frozen:
            return CalendarColors.frozenText
        case .normal:
            return .primary
        }
    }

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                    
            HStack(spacing: 12) {
                
                Text("Activity")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink {
                    ActivitiesHistoryView(viewModel: viewModel)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 50)
                        .glassEffect(.regular, in: Circle())
                }
                .tint(.primary)
                // Open the Edit Learning Goal screen.
                NavigationLink {
                    
                    EditLearningGoalView(
                        // Read the current settings from the ViewModel.
                        learningGoal: viewModel.learningGoal,
                        selectedDuration: viewModel.selectedDuration,
                        onUpdate: { newGoal, newDuration in
                            // Delegate the update to the ViewModel.
                            viewModel.updateLearningSettings(
                                goal: newGoal,
                                duration: newDuration
                            )
                        }
                    )
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 50)
                        .glassEffect(.regular, in: Circle())
                }
                .tint(.primary)
            }
            
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    let state = viewModel.calendarState(for: date)

                    VStack(spacing: 4) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.primary)

                        Text(date, format: .dateTime.day())
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(calendarTextColor(for: state))
                            .frame(width: 36, height: 36)
                            .background {
                                Circle()
                                    .fill(calendarBackground(for: state))
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                // Display the Learned and Frozen cards side by side.
                
                
                // First card: Learned statistics.
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.orange)
                    
                    // Display the number of learned days.
                    
                    Text(
                        // Use "day" for one day and "days" for all other counts.
                        "\(viewModel.totalLearnedDays) \(viewModel.totalLearnedDays == 1 ? "day" : "days")"
                    )
                    .font(.system(size: 18, weight: .semibold))
                    
                    
                    // Display the card title.
                    Text("Learned")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                    
                }
                
                
                .frame(maxWidth: .infinity)
                .frame(height: 105) // Keep the card height consistent.
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 24)
                )

                
                
                
                
                VStack(spacing: 8) {
                    // Display the freeze icon.
                    Image(systemName: "snowflake")
                        .font(.system(size: 24))
                        .foregroundStyle(.cyan)
                    
                    
                    // Display the number of frozen days.
                    
                    Text(
                        // Use "day" for one freeze and "days" for other counts.
                        "\(viewModel.totalFrozenDays) \(viewModel.totalFrozenDays == 1 ? "day" : "days")"
                    )
                    .font(.system(size: 16, weight: .semibold))
                    
                    // Display the card title.
                    Text("Freezed")
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                    
                }
                
                .frame(maxWidth: .infinity)
                .frame(height: 105) // Keep the card height consistent.
              
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 24)
                )

                
            }
            
            .padding(.top, 20) // Add space above the statistics cards.
            
            .padding(.bottom, 16) // Add space below both statistics cards.
            
            
            
            if viewModel.hasGoalEnded {
                
                // Replace activity controls with the goal result.
                GoalResultView(
                    result: viewModel.goalResult,
                    message: viewModel.goalResultMessage,
                    onSetGoal: {
                        viewModel.acknowledgeGoalResult()
                        onSetGoal()
                    }
                )
                
            } else {
            
            // Log as Learned button
            Button {
                viewModel.logLearning()
            } label: {
                
                Text(
                    // Show the completed label if learning was logged today.
                    viewModel.todayStatus == .learned
                    ? "Logged as Learned"
                    : "Log as Learned"
                )
                
            }
            
            .foregroundStyle(
                viewModel.todayStatus == .learned
                    ? (colorScheme == .dark ? Color.gray : Color.black)
                    : Color.white
            )
            .font(.system(size: 18 , weight: .semibold))
            .frame(width: 280, height: 280)
            
            .background {
                Circle()
                    .fill(
                        viewModel.todayStatus == .learned
                            ? (colorScheme == .dark
                                ? Color(white: 0.11)
                                : Color(white: 0.92))
                            : Color.orange
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(
                                Color.primary.opacity(0.16),
                                lineWidth: 1
                            )                    }
            }
            
            .disabled(viewModel.hasGoalEnded)
            
            
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            
            Spacer()
            // Keep a fixed 12-point gap between the buttons.
                .frame(height: 12)
            
            // Freeze button
        
                Button {
                    viewModel.freezeToday()
                } label: {
                   
                    Text(
                        viewModel.todayStatus == .frozen
                            ? "Frozen for a Day"
                            : "Freeze for a Day"
                    )
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        viewModel.todayStatus == .frozen
                            ? (colorScheme == .dark ? Color.gray : Color.black)
                            : Color.white
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background {
                        Capsule()
                            .fill(
                                viewModel.todayStatus == .frozen
                                    ? (colorScheme == .dark
                                        ? Color(white: 0.15)
                                        : Color(white: 0.90))
                                    : Color(
                                        red: 60 / 255,
                                        green: 211 / 255,
                                        blue: 254 / 255
                                    )
                            )
                            
                    }
                    
                    .overlay {
                        // Add a subtle highlight around the capsule.
                        Capsule()
                            .strokeBorder(
                                Color.primary.opacity(0.16),
                                lineWidth: 1
                            )
                    }


                }
                .padding(.horizontal, 32)
                
                .allowsHitTesting(
                    !viewModel.hasGoalEnded &&
                    (
                        viewModel.todayStatus == .frozen ||
                        viewModel.usedFreezes < viewModel.maxFreezes
                    )
                )





            
            
        
                Text("\(viewModel.usedFreezes) out of \(viewModel.maxFreezes) Freezes used")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)

                Spacer()

                } // End else: active goal controls

            } // End main VStack
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .navigationBarBackButtonHidden(true)

        } // End body
    } // End ActivityView

    #Preview {
        ActivityView(
            viewModel: ActivityViewModel(
                learningGoal: "Swift",
                selectedDuration: "Week"
            ),
            onSetGoal: {
                // Preview-only action.
            }
        )
        .preferredColorScheme(.dark)
    }
