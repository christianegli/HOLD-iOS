import SwiftUI

// MARK: - Error Display Types

enum ErrorDisplayStyle {
    case banner
    case modal
    case inline
    case toast
}

// MARK: - Error Actions

struct ErrorAction {
    let title: String
    let style: ErrorActionStyle
    let action: () -> Void
    
    enum ErrorActionStyle {
        case primary
        case secondary
        case destructive
        case retry
        
        var color: Color {
            switch self {
            case .primary: return .holdPrimary
            case .secondary: return .holdSecondary
            case .destructive: return .holdError
            case .retry: return .holdWarning
            }
        }
    }
    
    static func retry(_ action: @escaping () -> Void) -> ErrorAction {
        return ErrorAction(title: "Retry", style: .retry, action: action)
    }
    
    static func dismiss(_ action: @escaping () -> Void) -> ErrorAction {
        return ErrorAction(title: "Dismiss", style: .secondary, action: action)
    }
    
    static func settings(_ action: @escaping () -> Void) -> ErrorAction {
        return ErrorAction(title: "Settings", style: .primary, action: action)
    }
}

// MARK: - Error Display View

struct ErrorDisplayView: View {
    let error: CoreDataError
    let style: ErrorDisplayStyle
    let actions: [ErrorAction]
    let onDismiss: (() -> Void)?
    
    @State private var isVisible = true
    @State private var showDetails = false
    
    init(
        error: CoreDataError,
        style: ErrorDisplayStyle = .banner,
        actions: [ErrorAction] = [],
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.style = style
        self.actions = actions
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        Group {
            switch style {
            case .banner:
                bannerView
            case .modal:
                modalView
            case .inline:
                inlineView
            case .toast:
                toastView
            }
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
    
    // MARK: - Banner Style
    
    private var bannerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.holdError)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.holdHeading)
                        .foregroundColor(.holdTextPrimary)
                    
