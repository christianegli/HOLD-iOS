import Foundation

struct SessionData: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var startedAt: Date = Date()
    var completedAt: Date?
    var holdDuration: TimeInterval = 0
    var preparationRounds: Int = 4
    var protocolType: String = "Box Breathing"
    
    // Additional computed and tracking properties
    var isPersonalBest: Bool = false
    var improvementPercentage: Double = 0
    
    // MARK: - Computed Properties
    
    var isCompleted: Bool {
        return completedAt != nil
    }
    
    var sessionDuration: TimeInterval {
        guard let completedAt = completedAt else {
            return Date().timeIntervalSince(startedAt)
        }
        return completedAt.timeIntervalSince(startedAt)
    }
    
    var formattedHoldDuration: String {
        let minutes = Int(holdDuration) / 60
        let seconds = Int(holdDuration) % 60
        let milliseconds = Int((holdDuration.truncatingRemainder(dividingBy: 1)) * 10)
        
        if minutes > 0 {
            return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
        } else {
            return String(format: "%d.%ds", seconds, milliseconds)
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startedAt)
    }
    
    var formattedDateShort: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(startedAt) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(startedAt) {
            return "Yesterday"
        } else if Calendar.current.isDate(startedAt, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: startedAt)
    }
    
    var qualityScore: Double {
        switch holdDuration {
        case 0..<15: return 0.2      // Poor
        case 15..<30: return 0.4     // Below Average
        case 30..<60: return 0.6     // Average
        case 60..<120: return 0.8    // Good
        default: return 1.0         // Excellent
        }
    }
    
    var qualityLevel: QualityLevel {
        switch qualityScore {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .average
        case 0.2..<0.4: return .belowAverage
        default: return .poor
        }
    }
    
    var isValid: Bool {
        return holdDuration >= 0 && 
               preparationRounds >= 0 && 
               !protocolType.isEmpty &&
               startedAt <= Date() &&
               id != UUID(uuidString: "00000000-0000-0000-0000-000000000000")
    }
    
    // MARK: - Quality Level Enum
    
    enum QualityLevel: String, CaseIterable {
        case poor = "Poor"
        case belowAverage = "Below Average"
        case average = "Average"
        case good = "Good"
        case excellent = "Excellent"
        
        var color: String {
            switch self {
            case .poor: return "holdError"
            case .belowAverage: return "holdWarning"
            case .average: return "holdSecondary"
            case .good: return "holdPrimary"
            case .excellent: return "holdSuccess"
            }
        }
        
        var icon: String {
            switch self {
            case .poor: return "😔"
            case .belowAverage: return "😐"
            case .average: return "🙂"
            case .good: return "😊"
            case .excellent: return "🌟"
            }
        }
        
        var description: String {
            switch self {
            case .poor: return "Keep practicing! Every session builds strength."
            case .belowAverage: return "You're improving! Stay consistent."
            case .average: return "Good progress! Keep building your practice."
            case .good: return "Great work! You're developing strong breath control."
            case .excellent: return "Outstanding! You've achieved excellent breath mastery."
            }
        }
    }
    
    // MARK: - Initializers
    
    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        holdDuration: TimeInterval = 0,
        preparationRounds: Int = 4,
        protocolType: String = "Box Breathing",
        isPersonalBest: Bool = false,
        improvementPercentage: Double = 0
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.holdDuration = holdDuration
        self.preparationRounds = preparationRounds
        self.protocolType = protocolType
        self.isPersonalBest = isPersonalBest
        self.improvementPercentage = improvementPercentage
    }
    
    // MARK: - Validation and Safety
    
    mutating func sanitize() {
        // Ensure valid ID
        if id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            id = UUID()
        }
        
        // Ensure valid dates
        if startedAt > Date() {
            startedAt = Date()
        }
        
        if let completedAt = completedAt, completedAt < startedAt {
            self.completedAt = startedAt
        }
        
        // Ensure valid duration (no negative values)
        if holdDuration < 0 {
            holdDuration = 0
        }
        
        // Cap duration at reasonable maximum (10 minutes)
        if holdDuration > 600 {
            holdDuration = 600
        }
        
        // Ensure valid preparation rounds
        if preparationRounds < 0 {
            preparationRounds = 4
        }
        
        if preparationRounds > 10 {
            preparationRounds = 10
        }
        
        // Ensure valid protocol type
        if protocolType.isEmpty {
            protocolType = "Box Breathing"
        }
        
        // Validate improvement percentage
        if improvementPercentage.isNaN || improvementPercentage.isInfinite {
            improvementPercentage = 0
        }
        
        // Cap improvement percentage at reasonable values
        if improvementPercentage > 1000 {
            improvementPercentage = 1000
        }
        
        if improvementPercentage < -100 {
            improvementPercentage = -100
        }
    }
    
    // MARK: - Comparison Helpers
    
    func compare(to other: SessionData) -> ComparisonResult {
        let improvement = holdDuration - other.holdDuration
        let improvementPercentage = other.holdDuration > 0 ? (improvement / other.holdDuration) * 100 : 0
        
        return ComparisonResult(
            improvementSeconds: improvement,
            improvementPercentage: improvementPercentage,
            isImprovement: improvement > 0,
            isSignificantImprovement: improvementPercentage > 10
        )
    }
    
    struct ComparisonResult {
        let improvementSeconds: TimeInterval
        let improvementPercentage: Double
        let isImprovement: Bool
        let isSignificantImprovement: Bool
        
        var formattedImprovement: String {
            let sign = improvementSeconds >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.1fs", improvementSeconds))"
        }
        
        var formattedImprovementPercentage: String {
            let sign = improvementPercentage >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.1f%%", improvementPercentage))"
        }
    }
    
    // MARK: - Static Factory Methods
    
    static func createTestSession(
        duration: TimeInterval,
        daysAgo: Int = 0,
        protocolType: String = "Box Breathing"
    ) -> SessionData {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        
        return SessionData(
            startedAt: date,
            completedAt: date,
            holdDuration: duration,
            protocolType: protocolType
        )
    }
    
    // MARK: - Hashable and Equatable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SessionData, rhs: SessionData) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Collection Extensions

