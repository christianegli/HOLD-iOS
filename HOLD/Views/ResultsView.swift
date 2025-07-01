import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var holdDuration: TimeInterval {
        navigationViewModel.sessionData?.holdDuration ?? 0
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Great Job!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                Text("You held your breath for:")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f seconds", holdDuration))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            
            VStack(spacing: 16) {
                Text("Benefits Achieved:")
                    .font(.title3)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    Text("✓ Improved stress resilience")
                    Text("✓ Enhanced lung capacity")
                    Text("✓ Better focus and clarity")
                    Text("✓ Increased energy levels")
                }
                .foregroundColor(.green)
                .font(.body)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Go Again") {
                    navigationViewModel.navigateToBreathing()
                }
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .background(Color.cyan)
                .cornerRadius(12)
                
                Button("Home") {
                    navigationViewModel.navigateToHome()
                }
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.6))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
} 