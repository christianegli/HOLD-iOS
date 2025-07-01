import Foundation
import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var sessions: [SessionData] = []
    @Published var personalBest: TimeInterval = 0
    @Published var totalSessions: Int = 0
    @Published var averageHoldTime: TimeInterval = 0
    
    private let dataManager = DataManager.shared
    
    init() {
        loadData()
    }
    
    func addSession(_ session: SessionData) {
        sessions.append(session)
        dataManager.save(session)
        updateStats()
    }
    
    private func updateStats() {
        totalSessions = sessions.count
        personalBest = sessions.map(\.holdDuration).max() ?? 0
        averageHoldTime = sessions.isEmpty ? 0 : sessions.map(\.holdDuration).reduce(0, +) / Double(sessions.count)
    }
    
    private func loadData() {
        sessions = dataManager.loadSessions()
        updateStats()
    }
    

} 