import Foundation
import SwiftUI

// MARK: - Progress View Model

@MainActor
class ProgressViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sessions: [SessionData] = []
    @Published var personalBest: TimeInterval = 0
    @Published var totalSessions: Int = 0
    @Published var currentStreak: Int = 0
    @Published var averageHoldTime: TimeInterval = 0
    @Published var weeklyAverage: TimeInterval = 0
    @Published var improvementRate: Double = 0
    
    // MARK: - Loading and Error States
    @Published var isLoading = false
    @Published var lastError: CoreDataError?
    @Published var hasDataLoadError = false
    @Published var canRetryLoad = true
    
    // MARK: - Recent Data
    @Published var recentSessions: [SessionData] = []
    @Published var thisWeekSessions: [SessionData] = []
    @Published var lastWeekSessions: [SessionData] = []
    
    // MARK: - Private Properties
    private let coreDataManager = CoreDataManager.shared
    private let maxRetryAttempts = 3
    private var loadRetryCount = 0
    private var saveQueue: DispatchQueue = DispatchQueue(label: "progressSaveQueue", qos: .utility)
    
    // MARK: - Computed Properties
    var recentPerformance: PerformanceIndicator {
        guard !recentSessions.isEmpty else { return .noData }
        
        let recentAverage = recentSessions.prefix(5).map(\.holdDuration).reduce(0, +) / Double(min(5, recentSessions.count))
        let olderAverage = sessions.dropFirst(5).prefix(5).map(\.holdDuration).reduce(0, +) / Double(min(5, max(0, sessions.count - 5)))
        
        if olderAverage == 0 { return .improving }
        
        let improvement = (recentAverage - olderAverage) / olderAverage
        
        switch improvement {
        case 0.1...: return .improving
        case -0.1..<0.1: return .stable
        default: return .declining
        }
    }
    
    var qualityDistribution: (excellent: Int, good: Int, fair: Int, poor: Int) {
        let distribution = sessions.reduce((excellent: 0, good: 0, fair: 0, poor: 0)) { result, session in
            var updated = result
            switch session.qualityScore {
            case 0.8...1.0: updated.excellent += 1
            case 0.6..<0.8: updated.good += 1
            case 0.4..<0.6: updated.fair += 1
            default: updated.poor += 1
            }
            return updated
        }
        return distribution
    }
    
    enum PerformanceIndicator {
        case improving, stable, declining, noData
        
        var color: Color {
            switch self {
            case .improving: return .holdSuccess
            case .stable: return .holdPrimary
            case .declining: return .holdWarning
            case .noData: return .holdTextTertiary
            }
        }
        
        var description: String {
            switch self {
            case .improving: return "Improving"
            case .stable: return "Stable"
            case .declining: return "Needs focus"
            case .noData: return "No data"
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadProgress()
        }
    }
    
    // MARK: - Data Loading
    
    func loadProgress() async {
        await performWithLoading {
            let result = await coreDataManager.fetchSessions()
            
            switch result {
            case .success(let fetchedSessions):
                await updateSessions(fetchedSessions)
                loadRetryCount = 0
                hasDataLoadError = false
                canRetryLoad = true
                print("✅ Progress loaded successfully: \(fetchedSessions.count) sessions")
                
            case .failure(let error):
                await handleLoadError(error)
            }
        }
    }
    
    func retryLoadProgress() async {
        guard canRetryLoad && loadRetryCount < maxRetryAttempts else {
            print("❌ Max retry attempts reached")
            return
        }
        
        loadRetryCount += 1
        print("🔄 Retrying progress load (attempt \(loadRetryCount)/\(maxRetryAttempts))")
        
        await loadProgress()
    }
    
    private func updateSessions(_ newSessions: [SessionData]) async {
        // Validate and filter sessions
        let validSessions = newSessions.filter { $0.isValid }
        
        // Sort by date (newest first)
        let sortedSessions = validSessions.sorted { $0.startedAt > $1.startedAt }
        
        sessions = sortedSessions
        updateStats()
        updateRecentData()
    }
    
    // MARK: - Session Management
    
    func addSession(
        duration: TimeInterval,
        date: Date,
        protocolType: String = "Box Breathing",
        preparationRounds: Int = 4
    ) async {
        // Validate input
        guard duration >= 0,
              !protocolType.isEmpty,
              preparationRounds >= 0,
              date <= Date() else {
            await handleValidationError("Invalid session data")
            return
        }
        
        let sessionData = SessionData(
            id: UUID(),
            startedAt: date,
            completedAt: date,
            holdDuration: duration,
            preparationRounds: preparationRounds,
            protocolType: protocolType,
            isPersonalBest: duration > personalBest,
            improvementPercentage: personalBest > 0 ? ((duration - personalBest) / personalBest) * 100 : 0
        )
        
        await performWithLoading {
            let result = await coreDataManager.saveSession(sessionData)
            
            switch result {
            case .success:
                // Update local data immediately for responsive UI
                sessions.insert(sessionData, at: 0)
                updateStats()
                updateRecentData()
                
                print("✅ Session saved successfully: \(duration)s")
                
            case .failure(let error):
                await handleSaveError(error)
            }
        }
    }
    
    func deleteSession(withId id: UUID) async {
        await performWithLoading {
            let result = await coreDataManager.deleteSession(withId: id)
            
            switch result {
            case .success:
                // Remove from local data
                sessions.removeAll { $0.id == id }
                updateStats()
                updateRecentData()
                
                print("✅ Session deleted successfully")
                
            case .failure(let error):
                await handleDeleteError(error)
            }
        }
    }
    
    func deleteAllSessions() async {
        await performWithLoading {
            let result = await coreDataManager.deleteAllSessions()
            
            switch result {
            case .success:
                // Clear local data
                sessions.removeAll()
                updateStats()
                updateRecentData()
                
                print("✅ All sessions deleted successfully")
                
            case .failure(let error):
                await handleDeleteError(error)
            }
        }
    }
    
    // MARK: - Statistics Updates
    
    private func updateStats() {
        // Basic stats
        totalSessions = sessions.count
        personalBest = sessions.map(\.holdDuration).max() ?? 0
        averageHoldTime = sessions.isEmpty ? 0 : sessions.map(\.holdDuration).reduce(0, +) / Double(sessions.count)
        
        // Calculate streak
        currentStreak = calculateCurrentStreak()
        
        // Weekly stats
        let calendar = Calendar.current
        let now = Date()
        
        thisWeekSessions = sessions.filter { session in
            calendar.isDate(session.startedAt, equalTo: now, toGranularity: .weekOfYear)
        }
        
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) {
            lastWeekSessions = sessions.filter { session in
                calendar.isDate(session.startedAt, equalTo: lastWeek, toGranularity: .weekOfYear)
            }
        }
        
        weeklyAverage = thisWeekSessions.isEmpty ? 0 : 
            thisWeekSessions.map(\.holdDuration).reduce(0, +) / Double(thisWeekSessions.count)
        
        // Calculate improvement rate
        improvementRate = calculateImprovementRate()
    }
    
    private func updateRecentData() {
        recentSessions = Array(sessions.prefix(10))
    }
    
    private func calculateCurrentStreak() -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        // Look back day by day to find consecutive days with sessions
        for _ in 0..<30 { // Check up to 30 days back
            let hasSessionOnDate = sessions.contains { session in
                calendar.isDate(session.startedAt, inSameDayAs: currentDate)
            }
            
            if hasSessionOnDate {
                streak += 1
            } else if streak > 0 {
                break // Streak is broken
            }
            
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    private func calculateImprovementRate() -> Double {
        guard sessions.count >= 5 else { return 0 }
        
        let recentAverage = sessions.prefix(5).map(\.holdDuration).reduce(0, +) / 5.0
        let olderAverage = sessions.dropFirst(5).prefix(5).map(\.holdDuration).reduce(0, +) / 5.0
        
        guard olderAverage > 0 else { return 0 }
        
        return ((recentAverage - olderAverage) / olderAverage) * 100
    }
    
    // MARK: - Error Handling
    
    private func handleLoadError(_ error: CoreDataError) async {
        lastError = error
        hasDataLoadError = true
        
        if loadRetryCount < maxRetryAttempts {
            canRetryLoad = true
        } else {
            canRetryLoad = false
            print("❌ Max load retry attempts reached")
        }
        
        print("❌ Load error: \(error.localizedDescription)")
    }
    
    private func handleSaveError(_ error: CoreDataError) async {
        lastError = error
        print("❌ Save error: \(error.localizedDescription)")
        
        // Provide user feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
    
    private func handleDeleteError(_ error: CoreDataError) async {
        lastError = error
        print("❌ Delete error: \(error.localizedDescription)")
        
        // Reload data to ensure consistency
        await loadProgress()
    }
    
    private func handleValidationError(_ message: String) async {
        let validationError = CoreDataError.saveContextFailed(underlying: NSError(
            domain: "ValidationError",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: message]
        ))
        
        lastError = validationError
        print("❌ Validation error: \(message)")
    }
    
    func clearLastError() {
        lastError = nil
        hasDataLoadError = false
    }
    
    // MARK: - Loading State Management
    
    private func performWithLoading<T>(_ operation: () async -> T) async -> T {
        isLoading = true
        defer { isLoading = false }
        
        return await operation()
    }
    
    // MARK: - Data Export/Import
    
    func exportSessionData() -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try jsonEncoder.encode(sessions)
            return String(data: data, encoding: .utf8) ?? "Export failed"
        } catch {
            print("❌ Export error: \(error)")
            return "Export failed: \(error.localizedDescription)"
        }
    }
    
    func getDataSummary() -> DataSummary {
        return DataSummary(
            totalSessions: totalSessions,
            personalBest: personalBest,
            averageHoldTime: averageHoldTime,
            currentStreak: currentStreak,
            weeklyAverage: weeklyAverage,
            improvementRate: improvementRate,
            recentPerformance: recentPerformance,
            qualityDistribution: qualityDistribution,
            lastSessionDate: sessions.first?.startedAt
        )
    }
}

