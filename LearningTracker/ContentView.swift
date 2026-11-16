
import SwiftUI

struct ContentView: View {
    
    @State private var learningGoal = ""
    @FocusState private var isGoalFocused: Bool
    @State private var selectedDuration = "Week"
    @State private var viewModel = ActivityViewModel(
        learningGoal: "",
        selectedDuration: "Week"
    )

    @State private var showActivity = false

    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 65)
                
                // Welcome title
                HStack(spacing: 6) {
                    Text("Hello")
                    
                    Text("Learner")
                        .bold()
                }
                .font(.system(size: 32))
                .padding(.top, 85)
                
                // Description
                Text("This app will help you learn everyday!")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
                
                // Learning goal label
                Text("I want to learn")
                    .font(.subheadline)
                    .padding(.top, 40)
                
                
                TextField("Swift", text: $learningGoal)
                    .padding(12)
                    .focused($isGoalFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isGoalFocused = false
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isGoalFocused ? Color.gray : Color.clear,
                                lineWidth: 1
                            )
                    }

                
        
                
                Divider()
                
                Text("I want to learn it in a")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .padding(.top, 30)
                    
                
                HStack(spacing: 8) {
                    
                    ForEach(["Week", "Month", "Year"], id: \.self) { duration in
                        
                        Button(duration) {
                            selectedDuration = duration
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .foregroundStyle(
                            selectedDuration == duration
                            ? Color.white
                            : Color.secondary
                        )
                        
                        
                        .background {
                            Capsule()
                                .fill(
                                    selectedDuration == duration
                                        ? Color.orange
                                        : Color.clear
                                )
                        }
                        .glassEffect(.regular, in: Capsule())

                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    Color.primary.opacity(0.2),
                                    lineWidth: 1
                                )
                        }

                        .clipShape(Capsule())
                    }
                    
                }
                .padding(.top, 15)
                Spacer()
                
            
                Button {
                    // Start the goal using the shared ViewModel.
                    viewModel.startNewGoal(
                        goal: learningGoal,
                        duration: selectedDuration
                    )

                    isGoalFocused = false
                    showActivity = true
                } label: {
                    Text("Start Learning")
                }

                .padding()
                .background(
                    learningGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? Color.gray.opacity(0.3)
                    : Color.orange
                )
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(
                            Color.primary.opacity(0.2),
                            lineWidth: 1
                        )
                }
                .frame(maxWidth: .infinity)
                .disabled(
                    learningGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )

                Text("You can edit your desire later")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

            } // End VStack
            .padding(.horizontal, 18)
            .foregroundStyle(.primary)
            .background {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isGoalFocused = false
                    }
            }
            .navigationDestination(isPresented: $showActivity) {
                ActivityView(
                    viewModel: viewModel,
                    onSetGoal: {
                        // Return to the goal creation screen.
                        showActivity = false
                        learningGoal = ""
                        selectedDuration = "Week"
                    }
                )
            }

        } // End NavigationStack
    } // End body
} // End ContentView

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
