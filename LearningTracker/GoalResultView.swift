//
//  GoalResultView.swift
//  LearningTracker
//
//  Created by Tarfah Alsaleh on 05/06/1448 AH.
//


import SwiftUI

struct GoalResultView: View {

    // Receive the goal result from the ViewModel.
    let result: GoalResult

    // Receive the result message prepared by the ViewModel.
   let message: String

    // Notify the parent when the user wants to set a new goal.
    let onSetGoal: () -> Void

    
    var body: some View {
        ZStack {
            // Match the dark background from Sketch.
            Color.black.ignoresSafeArea()

            VStack {
                // Temporary title to verify the new screen.
                
                Text(message)
                    // Display the message provided by the ViewModel.
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                
                Button {
                    // Request the new goal flow from the parent.
                    onSetGoal()
                } label: {
                    Text("Set a goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.orange, in: Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)



            }
        }
    }
}



#Preview {
    // Preview the completed state without changing app data.
    GoalResultView(
        result: .completed,
        message: "Well done!",
        onSetGoal: {
            // Preview action only.
        }
    )
}


