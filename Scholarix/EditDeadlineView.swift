import SwiftUI
import FirebaseFirestore

struct EditDeadlineView: View {
    @ObservedObject var viewModel: AcademicViewModel
    private var originalDeadline: Deadline
    
    // --- Editable Fields ---
    @State private var title: String
    @State private var type: String
    @State private var dueDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var details: String
    @State private var priority: String
    @State private var selectedCourseId: String
    
    // --- UI State ---
    @Environment(\.dismiss) var dismiss
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // --- Constants ---
    let types = ["Homework", "Test", "Project", "Essay", "Application", "Event", "Club", "Sport", "Other"]
    let priorities = ["Low", "Medium", "High"]
    
    var isEvent: Bool {
        return ["Event", "Club", "Sport", "Other"].contains(type)
    }
    
    init(viewModel: AcademicViewModel, deadlineToEdit: Deadline) {
        self.viewModel = viewModel
        self.originalDeadline = deadlineToEdit
        
        _title = State(initialValue: deadlineToEdit.title)
        _type = State(initialValue: deadlineToEdit.type)
        _dueDate = State(initialValue: deadlineToEdit.dueDate)
        
        // Ensure end date is at least 1 hour after start if nil
        let defaultEnd = deadlineToEdit.dueDate.addingTimeInterval(3600)
        _endDate = State(initialValue: deadlineToEdit.endDate ?? defaultEnd)
        
        _isAllDay = State(initialValue: deadlineToEdit.isAllDay)
        _details = State(initialValue: deadlineToEdit.details ?? "")
        _priority = State(initialValue: deadlineToEdit.priority ?? "Medium")
        _selectedCourseId = State(initialValue: deadlineToEdit.courseId ?? "none")
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // --- 1. Background Gradient ---
                LinearGradient(
                    colors: [Color.orange.opacity(0.05), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // --- 2. Scrollable Form Content ---
                ScrollView {
                    VStack(spacing: 20) {
                        // Custom Header
                        header(title: "Edit Task", subtitle: "Update task details", icon: "pencil.circle.fill", color: .orange)
                        
                        // Card 1: Details
                        FormCard(title: "TASK DETAILS") {
                            HStack {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.orange)
                                    .frame(width: 24)
                                TextField("Title", text: $title)
                            }
                            .formRow()
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                Text("Type")
                                Spacer()
                                Picker("Type", selection: $type) {
                                    ForEach(types, id: \.self) { typeName in
                                        Text(typeName).tag(typeName)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.primary)
                            }
                            .padding(.vertical, 4)
                            .formRow()
                        }
                        
                        // Card 2: Timeline
                        FormCard(title: "TIMELINE") {
                            if isEvent {
                                Toggle(isOn: $isAllDay) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.purple)
                                            .frame(width: 24)
                                        Text("All-day")
                                    }
                                }
                                .padding(.vertical, 4)
                                .formRow()
                                
                                Divider()
                                
                                if isAllDay {
                                    DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                                        .formRow()
                                } else {
                                    DatePicker("Starts", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                        .onChange(of: dueDate) { _, newDate in
                                            // Auto-adjust end date if it becomes invalid
                                            if newDate > endDate {
                                                endDate = newDate.addingTimeInterval(3600)
                                            }
                                        }
                                        .formRow()
                                    
                                    Divider()
                                    
                                    DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                        .formRow()
                                }
                            } else {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .formRow()
                            }
                        }
                        
                        // Card 3: Additional Info
                        FormCard(title: "ADDITIONAL INFO") {
                            if !isEvent {
                                HStack {
                                    Image(systemName: "book.closed")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    Text("Course")
                                    Spacer()
                                    Picker("Course", selection: $selectedCourseId) {
                                        Text("None").tag("none")
                                        ForEach(viewModel.courses) { course in
                                            Text(course.name).tag(course.id ?? "")
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(.primary)
                                }
                                .padding(.vertical, 4)
                                .formRow()
                                
                                Divider()
                            }
                            
                            HStack {
                                Image(systemName: "flag")
                                    .foregroundColor(.red.opacity(0.7))
                                    .frame(width: 24)
                                Text("Priority")
                                Spacer()
                                Picker("Priority", selection: $priority) {
                                    ForEach(priorities, id: \.self) { level in
                                        Text(level).tag(level)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.primary)
                            }
                            .padding(.vertical, 4)
                            .formRow()
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                TextField("Details (Optional)", text: $details)
                            }
                            .formRow()
                        }
                        
                        Spacer(minLength: 100) // Space for the floating button
                    }
                    .padding(.top, 10)
                }
                .dismissKeyboardOnTap() // Helper from Extensions.swift
                
                // --- 3. Floating Save Button ---
                FloatingSaveButton(
                    label: "Save Changes",
                    isDisabled: title.isEmpty || isSaving,
                    isSaving: isSaving,
                    action: updateDeadline
                )
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            // Alert for errors
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // --- Update Logic ---
    private func updateDeadline() {
        // Validation for Events
        if isEvent && !isAllDay && endDate < dueDate {
            errorMessage = "End time cannot be before start time."
            showingErrorAlert = true
            return
        }
        
        Task {
            await MainActor.run { isSaving = true }
            
            // Create updated object
            var updatedDeadline = originalDeadline
            updatedDeadline.title = title
            updatedDeadline.type = type
            updatedDeadline.dueDate = dueDate
            updatedDeadline.endDate = (isEvent && !isAllDay) ? endDate : nil
            updatedDeadline.isAllDay = isEvent ? isAllDay : false
            updatedDeadline.details = details
            updatedDeadline.priority = priority
            updatedDeadline.courseId = selectedCourseId == "none" ? nil : selectedCourseId
            
            do {
                try await viewModel.updateDeadline(deadline: updatedDeadline)
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}
