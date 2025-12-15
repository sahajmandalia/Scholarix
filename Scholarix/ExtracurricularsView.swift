import SwiftUI

struct ExtracurricularsView: View {
    @StateObject private var viewModel = ExtracurricularsViewModel()
    @EnvironmentObject var menuManager: MenuManager // For the hamburger menu
    
    @State private var showingAddSheet = false
    @State private var selectedActivity: Activity?
    @State private var isSearching = false
    
    var body: some View {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    Theme.backgroundGrouped.ignoresSafeArea()
                    
                    // Content
                    List {
                        // --- NEW TITLE HEADER ---
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
                                        onEdit: { selectedActivity = activity },
                                        onDelete: { viewModel.deleteActivity(activity) }
                                    )
                                    .swipeActions(edge: .leading) {
                                        Button { selectedActivity = activity } label: { Label("Edit", systemImage: "pencil") }
                                            .tint(.orange)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) { viewModel.deleteActivity(activity) } label: { Label("Delete", systemImage: "trash") }
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
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
                .navigationTitle("Extracurricular Hub") // <--- UPDATED TITLE
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
                .sheet(item: $selectedActivity) { activity in
                    EditActivityView(activity: activity, viewModel: viewModel)
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
                        
                        Button(action: { showingAddSheet = true }) {
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
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 16)
            .background(Theme.backgroundGrouped)
        }
    }
}

// --- Subviews ---

struct ImpactCard: View {
    let hours: Double
    let active: Int
    
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

struct ActivityCard: View {
    let activity: Activity
    let onEdit: () -> Void
    let onDelete: () -> Void
    
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
    
    var icon: String {
        switch activity.type {
        case "Sport": return "sportscourt.fill"
        case "Club": return "person.3.fill"
        case "Service": return "heart.fill"
        case "Award": return "rosette"
        case "Work": return "briefcase.fill"
        default: return "star.fill"
        }
    }
    
    var durationString: String {
        let start = activity.startDate.formatted(date: .abbreviated, time: .omitted)
        let end = activity.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "Present"
        return "\(start) - \(end)"
    }
    
    var isOngoing: Bool {
        return activity.endDate == nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section with icon and main info
            HStack(alignment: .top, spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(themeColor.opacity(0.3), lineWidth: 2)
                        )
                    Image(systemName: icon)
                        .foregroundColor(themeColor)
                        .font(.system(size: 24, weight: .semibold))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(activity.title)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                    
                    Text(activity.position)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textSecondary)
                    
                    HStack(spacing: 8) {
                        // Type badge
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(activity.type)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(themeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(themeColor.opacity(0.15))
                        .cornerRadius(8)
                        
                        // Status badge for ongoing activities
                        if isOngoing {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Theme.success)
                                    .frame(width: 6, height: 6)
                                Text("Active")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Theme.success)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.success.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            
            // Middle section with stats
            HStack(spacing: 0) {
                // Hours stat
                if let hours = activity.hours, hours > 0 {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("\(Int(hours))")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(themeColor)
                        
                        Text("HOURS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                            .tracking(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeColor.opacity(0.08))
                    
                    Divider()
                }
                
                // Duration stat
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                        Text(durationString)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundColor(Theme.textPrimary)
                    
                    Text("TIMELINE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .tracking(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.textSecondary.opacity(0.05))
            }
            
            // Description section (if available)
            if let description = activity.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Description")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Theme.textSecondary)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(3)
                }
                .padding(16)
                .background(Theme.backgroundTertiary.opacity(0.5))
            }
            
            // Bottom section with actions
            Divider()
            
            HStack(spacing: 16) {
                Button(action: onEdit) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Edit")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Theme.warning)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.warning.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Theme.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.danger.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.shadowMedium, radius: 8, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.borderSubtle, lineWidth: 0.5)
        )
    }
}
