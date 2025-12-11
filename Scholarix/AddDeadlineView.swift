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
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing
                        header(title: "New Task", subtitle: "Add to your schedule", icon: "calendar.badge.plus", color: .blue)
                        
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
                                        Text("None").tag("")
                                        ForEach(courses) { course in Text(course.name).tag(course.id ?? "") }
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
            .disabled(isSaving)
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
