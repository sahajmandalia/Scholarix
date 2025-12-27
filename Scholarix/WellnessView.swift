import SwiftUI

struct WellnessView: View {
    @StateObject private var viewModel = WellnessViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    // UI State
    @State private var showingSetup = false
    @State private var showingHistory = false
    @State private var showingMoodDetail = false
    @State private var showingGoalSettings = false
    @State private var hasShownGoalSettings = false
    
    // Setup Inputs
    @State private var inputSleep = 7.0
    @State private var inputMood = "Content"
    
    // Goal Settings
    @State private var customSleepGoal = 8.0
    @State private var customWaterGoal = 8 // Changed to cups (was 64 oz)
    @State private var customExerciseGoal = 60
    
    let moods = ["Energized", "Content", "Tired", "Stressed", "Anxious"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Theme.backgroundGrouped.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // --- 1. HEADER ---
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Date().formatted(date: .complete, time: .omitted).uppercased())
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1)
                                
                                Text("Wellness Hub")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            Spacer()
                            
                            // Goals Button (moved from toolbar, more prominent)
                            Button(action: { showingGoalSettings = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "target")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Goals")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.wellnessGradient)
                                .clipShape(Capsule())
                                .shadow(color: Color.green.opacity(0.3), radius: 5, y: 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        if let log = viewModel.todayLog {
                            // --- 2. PROGRESS RINGS ROW ---
                            HStack(spacing: 24) {
                                ProgressRing(
                                    value: log.sleepHours,
                                    total: log.effectiveSleepGoal(),
                                    icon: "moon.fill",
                                    color: .purple,
                                    label: "Sleep"
                                )
                                ProgressRing(
                                    value: Double(log.waterIntake),
                                    total: Double(log.effectiveWaterGoal()),
                                    icon: "drop.fill",
                                    color: .blue,
                                    label: "Water"
                                )
                                ProgressRing(
                                    value: Double(log.exerciseMinutes),
                                    total: Double(log.effectiveExerciseGoal()),
                                    icon: "figure.run",
                                    color: .green,
                                    label: "Move"
                                )
                            }
                            .padding(.vertical, 28)
                            .frame(maxWidth: .infinity)
                            .background(Theme.cardBackground)
                            .cornerRadius(24)
                            .shadow(color: Theme.shadowLight, radius: 12, y: 6)
                            .padding(.horizontal, 20)
                            
                            // --- 3. MOOD CARD ---
                            Button(action: {
                                HapticManager.selection()
                                showingMoodDetail = true
                            }) {
                                HStack(spacing: 16) {
                                    Text(log.mood.wellnessMoodEmoji())
                                        .font(.system(size: 48))
                                        .padding(12)
                                        .background(Theme.backgroundGrouped)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Current Mood")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.textSecondary)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        Text(log.mood)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .padding(18)
                                .background(Theme.cardBackground)
                                .cornerRadius(20)
                                .shadow(color: Theme.shadowLight, radius: 10, y: 5)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            
                            // --- 4. TRACKING CONTROLS ---
                            VStack(spacing: 18) {
                                // Water (changed to cups)
                                LargeControlCard(
                                    title: "Hydration",
                                    value: "\(log.waterIntake / 8)", // Convert oz to cups
                                    unit: "cups",
                                    icon: "drop.fill",
                                    color: .blue,
                                    progress: Double(log.waterIntake) / Double(log.effectiveWaterGoal()),
                                    onMinus: {
                                        let newValue = max(0, log.waterIntake - 8) // 1 cup = 8 oz
                                        viewModel.updateMetric(key: "waterIntake", value: newValue)
                                        HapticManager.selection()
                                    },
                                    onPlus: {
                                        let newValue = log.waterIntake + 8 // 1 cup = 8 oz
                                        viewModel.updateMetric(key: "waterIntake", value: newValue)
                                        HapticManager.selection()
                                    }
                                )
                                
                                // Exercise (changed increment to 10)
                                LargeControlCard(
                                    title: "Exercise",
                                    value: "\(log.exerciseMinutes)",
                                    unit: "min",
                                    icon: "figure.run",
                                    color: .green,
                                    progress: Double(log.exerciseMinutes) / Double(log.effectiveExerciseGoal()),
                                    onMinus: {
                                        let newValue = max(0, log.exerciseMinutes - 10) // Changed from 15 to 10
                                        viewModel.updateMetric(key: "exerciseMinutes", value: newValue)
                                        HapticManager.selection()
                                    },
                                    onPlus: {
                                        let newValue = log.exerciseMinutes + 10 // Changed from 15 to 10
                                        viewModel.updateMetric(key: "exerciseMinutes", value: newValue)
                                        HapticManager.selection()
                                    }
                                )
                                
                                // Sleep
                                LargeControlCard(
                                    title: "Sleep",
                                    value: String(format: "%.1f", log.sleepHours),
                                    unit: "hrs",
                                    icon: "moon.stars.fill",
                                    color: .purple,
                                    progress: log.sleepHours / log.effectiveSleepGoal(),
                                    onMinus: {
                                        let newValue = max(0, log.sleepHours - 0.5)
                                        viewModel.updateMetric(key: "sleepHours", value: newValue)
                                        HapticManager.selection()
                                    },
                                    onPlus: {
                                        let newValue = log.sleepHours + 0.5
                                        viewModel.updateMetric(key: "sleepHours", value: newValue)
                                        HapticManager.selection()
                                    }
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // --- 5. INSIGHTS ---
                            InsightCard(log: log)
                                .padding(.horizontal, 20)
                            
                        } else {
                            // --- EMPTY STATE ---
                            emptyStateView
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 120) // Space for bottom bar
                }
            }
            .navigationTitle("Wellness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { menuManager.open() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // History button moved here from header
                        Button(action: { showingHistory = true }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                }
            }
            // Setup Sheet
            .sheet(isPresented: $showingSetup) {
                setupSheetView
            }
            // Goal Settings Sheet
            .sheet(isPresented: $showingGoalSettings) {
                goalSettingsSheetView
            }
            // History Sheet (Pass logs properly)
            .sheet(isPresented: $showingHistory) {
                WellnessHistoryView(logs: []) // Pass real logs if ViewModel has them
            }
            // Mood Alert
            .alert("Mood Check-in", isPresented: $showingMoodDetail) {
                Button("OK", role: .cancel) { }
            } message: {
                if let log = viewModel.todayLog {
                    Text("You are feeling \(log.mood) today.\nKeep tracking to see patterns!")
                }
            }
            .onAppear {
                viewModel.fetchTodayLog()
                
                // Show goal settings on first launch
                if !hasShownGoalSettings && !UserDefaults.standard.bool(forKey: "hasSetWellnessGoals") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        hasShownGoalSettings = true
                        showingGoalSettings = true
                    }
                }
            }
            .onDisappear { viewModel.detachListener() }
        }
    }
    
    // MARK: - Components
    
    var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)
            ZStack {
                Circle().fill(Color.orange.opacity(0.1)).frame(width: 200, height: 200)
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .orange.opacity(0.5), radius: 20)
            }
            
            VStack(spacing: 8) {
                Text("Good Morning!")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Start your day with intention.\nTrack your sleep and mood to begin.")
                    .font(.body)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                HapticManager.impact(style: .medium)
                showingSetup = true
            }) {
                Text("Start Day")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Theme.wellnessGradient)
                    .clipShape(Capsule())
                    .shadow(color: Color.green.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.vertical, 30)
    }
    
    private var setupSheetView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Daily Check-in").font(.title2).bold().padding(.top)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sleep Duration").font(.headline).foregroundColor(Theme.textSecondary)
                        HStack {
                            Image(systemName: "moon.fill").foregroundColor(.purple)
                            Text("\(String(format: "%.1f", inputSleep)) hrs").font(.title3).bold()
                            Spacer()
                        }
                        Slider(value: $inputSleep, in: 0...12, step: 0.5).tint(.purple)
                    }
                    .padding().background(Theme.cardBackground).cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Mood").font(.headline).foregroundColor(Theme.textSecondary)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    inputMood = mood
                                    HapticManager.selection()
                                }) {
                                    VStack {
                                        Text(mood.wellnessMoodEmoji()).font(.largeTitle)
                                        Text(mood).font(.caption).bold()
                                    }
                                    .frame(maxWidth: .infinity).padding(10)
                                    .background(inputMood == mood ? Theme.brandPrimary.opacity(0.15) : Theme.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(inputMood == mood ? Theme.brandPrimary : Color.clear, lineWidth: 2))
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        HapticManager.notification(type: .success)
                        viewModel.createDay(sleep: inputSleep, mood: inputMood)
                        showingSetup = false
                    }) {
                        Text("Save Entry").bold().foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(Theme.wellnessGradient).cornerRadius(16)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Theme.backgroundGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingSetup = false }
                }
            }
        }
    }
    
    private var goalSettingsSheetView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Set Your Goals").font(.title2).bold().padding(.top)
                    
                    Text("Customize your wellness targets to match your personal health goals.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "moon.stars.fill").foregroundColor(.purple)
                            Text("Sleep Goal").font(.headline).foregroundColor(Theme.textSecondary)
                        }
                        HStack {
                            Text("\(String(format: "%.1f", customSleepGoal)) hrs").font(.title3).bold()
                            Spacer()
                        }
                        Slider(value: $customSleepGoal, in: 4...12, step: 0.5).tint(.purple)
                    }
                    .padding().background(Theme.cardBackground).cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "drop.fill").foregroundColor(.blue)
                            Text("Water Goal").font(.headline).foregroundColor(Theme.textSecondary)
                        }
                        HStack {
                            Text("\(customWaterGoal) cups").font(.title3).bold() // Changed from oz to cups
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(customWaterGoal) },
                            set: { customWaterGoal = Int($0) }
                        ), in: 4...16, step: 1).tint(.blue) // Changed range to 4-16 cups (32-128 oz)
                    }
                    .padding().background(Theme.cardBackground).cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "figure.run").foregroundColor(.green)
                            Text("Exercise Goal").font(.headline).foregroundColor(Theme.textSecondary)
                        }
                        HStack {
                            Text("\(customExerciseGoal) min").font(.title3).bold()
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(customExerciseGoal) },
                            set: { customExerciseGoal = Int($0) }
                        ), in: 10...180, step: 10).tint(.green) // Changed step from 15 to 10
                    }
                    .padding().background(Theme.cardBackground).cornerRadius(16)
                    
                    Button(action: {
                        HapticManager.notification(type: .success)
                        // Convert cups to oz for storage
                        viewModel.updateGoals(
                            sleepGoal: customSleepGoal,
                            waterGoal: customWaterGoal * 8, // Convert cups to oz
                            exerciseGoal: customExerciseGoal
                        )
                        // Mark that goals have been set
                        UserDefaults.standard.set(true, forKey: "hasSetWellnessGoals")
                        showingGoalSettings = false
                    }) {
                        Text("Save Goals").bold().foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(Theme.wellnessGradient)
                            .cornerRadius(16)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Theme.backgroundGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingGoalSettings = false }
                }
            }
        }
        .onAppear {
            if let log = viewModel.todayLog {
                customSleepGoal = log.effectiveSleepGoal()
                customWaterGoal = log.effectiveWaterGoal() / 8 // Convert oz to cups
                customExerciseGoal = log.effectiveExerciseGoal()
            }
        }
    }
}

