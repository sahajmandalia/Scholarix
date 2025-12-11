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
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                // Content
                List {
                    // 1. Impact Summary Card
                    Section {
                        ImpactCard(hours: viewModel.totalHours, active: viewModel.activeCount)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
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
            .navigationTitle("Resume Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { menuManager.open() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
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
        }
    }
    
    // --- Components ---
    
    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.3))
            Text("Build Your Profile")
                .font(.headline)
            Text("Add clubs, sports, and awards here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    var bottomActionBar: some View {
        VStack {
            Spacer()
            ZStack {
                if isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search...", text: $viewModel.searchText)
                            .submitLabel(.done)
                        Button(action: { withAnimation { isSearching = false; viewModel.searchText = "" } }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                } else {
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { isSearching = true } }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button(action: { showingAddSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text("Activity")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// --- Subviews ---

struct ImpactCard: View {
    let hours: Double
    let active: Int
    
    var body: some View {
        HStack(spacing: 0) {
            statView(title: "Total Hours", value: String(format: "%.0f", hours))
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 40)
            statView(title: "Active", value: "\(active)")
        }
        .padding(24)
        .background(
            LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .shadow(color: .orange.opacity(0.3), radius: 15, x: 0, y: 8)
    }
    
    func statView(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .tracking(1)
            Text(value)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
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
        case "Sport": return .green
        case "Club": return .blue
        case "Service": return .pink
        case "Award": return .orange
        default: return .purple
        }
    }
    
    var icon: String {
        switch activity.type {
        case "Sport": return "sportscourt.fill"
        case "Club": return "person.3.fill"
        case "Service": return "heart.fill"
        case "Award": return "rosette"
        default: return "star.fill"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(themeColor)
                    .font(.headline)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(activity.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    if let hours = activity.hours, hours > 0 {
                        Text("\(Int(hours))h")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }
                
                Text(activity.position)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
            
            // Menu Button
            Menu {
                Button(action: onEdit) { Label("Edit", systemImage: "pencil") }
                Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.6))
                    .frame(width: 30, height: 30)
                    .padding(.leading, 4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
    }
    
    var dateString: String {
        let start = activity.startDate.formatted(date: .abbreviated, time: .omitted)
        let end = activity.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "Present"
        return "\(start) - \(end)"
    }
}
