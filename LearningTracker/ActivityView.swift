//
//  ActivityView.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 29/05/1448 AH.
//

import SwiftUI

struct ActivityView: View {
    
    
    @State private var showGoalResult = false
    @Environment(\.scenePhase) private var scenePhase

    
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
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: Circle())
                }
                
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
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: Circle())
                }
            }
            
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 4) {
                        
                        Text(date, format: .dateTime.weekday(.narrow))
                        // Keep weekday letters smaller than date numbers.
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.primary)
                        
                        
                        
                        Text(date, format: .dateTime.day())
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(
                                // Show white text for today or dates without activity.
                                Calendar.current.isDateInToday(date) ||
                                viewModel.status(for: date) == .none
                                ? Color.white
                                : viewModel.status(for: date) == .learned
                                ? CalendarColors.learned
                                : CalendarColors.frozen
                            )
                            .frame(width: 36, height: 36)
                            .background {
                                Circle()
                                    .fill(
                                        // Use a solid color for today's recorded activity.
                                        Calendar.current.isDateInToday(date)
                                        ? (viewModel.status(for: date) == .learned
                                           ? CalendarColors.learned
                                           : viewModel.status(for: date) == .frozen
                                           ? CalendarColors.frozen
                                           : Color.clear)
                                        // Use subtle colors for previous recorded activities.
                                        : (viewModel.status(for: date) == .learned
                                           ? CalendarColors.learnedPast
                                           : viewModel.status(for: date) == .frozen
                                           ? CalendarColors.frozenPast
                                           : Color.clear)
                                    )
                            }
                            .overlay {
                                Circle()
                                // Outline today if no activity has been recorded.
                                    .stroke(
                                        Calendar.current.isDateInToday(date) &&
                                        viewModel.status(for: date) == .none
                                        ? Color.gray
                                        : Color.clear,
                                        lineWidth: 1
                                    )
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
                    .font(.system(size: 16, weight: .semibold))
                    
                    
                    // Display the card title.
                    Text("Learned")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                }
                
                
                .frame(maxWidth: .infinity)
                .frame(height: 100) // Keep the card height consistent.
                .background {
                    RoundedRectangle(cornerRadius: 24)
                    // Create a subtle dark glass-like gradient.
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.16),
                                    Color(white: 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                    // Add a soft highlight to the card border.
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                
                
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
                        .foregroundStyle(.secondary)
                    
                }
                
                .frame(maxWidth: .infinity)
                .frame(height: 100) // Keep the card height consistent.
                
                .background {
                    RoundedRectangle(cornerRadius: 24)
                    // Create a dark glass-like surface.
                        .fill(Color(white: 0.11))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                    // Add a soft highlight to the card border.
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                
                
            }
            
            .padding(.top, 20) // Add space above the statistics cards.
            
            .padding(.bottom, 16) // Add space below both statistics cards.
            
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
                // Use gray text when learning is completed today.
                viewModel.todayStatus == .learned
                ? Color.gray
                : Color.white
            )
            
            .frame(width: 260, height: 260)
            
            .background {
                Circle()
                    .fill(
                        
                        // Use a dark background when learning is logged today.
                        viewModel.todayStatus == .learned
                        ? Color(white: 0.11)
                        : Color.orange
                        
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    }
            }
         
            .disabled(
                viewModel.hasGoalEnded ||
                viewModel.todayStatus == .frozen
            )

            
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
                    // Show the completed label only when today is frozen.
                    viewModel.todayStatus == .frozen
                    ? "Frozen for a Day"
                    : "Freeze for a Day"
                )
            }
            
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            // Add a subtle glass effect while keeping the capsule shape.
            .glassEffect(.regular, in: Capsule())
            
            .background {
                Capsule()
                    .fill(
                        viewModel.hasGoalEnded ||
                        (
                            viewModel.todayStatus == .none &&
                            viewModel.usedFreezes >= viewModel.maxFreezes
                        )
                            ? Color(white: 0.11)
                            : Color.cyan


                        
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                Color.white.opacity(0.3),
                                lineWidth: 1
                            )
                    }
            }
            .padding(.horizontal, 16)
            
            
            .foregroundStyle(
               
                
                viewModel.hasGoalEnded ||
                (
                    viewModel.todayStatus == .none &&
                    viewModel.usedFreezes >= viewModel.maxFreezes
                )
                    ? Color.gray
                    : Color.white


            )
            
            
            
            
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .padding(.horizontal, 24)
          
            .disabled(
                viewModel.hasGoalEnded ||
                viewModel.todayStatus == .learned ||
                (
                    viewModel.todayStatus == .none &&
                    viewModel.usedFreezes >= viewModel.maxFreezes
                )
            )

            
            
            
            Text("\(viewModel.usedFreezes) out of \(viewModel.maxFreezes) Freezes used")
            // Show freezes used within the selected time period.
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            
            
            Spacer()
            
            
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        
        // Hide the default navigation back button
        // to match the Sketch design.
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showGoalResult) {
            GoalResultView(
                result: viewModel.goalResult,
                message: viewModel.goalResultMessage,

                onSetGoal: {
                    // Save that the user has viewed the goal result.
                    viewModel.acknowledgeGoalResult()

                    // Dismiss the result screen.
                    showGoalResult = false
                }
            )
        }
        
        .onAppear {
            // Check whether the goal result should be displayed.
            showGoalResult = viewModel.shouldShowGoalResult
        }
        
        
        .onChange(of: scenePhase) { _, newPhase in
            // Check the goal result when the app becomes active.
            if newPhase == .active {
                showGoalResult = viewModel.shouldShowGoalResult
            }
        }


    }
}


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


