import SwiftUI

struct AcademicView: View {
    @StateObject private var viewModel = AcademicViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    // UI State
    @State private var showingAddSheet = false
    @State private var selectedCourse: Course?
    @State private var selectedDeadline: Deadline?
    @State private var selectedTab = 0 // 0: Courses, 1: Planner
    @State private var isListMode = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                // --- Navigation Links (Headless) ---
                Group {
                    NavigationLink(destination: EditCourseView(viewModel: viewModel, courseToEdit: selectedCourse ?? Course.placeholder()), tag: selectedCourse ?? Course.placeholder(), selection: $selectedCourse) { EmptyView() }
                    
                    if let deadline = selectedDeadline {
                        NavigationLink(destination: EditDeadlineView(viewModel: viewModel, deadlineToEdit: deadline), tag: deadline.id ?? "", selection: Binding(get: { selectedDeadline?.id }, set: { _ in self.selectedDeadline = nil })) { EmptyView() }
                    }
                }
                
                VStack(spacing: 0) {
                    // Standard Segmented Picker
                    Picker("View", selection: $selectedTab) {
                        Text("Courses").tag(0)
                        Text("Planner").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .background(Theme.backgroundGrouped)
                    
                    if selectedTab == 0 {
                        coursesList
                    } else {
                        plannerView
                    }
                }
                
                // --- Bottom Floating Action Bar ---
                bottomActionBar
            }
            .sheet(isPresented: $showingAddSheet) {
                if selectedTab == 0 {
                    AddCourseView(isPresented: $showingAddSheet)
                } else {
                    AddDeadlineView(isPresented: $showingAddSheet, courses: viewModel.courses)
                }
            }
            .onAppear {
                viewModel.fetchCourses()
                viewModel.fetchDeadlines()
            }
            .onDisappear { viewModel.detachListeners() }
            .dismissKeyboardOnTap()
            .navigationTitle("Academic Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // --- 1. Side Menu Button (Left) ---
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { menuManager.open() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                // --- 2. Settings & View Options (Right) ---
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if selectedTab == 1 {
                            Button(action: { withAnimation { isListMode.toggle() } }) {
                                Image(systemName: isListMode ? "calendar" : "list.bullet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // --- Subviews ---
    
    var coursesList: some View {
        List {
            // --- NEW TITLE HEADER ---
            Section {
                header(title: "Academic Hub", subtitle: "Your grades & performance", icon: "graduationcap.fill", color: .blue)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.top, 10)
            }
            
            // 1. GPA Card (Pinned to top)
            Section {
                GPACard(weighted: viewModel.weightedGPA, unweighted: viewModel.unweightedGPA)
                    .listRowInsets(EdgeInsets()) // Remove default padding
                    .listRowBackground(Color.clear)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
            }
            
            // 2. Courses List
            if viewModel.filteredCourses.isEmpty {
                Section {
                    emptyStateView(icon: "book.closed", title: "No Courses Yet", subtitle: "Tap '+' to add your classes.")
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(viewModel.filteredCourses) { course in
                        CourseCard(
                            course: course,
                            onEdit: { selectedCourse = course },
                            onDelete: { viewModel.deleteCourse(course: course) }
                        )
                        .swipeActions(edge: .leading) {
                            Button { selectedCourse = course } label: { Label("Edit", systemImage: "pencil") }.tint(.orange)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { viewModel.deleteCourse(course: course) } label: { Label("Delete", systemImage: "trash") }
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
        .padding(.bottom, 80)
    }
    
    var plannerView: some View {
        Group {
            if isListMode {
                List {
                    if viewModel.filteredDeadlines.isEmpty {
                        Section {
                            emptyStateView(icon: "calendar.badge.checkmark", title: "All Caught Up!", subtitle: "No upcoming tasks found.")
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        Section {
                            ForEach(viewModel.filteredDeadlines) { deadline in
                                TaskRowCard(
                                    deadline: deadline,
                                    viewModel: viewModel,
                                    onEdit: { selectedDeadline = deadline },
                                    onDelete: { viewModel.deleteDeadline(deadline: deadline) }
                                )
                                .swipeActions(edge: .leading) {
                                    Button { selectedDeadline = deadline } label: { Label("Edit", systemImage: "pencil") }.tint(.orange)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { viewModel.deleteDeadline(deadline: deadline) } label: { Label("Delete", systemImage: "trash") }
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
                .padding(.bottom, 80)
            } else {
                CalendarView(
                    deadlines: viewModel.filteredDeadlines,
                    selectedDeadline: $selectedDeadline,
                    onDelete: { viewModel.deleteDeadline(deadline: $0) },
                    onToggle: { viewModel.toggleCompletion(deadline: $0) }
                )
            }
        }
    }
    
    func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.3))
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    var bottomActionBar: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Gradient fade
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
                        
                        TextField("Search courses or tasks...", text: $viewModel.searchText)
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
                        
                        // Search Button
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
                        
                        // Add Button
                        Button(action: { showingAddSheet = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text(selectedTab == 0 ? "Add Course" : "Add Task")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Theme.brandGradient)
                            .clipShape(Capsule())
                            .shadow(color: Theme.brandPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
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

// --- SUBVIEWS ---

struct GPACard: View {
    let weighted: String
    let unweighted: String
    
    var body: some View {
        HStack(spacing: 0) {
            statView(title: "Weighted GPA", value: weighted, icon: "star.fill")
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 2, height: 50)
            statView(title: "Unweighted GPA", value: unweighted, icon: "graduationcap.fill")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(Theme.brandGradient)
        .cornerRadius(20)
        .shadow(color: Theme.brandPrimary.opacity(0.4), radius: 16, x: 0, y: 8)
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

struct CourseCard: View {
    let course: Course
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var levelColor: Color {
        switch course.courseLevel {
        case "AP", "IB": return Theme.brandSecondary
        case "Honors": return Theme.brandPrimary
        default: return Theme.textSecondary
        }
    }
    
    var letterGrade: String {
        guard let grade = course.gradePercent else { return "--" }
        switch grade {
        case 93...110: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        case 60..<63: return "D-"
        default: return "F"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section with course info
            HStack(alignment: .top, spacing: 12) {
                // Left side - Course details
                VStack(alignment: .leading, spacing: 10) {
                    Text(course.name)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        // Level badge
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text(course.courseLevel)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(levelColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(levelColor.opacity(0.15))
                        .cornerRadius(8)
                        
                        // Grade level badge
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Grade \(course.gradeLevel)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.textSecondary.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Credits badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text("\(course.credits, specifier: "%.1f") cr")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Theme.warning)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.warning.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Right side - Grade display
                VStack(spacing: 4) {
                    if let grade = course.gradePercent {
                        Text("\(grade, specifier: "%.1f")%")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(Theme.gradeColor(for: grade))
                        
                        Text(letterGrade)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.gradeColor(for: grade))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.gradeColor(for: grade).opacity(0.15))
                            .cornerRadius(6)
                    } else {
                        Text("--")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textTertiary)
                        
                        Text("No Grade")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.textTertiary)
                    }
                }
            }
            .padding(16)
            
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

struct TaskRowCard: View {
    let deadline: Deadline
    let viewModel: AcademicViewModel
    let onEdit: () -> Void
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { 
                viewModel.toggleCompletion(deadline: deadline) 
            }}) {
                Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(deadline.isCompleted ? Theme.success : Theme.textSecondary.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(deadline.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .strikethrough(deadline.isCompleted)
                    .foregroundColor(deadline.isCompleted ? Theme.textSecondary : Theme.textPrimary)
                
                HStack(spacing: 8) {
                    // Type Badge
                    Text(deadline.type.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.activityColor(for: deadline.type))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.activityColor(for: deadline.type).opacity(0.15))
                        .cornerRadius(6)
                    
                    // Date
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text(deadline.dueDate, style: .date)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            
            Spacer()
            
            // Menu
            Menu {
                Button(action: onEdit) { 
                    Label("Edit Task", systemImage: "pencil.circle.fill") 
                }
                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) { 
                        Label("Delete Task", systemImage: "trash.fill") 
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Theme.textSecondary.opacity(0.6))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(deadline.isCompleted ? Theme.success.opacity(0.3) : Theme.borderSubtle, lineWidth: deadline.isCompleted ? 1.5 : 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
    }
}

