import SwiftUI

struct WellnessView: View {
    @StateObject private var viewModel = WellnessViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    @State private var showingSetup = false
    @State private var showingHistory = false
    @State private var showingMoodDetail = false
    @State private var inputSleep = 7.0
    @State private var inputMood = "Content"
    
    let moods = ["Energized", "Content", "Tired", "Stressed", "Anxious"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.backgroundGrouped.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // --- TITLE HEADER ---
                        HStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.pink)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.pink.opacity(0.15))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Wellness Hub")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                                Text("Track your daily balance")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        if let log = viewModel.todayLog {
                            // --- LARGE CURRENT DAY CARD ---
                            VStack(spacing: 0) {
                                // Top Section: Date, Mood, Streak
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Today")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white.opacity(0.8))
                                                .textCase(.uppercase)
                                                .tracking(1)
                                            
                                            Text(Date(), style: .date)
                                                .font(.system(.title3, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        // Streak Badge
                                        HStack(spacing: 6) {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("\(viewModel.currentStreak)")
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                            Text("day\(viewModel.currentStreak != 1 ? "s" : "")")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(12)
                                    }
                                    
                                    // Mood Display
                                    Button(action: { showingMoodDetail = true }) {
                                        HStack(spacing: 12) {
                                            Text(log.mood.wellnessMoodEmoji())
                                                .font(.system(size: 40))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Feeling")
                                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .textCase(.uppercase)
                                                    .tracking(0.5)
                                                Text(log.mood)
                                                    .font(.system(.title3, design: .rounded))
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "info.circle.fill")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        .padding(16)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(24)
                                .background(
                                    LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                
                                // Progress Rings Section
                                HStack(spacing: 24) {
                                    ProgressRing(value: log.sleepHours, total: WellnessLog.sleepGoal, icon: "moon.fill", color: .purple, label: "Sleep")
                                    ProgressRing(value: Double(log.waterIntake), total: Double(WellnessLog.waterGoal), icon: "drop.fill", color: .blue, label: "Water")
                                    ProgressRing(value: Double(log.exerciseMinutes), total: Double(WellnessLog.exerciseGoal), icon: "figure.run", color: .green, label: "Move")
                                }
                                .padding(.vertical, 28)
                                .padding(.horizontal, 24)
                                .background(Theme.cardBackground)
                                
                                // Quick Actions Section
                                VStack(spacing: 12) {
                                    ControlCard(
                                        title: "Hydration",
                                        value: "\(log.waterIntake) oz",
                                        icon: "drop.fill",
                                        color: .blue,
                                        progress: Double(log.waterIntake) / Double(WellnessLog.waterGoal),
                                        onMinus: { viewModel.updateMetric(key: "waterIntake", value: max(0, log.waterIntake - 8)) },
                                        onPlus: { viewModel.updateMetric(key: "waterIntake", value: log.waterIntake + 8) }
                                    )
                                    
                                    ControlCard(
                                        title: "Movement",
                                        value: "\(log.exerciseMinutes) min",
                                        icon: "figure.run",
                                        color: .green,
                                        progress: Double(log.exerciseMinutes) / Double(WellnessLog.exerciseGoal),
                                        onMinus: { viewModel.updateMetric(key: "exerciseMinutes", value: max(0, log.exerciseMinutes - 10)) },
                                        onPlus: { viewModel.updateMetric(key: "exerciseMinutes", value: log.exerciseMinutes + 10) }
                                    )
                                    
                                    ControlCard(
                                        title: "Sleep",
                                        value: "\(String(format: "%.1f", log.sleepHours)) hrs",
                                        icon: "moon.fill",
                                        color: .purple,
                                        progress: log.sleepHours / WellnessLog.sleepGoal,
                                        onMinus: { viewModel.updateMetric(key: "sleepHours", value: max(0, log.sleepHours - 0.5)) },
                                        onPlus: { viewModel.updateMetric(key: "sleepHours", value: log.sleepHours + 0.5) }
                                    )
                                }
                                .padding(24)
                                .background(Theme.cardBackground)
                                
                                // Wellness Insight
                                InsightCard(log: log)
                                    .padding(24)
                                    .background(Theme.cardBackground)
                            }
                            .cornerRadius(24)
                            .shadow(color: Color.pink.opacity(0.3), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, 20)
                            
                            // --- COMPACT WEEKLY OVERVIEW ---
                            if !viewModel.weekLogs.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("This Week")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.textPrimary)
                                        .padding(.horizontal, 24)
                                    
                                    WeeklyCompactView(logs: viewModel.weekLogs)
                                }
                                .padding(.top, 8)
                            }
                            
                            // --- COMPACT RECENT LOGS ---
                            if viewModel.allLogs.count > 1 {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Recent Days")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.textPrimary)
                                        
                                        Spacer()
                                        
                                        Button(action: { showingHistory = true }) {
                                            HStack(spacing: 4) {
                                                Text("View All")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(.semibold)
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12, weight: .semibold))
                                            }
                                            .foregroundColor(Theme.brandPrimary)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(viewModel.allLogs.filter { !Calendar.current.isDateInToday($0.date) }.prefix(7), id: \.id) { log in
                                                CompactLogCard(log: log)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            
                        } else {
                            // --- EMPTY STATE ---
                            emptyStateView
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // --- Bottom Action Bar ---
                bottomActionBar
            }
            .navigationTitle("Wellness Hub")
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
                    HStack(spacing: 16) {
                        Button(action: { showingHistory = true }) {
                            Image(systemName: "calendar")
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
            .sheet(isPresented: $showingSetup) {
                setupSheetView
            }
            .sheet(isPresented: $showingHistory) {
                WellnessHistoryView(logs: viewModel.allLogs)
            }
            .alert("Mood Details", isPresented: $showingMoodDetail) {
                Button("OK", role: .cancel) { }
            } message: {
                if let log = viewModel.todayLog {
                    Text("Current Mood: \(log.mood)\n\nTake a moment to reflect on what's influencing your mood today. Remember, it's okay to feel different emotions throughout the day.")
                }
            }
            .onAppear {
                viewModel.fetchAllData()
            }
            .onDisappear { viewModel.detachListener() }
        }
    }
    
    // --- Helper Views ---
    
    var emptyStateView: some View {
        VStack(spacing: 25) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                .shadow(color: .orange.opacity(0.4), radius: 15)
                .padding(.top, 40)
            
            Text("Good Day!")
                .font(.system(.title2, design: .rounded)).bold()
                .foregroundColor(Theme.textPrimary)
            
            Text("Ready to track today's wellness journey?")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingSetup = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Start My Day")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Capsule())
                .shadow(color: Color.pink.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    var bottomActionBar: some View {
        VStack(spacing: 0) {
            Spacer()
            
            LinearGradient(
                colors: [Theme.backgroundGrouped.opacity(0), Theme.backgroundGrouped],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            HStack(spacing: 12) {
                Spacer()
                
                if viewModel.todayLog != nil {
                    Button(action: {
                        inputSleep = viewModel.todayLog?.sleepHours ?? 7.0
                        inputMood = viewModel.todayLog?.mood ?? "Content"
                        showingSetup = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Update Log")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.pink.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                } else {
                    Button(action: { showingSetup = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Log Today")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.pink.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Theme.backgroundGrouped)
        }
    }
    
    // First-time setup sheet
    private var setupSheetView: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            
                            Text("Daily Check-in")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Log your wellness metrics")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Sleep Input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Last Night's Sleep")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            HStack {
                                Text("\(inputSleep, specifier: "%.1f") hrs")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                    .frame(width: 80)
                                
                                Slider(value: $inputSleep, in: 0...12, step: 0.5)
                                    .tint(.purple)
                            }
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 2)
                        
                        // Mood Input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "face.smiling.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18, weight: .semibold))
                                Text("How Are You Feeling?")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(moods, id: \.self) { mood in
                                    Button(action: { inputMood = mood }) {
                                        VStack(spacing: 6) {
                                            Text(mood.wellnessMoodEmoji())
                                                .font(.system(size: 28))
                                            Text(mood)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(inputMood == mood ? Color.orange.opacity(0.15) : Theme.backgroundSecondary)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(inputMood == mood ? Color.orange : Color.clear, lineWidth: 2)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 2)
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 14))
                                Text("Wellness Tip")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Text("Start your day by tracking your baseline wellness. You can update your water intake and exercise throughout the day!")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                // Save Button
                Button(action: {
                    viewModel.createDay(sleep: inputSleep, mood: inputMood)
                    showingSetup = false
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Save Entry")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Theme.backgroundGrouped)
            }
            .background(Theme.backgroundGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingSetup = false
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - UI Components

struct ProgressRing: View {
    let value: Double, total: Double, icon: String, color: Color, label: String
    var progress: Double { min(value / total, 1.0) }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            .frame(width: 80, height: 80)
            
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

struct ControlCard: View {
    let title: String, value: String, icon: String, color: Color
    let progress: Double
    let onMinus: () -> Void, onPlus: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 22, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.15))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(color)
                            .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: progress)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 0) {
                Button(action: onMinus) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                .frame(width: 44, height: 44)
                .opacity(0.8)
                
                Button(action: onPlus) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Compact Views for Past Days

struct WeeklyCompactView: View {
    let logs: [WellnessLog]
    
    var averageSleep: Double {
        guard !logs.isEmpty else { return 0 }
        return logs.map { $0.sleepHours }.reduce(0, +) / Double(logs.count)
    }
    
    var averageWater: Double {
        guard !logs.isEmpty else { return 0 }
        return Double(logs.map { $0.waterIntake }.reduce(0, +)) / Double(logs.count)
    }
    
    var averageExercise: Double {
        guard !logs.isEmpty else { return 0 }
        return Double(logs.map { $0.exerciseMinutes }.reduce(0, +)) / Double(logs.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            CompactStatPill(icon: "moon.fill", color: .purple, value: "\(averageSleep, specifier: "%.1f")h", label: "Sleep")
            CompactStatPill(icon: "drop.fill", color: .blue, value: "\(Int(averageWater))oz", label: "Water")
            CompactStatPill(icon: "figure.run", color: .green, value: "\(Int(averageExercise))m", label: "Move")
        }
        .padding(.horizontal, 20)
    }
}

struct CompactStatPill: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 3)
    }
}

struct CompactLogCard: View {
    let log: WellnessLog
    
    var body: some View {
        VStack(spacing: 10) {
            // Date and Mood
            VStack(spacing: 6) {
                Text(log.date, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Text(log.mood.wellnessMoodEmoji())
                    .font(.system(size: 28))
            }
            
            Divider()
            
            // Compact Stats
            VStack(spacing: 8) {
                CompactStatRow(icon: "moon.fill", color: .purple, value: "\(log.sleepHours, specifier: "%.1f")h")
                CompactStatRow(icon: "drop.fill", color: .blue, value: "\(log.waterIntake)oz")
                CompactStatRow(icon: "figure.run", color: .green, value: "\(log.exerciseMinutes)m")
            }
        }
        .padding(16)
        .frame(width: 140)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 3)
    }
}

struct CompactStatRow: View {
    let icon: String
    let color: Color
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
        }
    }
}

struct InsightCard: View {
    let log: WellnessLog
    
    var insight: String {
        let sleepPercent = (log.sleepHours / WellnessLog.sleepGoal) * 100
        let waterPercent = (Double(log.waterIntake) / Double(WellnessLog.waterGoal)) * 100
        let exercisePercent = (Double(log.exerciseMinutes) / Double(WellnessLog.exerciseGoal)) * 100
        
        if sleepPercent >= 100 && waterPercent >= 100 && exercisePercent >= 100 {
            return "🎉 Amazing! You've hit all your wellness goals today!"
        } else if sleepPercent < 80 {
            return "💤 Try to get more sleep tonight. Quality rest is essential for your wellbeing."
        } else if waterPercent < 50 {
            return "💧 Remember to stay hydrated! Water helps you stay focused and energized."
        } else if exercisePercent < 50 {
            return "🏃‍♂️ A little movement goes a long way. Even a short walk can boost your mood!"
        } else {
            return "✨ Great progress today! Keep up the momentum with your wellness routine."
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
            
            Text(insight)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(14)
    }
}

// MARK: - Wellness History View

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
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 50))
                                .foregroundColor(Theme.textSecondary.opacity(0.3))
                            Text("No History Yet")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Theme.textPrimary)
                            Text("Your wellness logs will appear here")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(sortedLogs, id: \.id) { log in
                        HistoryLogCard(log: log)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGrouped)
            .navigationTitle("Wellness History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.brandPrimary)
                }
            }
        }
    }
}

struct HistoryLogCard: View {
    let log: WellnessLog
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.date, style: .date)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(log.mood.wellnessMoodEmoji())
                            .font(.system(size: 14))
                        Text(log.mood)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            }
            
            Divider()
            
            HStack(spacing: 20) {
                HistoryStatItem(icon: "moon.fill", color: .purple, value: "\(log.sleepHours, specifier: "%.1f")h")
                HistoryStatItem(icon: "drop.fill", color: .blue, value: "\(log.waterIntake)oz")
                HistoryStatItem(icon: "figure.run", color: .green, value: "\(log.exerciseMinutes)m")
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 4)
    }
}

struct HistoryStatItem: View {
    let icon: String
    let color: Color
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14, weight: .semibold))
            Text(value)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}
