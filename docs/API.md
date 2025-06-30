# Internal API Documentation

## Overview
This document outlines the internal APIs and interfaces within the HOLD iOS app. Since this is a local-first application, there are no external REST APIs, but there are important internal interfaces between components.

## Core Data Models

### Session Entity
Represents a completed breathing session.

```swift
@objc(Session)
public class Session: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var holdDuration: TimeInterval
    @NSManaged public var preparationRounds: Int16
    @NSManaged public var protocolType: String
    @NSManaged public var maxHeartRate: Int16
    @NSManaged public var minHeartRate: Int16
    @NSManaged public var minSpO2: Int16
}
```

### Protocol Entity
Defines breathing protocols and their parameters.

```swift
@objc(Protocol)
public class Protocol: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var inhaleSeconds: Int16
    @NSManaged public var holdSeconds: Int16
    @NSManaged public var exhaleSeconds: Int16
    @NSManaged public var pauseSeconds: Int16
    @NSManaged public var rounds: Int16
    @NSManaged public var isPro: Bool
}
```

## ViewModels

### SessionViewModel
Manages the current breathing session state and flow.

```swift
protocol SessionViewModelProtocol: ObservableObject {
    var currentPhase: BreathingPhase { get }
    var currentRound: Int { get }
    var countdown: Int { get }
    var holdDuration: TimeInterval { get }
    var isActive: Bool { get }
    
    func startSession()
    func pauseSession()
    func endSession()
    func skipToHold()
}

enum BreathingPhase {
    case prepare
    case inhale
    case hold
    case exhale
    case pause
    case finalHold
    case complete
}
```

### ProgressViewModel
Handles progress tracking and statistics.

```swift
protocol ProgressViewModelProtocol: ObservableObject {
    var personalBest: TimeInterval { get }
    var lastSessionDuration: TimeInterval { get }
    var currentStreak: Int { get }
    var totalSessions: Int { get }
    var progressData: [ProgressPoint] { get }
    
    func saveSession(_ session: SessionData)
    func getRecentSessions(limit: Int) -> [Session]
    func calculateImprovement() -> Double
}

struct ProgressPoint {
    let date: Date
    let duration: TimeInterval
}
```

### EducationViewModel
Manages educational content and benefits cards.

```swift
protocol EducationViewModelProtocol: ObservableObject {
    var currentCard: EducationCard? { get }
    var availableCards: [EducationCard] { get }
    
    func getCardForSession(_ session: SessionData) -> EducationCard?
    func markCardAsViewed(_ cardId: UUID)
    func getRandomBenefitCard() -> EducationCard
}

struct EducationCard {
    let id: UUID
    let title: String
    let content: String
    let benefitType: BenefitType
    let iconName: String
}

enum BenefitType {
    case physiological
    case mental
    case safety
    case technique
}
```

## Services

### CoreDataManager
Handles all Core Data operations.

```swift
protocol CoreDataManagerProtocol {
    func saveContext()
    func fetchSessions() -> [Session]
    func createSession(holdDuration: TimeInterval, protocolType: String) -> Session
    func deleteSession(_ session: Session)
    func getPersonalBest() -> TimeInterval
}
```

### HealthKitManager (Pro Feature)
Manages HealthKit integration for heart rate and SpO2 data.

```swift
protocol HealthKitManagerProtocol {
    var isAuthorized: Bool { get }
    
    func requestAuthorization() async throws
    func startHeartRateMonitoring() async throws
    func stopHeartRateMonitoring()
    func getCurrentHeartRate() -> Int?
    func saveSessionToHealth(_ session: SessionData) async throws
}
```

### HapticManager
Provides haptic feedback throughout the app.

```swift
protocol HapticManagerProtocol {
    func playBreathingPhaseHaptic(_ phase: BreathingPhase)
    func playSuccessHaptic()
    func playWarningHaptic()
    func playSelectionHaptic()
}

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
}
```

## Notifications

### Local Notifications
Used for breathing phase transitions and session reminders.

```swift
enum NotificationType {
    case phaseTransition(BreathingPhase)
    case sessionReminder
    case personalBest
}

protocol NotificationManagerProtocol {
    func schedulePhaseNotification(_ phase: BreathingPhase, delay: TimeInterval)
    func cancelAllNotifications()
    func requestPermission() async -> Bool
}
```

## Error Handling

### Custom Errors
Defined error types for different app operations.

```swift
enum HOLDError: LocalizedError {
    case coreDataError(String)
    case healthKitError(String)
    case timerError(String)
    case sessionError(String)
    
    var errorDescription: String? {
        switch self {
        case .coreDataError(let message):
            return "Data Error: \(message)"
        case .healthKitError(let message):
            return "Health Data Error: \(message)"
        case .timerError(let message):
            return "Timer Error: \(message)"
        case .sessionError(let message):
            return "Session Error: \(message)"
        }
    }
}
```

## Constants

### App Configuration
Central configuration for app behavior.

```swift
struct AppConfig {
    static let defaultProtocol = BoxBreathingProtocol()
    static let maxHoldDuration: TimeInterval = 600 // 10 minutes
    static let minHoldDuration: TimeInterval = 5   // 5 seconds
    static let hapticEnabled = true
    static let voiceGuidanceEnabled = true
}

struct BoxBreathingProtocol {
    let inhale: Int = 4
    let hold: Int = 4
    let exhale: Int = 4
    let pause: Int = 4
    let rounds: Int = 4
}
```

## Accessibility

### VoiceOver Support
Custom accessibility labels and hints.

```swift
extension View {
    func breathingPhaseAccessibility(_ phase: BreathingPhase, countdown: Int) -> some View {
        self.accessibilityLabel(phase.accessibilityLabel)
            .accessibilityValue("\(countdown) seconds")
            .accessibilityHint(phase.accessibilityHint)
    }
}

extension BreathingPhase {
    var accessibilityLabel: String {
        switch self {
        case .inhale: return "Inhale phase"
        case .hold: return "Hold breath phase"
        case .exhale: return "Exhale phase"
        case .pause: return "Pause phase"
        case .finalHold: return "Final breath hold"
        default: return "Breathing exercise"
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .inhale: return "Breathe in slowly"
        case .hold: return "Hold your breath"
        case .exhale: return "Breathe out slowly"
        case .pause: return "Pause before next breath"
        case .finalHold: return "Hold as long as comfortable"
        default: return "Follow the breathing guidance"
        }
    }
}
```

## Testing Interfaces

### Mock Protocols
For unit testing ViewModels and Services.

```swift
class MockCoreDataManager: CoreDataManagerProtocol {
    var mockSessions: [Session] = []
    var shouldFailSave = false
    
    func saveContext() {
        if shouldFailSave {
            // Simulate save failure
        }
    }
    
    func fetchSessions() -> [Session] {
        return mockSessions
    }
    
    // Additional mock implementations...
}
```

## Performance Monitoring

### Metrics Collection
Internal metrics for performance monitoring.

```swift
struct PerformanceMetrics {
    static func recordSessionStart()
    static func recordPhaseTransition(_ phase: BreathingPhase)
    static func recordSessionComplete(duration: TimeInterval)
    static func recordMemoryUsage()
}
``` 