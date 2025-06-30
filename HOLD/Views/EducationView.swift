import SwiftUI

/**
 * Education View - Comprehensive Breath Holding Education
 * 
 * RATIONALE: Provides users with essential knowledge about breath holding
 * techniques, scientific benefits, safety guidelines, and progressive training
 * methods. Enhances user understanding and promotes safe, effective practice.
 */

struct EducationView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State private var selectedCategory: EducationCategory = .basics
    @State private var currentCardIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    EducationHeader()
                    
                    // Category selector
                    CategorySelector(
                        selectedCategory: $selectedCategory,
                        onCategoryChange: { category in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCategory = category
                                currentCardIndex = 0
                            }
                        }
                    )
                    
                    // Educational cards for selected category
                    EducationCardsView(
                        category: selectedCategory,
                        currentIndex: $currentCardIndex
                    )
                    
                    // Quick tips section
                    QuickTipsSection()
                    
                    // Action buttons
                    ActionSection {
                        navigationViewModel.navigateToHome()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigationViewModel.navigateToHome()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                            Text("Home")
                        }
                        .foregroundColor(.cyan)
                    }
                }
            }
        }
        .accessibilityLabel("Education screen")
    }
}

struct EducationHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🧠")
                .font(.system(size: 64))
            
            VStack(spacing: 12) {
                Text("Master Your Breath")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Learn the science, techniques, and safety practices behind effective breath holding")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
}

struct CategorySelector: View {
    @Binding var selectedCategory: EducationCategory
    let onCategoryChange: (EducationCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EducationCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            onCategoryChange(category)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct CategoryButton: View {
    let category: EducationCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.title2)
                
                Text(category.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .cyan : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.cyan : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct EducationCardsView: View {
    let category: EducationCategory
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(spacing: 20) {
            if !category.cards.isEmpty {
                EducationCard(card: category.cards[currentIndex])
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(currentIndex)
                
                CardNavigation(
                    currentIndex: $currentIndex,
                    totalCards: category.cards.count
                )
            } else {
                Text("No content available for this category")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

struct EducationCard: View {
    let card: EducationCardData
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Card header
            VStack(spacing: 16) {
                Text(card.icon)
                    .font(.system(size: 48))
                
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(card.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.cyan)
                    .multilineTextAlignment(.center)
            }
            
            // Main content
            VStack(spacing: 16) {
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(showingDetails ? nil : 4)
                
                if !showingDetails && card.description.count > 200 {
                    Button("Read More") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDetails = true
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.cyan)
                }
            }
            
            // Key points
            if !card.keyPoints.isEmpty {
                VStack(spacing: 12) {
                    Text("Key Points")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        ForEach(Array(card.keyPoints.enumerated()), id: \.offset) { index, point in
                            HStack(alignment: .top, spacing: 12) {
                                Text("•")
                                    .foregroundColor(.cyan)
                                    .fontWeight(.bold)
                                
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            // Safety warning
            if let warning = card.safetyWarning {
                SafetyWarningCard(warning: warning)
            }
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title): \(card.subtitle)")
    }
}

struct SafetyWarningCard: View {
    let warning: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("⚠️")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Safety First")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text(warning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityLabel("Safety warning: \(warning)")
    }
}

struct CardNavigation: View {
    @Binding var currentIndex: Int
    let totalCards: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress indicators
            HStack(spacing: 8) {
                ForEach(0..<totalCards, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.cyan : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
            
            // Navigation buttons
            HStack(spacing: 40) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex = max(0, currentIndex - 1)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.subheadline)
                    .foregroundColor(currentIndex > 0 ? .cyan : .gray)
                }
                .disabled(currentIndex == 0)
                
                Spacer()
                
                Text("\(currentIndex + 1) of \(totalCards)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex = min(totalCards - 1, currentIndex + 1)
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(currentIndex < totalCards - 1 ? .cyan : .gray)
                }
                .disabled(currentIndex == totalCards - 1)
            }
        }
    }
}

struct QuickTipsSection: View {
    private let quickTips = [
        "Start with short holds and gradually increase duration",
        "Never practice breath holding while driving or in water",
        "Focus on relaxation rather than forcing longer holds",
        "Consistent practice is more valuable than occasional long sessions",
        "Listen to your body and stop if you feel dizzy or uncomfortable"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Quick Tips")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("💡")
                    .font(.title2)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(quickTips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(Color.cyan.opacity(0.2))
                            )
                        
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.2))
                    )
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ActionSection: View {
    let onStartPractice: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ready to practice what you've learned?")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button(action: onStartPractice) {
                HStack(spacing: 12) {
                    Image(systemName: "lungs.fill")
                        .font(.title3)
                    
                    Text("START PRACTICE SESSION")
                        .font(.system(size: 16, weight: .bold))
                        .tracking(1)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.cyan, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .accessibilityLabel("Start practice session")
        }
    }
}

// MARK: - Data Models

enum EducationCategory: CaseIterable {
    case basics, techniques, science, safety, advanced
    
