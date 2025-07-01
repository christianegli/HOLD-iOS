import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var sessions: [SessionData] = []
    
    func save(_ session: SessionData) {
        sessions.append(session)
    }
    
    func loadSessions() -> [SessionData] {
        return sessions
    }
    
    private init() {}
} 