                    Text(error.localizedDescription)
                        .font(.holdBody)
                        .foregroundColor(.holdTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss?()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.holdTextTertiary)
                        .font(.caption.weight(.medium))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if !actions.isEmpty {
                Divider()
                
                HStack(spacing: 12) {
                    ForEach(actions.indices, id: \.self) { index in
                        let action = actions[index]
                        
                        Button(action.title) {
                            action.action()
                            if action.style != .retry {
                                withAnimation {
                                    isVisible = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDismiss?()
                                }
                            }
                        }
                        .font(.holdBody.weight(.medium))
                        .foregroundColor(action.style.color)
                        
                        if index < actions.count - 1 {
                            Divider()
                                .frame(height: 20)
                        }
                    }
                    
                    Spacer()
                    
                    if let recoverySuggestion = error.recoverySuggestion {
                        Button("Details") {
                            showDetails.toggle()
                        }
                        .font(.holdCaption)
                        .foregroundColor(.holdTextTertiary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            if showDetails, let recoverySuggestion = error.recoverySuggestion {
                Divider()
                
                Text(recoverySuggestion)
                    .font(.holdCaption)
                    .foregroundColor(.holdTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
        .background(Color.holdCard)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.holdError)
                .opacity(0.3),
            alignment: .top
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Modal Style
    
    private var modalView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.holdError)
                
                Text("Error Occurred")
                    .font(.holdTitle)
                    .foregroundColor(.holdTextPrimary)
            }
            
            // Error Details
            VStack(spacing: 8) {
                Text(error.localizedDescription)
                    .font(.holdBody)
                    .foregroundColor(.holdTextSecondary)
                    .multilineTextAlignment(.center)
                
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                        .font(.holdCaption)
                        .foregroundColor(.holdTextTertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Actions
            if !actions.isEmpty {
                VStack(spacing: 12) {
                    ForEach(actions.indices, id: \.self) { index in
                        let action = actions[index]
                        
                        Button(action.title) {
                            action.action()
                            if action.style != .retry {
                                withAnimation {
                                    isVisible = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDismiss?()
                                }
                            }
                        }
                        .font(.holdBody.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(action.style.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(24)
        .background(Color.holdCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Inline Style
    
    private var inlineView: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.holdError)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(error.localizedDescription)
                    .font(.holdBody)
                    .foregroundColor(.holdTextPrimary)
                
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                        .font(.holdCaption)
                        .foregroundColor(.holdTextSecondary)
                }
            }
            
            Spacer()
            
            if let retryAction = actions.first(where: { $0.style == .retry }) {
                Button("Retry") {
                    retryAction.action()
                }
                .font(.holdCaption.weight(.medium))
                .foregroundColor(.holdPrimary)
            }
        }
        .padding(12)
        .background(Color.holdError.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Toast Style
    
    private var toastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.holdError)
                .font(.caption)
            
            Text(error.localizedDescription)
                .font(.holdCaption)
                .foregroundColor(.holdTextPrimary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.holdCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss?()
                }
            }
        }
    }
}

// MARK: - Session Recovery View

struct SessionRecoveryView: View {
    let interruptionType: InterruptionType
    let onResumeSession: () -> Void
    let onDiscardSession: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: interruptionIcon)
                    .font(.system(size: 48))
                    .foregroundColor(.holdWarning)
                
                Text("Session Interrupted")
                    .font(.holdTitle)
                    .foregroundColor(.holdTextPrimary)
            }
            
            // Message
            Text(interruptionType.userMessage)
                .font(.holdBody)
                .foregroundColor(.holdTextSecondary)
                .multilineTextAlignment(.center)
            
            Text("Would you like to resume where you left off?")
                .font(.holdCaption)
                .foregroundColor(.holdTextTertiary)
                .multilineTextAlignment(.center)
            
            // Actions
            VStack(spacing: 12) {
                Button("Resume Session") {
                    onResumeSession()
                }
                .font(.holdBody.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.holdPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("Start Fresh") {
                    onDiscardSession()
                }
                .font(.holdBody)
                .foregroundColor(.holdTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.holdTextTertiary, lineWidth: 1)
                )
            }
        }
        .padding(24)
        .background(Color.holdCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    private var interruptionIcon: String {
        switch interruptionType {
        case .appBackgrounded: return "apps.iphone"
        case .phoneCall: return "phone.fill"
        case .systemAlert: return "bell.fill"
        case .lowBattery: return "battery.25"
        case .userInitiated: return "pause.circle.fill"
        case .emergencyStop: return "stop.circle.fill"
        case .timerFailure: return "clock.badge.exclamationmark.fill"
        }
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    let message: String
    let showProgress: Bool
    
    init(message: String = "Loading...", showProgress: Bool = true) {
        self.message = message
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if showProgress {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.holdPrimary)
            }
            
            Text(message)
                .font(.holdBody)
                .foregroundColor(.holdTextSecondary)
        }
        .padding(24)
        .background(Color.holdCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Safety Warning View

struct SafetyWarningView: View {
    let warnings: [String]
    let onDismiss: () -> Void
    let onProceed: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.holdWarning)
                
                Text("Safety Check")
                    .font(.holdTitle)
                    .foregroundColor(.holdTextPrimary)
            }
            
            // Warnings
            VStack(alignment: .leading, spacing: 8) {
                ForEach(warnings, id: \.self) { warning in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.holdWarning)
                            .font(.caption)
                            .padding(.top, 2)
                        
                        Text(warning)
                            .font(.holdCaption)
                            .foregroundColor(.holdTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            // Actions
            VStack(spacing: 12) {
                Button("Proceed Anyway") {
                    onProceed()
                }
                .font(.holdBody.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.holdWarning)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("Cancel") {
                    onDismiss()
                }
                .font(.holdBody)
                .foregroundColor(.holdTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.holdTextTertiary, lineWidth: 1)
                )
            }
        }
        .padding(24)
        .background(Color.holdCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - View Modifiers

extension View {
    func errorBanner(
        error: Binding<CoreDataError?>,
        actions: [ErrorAction] = []
    ) -> some View {
        self.overlay(
            Group {
                if let errorValue = error.wrappedValue {
                    VStack {
                        ErrorDisplayView(
                            error: errorValue,
                            style: .banner,
                            actions: actions,
                            onDismiss: {
                                error.wrappedValue = nil
                            }
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            },
            alignment: .top
        )
    }
    
    func loadingOverlay(
        isLoading: Bool,
        message: String = "Loading..."
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    LoadingStateView(message: message)
                }
            }
        )
    }
} 