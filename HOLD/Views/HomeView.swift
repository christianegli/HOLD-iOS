import SwiftUI

struct GradientCircleIcon: View {
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.8, green: 1.0, blue: 0.8), Color(red: 0.6, green: 0.8, blue: 1.0)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 2)
            )
    }
}

struct HomeView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            mainContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await progressViewModel.loadProgress()
            }
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
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 24) {
            HeaderSection()
            if !isLoading {
                ProgressSection(progressViewModel: progressViewModel)
            }
            ActionButtonsSection()
            if !isLoading && progressViewModel.recentSessions.count > 0 {
                RecentSessionsSection(progressViewModel: progressViewModel)
            }
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sub-Views
    private struct HeaderSection: View {
        var body: some View {
            VStack(spacing: 12) {
                GradientCircleIcon()
                    .frame(width: 120, height: 120)
                    .accessibilityHidden(true)
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
        }
    }
    
    private struct ProgressSection: View {
        @ObservedObject var progressViewModel: ProgressViewModel
        var body: some View {
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
                    ProgressStatCard(title: "Personal Best", value: String(format: "%.1fs", progressViewModel.personalBest), icon: "🏆", color: .yellow)
                    ProgressStatCard(title: "Sessions", value: "\(progressViewModel.totalSessions)", icon: "📊", color: .cyan)
                    ProgressStatCard(title: "Streak", value: "\(progressViewModel.currentStreak)", icon: "🔥", color: .orange)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
        }
    }
    
    private struct ActionButtonsSection: View {
        @EnvironmentObject var navigationViewModel: NavigationViewModel
        var body: some View {
            VStack(spacing: 16) {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    navigationViewModel.navigateToEducation()
                }) {
                    HStack(spacing: 12) {
                        Text("🧠").font(.title2).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Learn & Improve").font(.headline)
                            Text("Breathing techniques and benefits").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).accessibilityHidden(true)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.cyan.opacity(0.3))
                    .cornerRadius(12)
                }
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    navigationViewModel.navigateToBreathing()
                }) {
                    HStack {
                        Text("START TRAINING").font(.title2).fontWeight(.bold)
                        Image(systemName: "play.fill").font(.title3).accessibilityHidden(true)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(25)
                }
            }
        }
    }
    
    private struct RecentSessionsSection: View {
        @ObservedObject var progressViewModel: ProgressViewModel
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Sessions")
                    .font(.headline)
                    .foregroundColor(.white)
                ForEach(Array(progressViewModel.recentSessions.prefix(3).enumerated()), id: \.offset) { index, session in
                    HStack {
                        Circle().fill(sessionQualityColor(for: session.holdDuration)).frame(width: 8, height: 8)
                        Text(String(format: "%.1fs", session.holdDuration)).foregroundColor(.white)
                        Spacer()
                        Text((session.completedAt ?? session.startedAt), style: .relative).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
        }
        private func sessionQualityColor(for duration: TimeInterval) -> Color {
            switch duration {
            case 60...: return .holdSuccess
            case 30..<60: return .holdPrimary
            default: return .holdWarning
            }
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