import Foundation
import SwiftUI
import AVFoundation

// MARK: - Session Interruption Types

enum InterruptionType {
    case appBackgrounded
    case phoneCall
    case systemAlert
    case lowBattery
    case userInitiated
    case emergencyStop
    case timerFailure
    
    var priority: Int {
        switch self {
        case .emergencyStop: return 0
        case .phoneCall: return 1
        case .systemAlert: return 2
        case .lowBattery: return 3
        case .appBackgrounded: return 4
        case .userInitiated: return 5
        case .timerFailure: return 6
        }
    }
    
    var shouldAutoResume: Bool {
        switch self {
        case .appBackgrounded, .systemAlert, .lowBattery: return true
        case .phoneCall, .userInitiated, .emergencyStop, .timerFailure: return false
        }
    }
    
    var userMessage: String {
        switch self {
        case .appBackgrounded:
            return "Session paused while app was in background"
        case .phoneCall:
            return "Session interrupted by phone call"
        case .systemAlert:
            return "Session interrupted by system alert"
        case .lowBattery:
            return "Session paused due to low battery"
        case .userInitiated:
            return "Session paused by user"
        case .emergencyStop:
            return "Session stopped for safety"
        case .timerFailure:
            return "Session interrupted due to technical issue"
        }
    }
}

// MARK: - Session State

enum SessionState {
    case idle
    case breathing(round: Int, phase: String, timeRemaining: TimeInterval)
    case holding(duration: TimeInterval, personalBest: TimeInterval)
    case interrupted(type: InterruptionType, savedState: SessionState)
    case completed(duration: TimeInterval)
    case error(description: String)
    
    var isActive: Bool {
        switch self {
        case .breathing, .holding: return true
        default: return false
        }
    }
    
    var canRecover: Bool {
        switch self {
        case .interrupted(let type, _): return type.shouldAutoResume
        default: return false
        }
    }
}

// MARK: - Session Recovery Data

struct SessionRecoveryData: Codable {
    let sessionId: UUID
    let startTime: Date
    let interruptionTime: Date
    let sessionState: SessionStateData
    let elapsedTime: TimeInterval
    
    struct SessionStateData: Codable {
        let type: String
        let round: Int?
        let phase: String?
        let timeRemaining: TimeInterval?
        let holdDuration: TimeInterval?
        let personalBest: TimeInterval?
    }
}

// MARK: - Session Interruption Manager

class SessionInterruptionManager: ObservableObject {
    static let shared = SessionInterruptionManager()
    
    @Published var currentState: SessionState = .idle
    @Published var hasRecoverableSession = false
    @Published var lastInterruption: InterruptionType?
    @Published var backgroundTime: Date?
    @Published var canShowRecoveryPrompt = false
    
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    private let recoveryDataKey = "SessionRecoveryData"
    private let maxRecoveryTimeInterval: TimeInterval = 300 // 5 minutes
    private var interruptionObservers: [NSObjectProtocol] = []
    
    init() {
        setupNotifications()
        checkForRecoverableSession()
    }
    
    // MARK: - Notification Setup
    
    private func setupNotifications() {
        // App lifecycle notifications
        let willResignActive = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillResignActive()
        }
        
