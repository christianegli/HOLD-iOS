import Foundation

struct SessionData {
    var id: UUID = UUID()
    var startedAt: Date = Date()
    var completedAt: Date?
    var holdDuration: TimeInterval = 0
    var preparationRounds: Int = 4
    var protocolType: String = "Box Breathing"
} 