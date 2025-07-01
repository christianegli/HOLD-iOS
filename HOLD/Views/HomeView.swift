import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Header with accessibility
                VStack(spacing: 12) {
                    Text("🫁")
                        .font(.system(size: 80))
                        .accessibilityLabel("Lungs icon")
                        .accessibilityHidden(true) // Icon is decorative
                    
                    Text("HOLD")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("HOLD - Breath Training App")
                    
                    Text("Breath Training")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel("Breath training and improvement")
                }
                .padding(.top, 20)
                
                // Progress Stats Card with accessibility
                if !isLoading {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            ProgressStatCard(
                                title: "Personal Best",
                                value: String(format: "%.1fs", progressViewModel.personalBest),
                                icon: "🏆",
                                color: .yellow
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Personal best: \(String(format: "%.1f seconds", progressViewModel.personalBest))")
                            .accessibilityAddTraits(.isSummaryElement)
                            
                            ProgressStatCard(
                                title: "Sessions",
                                value: "\(progressViewModel.totalSessions)",
                                icon: "📊",
                                color: .cyan
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Total sessions completed: \(progressViewModel.totalSessions)")
                            
                            ProgressStatCard(
                                title: "Streak",
                                value: "\(progressViewModel.currentStreak)",
                                icon: "🔥",
                                color: .orange
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Current streak: \(progressViewModel.currentStreak) days")
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Progress summary")
                }
                
                // Action Buttons with enhanced accessibility
                VStack(spacing: 16) {
                    Button(action: {
                        // Haptic feedback for better accessibility
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        navigationViewModel.navigateToEducation()
                    }) {
                        HStack(spacing: 12) {
                            Text("🧠")
                                .font(.title2)
                                .accessibilityHidden(true) // Decorative emoji
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Learn & Improve")
                                    .font(.headline)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                Text("Breathing techniques and benefits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.cyan.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Learn and improve breathing")
                    .accessibilityHint("Opens educational content about breathing techniques and benefits")
                    .accessibilityAddTraits(.isButton)
                    
                    Button(action: {
                        // Strong haptic feedback for primary action
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        navigationViewModel.navigateToBreathing()
                    }) {
                        HStack {
                            Text("START TRAINING")
                                .font(.title2)
                                .fontWeight(.bold)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                            
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .accessibilityHidden(true)
                        }
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
                    .accessibilityLabel("Start breathing training")
                    .accessibilityHint("Begins the breathing preparation and breath holding session")
                    .accessibilityAddTraits([.isButton, .startsMediaSession])
                    
                    // Quick stats for accessibility
                    if !isLoading && progressViewModel.recentSessions.count > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Sessions")
                                .font(.headline)
                                .foregroundColor(.white)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                .accessibilityAddTraits(.isHeader)
                            
                            ForEach(Array(progressViewModel.recentSessions.prefix(3).enumerated()), id: \.offset) { index, session in
                                HStack {
                                    Circle()
                                        .fill(sessionQualityColor(for: session.duration))
                                        .frame(width: 8, height: 8)
                                        .accessibilityHidden(true)
                                    
                                    Text("\(String(format: "%.1fs", session.duration))")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                                    
                                    Spacer()
                                    
                                    Text(session.date, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Session \(index + 1): \(String(format: "%.1f seconds", session.duration)), \(session.date, style: .relative)")
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Recent sessions summary")
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            progressViewModel.loadProgress()
            // Simulate loading for smooth animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isLoading = false
                }
            }
        }
        .accessibilityAction(named: "Start Training") {
            navigationViewModel.navigateToBreathing()
        }
        .accessibilityAction(named: "View Education") {
            navigationViewModel.navigateToEducation()
        }
    }
    
    private func sessionQualityColor(for duration: TimeInterval) -> Color {
        switch duration {
        case 0..<30: return .red.opacity(0.7)
        case 30..<60: return .orange.opacity(0.7)
        case 60..<90: return .yellow.opacity(0.7)
        default: return .green.opacity(0.7)
        }
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)
                .accessibilityHidden(true)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
} 