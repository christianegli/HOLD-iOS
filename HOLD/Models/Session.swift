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
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startedAt)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startedAt)
    }
    
    // MARK: - Quality and Validation
    
    var qualityScore: Double {
        guard holdDuration > 0 else { return 0.0 }
        
        // Base score from duration (0-70 points)
        let durationScore = min(holdDuration / 120.0, 1.0) * 70.0
        
        // Consistency bonus (0-20 points)
        let consistencyScore = preparationRounds >= 4 ? 20.0 : Double(preparationRounds) * 5.0
        
        // Completion bonus (0-10 points)
        let completionScore = isCompleted ? 10.0 : 0.0
        
        return durationScore + consistencyScore + completionScore
    }
    
    var qualityLevel: String {
        let score = qualityScore
        switch score {
        case 80...100: return "Excellent"
        case 60...79: return "Good"
        case 40...59: return "Fair"
        case 20...39: return "Needs Improvement"
        default: return "Poor"
        }
    }
    
    var isValid: Bool {
        return holdDuration > 0 && preparationRounds > 0 && !protocolType.isEmpty
    }
    
    // MARK: - Session Analysis
    
    func comparedTo(_ otherSession: SessionData) -> String {
        guard otherSession.isValid else { return "First session" }
        
        let timeDiff = holdDuration - otherSession.holdDuration
        let percentChange = (timeDiff / otherSession.holdDuration) * 100
        
        if abs(percentChange) < 5 {
            return "Similar performance"
        } else if percentChange > 0 {
            return String(format: "+%.1f%% improvement", percentChange)
        } else {
            return String(format: "%.1f%% decrease", abs(percentChange))
        }
    }
    
    var performanceCategory: String {
        switch holdDuration {
        case 0...15: return "Beginner"
        case 16...30: return "Novice"
        case 31...60: return "Intermediate"
        case 61...120: return "Advanced"
        default: return "Expert"
        }
    }
    
    // MARK: - Data Sanitization
    
    mutating func sanitize() {
        // Ensure reasonable bounds
        holdDuration = max(0, min(600, holdDuration)) // 0-10 minutes max
        preparationRounds = max(1, min(10, preparationRounds))
        
        // Clean up string fields
        protocolType = protocolType.trimmingCharacters(in: .whitespacesAndNewlines)
        if protocolType.isEmpty {
            protocolType = "Box Breathing"
        }
        
        // Ensure date consistency
        if let completed = completedAt, completed < startedAt {
            completedAt = nil
        }
    }
} 