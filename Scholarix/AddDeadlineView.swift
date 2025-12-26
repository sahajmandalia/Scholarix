import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddDeadlineView: View {
    @Binding var isPresented: Bool
    let courses: [Course]
    
    @State private var title = ""
    @State private var type = "Homework"
    @State private var dueDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var selectedCourseId: String = ""
    @State private var priority = "Medium"
    @State private var details = ""
    
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var alertMessage = ""
    
    let types = ["Homework", "Test", "Project", "Essay", "Application", "Event", "Club", "Sport", "Other"]
    let priorities = ["Low", "Medium", "High"]
    
    var isEvent: Bool { ["Event", "Club", "Sport", "Other"].contains(type) }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // --- PREMIUM BACKGROUND ---
                LinearGradient(
                    colors: [Color.cyan.opacity(0.05), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        header(title: "New Task", subtitle: "Add to your schedule", icon: "calendar.badge.plus", color: .cyan)
                        
                        FormCard(title: "TASK DETAILS") {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.cyan)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Title", text: $title)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "tag")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Type")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Picker("Type", selection: $type) {
                                    ForEach(types, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.menu)
                                .accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        FormCard(title: "TIMELINE") {
                            if isEvent {
                                Toggle(isOn: $isAllDay) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "clock")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 28, alignment: .center)
                                        Text("All-day")
                                            .font(.system(.body, design: .rounded))
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                Divider()
                                
                                if isAllDay {
                                    DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                                        .font(.system(.body, design: .rounded))
                                        .padding(.vertical, 8)
                                } else {
                                    DatePicker("Starts", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                        .onChange(of: dueDate) { _, newDate in
                                            if newDate > endDate { endDate = newDate.addingTimeInterval(3600) }
                                        }
                                        .font(.system(.body, design: .rounded))
                                        .padding(.vertical, 8)
                                    
                                    Divider()
                                    
                                    DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                        .font(.system(.body, design: .rounded))
                                        .padding(.vertical, 8)
                                }
                            } else {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .font(.system(.body, design: .rounded))
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        FormCard(title: "ADDITIONAL INFO") {
                            if !isEvent {
                                HStack(spacing: 12) {
                                    Image(systemName: "book.closed")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 28, alignment: .center)
                                    Text("Course")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Picker("Course", selection: $selectedCourseId) {
                                        Text("None").tag("")
                                        ForEach(courses) { course in Text(course.name).tag(course.id ?? "") }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Theme.brandPrimary)
                                }
                                .padding(.vertical, 8)
                                
                                Divider()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "flag")
                                    .foregroundColor(.red.opacity(0.7))
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Priority")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Picker("Priority", selection: $priority) {
                                    ForEach(priorities, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.menu)
                                .accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Details (Optional)", text: $details)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 10)
                }
                .dismissKeyboardOnTap() // <--- KEYBOARD DISMISSAL
                
                FloatingSaveButton(
                    label: "Add Task",
                    isDisabled: title.isEmpty || isSaving,
                    isSaving: isSaving,
                    action: addDeadline
                )
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { isPresented = false }.disabled(isSaving) }
            }
            .alert("Error", isPresented: $showingErrorAlert) { Button("OK", role: .cancel) { } } message: { Text(alertMessage) }
            .interactiveDismissDisabled(isSaving)
        }
    }
    
    private func addDeadline() {
        guard let userId = Auth.auth().currentUser?.uid else { alertMessage = "Not logged in"; showingErrorAlert = true; return }
        if isEvent && !isAllDay && endDate < dueDate { alertMessage = "End time cannot be before start time."; showingErrorAlert = true; return }
        
        isSaving = true
        let finalEndDate = (isEvent && !isAllDay) ? endDate : nil
        let finalIsAllDay = isEvent ? isAllDay : false
        
        let newDeadline = Deadline(
            id: nil, title: title, type: type, dueDate: dueDate, endDate: finalEndDate,
            isAllDay: finalIsAllDay, isCompleted: false, details: details.isEmpty ? nil : details,
            courseId: selectedCourseId.isEmpty ? nil : selectedCourseId, priority: priority
        )
        
        let docRef = Firestore.firestore().collection(Constants.Firestore.root).document(Constants.appId)
            .collection(Constants.Firestore.users).document(userId).collection(Constants.Firestore.deadlines).document()
            
        try? docRef.setData(from: newDeadline) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error { alertMessage = error.localizedDescription; showingErrorAlert = true }
                else { isPresented = false }
            }
        }
    }
}
