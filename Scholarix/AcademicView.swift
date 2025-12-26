import SwiftUI

struct AcademicView: View {
    @StateObject private var viewModel = AcademicViewModel()
    @EnvironmentObject var menuManager: MenuManager
    
    // UI State
    @State private var showingAddSheet = false
    @State private var selectedTab = 0 // 0: Courses, 1: Planner
    @State private var isListMode = false
    @State private var isSearching = false
    
    // --- Navigation State ---
    // State for Editing (Swipe/Menu)
    @State private var selectedCourse: Course?
    @State private var selectedDeadline: Deadline?
    
    // State for Details (Card Tap)
    @State private var courseForDetail: Course?
    @State private var deadlineForDetail: Deadline?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                // --- Navigation Links (Headless) ---
                Group {
                    // 1. Edit Links
                    NavigationLink(destination: EditCourseView(viewModel: viewModel, courseToEdit: selectedCourse ?? Course.placeholder()), tag: selectedCourse ?? Course.placeholder(), selection: $selectedCourse) { EmptyView() }
                    
                    if let deadline = selectedDeadline {
                        NavigationLink(destination: EditDeadlineView(viewModel: viewModel, deadlineToEdit: deadline), tag: deadline.id ?? "", selection: Binding(get: { selectedDeadline?.id }, set: { _ in self.selectedDeadline = nil })) { EmptyView() }
                    }
                    
                    // 2. Detail Links
                    NavigationLink(destination: CourseDetailView(viewModel: viewModel, courseId: courseForDetail?.id ?? ""), tag: courseForDetail ?? Course.placeholder(), selection: $courseForDetail) { EmptyView() }
                    
                    if let deadline = deadlineForDetail {
                        NavigationLink(destination: DeadlineDetailView(viewModel: viewModel, deadlineId: deadline.id ?? ""), tag: deadline.id ?? "", selection: Binding(get: { deadlineForDetail?.id }, set: { _ in self.deadlineForDetail = nil })) { EmptyView() }
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
                    .background(Color(.systemGroupedBackground))
                    
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
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isListMode.toggle()
                                }
                            }) {
                                Image(systemName: isListMode ? "calendar" : "list.bullet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
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
                            onSelect: { courseForDetail = course }, // Link tap to Detail
                            onEdit: { selectedCourse = course },    // Link edit to Edit
                            onDelete: { viewModel.deleteCourse(course: course) }
                        )
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
                                    onSelect: { deadlineForDetail = deadline }, // Link tap to Detail
                                    onEdit: { selectedDeadline = deadline },    // Link edit to Edit
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
                // IMPORTANT: Ensure your CalendarView handles onSelect and onEdit
                CalendarView(
                    deadlines: viewModel.filteredDeadlines,
                    onSelect: { deadlineForDetail = $0 },
                    onEdit: { selectedDeadline = $0 },
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
        VStack {
            Spacer()
            ZStack {
                if isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search...", text: $viewModel.searchText).submitLabel(.done)
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSearching = false
                                viewModel.searchText = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSearching = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingAddSheet = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                Text(selectedTab == 0 ? "Course" : "Task")
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
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    .padding()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearching)
        }
    }
}

// --- SUBVIEWS ---

struct GPACard: View {
    let weighted: String
    let unweighted: String
    
    @State private var animateNumbers = false
    
    var body: some View {
        HStack(spacing: 0) {
            statView(title: "Weighted", value: weighted)
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 40)
            statView(title: "Unweighted", value: unweighted)
        }
        .padding(24)
        .background(
            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(24)
        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(animateNumbers ? 1.0 : 0.95)
        .opacity(animateNumbers ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateNumbers = true
            }
        }
    }
    
    func statView(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .tracking(1)
            Text(value)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// --- MINIMALIST COURSE CARD ---
struct CourseCard: View {
    let course: Course
    let onSelect: () -> Void // New Handler
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var levelColor: Color {
        switch course.courseLevel {
        case "AP", "IB": return .purple
        case "Honors": return .blue
        default: return .gray
        }
    }
    
    func gradeColor(for grade: Double) -> Color {
        switch grade {
        case 90...: return .green
        case 80..<90: return .blue
        default: return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Capsule()
                .fill(levelColor)
                .frame(width: 6)
                .padding(.vertical, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(course.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(course.courseLevel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(levelColor.opacity(0.2))
                        .foregroundColor(levelColor)
                        .clipShape(Capsule())
                    
                    Text("\(course.credits, specifier: "%.1f") cr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Group {
                if let grade = course.gradePercent {
                    Text("\(grade, specifier: "%.0f")%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(gradeColor(for: grade))
                        .clipShape(Capsule())
                } else {
                    Text("--")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                }
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
                onSelect() // Triggers Detail View
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

struct TaskRowCard: View {
    let deadline: Deadline
    let viewModel: AcademicViewModel
    let onSelect: () -> Void // New Handler
    let onEdit: () -> Void
    var onDelete: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var typeColor: Color {
        switch deadline.type {
        case "Test": return Theme.activityTest
        case "Project": return Theme.activityProject
        case "Essay": return Theme.activityEssay
        case "Application": return Theme.activityApplication
        case "Event": return Theme.activityEvent
        default: return Theme.brandPrimary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Capsule()
                .fill(deadline.isCompleted ? Color.gray.opacity(0.3) : typeColor)
                .frame(width: 6)
                .padding(.vertical, 16)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleCompletion(deadline: deadline)
                }
            }) {
                Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(deadline.isCompleted ? .green : .secondary.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(deadline.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .strikethrough(deadline.isCompleted)
                    .foregroundColor(deadline.isCompleted ? Theme.textSecondary : Theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if !deadline.isCompleted {
                        Text(deadline.type.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(typeColor.opacity(0.2))
                            .foregroundColor(typeColor)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text(deadline.dueDate, style: .date)
                    }
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) { Label("Edit", systemImage: "pencil") }
                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textSecondary.opacity(0.6))
                    .frame(width: 30, height: 30)
                    .padding(.leading, 8)
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
                onSelect() // Triggers Detail View
            }
        }
    }
}