// MARK: - Supporting Types

struct DataSummary {
    let totalSessions: Int
    let personalBest: TimeInterval
    let averageHoldTime: TimeInterval
    let currentStreak: Int
    let weeklyAverage: TimeInterval
    let improvementRate: Double
    let recentPerformance: ProgressViewModel.PerformanceIndicator
    let qualityDistribution: (excellent: Int, good: Int, fair: Int, poor: Int)
    let lastSessionDate: Date?
    
    var formattedPersonalBest: String {
        return String(format: "%.1fs", personalBest)
    }
    
    var formattedAverageHoldTime: String {
        return String(format: "%.1fs", averageHoldTime)
    }
    
    var formattedWeeklyAverage: String {
        return String(format: "%.1fs", weeklyAverage)
    }
    
    var formattedImprovementRate: String {
        let sign = improvementRate >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f%%", improvementRate))"
    }
}

// MARK: - Session Data Extensions

extension SessionData {
    mutating func validate() -> Bool {
        // Ensure ID exists
        if id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
            id = UUID()
        }
        
        // Validate and fix dates
        if startedAt > Date() {
            startedAt = Date()
        }
        
        if let completedAt = completedAt, completedAt < startedAt {
            self.completedAt = startedAt
        }
        
        // Validate duration
        if holdDuration < 0 {
            holdDuration = 0
            return false
        }
        
