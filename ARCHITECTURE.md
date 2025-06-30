# System Architecture

## Overview
HOLD is architected as a native iOS application using SwiftUI with a focus on simplicity, accessibility, and performance. The app follows MVVM (Model-View-ViewModel) pattern to ensure clean separation of concerns and testability.

## Design Principles

1. **MVP First**: Core breath-hold functionality before advanced features
2. **Accessibility**: VoiceOver support, large typography, haptic feedback
3. **Performance**: Smooth animations and responsive UI during critical breathing phases
4. **Privacy**: All data stored locally with optional HealthKit integration
5. **Offline-First**: Full functionality without internet connection

## Component Structure

### Core App Structure
```
HOLD/
├── App/
│   ├── HOLDApp.swift              # App entry point
│   └── ContentView.swift          # Root view coordinator
├── Views/
│   ├── HomeView.swift             # Main landing screen
│   ├── BreathingView.swift        # Guided breathing prep
│   ├── HoldView.swift             # Breath-hold timer
│   ├── ResultsView.swift          # Session results
│   └── EducationView.swift        # Benefits cards
├── ViewModels/
│   ├── SessionViewModel.swift     # Session state management
│   ├── ProgressViewModel.swift    # Progress tracking
│   └── EducationViewModel.swift   # Educational content
├── Models/
│   ├── Session.swift              # Core Data model
│   ├── Protocol.swift             # Breathing protocols
│   └── EducationCard.swift        # Educational content
├── Services/
│   ├── CoreDataManager.swift      # Data persistence
│   ├── HealthKitManager.swift     # Health metrics (Pro)
│   └── HapticManager.swift        # Tactile feedback
└── Resources/
    ├── Assets.xcassets            # Images and colors
    └── EducationContent.json      # Educational cards data
```

## Data Flow

### Session Flow
1. **HomeView** → User taps "Start Session"
2. **SessionViewModel** → Initializes new session
3. **BreathingView** → 4 rounds of box breathing (4-4-4-4)
4. **HoldView** → Maximum breath-hold with timer
5. **ResultsView** → Display results and save to Core Data
6. **EducationView** → Show contextual benefit card

### Data Persistence
- **Core Data** for local session history and progress
- **UserDefaults** for app settings and preferences
- **HealthKit** (Pro) for physiological metrics integration

## Technology Choices

### SwiftUI over UIKit
**Rationale**: Modern declarative syntax, better accessibility support, smooth animations, and reduced boilerplate code for rapid MVP development.

### Core Data over SQLite
**Rationale**: Native iOS integration, automatic threading, built-in migration support, and seamless SwiftUI integration with @FetchRequest.

### MVVM Pattern
**Rationale**: Clear separation of business logic from UI, better testability, and reactive programming with Combine publishers.

### Local-First Architecture
**Rationale**: Privacy-focused, works offline, faster performance, and user owns their data.

## Performance Considerations

### Breathing Phase Transitions
- Pre-calculated animation timings to ensure smooth transitions
- Background thread processing for timer calculations
- Minimal UI updates during critical breathing phases

### Memory Management
- Lazy loading of educational content
- Efficient Core Data fetch requests with predicates
- Proper cleanup of timers and observers

## Accessibility Features

### VoiceOver Support
- Semantic labels for all interactive elements
- Dynamic type support for text scaling
- Screen reader announcements for phase transitions

### Motor Accessibility
- Large touch targets (minimum 44pt)
- Haptic feedback for all interactions
- Voice control compatibility

### Visual Accessibility
- High contrast mode support
- Reduced motion preferences respected
- Color-blind friendly design

## Security & Privacy

### Data Protection
- All session data encrypted at rest
- No analytics or tracking
- Optional HealthKit data with explicit permissions

### App Store Guidelines
- Clear privacy policy
- Explicit health disclaimers
- Age-appropriate content ratings

## Scalability Considerations

### Pro Features Architecture
- Feature flags for free vs. pro functionality
- Modular protocol system for easy expansion
- Plugin architecture for additional breathing techniques

### Future Enhancements
- Apple Watch companion app architecture
- CloudKit sync for multi-device support
- Widget framework integration for quick sessions

## Testing Strategy

### Unit Tests
- ViewModel business logic
- Core Data operations
- Protocol calculations

### UI Tests
- Critical user flows
- Accessibility compliance
- Timer accuracy validation

### Performance Tests
- Animation smoothness
- Memory usage during long sessions
- Battery impact assessment 