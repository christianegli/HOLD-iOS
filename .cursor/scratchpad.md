# Project Scratchpad
**Current Role:** Planner
**MVP Status:** Planning Complete
**GitHub Repo:** https://github.com/christianegli/HOLD-iOS
**Last Push:** Initial documentation structure

## Background and Motivation
The goal is to transform the existing HOLD breath-training web prototype into a native iOS application with a beautiful, modern SwiftUI interface. The app will guide users through structured breathing protocols and a final breath-hold, helping them improve stress resilience and lung capacity.

## Research Findings
### Competitive Analysis
- **Breathwrk** – Large library of guided exercises, customizable visuals/haptics, Apple Health integration, freemium subscription (4.8★/17.9K).
- **Wim Hof Method** – Combines breathing, cold exposure, and mindset training; rich content but heavier UX (4.8★/6.4K).
- **Box Breathe Inhale** – Focused box-breathing tool with extensive customization & Apple Watch support; simple UI (4.8★/285).
- **Breathe for better HRV** – Paid app focused on HRV/coherent breathing and 4-7-8; limited scope.
- **Calm / Headspace** – Broader meditation apps that include breathing modules but lack deep protocol training.

### User Pain Points
1. Overly complex apps when users only want quick, protocol-based sessions.
2. Essential breathing timers locked behind subscriptions.
3. Visuals not immersive enough or distracting.
4. Limited real-time physiological feedback (HR, SpO₂) integration.
5. Inconsistent experience between iPhone and Apple Watch.

### Revised MVP Focus (Breath-Hold–Centric)
Core, minimal experience that remains highly accessible:
- [ESSENTIAL] Quick-start flow: Home → 4× Prep Breathing rounds (Box 4-4-4-4) → Max Breath Hold timer → Results.
- [ESSENTIAL] Continuous breath-hold tracking with personal best, last session, and visual progression sparkline.
- [ESSENTIAL] Simple Benefits panel after each session (e.g., "You stimulated the vagus nerve, improved CO₂ tolerance, and boosted EPO by ~X%") using pre-written educational snippets.
- [ESSENTIAL] Accessibility: large typography, haptic cues, VoiceOver labels.
- [ESSENTIAL] Data stored locally (CoreData) for history & streaks.

### One-Time Purchase (HOLD Pro)
Unlocks powerful, but non-essential features:
- Advanced Protocols: CO₂ Tolerance Table, O₂ Deprivation Ladder, 4-7-8, etc.
- Custom protocol builder & interval editor.
- Detailed analytics dashboard (weekly/monthly graphs, HR/SpO₂ overlays).
- Apple HealthKit + Apple Watch real-time metrics & haptic guidance.
- Breathing coach voice packs & soundscapes.

_No subscriptions; single lifetime purchase maintains simplicity & trust._

### Education Strategy
We will embed bite-size "Did you know?" cards:
1. Physiological benefits (EPO, HRV, stress response).
2. Safety guidelines & contraindications.
3. Tips for improving breath-hold (relaxation, pre-oxygenation, CO₂ tolerance).
Triggered contextually (e.g., after session or via "Learn" tab). All offline HTML/SwiftUI views to avoid external dependencies.

## Key Challenges and Analysis
1. **Timer Precision**: Ensuring accurate timing during breathing phases and hold duration
2. **Animation Performance**: Smooth visual transitions during breathing cycles
3. **Accessibility**: Full VoiceOver support while maintaining visual appeal
4. **Data Persistence**: Reliable Core Data implementation for session history
5. **Haptic Feedback**: Meaningful tactile cues without being distracting

## High-level Task Breakdown

### Phase 1: MVP Core Functionality (Priority: CRITICAL)

#### Task 1: Project Setup & Foundation
- [ ] Create new Xcode project with SwiftUI
- [ ] Set up Core Data model with Session entity
- [ ] Configure basic app structure (MVVM pattern)
- [ ] Implement basic navigation flow
- **Success Criteria**: App launches, navigates between views, Core Data stack functional
- **Priority**: CRITICAL

#### Task 2: Home Screen Implementation
- [ ] Create HomeView with "Tap to Start" button
- [ ] Implement personal best display
- [ ] Add streak counter and basic stats
- [ ] Design minimal, accessible interface
- **Success Criteria**: Clean home screen with proper accessibility labels
- **Priority**: CRITICAL

#### Task 3: Breathing Preparation Flow
- [ ] Create BreathingView with visual breathing guide
- [ ] Implement 4-4-4-4 box breathing timer
- [ ] Add smooth animations for inhale/exhale/hold phases
- [ ] Include round counter (1 of 4, 2 of 4, etc.)
- **Success Criteria**: 4 rounds of guided breathing with smooth transitions
- **Priority**: CRITICAL

