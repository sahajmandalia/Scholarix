import SwiftUI
import FirebaseFirestore

struct EditDeadlineView: View {
    @ObservedObject var viewModel: AcademicViewModel
    private var originalDeadline: Deadline
    
    @State private var title: String
    @State private var type: String
    @State private var dueDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var details: String
    @State private var priority: String
    @State private var selectedCourseId: String
    
    @Environment(\.dismiss) var dismiss
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    let types = ["Homework", "Test", "Project", "Essay", "Application", "Event", "Club", "Sport", "Other"]
    let priorities = ["Low", "Medium", "High"]
    
    var isEvent: Bool { return ["Event", "Club", "Sport", "Other"].contains(type) }
    
    init(viewModel: AcademicViewModel, deadlineToEdit: Deadline) {
        self.viewModel = viewModel
        self.originalDeadline = deadlineToEdit
        _title = State(initialValue: deadlineToEdit.title)
        _type = State(initialValue: deadlineToEdit.type)
        _dueDate = State(initialValue: deadlineToEdit.dueDate)
        _endDate = State(initialValue: deadlineToEdit.endDate ?? deadlineToEdit.dueDate.addingTimeInterval(3600))
        _isAllDay = State(initialValue: deadlineToEdit.isAllDay)
        _details = State(initialValue: deadlineToEdit.details ?? "")
        _priority = State(initialValue: deadlineToEdit.priority ?? "Medium")
        _selectedCourseId = State(initialValue: deadlineToEdit.courseId ?? "none")
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing
                        header(title: "Edit Task", subtitle: "Update task details", icon: "pencil.circle.fill", color: .orange)
                        
                        FormCard(title: "TASK DETAILS") {
                            HStack {
                                Image(systemName: "pencil.and.outline").foregroundColor(.gray)
                                TextField("Title", text: $title)
                            }
                            Divider()
                            HStack {
                                Image(systemName: "tag").foregroundColor(.gray)
                                Text("Type")
                                Spacer()
                                Picker("Type", selection: $type) { ForEach(types, id: \.self) { Text($0).tag($0) } }
                                    .pickerStyle(.menu).accentColor(.blue)
                            }
                        }
                        
                        FormCard(title: "TIMELINE") {
                            if isEvent {
                                Toggle(isOn: $isAllDay) {
                                    HStack {
                                        Image(systemName: "clock").foregroundColor(.gray)
                                        Text("All-day")
                                    }
                                }
                                Divider()
                                if isAllDay {
                                    DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                                } else {
                                    DatePicker("Starts", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                        .onChange(of: dueDate) { _, newDate in
                                            if newDate > endDate { endDate = newDate.addingTimeInterval(3600) }
                                        }
                                    Divider()
                                    DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                }
                            } else {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            }
                        }
                        
                        FormCard(title: "ADDITIONAL INFO") {
                            if !isEvent {
                                HStack {
                                    Image(systemName: "book.closed").foregroundColor(.gray)
                                    Text("Course")
                                    Spacer()
                                    Picker("Course", selection: $selectedCourseId) {
                                        Text("None").tag("none")
                                        ForEach(viewModel.courses) { course in Text(course.name).tag(course.id ?? "") }
                                    }.pickerStyle(.menu).accentColor(.blue)
                                }
                                Divider()
                            }
                            HStack {
                                Image(systemName: "flag").foregroundColor(.gray).padding(.trailing, 2)
                                Text("Priority")
                                Spacer()
                                Picker("Priority", selection: $priority) {
                                    ForEach(priorities, id: \.self) { Text($0).tag($0) }
                                }.pickerStyle(.menu).accentColor(.blue)
                            }
                            Divider()
                            HStack {
                                Image(systemName: "text.alignleft").foregroundColor(.gray)
                                TextField("Details", text: $details)
                            }
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 1)
                }
                
                FloatingSaveButton(
                    label: "Save Changes",
                    isDisabled: title.isEmpty || isSaving,
                    isSaving: isSaving,
                    action: updateDeadline
                )
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingErrorAlert) { Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK"))) }
        }
    }
    
    private func updateDeadline() {
        if isEvent && !isAllDay && endDate < dueDate { errorMessage = "End time cannot be before start time."; showingErrorAlert = true; return }
        
        Task {
            await MainActor.run { isSaving = true }
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
