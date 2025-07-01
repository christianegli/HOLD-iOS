import SwiftUI

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @State private var isAppearing = false
    
    var body: some View {
        ZStack {
            // Enhanced dynamic background
            Group {
                switch navigationViewModel.currentScreen {
                case .home:
                    homeBackgroundGradient
                case .education:
                    educationBackgroundGradient
                case .breathing:
                    breathingBackgroundGradient
                case .hold:
                    holdBackgroundGradient
                case .results:
                    resultsBackgroundGradient
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: navigationViewModel.currentScreen)
            
            // Main content with enhanced transitions
            Group {
                switch navigationViewModel.currentScreen {
                case .home:
                    HomeView()
                        .environmentObject(navigationViewModel)
                        .environmentObject(progressViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                case .education:
                    EducationView()
                        .environmentObject(navigationViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                case .breathing:
                    BreathingView()
                        .environmentObject(navigationViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        
                case .hold:
                    HoldView()
                        .environmentObject(navigationViewModel)
                        .environmentObject(progressViewModel)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                        
                case .results:
                    ResultsView()
                        .environmentObject(navigationViewModel)
                        .environmentObject(progressViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: navigationViewModel.currentScreen)
            
            // App launch animation overlay
            if !isAppearing {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("🫁")
                            .font(.system(size: 120))
                            .scaleEffect(isAppearing ? 1.0 : 0.5)
                            .opacity(isAppearing ? 0 : 1)
                        
                        Text("HOLD")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(isAppearing ? 0 : 1)
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                isAppearing = true
            }
        }
    }
    
    // MARK: - Background Gradients
    
    private var homeBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.05, green: 0.08, blue: 0.12), location: 0.0),
                .init(color: Color(red: 0.08, green: 0.12, blue: 0.16), location: 0.4),
                .init(color: Color(red: 0.04, green: 0.10, blue: 0.18), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var educationBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.06, green: 0.08, blue: 0.14), location: 0.0),
                .init(color: Color(red: 0.08, green: 0.12, blue: 0.18), location: 0.5),
                .init(color: Color(red: 0.05, green: 0.11, blue: 0.20), location: 1.0)
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    private var breathingBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.02, green: 0.12, blue: 0.18), location: 0.0),
                .init(color: Color(red: 0.04, green: 0.08, blue: 0.16), location: 0.6),
                .init(color: Color(red: 0.06, green: 0.04, blue: 0.14), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var holdBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.01, green: 0.05, blue: 0.12), location: 0.0),
                .init(color: Color(red: 0.02, green: 0.08, blue: 0.16), location: 0.5),
                .init(color: Color(red: 0.04, green: 0.06, blue: 0.20), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var resultsBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.08, green: 0.12, blue: 0.08), location: 0.0),
                .init(color: Color(red: 0.06, green: 0.14, blue: 0.12), location: 0.5),
                .init(color: Color(red: 0.04, green: 0.10, blue: 0.16), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Enhanced Navigation View Model

class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .home
    @Published var sessionData: SessionData?
    @Published var isTransitioning = false
    
    enum AppScreen: String, CaseIterable {
        case home = "Home"
        case education = "Education"  
        case breathing = "Breathing"
        case hold = "Hold"
        case results = "Results"
    }
    
    func navigateToEducation() {
        performTransition(to: .education, duration: 0.5)
    }
    
    func navigateToBreathing() {
        sessionData = SessionData()
        performTransition(to: .breathing, duration: 0.6)
    }
    
    func navigateToHold() {
        performTransition(to: .hold, duration: 0.7, animation: .spring(response: 0.6, dampingFraction: 0.7))
    }
    
    func navigateToResults(holdDuration: TimeInterval) {
        sessionData?.holdDuration = holdDuration
        sessionData?.completedAt = Date()
        performTransition(to: .results, duration: 0.8, animation: .spring(response: 0.5, dampingFraction: 0.8))
    }
    
    func navigateToHome() {
        sessionData = nil
        performTransition(to: .home, duration: 0.5)
    }
    
    private func performTransition(to screen: AppScreen, duration: Double, animation: Animation = .easeInOut(duration: 0.5)) {
        isTransitioning = true
        
        withAnimation(animation) {
            currentScreen = screen
        }
        
        // Reset transition state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isTransitioning = false
        }
    }
}

// MARK: - Session Data Model (defined in Models/Session.swift)

// MARK: - Design System Extensions

extension Color {
    // Primary colors
    static let holdPrimary = Color(red: 0.0, green: 0.8, blue: 0.8) // Cyan
    static let holdSecondary = Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
    static let holdAccent = Color(red: 1.0, green: 0.8, blue: 0.2) // Gold
    
    // Status colors
    static let holdSuccess = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    static let holdWarning = Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
    static let holdError = Color(red: 1.0, green: 0.3, blue: 0.3) // Red
    
    // Background colors
    static let holdBackground = Color(red: 0.05, green: 0.08, blue: 0.12)
    static let holdSurface = Color(red: 0.08, green: 0.12, blue: 0.16)
    static let holdCard = Color(red: 0.10, green: 0.14, blue: 0.18)
    
    // Text colors
    static let holdTextPrimary = Color.white
    static let holdTextSecondary = Color(red: 0.8, green: 0.8, blue: 0.8)
    static let holdTextTertiary = Color(red: 0.6, green: 0.6, blue: 0.6)
}

extension Font {
    // Typography scale
    static let holdDisplay = Font.system(size: 40, weight: .bold, design: .rounded)
    static let holdTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let holdHeading = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let holdBody = Font.system(size: 16, weight: .regular, design: .default)
    static let holdCaption = Font.system(size: 14, weight: .medium, design: .default)
    static let holdMono = Font.system(size: 18, weight: .medium, design: .monospaced)
}

extension ShapeStyle where Self == Color {
    static var holdPrimary: Color { Color.holdPrimary }
    static var holdSecondary: Color { Color.holdSecondary }
    static var holdAccent: Color { Color.holdAccent }
    static var holdSuccess: Color { Color.holdSuccess }
    static var holdWarning: Color { Color.holdWarning }
    static var holdError: Color { Color.holdError }
    static var holdBackground: Color { Color.holdBackground }
    static var holdSurface: Color { Color.holdSurface }
    static var holdCard: Color { Color.holdCard }
    static var holdTextPrimary: Color { Color.holdTextPrimary }
    static var holdTextSecondary: Color { Color.holdTextSecondary }
    static var holdTextTertiary: Color { Color.holdTextTertiary }
}

// MARK: - Temporary inline EducationView placeholder (until project file is updated)
struct EducationView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Text("Breath Hold Training")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.holdTextPrimary)
            Text("Learn safe techniques before starting")
                .font(.body)
                .foregroundColor(.holdTextSecondary)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                navigationViewModel.navigateToBreathing()
            }) {
                Text("Start Training")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.holdPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .padding()
        .background(Color.holdBackground)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
