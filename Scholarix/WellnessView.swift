import SwiftUI

struct WellnessView: View {
    @StateObject private var viewModel = WellnessViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    @State private var showingSetup = false
    @State private var inputSleep = 7.0
    @State private var inputMood = "Content"
    
    let moods = ["Energized", "Content", "Tired", "Stressed", "Anxious"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGrouped.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Title Header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Wellness Hub")
                                    .font(.system(.title, design: .rounded)).bold()
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.pink)
                                    .font(.title2)
                            }
                            Text("Track your daily balance")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        if let log = viewModel.todayLog {
                            // --- Interactive Dashboard ---
                            HStack(spacing: 20) {
                                ProgressRing(value: log.sleepHours, total: WellnessLog.sleepGoal, icon: "moon.fill", color: .purple, label: "Sleep")
                                ProgressRing(value: Double(log.waterIntake), total: Double(WellnessLog.waterGoal), icon: "drop.fill", color: .blue, label: "Water")
                                ProgressRing(value: Double(log.exerciseMinutes), total: Double(WellnessLog.exerciseGoal), icon: "figure.run", color: .green, label: "Move")
                            }
                            .padding(.vertical, 10)
                            
                            VStack(spacing: 16) {
                                ControlCard(title: "Hydration", value: "\(log.waterIntake) oz", icon: "drop.fill", color: .blue,
                                            onMinus: { viewModel.updateMetric(key: "waterIntake", value: max(0, log.waterIntake - 8)) },
                                            onPlus: { viewModel.updateMetric(key: "waterIntake", value: log.waterIntake + 8) })
                                
                                ControlCard(title: "Movement", value: "\(log.exerciseMinutes) min", icon: "figure.run", color: .green,
                                            onMinus: { viewModel.updateMetric(key: "exerciseMinutes", value: max(0, log.exerciseMinutes - 10)) },
                                            onPlus: { viewModel.updateMetric(key: "exerciseMinutes", value: log.exerciseMinutes + 10) })
                                
                                ControlCard(title: "Sleep Adjust", value: "\(String(format: "%.1f", log.sleepHours)) hrs", icon: "zzz", color: .purple,
                                            onMinus: { viewModel.updateMetric(key: "sleepHours", value: max(0, log.sleepHours - 0.5)) },
                                            onPlus: { viewModel.updateMetric(key: "sleepHours", value: log.sleepHours + 0.5) })
                            }
                            .padding(.horizontal)
                            
                        } else {
                            // --- Startup / Setup View ---
                            VStack(spacing: 25) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                                    .shadow(color: .orange.opacity(0.4), radius: 15)
                                    .padding(.top, 40)
                                
                                Text("Good Morning!")
                                    .font(.system(.title2, design: .rounded)).bold()
                                
                                Text("Ready to track today's wellness journey?")
                                    .foregroundColor(Theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Button(action: { showingSetup = true }) {
                                    Text("Start My Day")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 16)
                                        .background(Theme.brandGradient)
                                        .clipShape(Capsule())
                                        .shadow(color: Theme.brandPrimary.opacity(0.3), radius: 10, y: 5)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { menuManager.open() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingSetup) {
                setupSheetView
            }
            .onAppear { viewModel.fetchTodayLog() }
            .onDisappear { viewModel.detachListener() }
        }
    }
    
    // First-time setup sheet
    private var setupSheetView: some View {
        VStack(spacing: 30) {
            Text("Daily Check-in")
                .font(.title3).bold()
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Last Night's Sleep")
                    .font(.subheadline).foregroundColor(.secondary)
                HStack {
                    Text("\(inputSleep, specifier: "%.1f") hrs")
                        .font(.headline).foregroundColor(.purple)
                        .frame(width: 70)
                    Slider(value: $inputSleep, in: 0...12, step: 0.5)
                }
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(12)
            
            Button(action: {
                viewModel.createDay(sleep: inputSleep, mood: inputMood)
                showingSetup = false
            }) {
                Text("Log Entry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.brandPrimary)
                    .cornerRadius(12)
            }
        }
        .padding()
        .presentationDetents([.medium])
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
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
        }
    }
}

struct ControlCard: View {
    let title: String, value: String, icon: String, color: Color, onMinus: () -> Void, onPlus: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value).font(.system(.title3, design: .rounded)).fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Button(action: onMinus) {
                    Image(systemName: "minus").frame(width: 40, height: 40)
                }
                Divider().frame(height: 24)
                Button(action: onPlus) {
                    Image(systemName: "plus").frame(width: 40, height: 40)
                }
            }
            .background(Color(.tertiarySystemFill))
            .cornerRadius(12)
            .foregroundColor(Theme.textPrimary)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: Theme.shadowLight, radius: 8, y: 4)
    }
}
