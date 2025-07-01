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
    @State private var breathingGlow: Double = 0.0
    @State private var phaseProgress: Double = 0.0
    @State private var showInstructions = true

    
    enum BreathingPhase: String, CaseIterable {
        case ready = "Ready"
        case inhale = "Inhale"
        case hold1 = "Hold Full"
        case exhale = "Exhale"
        case hold2 = "Hold Empty"
        case finalInhale = "Final Inhale"
        case finalExhale = "Final Exhale"
        
        var duration: TimeInterval {
            switch self {
            case .ready: return 3.0
            case .inhale, .hold1, .exhale, .hold2: return 4.0
            case .finalInhale: return 4.0
            case .finalExhale: return 2.0
            }
        }
        
        var instruction: String {
            switch self {
            case .ready: return "Prepare to begin breathing"
            case .inhale: return "Breathe in slowly and deeply"
            case .hold1: return "Hold your breath"
            case .exhale: return "Breathe out slowly and completely"
            case .hold2: return "Hold empty"
            case .finalInhale: return "Take your final deep breath"
            case .finalExhale: return "Exhale halfway and hold"
            }
        }
        
        var color: Color {
            switch self {
            case .ready: return .holdTextSecondary
            case .inhale: return .holdSuccess
            case .hold1: return .holdAccent
            case .exhale: return .holdSecondary
            case .hold2: return .holdWarning
            case .finalInhale: return .holdSuccess
            case .finalExhale: return .holdSecondary
            }
        }
        
        var targetScale: CGFloat {
            switch self {
            case .ready: return 1.0
            case .inhale: return 1.6
            case .hold1: return 1.6
            case .exhale: return 0.8
            case .hold2: return 0.8
            case .finalInhale: return 1.6
            case .finalExhale: return 1.0
            }
        }
        
        var accessibilityAnnouncement: String {
            switch self {
            case .ready: return "Get ready to start breathing exercise"
            case .inhale: return "Now inhaling for 4 seconds"
            case .hold1: return "Hold your breath for 4 seconds"
            case .exhale: return "Now exhaling for 4 seconds"
            case .hold2: return "Hold empty for 4 seconds"
            case .finalInhale: return "Take your final deep breath for 4 seconds"
            case .finalExhale: return "Exhale halfway for 2 seconds then hold"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Instructions overlay
            if showInstructions && !isActive {
                instructionsOverlay
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1)
            }
            

            
            // Main breathing interface
            VStack(spacing: 32) {
                // Enhanced header
                VStack(spacing: 16) {
                    Text("Box Breathing")
                        .font(.holdTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.holdTextPrimary)
                        .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Box Breathing Exercise")
                    
                    Text("4-4-4-4 Preparation")
                        .font(.holdBody)
                        .foregroundColor(.holdTextSecondary)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel("Four counts inhale, four counts hold, four counts exhale, four counts hold")
                    
                    // Enhanced progress indicator
                    progressIndicator
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Enhanced breathing circle
                breathingCircle
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Breathing guide circle showing \(currentPhase.rawValue) phase with \(String(format: "%.0f", max(0, timeRemaining))) seconds remaining")
                    .accessibilityValue("\(currentPhase.instruction)")
                
                Spacer()
                
                // Enhanced control buttons
                controlButtons
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 24)
        }
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
    
    // MARK: - Instructions Overlay
    
    private var instructionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🫁")
                    .font(.system(size: 60))
                
                Text("Box Breathing Guide")
                    .font(.holdTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.holdTextPrimary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    instructionStep(phase: "Inhale", duration: "4 seconds", description: "Breathe in slowly", color: .holdSuccess)
                    instructionStep(phase: "Hold", duration: "4 seconds", description: "Hold your breath", color: .holdAccent)
                    instructionStep(phase: "Exhale", duration: "4 seconds", description: "Breathe out slowly", color: .holdSecondary)
                    instructionStep(phase: "Hold", duration: "4 seconds", description: "Hold empty", color: .holdWarning)
                }
                .padding()
                .background(Color.holdCard.opacity(0.6))
                .cornerRadius(16)
                
                Text("You'll complete 4 rounds to prepare for the breath hold")
                    .font(.holdCaption)
                    .foregroundColor(.holdTextSecondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showInstructions = false
                    }
                }) {
                    Text("Got it!")
                        .font(.holdHeading)
                        .fontWeight(.semibold)
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
                .accessibilityLabel("Dismiss instructions and start breathing")
            }
            .padding(32)
        }
    }
    
    private func instructionStep(phase: String, duration: String, description: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phase)
                    .font(.holdCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.holdTextSecondary)
            }
            
            Spacer()
            
            Text(duration)
                .font(.holdCaption)
                .foregroundColor(.holdTextTertiary)
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Round \(currentRound) of \(totalRounds)")
                    .font(.holdHeading)
                    .foregroundColor(.holdPrimary)
                    .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                    .accessibilityLabel("Currently on round \(currentRound) of \(totalRounds) total rounds")
                
                Spacer()
                
                if isActive {
                    Text(currentPhase.rawValue.uppercased())
                        .font(.holdCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(currentPhase.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(currentPhase.color.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Progress bar
            HStack(spacing: 8) {
                ForEach(1...totalRounds, id: \.self) { round in
                    Rectangle()
                        .fill(round < currentRound ? .holdSuccess : 
                              round == currentRound ? .holdPrimary : .holdTextTertiary.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: currentRound)
                }
            }
            .accessibilityHidden(true) // Redundant with round text
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Breathing Circle
    
    private var breathingCircle: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        currentPhase.color.opacity(0.3 - Double(index) * 0.1),
                        lineWidth: 2
                    )
                    .frame(width: 320 + CGFloat(index) * 40, height: 320 + CGFloat(index) * 40)
                    .scaleEffect(circleScale * (1.0 + Double(index) * 0.1))
                    .opacity(breathingGlow * (1.0 - Double(index) * 0.3))
                    .animation(.easeInOut(duration: currentPhase.duration), value: circleScale)
            }
            
            // Main breathing circle
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                currentPhase.color.opacity(0.2),
                                currentPhase.color.opacity(0.05),
                                .clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(circleScale)
                    .animation(.easeInOut(duration: currentPhase.duration), value: circleScale)
                
                // Breathing guide circle
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: currentPhase.color, location: 0.0),
                                .init(color: currentPhase.color.opacity(0.8), location: 0.5),
                                .init(color: currentPhase.color, location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(circleScale)
                    .animation(.easeInOut(duration: currentPhase.duration), value: circleScale)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(
                        currentPhase.color.opacity(0.8),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(circleScale)
                    .animation(.linear(duration: 0.1), value: phaseProgress)
                
                // Center content
                VStack(spacing: 16) {
                    // Phase indicator
                    Text(currentPhase.rawValue.uppercased())
                        .font(.holdTitle)
                        .fontWeight(.bold)
                        .foregroundColor(currentPhase.color)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel("Current phase: \(currentPhase.rawValue)")
                    
                    // Timer display
                    Text(String(format: "%.0f", max(0, timeRemaining)))
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(.holdTextPrimary)
                        .dynamicTypeSize(.large...DynamicTypeSize.accessibility2)
                        .accessibilityLabel("Time remaining: \(String(format: "%.0f seconds", max(0, timeRemaining)))")
                    
                    // Instruction text
                    Text(currentPhase.instruction)
                        .font(.holdCaption)
                        .foregroundColor(.holdTextSecondary)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        .accessibilityLabel(currentPhase.instruction)
                }
            }
        }
        .frame(width: 360, height: 360)
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            if !isActive {
                Button(action: startBreathing) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text("Start Breathing")
                            .font(.holdHeading)
                            .fontWeight(.semibold)
                            .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                    }
                    .foregroundColor(.holdTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.holdSuccess, .holdSuccess.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .accessibilityLabel("Start breathing exercise")
                .accessibilityHint("Begins the 4-round box breathing preparation")
                .accessibilityAddTraits(.isButton)
            } else {
                HStack(spacing: 16) {
                    Button(action: togglePause) {
                        HStack {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.title3)
                                .accessibilityHidden(true)
                            Text(isPaused ? "Resume" : "Pause")
                                .font(.holdBody)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        }
                        .foregroundColor(.holdTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.holdWarning.opacity(0.8))
                        .cornerRadius(12)
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
                                .font(.holdBody)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                        }
                        .foregroundColor(.holdTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.holdPrimary.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Skip to breath hold")
                    .accessibilityHint("Skip remaining breathing rounds and go directly to breath holding")
                    .accessibilityAddTraits(.isButton)
                }
            }
            
            // Emergency stop button
            if isActive {
                Button(action: stopBreathing) {
                    HStack {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text("Stop")
                            .font(.holdCaption)
                            .fontWeight(.semibold)
                            .dynamicTypeSize(.medium...DynamicTypeSize.accessibility1)
                    }
                    .foregroundColor(.holdTextPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.holdError.opacity(0.8))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Stop breathing exercise")
                .accessibilityHint("Immediately stops the breathing exercise and returns to home")
                .accessibilityAddTraits(.isButton)
            }
        }
    }
    
    // MARK: - Final Breath Overlay
    

    

    
    // MARK: - Breathing Exercise Logic
    
    private func setupBreathingExercise() {
        currentRound = 1
        currentPhase = .ready
        timeRemaining = currentPhase.duration
        isActive = false
        isPaused = false
        circleScale = 1.0
        breathingGlow = 0.3
        phaseProgress = 0.0
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
                
                // Update progress
                let totalDuration = currentPhase.duration
                phaseProgress = 1.0 - (timeRemaining / totalDuration)
                
                // Update visual effects
                updateVisualEffects()
                
                if timeRemaining <= 0 {
                    advancePhase()
                }
            }
        }
    }
    
    private func updateVisualEffects() {
        // Update breathing glow based on phase
        let glowIntensity = currentPhase == .inhale || currentPhase == .exhale ? 0.8 : 0.4
        withAnimation(.easeInOut(duration: 0.3)) {
            breathingGlow = glowIntensity
        }
    }
    
    private func advancePhase() {
        // Haptic feedback for phase transitions
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        switch currentPhase {
        case .ready:
            currentPhase = .inhale
            
        case .inhale:
            currentPhase = .hold1
            
        case .hold1:
            currentPhase = .exhale
            
        case .exhale:
            currentPhase = .hold2
            
        case .hold2:
            if currentRound < totalRounds {
                // Move directly to the next round (skip the old "complete" pause)
                currentRound += 1
                currentPhase = .inhale
                // Accessibility announcement for new round
                UIAccessibility.post(notification: .announcement, argument: "Round \(currentRound) of \(totalRounds) starting")
            } else {
                // All rounds complete – proceed to final inhale
                currentPhase = .finalInhale
                UIAccessibility.post(notification: .announcement, argument: "Final breath preparation")
            }
            
        case .finalInhale:
            // Move to final exhale
            currentPhase = .finalExhale
            
        case .finalExhale:
            // Final breath complete – proceed to breath hold
            completeBreathing()
            return
        }
        
        // Update circle scale and reset timer
        withAnimation(.easeInOut(duration: currentPhase.duration)) {
            circleScale = currentPhase.targetScale
        }
        
        timeRemaining = currentPhase.duration
        phaseProgress = 0.0
        
        // Live accessibility announcements
        UIAccessibility.post(notification: .announcement, argument: currentPhase.accessibilityAnnouncement)
    }
    
    private func completeBreathing() {
        timer?.invalidate()
        isActive = false
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Navigate directly to hold view
        UIAccessibility.post(notification: .announcement, argument: "Breathing preparation complete. Starting breath hold.")
        
        navigationViewModel.navigateToHold()
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
