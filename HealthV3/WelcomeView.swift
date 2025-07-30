import SwiftUI
import AudioToolbox

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("Welcome to Your Health!", comment: ""))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(NSLocalizedString("Track your steps, water intake, and stay healthy with daily reminders. Let's get started!", comment: ""))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                print("WelcomeView: Get Started button tapped")
                dismiss()
                AudioServicesPlaySystemSound(1519)
            }) {
                Text(NSLocalizedString("Get Started", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    WelcomeView()
}