        let didBecomeActive = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppDidBecomeActive()
        }
        
        let didEnterBackground = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppDidEnterBackground()
        }
        
        let willEnterForeground = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillEnterForeground()
        }
        
        // Audio session interruptions
        let audioInterruption = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioSessionInterruption(notification)
        }
        
        // Battery level notifications
        let batteryLevelChanged = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkBatteryLevel()
        }
        
        interruptionObservers = [
            willResignActive,
            didBecomeActive,
            didEnterBackground,
            willEnterForeground,
            audioInterruption,
            batteryLevelChanged
        ]
        
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    // MARK: - Session Management
    
    func startSession() {
        clearRecoveryData()
        currentState = .idle
        hasRecoverableSession = false
        canShowRecoveryPrompt = false
        print("🎯 Session started - monitoring for interruptions")
    }
    
    func updateSessionState(_ newState: SessionState) {
        currentState = newState
        
        // Save recovery data for active sessions
        if newState.isActive {
            saveRecoveryData()
        }
    }
    
    func endSession() {
        currentState = .idle
        clearRecoveryData()
        hasRecoverableSession = false
        canShowRecoveryPrompt = false
        print("✅ Session ended - recovery data cleared")
    }
    
    func handleEmergencyStop() {
        if currentState.isActive {
            let savedState = currentState
            currentState = .interrupted(type: .emergencyStop, savedState: savedState)
            clearRecoveryData() // Emergency stops shouldn't be recoverable
            
            // Provide haptic feedback
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
            
            print("🚨 Emergency stop triggered")
        }
    }
    
    // MARK: - App Lifecycle Handlers
    
    private func handleAppWillResignActive() {
        if currentState.isActive {
            print("⚠️ App will resign active during session")
            interruptSession(.appBackgrounded)
        }
    }
    
    private func handleAppDidBecomeActive() {
        if let backgroundTime = backgroundTime {
            let backgroundDuration = Date().timeIntervalSince(backgroundTime)
            print("📱 App became active after \(backgroundDuration)s in background")
            
            if backgroundDuration > maxRecoveryTimeInterval {
                print("⏰ Background time exceeded recovery limit - clearing session")
                clearRecoveryData()
                hasRecoverableSession = false
            }
        }
        
        self.backgroundTime = nil
    }
    
    private func handleAppDidEnterBackground() {
        backgroundTime = Date()
        
        if currentState.isActive {
            print("📱 App entered background during active session")
            interruptSession(.appBackgrounded)
            saveRecoveryData()
        }
    }
    
    private func handleAppWillEnterForeground() {
        checkForRecoverableSession()
    }
    
    // MARK: - Audio Session Interruption
    
    private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            if currentState.isActive {
                print("🔊 Audio session interrupted")
                interruptSession(.phoneCall)
            }
            
        case .ended:
            if case .interrupted(let interruptionType, _) = currentState,
               interruptionType == .phoneCall {
                print("🔊 Audio session interruption ended")
                // Don't auto-resume after phone calls for safety
            }
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Battery Monitoring
    
    private func checkBatteryLevel() {
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel < 0.10 && batteryLevel > 0 && currentState.isActive {
            print("🔋 Low battery detected during session")
            interruptSession(.lowBattery)
        }
    }
    
    // MARK: - Interruption Handling
    
    private func interruptSession(_ type: InterruptionType) {
        guard currentState.isActive else { return }
        
        let savedState = currentState
        currentState = .interrupted(type: type, savedState: savedState)
        lastInterruption = type
        
        print("⏸️ Session interrupted: \(type.userMessage)")
        
        // Provide appropriate feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        
        // Save recovery data if appropriate
        if type.shouldAutoResume {
            saveRecoveryData()
            hasRecoverableSession = true
        }
    }
    
    func resumeInterruptedSession() -> SessionState? {
        guard case .interrupted(let type, let savedState) = currentState,
              type.shouldAutoResume else {
            return nil
        }
        
        print("▶️ Resuming interrupted session")
        currentState = savedState
        hasRecoverableSession = false
        
        // Clear interruption data
        lastInterruption = nil
        
        return savedState
    }
    
    func discardInterruptedSession() {
        print("🗑️ Discarding interrupted session")
        currentState = .idle
        clearRecoveryData()
        hasRecoverableSession = false
        canShowRecoveryPrompt = false
        lastInterruption = nil
    }
    
    // MARK: - Recovery Data Management
    
    private func saveRecoveryData() {
        let recoveryData = createRecoveryData()
        
        do {
            let data = try JSONEncoder().encode(recoveryData)
            UserDefaults.standard.set(data, forKey: recoveryDataKey)
            print("💾 Recovery data saved")
        } catch {
            print("❌ Failed to save recovery data: \(error)")
        }
    }
    
    private func createRecoveryData() -> SessionRecoveryData {
        let sessionStateData: SessionRecoveryData.SessionStateData
        
        switch currentState {
        case .breathing(let round, let phase, let timeRemaining):
            sessionStateData = SessionRecoveryData.SessionStateData(
                type: "breathing",
                round: round,
                phase: phase,
                timeRemaining: timeRemaining,
                holdDuration: nil,
                personalBest: nil
            )
        case .holding(let duration, let personalBest):
            sessionStateData = SessionRecoveryData.SessionStateData(
                type: "holding",
                round: nil,
                phase: nil,
                timeRemaining: nil,
                holdDuration: duration,
                personalBest: personalBest
            )
        case .interrupted(_, let savedState):
            // Recursive call for nested interrupted state
            let tempState = currentState
            currentState = savedState
            let recoveryData = createRecoveryData()
            currentState = tempState
            return recoveryData
        default:
            sessionStateData = SessionRecoveryData.SessionStateData(
                type: "unknown",
                round: nil,
                phase: nil,
                timeRemaining: nil,
                holdDuration: nil,
                personalBest: nil
            )
        }
        
        return SessionRecoveryData(
            sessionId: UUID(),
            startTime: Date(),
            interruptionTime: Date(),
            sessionState: sessionStateData,
            elapsedTime: 0
        )
    }
    
    private func loadRecoveryData() -> SessionRecoveryData? {
        guard let data = UserDefaults.standard.data(forKey: recoveryDataKey) else {
            return nil
        }
        
        do {
            let recoveryData = try JSONDecoder().decode(SessionRecoveryData.self, from: data)
            
            // Check if recovery data is still valid (within time limit)
            let timeSinceInterruption = Date().timeIntervalSince(recoveryData.interruptionTime)
            guard timeSinceInterruption <= maxRecoveryTimeInterval else {
                print("⏰ Recovery data expired - clearing")
                clearRecoveryData()
                return nil
            }
            
            return recoveryData
        } catch {
            print("❌ Failed to load recovery data: \(error)")
            clearRecoveryData()
            return nil
        }
    }
    
    private func clearRecoveryData() {
        UserDefaults.standard.removeObject(forKey: recoveryDataKey)
        print("🗑️ Recovery data cleared")
    }
    
    private func checkForRecoverableSession() {
        guard let recoveryData = loadRecoveryData() else {
            hasRecoverableSession = false
            canShowRecoveryPrompt = false
            return
        }
        
        hasRecoverableSession = true
        
        // Delay showing recovery prompt to avoid UI conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.canShowRecoveryPrompt = true
        }
        
        print("🔄 Recoverable session detected")
    }
    
    func restoreSessionFromRecovery() -> Bool {
        guard let recoveryData = loadRecoveryData() else {
            return false
        }
        
        let sessionStateData = recoveryData.sessionState
        
        switch sessionStateData.type {
        case "breathing":
            if let round = sessionStateData.round,
               let phase = sessionStateData.phase,
               let timeRemaining = sessionStateData.timeRemaining {
                currentState = .breathing(round: round, phase: phase, timeRemaining: timeRemaining)
                print("🔄 Restored breathing session: Round \(round), Phase \(phase)")
                return true
            }
        case "holding":
            if let holdDuration = sessionStateData.holdDuration,
               let personalBest = sessionStateData.personalBest {
                currentState = .holding(duration: holdDuration, personalBest: personalBest)
                print("🔄 Restored holding session: \(holdDuration)s duration")
                return true
            }
        default:
            break
        }
        
        clearRecoveryData()
        return false
    }
    
    // MARK: - Safety Checks
    
    func performSafetyCheck() -> [String] {
        var warnings: [String] = []
        
        // Battery check
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel < 0.15 && batteryLevel > 0 {
            warnings.append("Low battery (\(Int(batteryLevel * 100))%) - consider charging before longer sessions")
        }
        
        // Background app refresh check
        if UIApplication.shared.backgroundRefreshStatus != .available {
            warnings.append("Background App Refresh is disabled - session recovery may be limited")
        }
        
        // Device orientation check
        if UIDevice.current.orientation.isLandscape {
            warnings.append("Consider using portrait orientation for better experience")
        }
        
        return warnings
    }
    
    deinit {
        interruptionObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
} 