#### Task 4: Breath Hold Implementation
- [ ] Create HoldView with expanding circle animation
- [ ] Implement precise timer for breath hold duration
- [ ] Add "Release" button for ending hold
- [ ] Include placeholder metrics (HR, SpO₂)
- **Success Criteria**: Accurate breath hold timing with immersive visuals
- **Priority**: CRITICAL

#### Task 5: Results & Data Persistence
- [ ] Create ResultsView showing hold duration
- [ ] Implement Core Data session saving
- [ ] Calculate and display improvement percentage
- [ ] Add "Go Again" and "Done" buttons
- **Success Criteria**: Session data saved, results displayed accurately
- **Priority**: CRITICAL

#### Task 6: Basic Education Cards
- [ ] Create EducationCard model and view
- [ ] Implement 5-10 educational snippets about benefits
- [ ] Show contextual card after each session
- [ ] Include simple "Learn More" content
- **Success Criteria**: Educational content displayed after sessions
- **Priority**: CRITICAL

### Phase 2: MVP Polish & Accessibility (Priority: HIGH)

#### Task 7: Accessibility Implementation
- [ ] Add comprehensive VoiceOver labels
- [ ] Implement Dynamic Type support
- [ ] Add haptic feedback for phase transitions
- [ ] Test with accessibility inspector
- **Success Criteria**: Full VoiceOver navigation, proper accessibility
- **Priority**: HIGH

#### Task 8: Visual Polish & Animations
- [ ] Refine breathing circle animations
- [ ] Implement smooth transitions between views
- [ ] Add visual feedback for personal bests
- [ ] Polish color scheme and typography
- **Success Criteria**: Smooth, professional animations throughout
- **Priority**: HIGH

#### Task 9: Error Handling & Edge Cases
- [ ] Implement proper error handling for Core Data
- [ ] Add session interruption recovery
- [ ] Handle app backgrounding during sessions
- [ ] Add input validation and safety checks
- **Success Criteria**: App handles errors gracefully, no crashes
- **Priority**: HIGH

### Phase 3: Pro Features Foundation (Priority: LATER)

#### Task 10: In-App Purchase Setup
- [ ] Configure App Store Connect for HOLD Pro
- [ ] Implement StoreKit integration
- [ ] Create feature flags for Pro content
- [ ] Add Pro upgrade UI
- **Success Criteria**: Working in-app purchase flow
- **Priority**: LATER

#### Task 11: Advanced Analytics Dashboard
- [ ] Create detailed progress charts
- [ ] Implement weekly/monthly trend analysis
- [ ] Add session history with filtering
- [ ] Include statistical insights
- **Success Criteria**: Comprehensive analytics for Pro users
- **Priority**: LATER

#### Task 12: HealthKit Integration
- [ ] Request HealthKit permissions
- [ ] Implement heart rate monitoring
- [ ] Add SpO₂ data collection (if available)
- [ ] Save sessions to Health app
- **Success Criteria**: Live health metrics during sessions
- **Priority**: LATER

## Project Status Board

### MVP Tasks (Priority: CRITICAL)
- [ ] Task 1: Project Setup & Foundation (Ready to start)
- [ ] Task 2: Home Screen Implementation
- [ ] Task 3: Breathing Preparation Flow
- [ ] Task 4: Breath Hold Implementation
- [ ] Task 5: Results & Data Persistence
- [ ] Task 6: Basic Education Cards

### Polish Tasks (Priority: HIGH)
- [ ] Task 7: Accessibility Implementation
- [ ] Task 8: Visual Polish & Animations
- [ ] Task 9: Error Handling & Edge Cases

### Pro Feature Tasks (Priority: LATER)
- [ ] Task 10: In-App Purchase Setup
- [ ] Task 11: Advanced Analytics Dashboard
- [ ] Task 12: HealthKit Integration

## Current Status / Progress Tracking
✅ **Documentation Complete**: README, ARCHITECTURE, DECISIONS, API docs created
✅ **GitHub Repository**: https://github.com/christianegli/HOLD-iOS initialized
⏳ **Next Step**: Ready for Executor to begin Task 1 (Project Setup & Foundation)

## Documentation Status
- [x] README.md updated with comprehensive project overview
- [x] ARCHITECTURE.md created with system design
- [x] DECISIONS.md has 7 ADRs covering key technical decisions
- [x] docs/API.md documents internal interfaces
- [ ] docs/SETUP.md (will create when needed)
- [ ] docs/CONTRIBUTING.md (will create when needed)

## Lessons Learned
- Research shows users want simple, focused breathing apps without subscription complexity
- Accessibility must be built-in from the start, not added later
- Local-first approach provides better privacy and performance
- One-time purchase model differentiates from subscription-heavy competitors 