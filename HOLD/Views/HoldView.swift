import SwiftUI

struct HoldView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isHolding = false
    @State private var circleScale: CGFloat = 1.0
    @State private var lastMilestoneAnnounced: Int = 0
    @State private var personalBest: TimeInterval = 0
    @State private var isNewRecord = false
    @State private var backgroundColorIntensity: Double = 0.0
    
    private let milestones = [10, 20, 30, 45, 60, 90, 120, 180]
    
    var body: some View {
        ZStack {
            // Dynamic background that responds to hold duration
            LinearGradient(
                gradient: Gradient(colors: [
                    .black,
                    Color.cyan.opacity(backgroundColorIntensity * 0.3),
                    Color.blue.opacity(backgroundColorIntensity * 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header with accessibility
                VStack(spacing: 16) {
                    Text("HOLD")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Breath Hold Exercise")
                    
                    if !isHolding {
                        VStack(spacing: 8) {
                            Text("Hold starting...")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                .accessibilityLabel("Breath hold starting")
                            
                            if personalBest > 0 {
                                Text("Beat: \(String(format: "%.1fs", personalBest))")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                    .accessibilityLabel("Goal: beat \(String(format: "%.1f seconds", personalBest))")
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            if isNewRecord {
                                Text("🎉 NEW RECORD! 🎉")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                    .accessibilityLabel("New personal record!")
                                    .scaleEffect(1.1)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isNewRecord)
                            } else if elapsedTime > personalBest * 0.8 && personalBest > 0 {
                                Text("You're doing great!")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                    .accessibilityLabel("You're doing great!")
                            } else {
                                Text("Keep holding...")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                                    .accessibilityLabel("Keep holding your breath")
                            }
                            
                            if personalBest > 0 {
                                Text("Beat: \(String(format: "%.1fs", personalBest))")
                                    .font(.caption)
                                    .foregroundColor(.yellow.opacity(0.8))
                                    .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                                    .accessibilityLabel("Goal: beat \(String(format: "%.1f seconds", personalBest))")
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Expandable Timer Circle
                ZStack {
                    // Background glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    .cyan.opacity(0.3),
                                    .cyan.opacity(0.1),
                                    .clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .scaleEffect(circleScale * 0.5)
                        .opacity(isHolding ? 0.8 : 0.3)
                    
                    // Main timer circle
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.cyan, .blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 8
                                )
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: 2.0), value: circleScale)
                    
                    // Timer display
                    VStack(spacing: 12) {
                        Text(String(format: "%.1f", elapsedTime))
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .dynamicTypeSize(.large...DynamicTypeSize.accessibility3)
                            .accessibilityLabel("Current time: \(String(format: "%.1f seconds", elapsedTime))")
                        
                        Text("seconds")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Breath hold timer showing \(String(format: "%.1f seconds", elapsedTime))")
                .accessibilityValue(isHolding ? "Currently holding breath" : "Ready to start")
                
                Spacer()
                
                // Control Buttons with Enhanced Accessibility
                VStack(spacing: 20) {
                    if !isHolding {
                        // Auto-starting - show safety info only
                        VStack(spacing: 4) {
                            Text("⚠️ Safety First")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                                .accessibilityLabel("Safety reminder:")
                            
                            Text("Only hold as long as comfortable")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                                .accessibilityLabel("Only hold your breath as long as comfortable")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isSummaryElement)
                        
                    } else {
                        Button(action: stopHolding) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                    .font(.title2)
                                    .accessibilityHidden(true)
                                Text("RELEASE")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 25)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(35)
                            .scaleEffect(1.05)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isHolding)
                        }
                        .accessibilityLabel("Release breath")
                        .accessibilityHint("Stop holding your breath and see your results")
                        .accessibilityAddTraits([.isButton, .playsSound])
                        
                        // Emergency stop instructions for accessibility
                        Text("Tap anywhere to release if needed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .dynamicTypeSize(.small...DynamicTypeSize.accessibility1)
                            .accessibilityLabel("Emergency instruction: tap anywhere on screen to release if needed")
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
        }
        .onTapGesture {
            // Emergency release - tap anywhere during hold
            if isHolding {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
                UIAccessibility.post(notification: .announcement, argument: "Emergency release activated")
                stopHolding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupHoldView()
        }
        .onDisappear {
            cleanup()
        }
        .accessibilityAction(named: "Start Hold") {
            if !isHolding {
                startHolding()
            }
        }
        .accessibilityAction(named: "Release Breath") {
            if isHolding {
                stopHolding()
            }
        }
        .accessibilityAction(named: "Emergency Stop") {
            if isHolding {
                UIAccessibility.post(notification: .announcement, argument: "Emergency stop activated")
                stopHolding()
            }
        }
    }
    
    // MARK: - Hold Logic
    
    private func setupHoldView() {
        elapsedTime = 0
        isHolding = false
        circleScale = 1.0
        lastMilestoneAnnounced = 0
        isNewRecord = false
        backgroundColorIntensity = 0.0
        
        // Load personal best from progress
        Task {
            await progressViewModel.loadProgress()
            // Capture updated personal best on main thread
            personalBest = progressViewModel.personalBest
        }
        
        // Auto-start the hold since we're coming from final breath sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startHolding()
        }
    }
    
    private func startHolding() {
        isHolding = true
        elapsedTime = 0
        lastMilestoneAnnounced = 0
        isNewRecord = false
        
        // Initial haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Accessibility announcement
        UIAccessibility.post(notification: .announcement, argument: "Breath hold started. Timer running.")
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
            updateVisualEffects()
            checkMilestones()
            checkNewRecord()
        }
        
        // Animate circle growth
        withAnimation(.easeInOut(duration: 3.0)) {
            circleScale = 1.5
        }
    }
    
    private func updateVisualEffects() {
        // Gradually increase background intensity
        let intensity = min(elapsedTime / 120.0, 1.0) // Max intensity at 2 minutes
        withAnimation(.easeInOut(duration: 0.5)) {
            backgroundColorIntensity = intensity
        }
        
        // Pulse circle scale based on time
        let pulseFactor = sin(elapsedTime * 0.5) * 0.1 + 1.0
        circleScale = 1.5 + (elapsedTime / 60.0) * 0.5 + pulseFactor * 0.05
    }
    
    private func checkMilestones() {
        let currentSeconds = Int(elapsedTime)
        
        for milestone in milestones {
            if currentSeconds >= milestone && milestone > lastMilestoneAnnounced {
                lastMilestoneAnnounced = milestone
                
                // Milestone haptic feedback
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                // Milestone accessibility announcement
                let announcement = "\(milestone) seconds! Keep going!"
                UIAccessibility.post(notification: .announcement, argument: announcement)
                
                // Visual milestone effect
                withAnimation(.easeInOut(duration: 0.5)) {
                    circleScale += 0.1
                }
                
                break
            }
        }
    }
    
    private func checkNewRecord() {
        if !isNewRecord && personalBest > 0 && elapsedTime > personalBest {
            isNewRecord = true
            
            // New record haptic feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            // New record accessibility announcement
            UIAccessibility.post(notification: .announcement, argument: "New personal record! You've beaten your previous best!")
            
            // Visual celebration
            withAnimation(.spring(response: 0.6, dampingFraction: 0.3)) {
                circleScale += 0.3
            }
        }
    }
    
    private func stopHolding() {
        timer?.invalidate()
        isHolding = false
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Final accessibility announcement
        let resultAnnouncement = isNewRecord 
            ? "Breath hold complete! New record: \(String(format: "%.1f seconds", elapsedTime))"
            : "Breath hold complete: \(String(format: "%.1f seconds", elapsedTime))"
        
        UIAccessibility.post(notification: .announcement, argument: resultAnnouncement)
        
        // Navigate to results after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigationViewModel.navigateToResults(holdDuration: elapsedTime)
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        timer = nil
        isHolding = false
    }
    
    // MARK: - Emergency Features for Accessibility
    
    private func emergencyStop() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        UIAccessibility.post(notification: .announcement, argument: "Emergency stop. Session ended safely.")
        
        cleanup()
        navigationViewModel.navigateToHome()
    }
} 