    var title: String {
        switch self {
        case .basics: return "Basics"
        case .techniques: return "Techniques"
        case .science: return "Science"
        case .safety: return "Safety"
        case .advanced: return "Advanced"
        }
    }
    
    var icon: String {
        switch self {
        case .basics: return "🎯"
        case .techniques: return "🫁"
        case .science: return "🧬"
        case .safety: return "⚠️"
        case .advanced: return "🏆"
        }
    }
    
    var cards: [EducationCardData] {
        switch self {
        case .basics:
            return EducationCardData.basicCards
        case .techniques:
            return EducationCardData.techniqueCards
        case .science:
            return EducationCardData.scienceCards
        case .safety:
            return EducationCardData.safetyCards
        case .advanced:
            return EducationCardData.advancedCards
        }
    }
}

struct EducationCardData {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let keyPoints: [String]
    let safetyWarning: String?
    
    // MARK: - Basic Cards
    static let basicCards = [
        EducationCardData(
            icon: "🫁",
            title: "What is Breath Holding?",
            subtitle: "Understanding the fundamentals",
            description: "Breath holding, or apnea, is the voluntary cessation of breathing. When practiced safely, it can improve your body's oxygen efficiency, enhance mental focus, and build resilience to stress. The key is gradual progression and listening to your body's signals.",
            keyPoints: [
                "Voluntary cessation of breathing for health benefits",
                "Improves oxygen efficiency and mental focus",
                "Builds stress resilience and mental strength",
                "Requires gradual progression and body awareness"
            ],
            safetyWarning: "Never practice breath holding in water or while driving. Always practice in a safe environment."
        ),
        
        EducationCardData(
            icon: "🎯",
            title: "Getting Started",
            subtitle: "Your first steps to breath mastery",
            description: "Begin with short, comfortable holds of 15-30 seconds. Focus on relaxation rather than pushing limits. Your body will naturally adapt and improve with consistent practice. The goal is building capacity gradually while maintaining safety.",
            keyPoints: [
                "Start with 15-30 second holds",
                "Prioritize relaxation over duration",
                "Practice consistency over intensity",
                "Allow natural adaptation and improvement"
            ],
            safetyWarning: "Stop immediately if you feel dizzy, lightheaded, or uncomfortable."
        ),
        
        EducationCardData(
            icon: "📈",
            title: "Tracking Progress",
            subtitle: "Measuring your improvement",
            description: "Progress in breath holding isn't just about duration. Pay attention to how relaxed you feel during holds, your recovery time, and overall comfort. Quality of practice matters more than quantity. Small, consistent improvements compound over time.",
            keyPoints: [
                "Duration is just one measure of progress",
                "Monitor relaxation and comfort levels",
                "Track recovery time between sessions",
                "Focus on quality over quantity"
            ],
            safetyWarning: nil
        )
    ]
    
    // MARK: - Technique Cards
    static let techniqueCards = [
        EducationCardData(
            icon: "📦",
            title: "Box Breathing",
            subtitle: "The foundation technique",
            description: "Box breathing (4-4-4-4) is the cornerstone of breath training. Inhale for 4 counts, hold for 4, exhale for 4, pause for 4. This technique balances your nervous system, reduces stress, and prepares your body for longer breath holds.",
            keyPoints: [
                "Equal timing for all four phases",
                "Balances the nervous system",
                "Reduces stress and anxiety",
                "Prepares body for breath holding"
            ],
            safetyWarning: "If 4 counts feels too long, start with 3 or even 2 counts and build up gradually."
        ),
        
        EducationCardData(
            icon: "🌊",
            title: "Diaphragmatic Breathing",
            subtitle: "Breathing from your core",
            description: "Proper breathing uses the diaphragm, not just the chest. Place one hand on your chest, one on your belly. The belly hand should move more than the chest hand. This technique maximizes oxygen intake and promotes relaxation.",
            keyPoints: [
                "Use diaphragm instead of chest muscles",
                "Belly should expand more than chest",
                "Maximizes oxygen intake efficiency",
                "Promotes natural relaxation response"
            ],
            safetyWarning: nil
        ),
        
        EducationCardData(
            icon: "🧘",
            title: "Relaxation Techniques",
            subtitle: "Staying calm during holds",
            description: "Mental relaxation is crucial for longer breath holds. Practice progressive muscle relaxation, visualization, or mindfulness meditation. The more relaxed you are, the less oxygen your body consumes during the hold.",
            keyPoints: [
                "Mental relaxation reduces oxygen consumption",
                "Practice progressive muscle relaxation",
                "Use visualization and mindfulness",
                "Calm mind enables longer holds"
            ],
            safetyWarning: "Never force relaxation. If you feel anxious, end the hold and try again later."
        )
    ]
    
