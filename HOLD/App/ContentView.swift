import SwiftUI

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.07, blue: 0.09),
                    Color(red: 0.12, green: 0.16, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Group {
                switch navigationViewModel.currentScreen {
                case .home:
                    HomeView()
                        .environmentObject(navigationViewModel)
                case .education:
                    EducationView()
                        .environmentObject(navigationViewModel)
                case .breathing:
                    BreathingView()
                        .environmentObject(navigationViewModel)
                case .hold:
                    HoldView()
                        .environmentObject(navigationViewModel)
                case .results:
                    ResultsView()
                        .environmentObject(navigationViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: navigationViewModel.currentScreen)
        }
        .preferredColorScheme(.dark)
    }
}

class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .home
    @Published var sessionData: SessionData?
    
    enum AppScreen {
        case home, education, breathing, hold, results
    }
    
    func navigateToEducation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .education
        }
    }
    
    func navigateToBreathing() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .breathing
        }
        sessionData = SessionData()
    }
    
    func navigateToHold() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentScreen = .hold
        }
    }
    
    func navigateToResults(holdDuration: TimeInterval) {
        sessionData?.holdDuration = holdDuration
        sessionData?.completedAt = Date()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            currentScreen = .results
        }
    }
    
    func navigateToHome() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = .home
        }
        sessionData = nil
    }
}

struct SessionData {
    var startedAt: Date = Date()
    var completedAt: Date?
    var holdDuration: TimeInterval = 0
    var preparationRounds: Int = 4
    var protocolType: String = "Box Breathing"
}

#Preview {
    ContentView()
}