// MARK: - Reusable Components

struct LargeControlCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let progress: Double
    let onMinus: () -> Void
    let onPlus: () -> Void
    
    @State private var minusPressed = false
    @State private var plusPressed = false
    @State private var minusTimer: Timer?
    @State private var plusTimer: Timer?
    
    private let buttonPressAnimationDuration: Double = 0.1
    private let holdRepeatInterval: TimeInterval = 0.15 // How often to repeat when holding
    private let holdStartDelay: TimeInterval = 0.5 // How long before hold starts repeating
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(color)
            }
            
            // Text & Progress
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.8)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.15))
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * min(progress, 1.0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                    }
                }
                .frame(height: 8)
            }
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 10) {
                // Minus Button with Long Press
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(minusPressed ? color : Theme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Theme.backgroundGrouped)
                    .clipShape(Circle())
                    .shadow(color: Theme.shadowLight, radius: 4, y: 2)
                    .scaleEffect(minusPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: minusPressed)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !minusPressed {
                                    minusPressed = true
                                    onMinus() // This already calls HapticManager.selection()
                                    
                                    // Start timer after initial delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + holdStartDelay) {
                                        if minusPressed {
                                            minusTimer = Timer.scheduledTimer(withTimeInterval: holdRepeatInterval, repeats: true) { _ in
                                                onMinus()
                                            }
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                minusPressed = false
                                minusTimer?.invalidate()
                                minusTimer = nil
                            }
                    )
                
                // Plus Button with Long Press
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.4), radius: 5, y: 3)
                    .scaleEffect(plusPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: plusPressed)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !plusPressed {
                                    plusPressed = true
                                    onPlus() // This already calls HapticManager.selection()
                                    
                                    // Start timer after initial delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + holdStartDelay) {
                                        if plusPressed {
                                            plusTimer = Timer.scheduledTimer(withTimeInterval: holdRepeatInterval, repeats: true) { _ in
                                                onPlus()
                                            }
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                plusPressed = false
                                plusTimer?.invalidate()
                                plusTimer = nil
                            }
                    )
            }
        }
        .padding(18)
        .background(Theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: Theme.shadowLight, radius: 10, y: 5)
    }
}

