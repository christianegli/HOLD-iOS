import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var animateIn = false
    @State private var celebrateRecord = false
    @State private var showProgressChart = false
    @State private var pulseScale: CGFloat = 1.0
    
    var holdDuration: TimeInterval {
        navigationViewModel.sessionData?.holdDuration ?? 0
    }
    
    var isPersonalBest: Bool {
        holdDuration > progressViewModel.personalBest && progressViewModel.personalBest > 0
    }
    
    var improvementPercentage: Double {
        guard progressViewModel.personalBest > 0 else { return 0 }
        return ((holdDuration - progressViewModel.personalBest) / progressViewModel.personalBest) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // Hero Section with Personal Best Celebration
                VStack(spacing: 24) {
                    if isPersonalBest {
                        personalBestCelebration
                    } else {
                        standardCelebration
                    }
                    
                    // Main Duration Display
                    VStack(spacing: 12) {
                        Text("You held your breath for:")
                            .font(.holdBody)
                            .foregroundColor(.holdTextSecondary)
                            .opacity(animateIn ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateIn)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(format: "%.1f", holdDuration))
                                .font(.system(size: 72, weight: .bold, design: .monospaced))
                                .foregroundColor(.holdPrimary)
                                .scaleEffect(animateIn ? 1.0 : 0.8)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: animateIn)
                            
                            Text("sec")
                                .font(.holdHeading)
                                .foregroundColor(.holdTextSecondary)
                                .offset(y: 8)
                                .opacity(animateIn ? 1 : 0)
                                .animation(.easeInOut(duration: 0.6).delay(0.8), value: animateIn)
                        }
                        
                        // Improvement indicator
                        if progressViewModel.personalBest > 0 {
                            improvementIndicator
                        }
                    }
                }
                
                // Progress Visualization
                if showProgressChart {
                    progressVisualization
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Achievement Badges
                achievementBadges
                
                // Educational Benefits
                benefitsSection
                
                // Session Statistics
                sessionStats
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            setupAnimations()
            saveSession()
        }
    }
    
    // MARK: - Hero Sections
    
    private var personalBestCelebration: some View {
        VStack(spacing: 16) {
            // Animated trophy with confetti effect
            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(Color.holdAccent.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .offset(
                            x: cos(Double(index) * .pi / 6) * 60,
                            y: sin(Double(index) * .pi / 6) * 60
                        )
                        .scaleEffect(celebrateRecord ? 0.5 : 1.5)
                        .opacity(celebrateRecord ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5).delay(Double(index) * 0.1),
                            value: celebrateRecord
                        )
                }
                
                Text("🏆")
                    .font(.system(size: 80))
                    .scaleEffect(pulseScale)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: pulseScale
                    )
            }
            .frame(height: 120)
            
            Text("🎉 NEW PERSONAL BEST! 🎉")
                .font(.holdTitle)
                .fontWeight(.bold)
                .foregroundColor(.holdAccent)
                .multilineTextAlignment(.center)
                .scaleEffect(animateIn ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateIn)
            
            Text("+\(String(format: "%.1f%%", abs(improvementPercentage))) improvement!")
                .font(.holdHeading)
                .foregroundColor(.holdSuccess)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateIn)
        }
    }
    
    private var standardCelebration: some View {
        VStack(spacing: 16) {
            Text("🌟")
                .font(.system(size: 80))
                .scaleEffect(animateIn ? 1.0 : 0.7)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: animateIn)
            
            Text("Excellent Work!")
                .font(.holdTitle)
                .fontWeight(.bold)
                .foregroundColor(.holdTextPrimary)
                .scaleEffect(animateIn ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateIn)
        }
    }
    
    private var improvementIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: improvementPercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.holdCaption)
                .foregroundColor(improvementPercentage >= 0 ? .holdSuccess : .holdWarning)
            
            Text("\(improvementPercentage >= 0 ? "+" : "")\(String(format: "%.1f%%", improvementPercentage))")
                .font(.holdCaption)
                .foregroundColor(improvementPercentage >= 0 ? .holdSuccess : .holdWarning)
            
            Text("vs personal best")
                .font(.holdCaption)
                .foregroundColor(.holdTextTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .opacity(animateIn ? 1 : 0)
        .animation(.easeInOut(duration: 0.6).delay(1.0), value: animateIn)
    }
    
    // MARK: - Progress Visualization
    
    private var progressVisualization: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress Overview")
                    .font(.holdHeading)
                    .foregroundColor(.holdTextPrimary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                progressCard(
                    title: "Previous Best",
                    value: String(format: "%.1fs", progressViewModel.personalBest),
                    color: .holdTextSecondary
                )
                
                progressCard(
                    title: "This Session",
                    value: String(format: "%.1fs", holdDuration),
                    color: isPersonalBest ? .holdAccent : .holdPrimary
                )
                
                progressCard(
                    title: "Total Sessions",
                    value: "\(progressViewModel.totalSessions + 1)",
                    color: .holdSecondary
                )
            }
        }
        .padding(20)
        .background(.holdCard.opacity(0.6))
        .cornerRadius(16)
    }
    
    private func progressCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.holdHeading)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.holdCaption)
                .foregroundColor(.holdTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.holdSurface.opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Achievement Badges
    
    private var achievementBadges: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.holdHeading)
                    .foregroundColor(.holdTextPrimary)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                achievementBadge(
                    icon: "lungs.fill",
                    title: "Breath Master",
                    description: "Completed breathing session",
                    earned: true
                )
                
                achievementBadge(
                    icon: "timer",
                    title: "Endurance",
                    description: holdDuration >= 30 ? "30+ seconds" : "Building up",
                    earned: holdDuration >= 30
                )
                
                achievementBadge(
                    icon: "star.fill",
                    title: "Personal Best",
                    description: isPersonalBest ? "New record!" : "Keep trying",
                    earned: isPersonalBest
                )
                
                achievementBadge(
                    icon: "heart.fill",
                    title: "Wellness",
                    description: "Improved stress resilience",
                    earned: true
                )
            }
        }
        .padding(20)
        .background(.holdCard.opacity(0.4))
        .cornerRadius(16)
        .opacity(animateIn ? 1 : 0)
        .animation(.easeInOut(duration: 0.8).delay(1.2), value: animateIn)
    }
    
    private func achievementBadge(icon: String, title: String, description: String, earned: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(earned ? .holdAccent : .holdTextTertiary)
                .frame(width: 40, height: 40)
                .background(earned ? .holdAccent.opacity(0.2) : .holdSurface.opacity(0.3))
                .clipShape(Circle())
            
            Text(title)
                .font(.holdCaption)
                .fontWeight(.semibold)
                .foregroundColor(earned ? .holdTextPrimary : .holdTextTertiary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.holdTextTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(earned ? .holdSurface.opacity(0.6) : .holdSurface.opacity(0.3))
        .cornerRadius(12)
        .saturation(earned ? 1.0 : 0.5)
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Benefits Achieved")
                    .font(.holdHeading)
                    .foregroundColor(.holdTextPrimary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                benefitRow(icon: "brain.head.profile", text: "Enhanced cognitive function & focus", delay: 1.4)
                benefitRow(icon: "heart.fill", text: "Improved cardiovascular health", delay: 1.6)
                benefitRow(icon: "lungs.fill", text: "Increased lung capacity & efficiency", delay: 1.8)
                benefitRow(icon: "leaf.fill", text: "Boosted stress resilience & recovery", delay: 2.0)
            }
        }
        .padding(20)
        .background(.holdSuccess.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func benefitRow(icon: String, text: String, delay: Double) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.holdSuccess)
                .frame(width: 24)
            
            Text(text)
                .font(.holdBody)
                .foregroundColor(.holdTextSecondary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.holdSuccess)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(x: animateIn ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(delay), value: animateIn)
    }
    
    // MARK: - Session Statistics
    
    private var sessionStats: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Session Details")
                    .font(.holdHeading)
                    .foregroundColor(.holdTextPrimary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                statItem(title: "Protocol", value: "Box Breathing")
                statItem(title: "Prep Rounds", value: "4")
                statItem(title: "Duration", value: formatTime(holdDuration))
            }
        }
        .padding(20)
        .background(.holdCard.opacity(0.3))
        .cornerRadius(16)
        .opacity(animateIn ? 1 : 0)
        .animation(.easeInOut(duration: 0.8).delay(2.2), value: animateIn)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.holdCaption)
                .fontWeight(.semibold)
                .foregroundColor(.holdTextPrimary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.holdTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                navigationViewModel.navigateToBreathing()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    Text("Try Again")
                        .font(.holdHeading)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.holdTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.holdPrimary, .holdSecondary]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .accessibilityLabel("Try another breathing session")
            .scaleEffect(animateIn ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(2.4), value: animateIn)
            
            HStack(spacing: 12) {
                Button(action: {
                    navigationViewModel.navigateToEducation()
                }) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Learn More")
                    }
                    .font(.holdBody)
                    .foregroundColor(.holdTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.holdSurface.opacity(0.6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    navigationViewModel.navigateToHome()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .font(.holdBody)
                    .foregroundColor(.holdTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.holdSurface.opacity(0.6))
                    .cornerRadius(12)
                }
            }
            .opacity(animateIn ? 1 : 0)
            .animation(.easeInOut(duration: 0.6).delay(2.6), value: animateIn)
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupAnimations() {
        // Trigger main animation sequence
        withAnimation {
            animateIn = true
        }
        
        // Personal best celebration
        if isPersonalBest {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    celebrateRecord = true
                    pulseScale = 1.2
                }
            }
        }
        
        // Show progress chart after initial animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showProgressChart = true
            }
        }
    }
    
    private func saveSession() {
        // Save session data
        progressViewModel.addSession(
            duration: holdDuration,
            date: Date(),
            protocolType: "Box Breathing"
        )
        
        // Update navigation session data
        navigationViewModel.sessionData?.isPersonalBest = isPersonalBest
        navigationViewModel.sessionData?.improvementPercentage = improvementPercentage
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return String(format: "%.1fs", time)
        }
    }
} 