    // MARK: - Science Cards
    static let scienceCards = [
        EducationCardData(
            icon: "🧬",
            title: "The Physiology",
            subtitle: "What happens in your body",
            description: "During breath holding, your body activates the 'dive response' - heart rate slows, blood vessels constrict, and oxygen is conserved for vital organs. This ancient survival mechanism can be trained to improve overall health and resilience.",
            keyPoints: [
                "Activates the mammalian dive response",
                "Heart rate naturally decreases",
                "Blood flow redirects to vital organs",
                "Improves overall physiological resilience"
            ],
            safetyWarning: nil
        ),
        
        EducationCardData(
            icon: "🧠",
            title: "Neurological Benefits",
            subtitle: "Training your brain",
            description: "Breath holding stimulates the vagus nerve, promoting parasympathetic nervous system activation. This leads to reduced stress, improved heart rate variability, better focus, and enhanced emotional regulation.",
            keyPoints: [
                "Stimulates the vagus nerve",
                "Activates parasympathetic nervous system",
                "Improves heart rate variability",
                "Enhances focus and emotional regulation"
            ],
            safetyWarning: nil
        ),
        
        EducationCardData(
            icon: "💪",
            title: "Physical Adaptations",
            subtitle: "How your body improves",
            description: "Regular practice increases red blood cell production, improves oxygen utilization efficiency, and strengthens respiratory muscles. These adaptations enhance both athletic performance and everyday energy levels.",
            keyPoints: [
                "Increases red blood cell production",
                "Improves oxygen utilization efficiency",
                "Strengthens respiratory muscles",
                "Enhances athletic and daily performance"
            ],
            safetyWarning: nil
        )
    ]
    
    // MARK: - Safety Cards
    static let safetyCards = [
        EducationCardData(
            icon: "⚠️",
            title: "Essential Safety Rules",
            subtitle: "Non-negotiable guidelines",
            description: "Never practice breath holding in water, while driving, or in any potentially dangerous situation. Always practice seated or lying down in a safe environment. If you feel dizzy, lightheaded, or uncomfortable, stop immediately.",
            keyPoints: [
                "Never practice in water or while driving",
                "Always practice in safe, seated position",
                "Stop if dizzy or uncomfortable",
                "Have someone nearby when possible"
            ],
            safetyWarning: "Shallow water blackout can occur without warning. Never practice breath holding in water."
        ),
        
        EducationCardData(
            icon: "🚨",
            title: "Warning Signs",
            subtitle: "When to stop immediately",
            description: "Learn to recognize your body's warning signals: dizziness, tingling, visual disturbances, or strong urge to breathe. These are safety mechanisms - respect them. Recovery should be quick and comfortable after ending a hold.",
            keyPoints: [
                "Dizziness or lightheadedness",
                "Tingling sensations or numbness",
                "Visual disturbances or tunnel vision",
                "Strong, urgent need to breathe"
            ],
            safetyWarning: "If symptoms persist after breathing resumes, stop practice and consult a healthcare provider."
        ),
        
        EducationCardData(
            icon: "🏥",
            title: "Medical Considerations",
            subtitle: "Who should avoid breath holding",
            description: "Certain medical conditions make breath holding inadvisable. Consult your healthcare provider if you have heart conditions, respiratory disorders, pregnancy, or take medications affecting breathing or circulation.",
            keyPoints: [
                "Heart or cardiovascular conditions",
                "Respiratory disorders or lung disease",
                "Pregnancy or recent surgery",
                "Medications affecting breathing or circulation"
            ],
            safetyWarning: "Always consult your healthcare provider before starting any breath holding practice."
        )
    ]
    
    // MARK: - Advanced Cards
    static let advancedCards = [
        EducationCardData(
            icon: "🏆",
            title: "Advanced Techniques",
            subtitle: "Taking your practice further",
            description: "Once you've mastered the basics, explore advanced techniques like the Wim Hof Method, CO2 tolerance training, or extended box breathing patterns. These methods can significantly enhance your breath holding capacity and overall well-being.",
            keyPoints: [
                "Wim Hof Method for cold exposure integration",
                "CO2 tolerance training for longer holds",
                "Extended box breathing patterns",
                "Integration with meditation practices"
            ],
            safetyWarning: "Advanced techniques should only be practiced after mastering basic safety and techniques."
        ),
        
        EducationCardData(
            icon: "📊",
            title: "Performance Optimization",
            subtitle: "Maximizing your potential",
            description: "Track multiple metrics: hold duration, recovery time, heart rate variability, and subjective comfort. Use this data to optimize your training schedule, identify patterns, and prevent overtraining.",
            keyPoints: [
                "Track multiple performance metrics",
                "Monitor recovery and comfort levels",
                "Optimize training frequency and intensity",
                "Prevent overtraining through data analysis"
            ],
            safetyWarning: nil
        ),
        
        EducationCardData(
            icon: "🌟",
            title: "Lifestyle Integration",
            subtitle: "Beyond formal practice",
            description: "Integrate breath awareness into daily life: use box breathing during stress, practice breath holds during exercise recovery, or incorporate breathing exercises into your morning routine. The benefits extend far beyond formal training sessions.",
            keyPoints: [
                "Use breathing for stress management",
                "Integrate with exercise and recovery",
                "Morning routine breath practices",
                "Mindful breathing throughout the day"
            ],
            safetyWarning: nil
        )
    ]
}

#Preview {
    EducationView()
        .environmentObject(NavigationViewModel())
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.07, blue: 0.09),
                    Color(red: 0.12, green: 0.16, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
