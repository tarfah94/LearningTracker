
import SwiftUI

struct GoalResultView: View {

    let result: GoalResult
    let message: String
    let onSetGoal: () -> Void

    // Presentation details for the result.
    private var resultIcon: String {
        switch result {
        case .completed:
            return "hands.clap.fill"
        case .notMet:
            return "xmark.seal.fill"
        case .inProgress:
            return ""
        }
    }

    private var resultColor: Color {
        result == .completed ? .yellow : .orange
    }

    private var subtitle: String {
        switch result {
        case .completed:
            return "Ready for your next goal?"
        case .notMet:
            return "Want to set another goal?"
        case .inProgress:
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer(minLength: 32)

            // Display the result icon.
            Image(systemName: resultIcon)
                .font(.system(size: 46, weight: .medium))
                .foregroundStyle(resultColor)

            // Display the message from the ViewModel.
            Text(message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 18)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 6)

            Button {
                onSetGoal()
            } label: {
                Label("Set a goal", systemImage: "pencil.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .frame(height: 48)
                    .background(Color.orange, in: Capsule())
            }
            .padding(.top, 68)

            Spacer(minLength: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    GoalResultView(
        result: .completed,
        message: "Well done!",
        onSetGoal: {}
    )
    .preferredColorScheme(.dark)
}
