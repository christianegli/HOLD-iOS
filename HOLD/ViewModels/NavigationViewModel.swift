import SwiftUI

class NavigationViewModel: ObservableObject {
    @Published var currentView: AppView = .home
    @Published var sessionData: SessionData?
    
    enum AppView {
        case home
        case education
        case breathing
        case hold
        case results
    }
    
    func navigateToEducation() {
        currentView = .education
    }
    
    func navigateToBreathing() {
        currentView = .breathing
    }
    
    func navigateToHold() {
        currentView = .hold
    }
    
    func navigateToResults(with data: SessionData) {
        sessionData = data
        currentView = .results
    }
    
    func navigateToHome() {
        currentView = .home
        sessionData = nil
    }
} 