        // Validate preparation rounds
        if preparationRounds < 0 {
            preparationRounds = 4
        }
        
        // Validate protocol type
        if protocolType.isEmpty {
            protocolType = "Box Breathing"
        }
        
        return true
    }
}

// MARK: - Convenience Methods

extension ProgressViewModel {
    func addSession(duration: TimeInterval, date: Date = Date()) async {
        await addSession(
            duration: duration,
            date: date,
            protocolType: "Box Breathing",
            preparationRounds: 4
        )
    }
    
    func getSessionsForDate(_ date: Date) -> [SessionData] {
        let calendar = Calendar.current
        return sessions.filter { session in
            calendar.isDate(session.startedAt, inSameDayAs: date)
        }
    }
    
    func getSessionsForWeek(containing date: Date) -> [SessionData] {
        let calendar = Calendar.current
        return sessions.filter { session in
            calendar.isDate(session.startedAt, equalTo: date, toGranularity: .weekOfYear)
        }
    }
    
    func getBestSessionThisWeek() -> SessionData? {
        return thisWeekSessions.max { $0.holdDuration < $1.holdDuration }
    }
    
    func getWorstSessionThisWeek() -> SessionData? {
        return thisWeekSessions.min { $0.holdDuration < $1.holdDuration }
    }
} 