extension Array where Element == SessionData {
    var personalBest: TimeInterval {
        return self.map(\.holdDuration).max() ?? 0
    }
    
    var averageDuration: TimeInterval {
        guard !isEmpty else { return 0 }
        return self.map(\.holdDuration).reduce(0, +) / Double(count)
    }
    
    var totalDuration: TimeInterval {
        return self.map(\.holdDuration).reduce(0, +)
    }
    
    func sessionsForDate(_ date: Date) -> [SessionData] {
        let calendar = Calendar.current
        return self.filter { session in
            calendar.isDate(session.startedAt, inSameDayAs: date)
        }
    }
    
    func sessionsThisWeek() -> [SessionData] {
        let calendar = Calendar.current
        let now = Date()
        return self.filter { session in
            calendar.isDate(session.startedAt, equalTo: now, toGranularity: .weekOfYear)
        }
    }
    
    func sessionsThisMonth() -> [SessionData] {
        let calendar = Calendar.current
        let now = Date()
        return self.filter { session in
            calendar.isDate(session.startedAt, equalTo: now, toGranularity: .month)
        }
    }
    
    func recentSessions(count: Int = 10) -> [SessionData] {
        return Array(self.prefix(count))
    }
    
    var qualityDistribution: (excellent: Int, good: Int, average: Int, belowAverage: Int, poor: Int) {
        return self.reduce((excellent: 0, good: 0, average: 0, belowAverage: 0, poor: 0)) { result, session in
            var updated = result
            switch session.qualityLevel {
            case .excellent: updated.excellent += 1
            case .good: updated.good += 1
            case .average: updated.average += 1
            case .belowAverage: updated.belowAverage += 1
            case .poor: updated.poor += 1
            }
            return updated
        }
    }
} 