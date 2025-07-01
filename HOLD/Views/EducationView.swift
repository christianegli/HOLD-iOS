import SwiftUI

struct EducationView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Text("🧠")
                .font(.system(size: 80))
            
            Text("Education")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text("Learn about breath holding benefits")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Text("• Improves stress resilience")
                Text("• Increases lung capacity")  
                Text("• Enhances focus")
                Text("• Boosts energy levels")
            }
            .foregroundColor(.white)
            .font(.body)
            
            Button(action: {
                navigationViewModel.navigateToBreathing()
            }) {
                Text("START TRAINING")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.cyan, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            
            Button(action: {
                navigationViewModel.navigateToHome()
            }) {
                Text("← Back")
                    .font(.title3)
                    .foregroundColor(.cyan)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 