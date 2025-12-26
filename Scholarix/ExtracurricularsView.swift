import SwiftUI

struct ExtracurricularsView: View {
    @StateObject private var viewModel = ExtracurricularsViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    // --- Navigation State ---
    @State private var activityForDetail: Activity?
    @State private var activityForEdit: Activity?
    
    @State private var showingAddSheet = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.backgroundGrouped.ignoresSafeArea()
                
                // --- Navigation Links (Headless) ---
                Group {
                    // 1. Detail View
                    if let activity = activityForDetail {
                        NavigationLink(
                            destination: ActivityDetailView(viewModel: viewModel, activityId: activity.id ?? ""),
                            tag: activity.id ?? "",
                            selection: Binding(get: { activityForDetail?.id }, set: { _ in self.activityForDetail = nil })
                        ) { EmptyView() }
                    }
                    
                    // 2. Edit View
                    if let activity = activityForEdit {
                        NavigationLink(
                            destination: EditActivityView(activity: activity, viewModel: viewModel),
                            tag: activity.id ?? "",
                            selection: Binding(get: { activityForEdit?.id }, set: { _ in self.activityForEdit = nil })
                        ) { EmptyView() }
                    }
                }
                
                // Content
                List {
                    // --- TITLE HEADER ---
                    Section {
                        header(title: "Extracurriculars", subtitle: "Clubs, Sports & Awards", icon: "trophy.fill", color: .orange)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top, 10)
                    }

                    // 1. Impact Summary Card
                    Section {
                        ImpactCard(hours: viewModel.totalHours, active: viewModel.activeCount)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                    }
                    
                    // 2. Activities List
                    if viewModel.filteredActivities.isEmpty {
                        Section {
                            emptyStateView
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        Section(header: Text("Activities").font(.headline).foregroundColor(.primary)) {
                            ForEach(viewModel.filteredActivities) { activity in
                                ActivityCard(
                                    activity: activity,
                                    onSelect: { activityForDetail = activity }, // Tap card -> Detail
                                    onEdit: { activityForEdit = activity },     // Edit button -> Edit Screen
                                    onDelete: { viewModel.deleteActivity(activity) }
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80) // Space for bottom bar
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationTitle("Extracurricular Hub")
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
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddActivityView(isPresented: $showingAddSheet, viewModel: viewModel)
            }
            .onAppear { viewModel.fetchActivities() }
            .onDisappear { viewModel.detachListener() }
            .dismissKeyboardOnTap()
        }
    }
    
    // --- Components ---
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(Theme.warning.opacity(0.4))
            Text("Build Your Profile 🏆")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            Text("Add clubs, sports, and awards here to showcase your achievements")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
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
            
            ZStack {
                if isSearching {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.brandPrimary)
                        
                        TextField("Search activities...", text: $viewModel.searchText)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                            .submitLabel(.done)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSearching = false
                                viewModel.searchText = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Theme.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Theme.shadowLight, radius: 10, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.brandPrimary.opacity(0.3), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    HStack(spacing: 12) {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSearching = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 48, height: 48)
                                .background(Theme.cardBackground)
                                .clipShape(Circle())
                                .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 3)
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingAddSheet = true
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Add Activity")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [Theme.warning, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: Theme.warning.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    .padding(.horizontal, 16)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearching)
            .padding(.bottom, 16)
            .background(Theme.backgroundGrouped)
        }
    }
}

// --- Subviews ---

struct ImpactCard: View {
    let hours: Double
    let active: Int
    
    @State private var animateNumbers = false
    
    var body: some View {
        HStack(spacing: 0) {
            statView(title: "Total Hours", value: String(format: "%.0f", hours), icon: "clock.fill")
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 2, height: 50)
            statView(title: "Active Now", value: "\(active)", icon: "flame.fill")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(
            LinearGradient(colors: [Theme.warning, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: Theme.warning.opacity(0.4), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(animateNumbers ? 1.0 : 0.95)
        .opacity(animateNumbers ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateNumbers = true
            }
        }
    }
    
    func statView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            Text(value)
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .tracking(1.2)
        }
        .frame(maxWidth: .infinity)
    }
}

// --- ACTIVITY CARD - Redesigned to match CourseCard format ---
struct ActivityCard: View {
    let activity: Activity
    let onSelect: () -> Void // New selection handler
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDescription = false
    @State private var isPressed = false
    
    var themeColor: Color {
        switch activity.type {
        case "Sport": return Theme.activitySport
        case "Club": return Theme.activityClub
        case "Service": return Color.pink
        case "Award": return Theme.warning
        case "Work": return Theme.info
        default: return Theme.brandSecondary
        }
    }
    
    var badgeText: String {
        if let hours = activity.hours, hours > 0 {
            return "\(Int(hours))h"
        } else if activity.endDate == nil {
            return "Active"
        }
        return ""
    }
    
    var badgeAccessibilityLabel: String {
        if let hours = activity.hours, hours > 0 {
            return "\(Int(hours)) hours"
        } else if activity.endDate == nil {
            return "Active"
        }
        return ""
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Vertical Capsule indicator (matching CourseCard)
            Capsule()
                .fill(themeColor)
                .frame(width: 6)
                .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                // Activity title with info button
                HStack(alignment: .center, spacing: 6) {
                    Text(activity.title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    if let description = activity.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingDescription = true
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(themeColor)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Info about \(activity.title)")
                        .alert(isPresented: $showingDescription) {
                            Alert(
                                title: Text(activity.title),
                                message: Text(description),
                                dismissButton: .default(Text("Got it!"))
                            )
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    // Type badge (matching CourseCard style)
                    if !activity.type.isEmpty {
                        Text(activity.type)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeColor.opacity(0.2))
                            .foregroundColor(themeColor)
                            .clipShape(Capsule())
                    }
                    
                    // Position text
                    if !activity.position.isEmpty {
                        Text(activity.position)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Hours/Active Badge (matching CourseCard grade badge)
            if !badgeText.isEmpty {
                Text(badgeText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(themeColor)
                    .clipShape(Capsule())
                    .accessibilityLabel(badgeAccessibilityLabel)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = false
                }
                onSelect() // Triggers navigation to Detail View
            }
        }
        .swipeActions(edge: .leading) {
            Button { onEdit() } label: { Label("Edit", systemImage: "pencil") }.tint(.orange)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
    }
}