struct ProgressRing: View {
    let value: Double
    let total: Double
    let icon: String
    let color: Color
    let label: String
    var progress: Double { min(value / max(total, 1), 1.0) }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 22, weight: .semibold))
            }
            .frame(width: 84, height: 84)
            
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct InsightCard: View {
    let log: WellnessLog
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Insight")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(insightText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(18)
        .background(Theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: Theme.shadowLight, radius: 10, y: 5)
    }
    
    var insightText: String {
        let sleepGoalMet = log.sleepHours >= log.effectiveSleepGoal()
        let waterGoalMet = log.waterIntake >= log.effectiveWaterGoal()
        let exerciseGoalMet = log.exerciseMinutes >= log.effectiveExerciseGoal()
        let score = (sleepGoalMet ? 1 : 0) + (waterGoalMet ? 1 : 0) + (exerciseGoalMet ? 1 : 0)
        
        if score == 3 { return "You're crushing it! All goals met." }
        if score == 2 { return "Great job! Just one goal left." }
        return "Keep going! Small steps count."
    }
}

// MARK: - Wellness History View (Required for sheet)
struct WellnessHistoryView: View {
    let logs: [WellnessLog]
    @Environment(\.dismiss) var dismiss
    
    var sortedLogs: [WellnessLog] {
        logs.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            List {
                if sortedLogs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No history available yet.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                    .padding(.top, 50)
                } else {
                    ForEach(sortedLogs, id: \.id) { log in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(log.date, style: .date).font(.headline)
                                Text(log.mood).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            if log.sleepHours >= 7 { Image(systemName: "star.fill").foregroundColor(.yellow) }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Helpers
struct HapticManager {
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) { UIImpactFeedbackGenerator(style: style).impactOccurred() }
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) { UINotificationFeedbackGenerator().notificationOccurred(type) }
}
