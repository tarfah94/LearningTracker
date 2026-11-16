
import SwiftUI

struct EditLearningGoalView: View {

    @Environment(\.dismiss) private var dismiss

    // Store the editable learning goal and duration.
    @State private var learningGoal: String
    @State private var selectedDuration: String

    // Control the confirmation alert.
    @State private var showUpdateAlert = false
    let onUpdate: (String, String) -> Void
    // Receive the user's current goal and duration.
   
    init(
        learningGoal: String,
        selectedDuration: String,
        onUpdate: @escaping (String, String) -> Void
    ) {
        // Initialize editable values from the current goal.
        _learningGoal = State(initialValue: learningGoal)
        _selectedDuration = State(initialValue: selectedDuration)

        // Store the action to run after confirmation.
        self.onUpdate = onUpdate
    }

    
    // Track whether the learning goal text field is focused.
    @FocusState private var isGoalFocused: Bool


    var body: some View {
        ZStack {
            // Match the dark background from Sketch.
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Header

                HStack {
                    Button {
                        // Return to the previous screen.
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .glassEffect(.regular, in: Circle())
                    }

                    Spacer()

                    Text("Learning Goal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        // Dismiss the keyboard before showing confirmation.
                           isGoalFocused = false

                           // Show the custom confirmation dialog.
                           showUpdateAlert = true
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background {
                                Circle()
                                    .fill(Color.orange)
                            }
                    }
                }

                // MARK: - Learning Goal Field

                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)

                    TextField(
                        "Enter your learning goal",
                        text: $learningGoal
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .tint(.orange)
                    
                    // Connect the text field to keyboard focus.
                    .focused($isGoalFocused)


                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)
                }
                .padding(.top, 40)

                // MARK: - Duration Selection

                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn it in a")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        ForEach(
                            ["Week", "Month", "Year"],
                            id: \.self
                        ) { duration in

                            Button {
                                // Update the selected duration.
                                selectedDuration = duration
                            } label: {
                                Text(duration)
                                    .font(.system(size: 14))
                                    .foregroundStyle(
                                        selectedDuration == duration
                                            ? Color.white
                                            : Color.gray
                                    )
                                    .padding(.horizontal, 18)
                                    .frame(height: 38)
                                    .background {
                                        Capsule()
                                            .fill(
                                                selectedDuration == duration
                                                    ? Color.orange
                                                    : Color(white: 0.13)
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 28)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            
            if showUpdateAlert {
                // Dim the screen behind the confirmation dialog.
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

          
                VStack(alignment: .leading, spacing: 16) {

                    // Left-aligned confirmation title.
                    Text("Update goal")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    // Left-aligned warning message.
                    Text("If you update now, your streak will start over.")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {

                        Button("Dismiss") {
                            // Close the dialog without saving changes.
                            showUpdateAlert = false
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Color(white: 0.23),
                            in: Capsule()
                        )

                        Button("Update") {
                            // Confirm the update through the ViewModel callback.
                            onUpdate(learningGoal, selectedDuration)
                            showUpdateAlert = false
                            dismiss()
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Color(red: 1, green: 0.58, blue: 0.17),
                            in: Capsule()
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .frame(width: 250)
                .background {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(white: 0.11))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                }

            }

        }


        // Keep only the custom back button.
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    EditLearningGoalView(
        learningGoal: "Learn SwiftUI",
        selectedDuration: "Week",
        onUpdate: { _, _ in
            // No changes are saved in the preview.
        }
    )
}

