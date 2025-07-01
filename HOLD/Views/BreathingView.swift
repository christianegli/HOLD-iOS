import SwiftUI

struct BreathingView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State private var currentRound = 1
    @State private var totalRounds = 4
    @State private var currentPhase: BreathingPhase = .ready
    @State private var timeRemaining = 4.0
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var isPaused = false
    @State private var circleScale: CGFloat = 1.0
    
    enum BreathingPhase: String, CaseIterable {
        case ready = "Ready"
        case inhale = "Inhale"
        case hold1 = "Hold"
        case exhale = "Exhale"
        case hold2 = "Hold"
        case complete = "Complete"
        
        var duration: TimeInterval {
            switch self {
            case .ready: return 3.0
            case .inhale, .hold1, .exhale, .hold2: return 4.0
            case .complete: return 2.0
            }
        }
        
        var instruction: String {
            switch self {
            case .ready: return "Prepare to begin breathing"
            case .inhale: return "Breathe in slowly and deeply"
            case .hold1: return "Hold your breath"
            case .exhale: return "Breathe out slowly and completely"
            case .hold2: return "Hold empty"
            case .complete: return "Round complete"
            }
        }
        
        var accessibilityAnnouncement: String {
            switch self {
            case .ready: return "Get ready to start breathing exercise"
            case .inhale: return "Now inhaling for 4 seconds"
            case .hold1: return "Hold your breath for 4 seconds"
            case .exhale: return "Now exhaling for 4 seconds"
            case .hold2: return "Hold empty for 4 seconds"
            case .complete: return "Round \(self) finished"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header with accessibility
            VStack(spacing: 12) {
                Text("Box Breathing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Box Breathing Exercise")
                
                Text("4-4-4-4 Preparation")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                    .accessibilityLabel("Four counts inhale, four counts hold, four counts exhale, four counts hold")
                
                // Progress indicator
                HStack {
                    Text("Round \(currentRound) of \(totalRounds)")
                        .font(.headline)
                        .foregroundColor(.cyan)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel("Currently on round \(currentRound) of \(totalRounds) total rounds")
                    
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(1...totalRounds, id: \.self) { round in
                            Circle()
                                .fill(round <= currentRound ? Color.cyan : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .accessibilityHidden(true) // Redundant with round text
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Breathing Circle with accessibility
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.cyan.opacity(0.1))
                    .frame(width: 280, height: 280)
                
                // Animated breathing circle
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.cyan, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale)
                    .animation(.easeInOut(duration: currentPhase.duration), value: circleScale)
                
                // Center content
                VStack(spacing: 16) {
                    // Phase indicator
                    Text(currentPhase.rawValue.uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel("Current phase: \(currentPhase.rawValue)")
                    
                    // Timer display
                    Text(String(format: "%.0f", max(0, timeRemaining)))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                        .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                        .accessibilityLabel("Time remaining: \(String(format: "%.0f seconds", max(0, timeRemaining)))")
                    
                    // Instruction text
                    Text(currentPhase.instruction)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel(currentPhase.instruction)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Breathing guide circle showing \(currentPhase.rawValue) phase with \(String(format: "%.0f", max(0, timeRemaining))) seconds remaining")
            .accessibilityValue("\(currentPhase.instruction)")
            
            Spacer()
            
            // Control buttons with enhanced accessibility
            VStack(spacing: 16) {
                if !isActive {
                    Button(action: startBreathing) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .accessibilityHidden(true)
                            Text("Start Breathing")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .mint]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                    .accessibilityLabel("Start breathing exercise")
                    .accessibilityHint("Begins the 4-round box breathing preparation")
                    .accessibilityAddTraits(.isButton)
                } else {
                    HStack(spacing: 20) {
                        Button(action: togglePause) {
                            HStack {
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    .font(.title3)
                                    .accessibilityHidden(true)
                                Text(isPaused ? "Resume" : "Pause")
                                    .font(.headline)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(20)
                        }
                        .accessibilityLabel(isPaused ? "Resume breathing exercise" : "Pause breathing exercise")
                        .accessibilityHint(isPaused ? "Continues the breathing exercise" : "Pauses the breathing exercise")
                        .accessibilityAddTraits(.isButton)
                        
                        Button(action: skipToHold) {
                            HStack {
                                Image(systemName: "forward.fill")
                                    .font(.title3)
                                    .accessibilityHidden(true)
                                Text("Skip to Hold")
                                    .font(.headline)
                                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.cyan)
                            .cornerRadius(20)
                        }
                        .accessibilityLabel("Skip to breath hold")
                        .accessibilityHint("Skip remaining breathing rounds and go directly to breath holding")
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }
            
            // Emergency stop button for accessibility
            if isActive {
                Button(action: stopBreathing) {
                    HStack {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text("Stop")
                            .font(.headline)
                            .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(15)
                }
                .accessibilityLabel("Stop breathing exercise")
                .accessibilityHint("Immediately stops the breathing exercise and returns to home")
                .accessibilityAddTraits(.isButton)
            }
            
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupBreathingExercise()
        }
        .onDisappear {
            cleanup()
        }
        .accessibilityAction(named: "Start Breathing") {
            if !isActive {
                startBreathing()
            }
        }
        .accessibilityAction(named: "Pause") {
            if isActive && !isPaused {
                togglePause()
            }
        }
        .accessibilityAction(named: "Resume") {
            if isActive && isPaused {
                togglePause()
            }
        }
        .accessibilityAction(named: "Skip to Hold") {
            if isActive {
                skipToHold()
            }
        }
    }
    
    // MARK: - Breathing Exercise Logic
    
    private func setupBreathingExercise() {
        currentRound = 1
        currentPhase = .ready
        timeRemaining = currentPhase.duration
        isActive = false
        isPaused = false
        circleScale = 1.0
    }
    
    private func startBreathing() {
        isActive = true
        isPaused = false
        currentPhase = .ready
        timeRemaining = currentPhase.duration
        
        // Initial haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Accessibility announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .announcement, argument: "Starting box breathing exercise. Round 1 of 4.")
        }
        
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !isPaused {
                timeRemaining -= 0.1
                
                if timeRemaining <= 0 {
                    advancePhase()
                }
            }
        }
    }
    
    private func advancePhase() {
        // Haptic feedback for phase transitions
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        switch currentPhase {
        case .ready:
            currentPhase = .inhale
            circleScale = 1.4
            
        case .inhale:
            currentPhase = .hold1
            
        case .hold1:
            currentPhase = .exhale
            circleScale = 1.0
            
        case .exhale:
            currentPhase = .hold2
            
        case .hold2:
            currentPhase = .complete
            
        case .complete:
            if currentRound < totalRounds {
                currentRound += 1
                currentPhase = .inhale
                circleScale = 1.4
                
                // Accessibility announcement for new round
                UIAccessibility.post(notification: .announcement, argument: "Round \(currentRound) of \(totalRounds) starting")
            } else {
                // All rounds complete
                completeBreathing()
                return
            }
        }
        
        timeRemaining = currentPhase.duration
        
        // Live accessibility announcements
        UIAccessibility.post(notification: .announcement, argument: currentPhase.accessibilityAnnouncement)
    }
    
    private func completeBreathing() {
        timer?.invalidate()
        isActive = false
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Final accessibility announcement
        UIAccessibility.post(notification: .announcement, argument: "Breathing preparation complete. Ready for breath hold.")
        
        // Navigate to hold view after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            navigationViewModel.navigateToHold()
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let announcement = isPaused ? "Breathing exercise paused" : "Breathing exercise resumed"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    private func skipToHold() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        UIAccessibility.post(notification: .announcement, argument: "Skipping to breath hold")
        
        cleanup()
        navigationViewModel.navigateToHold()
    }
    
    private func stopBreathing() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        UIAccessibility.post(notification: .announcement, argument: "Breathing exercise stopped")
        
        cleanup()
        navigationViewModel.navigateToHome()
    }
    
    private func cleanup() {
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false
    }
}
