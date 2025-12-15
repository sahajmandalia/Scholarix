import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddCourseView: View {
    @Binding var isPresented: Bool
    
    @State private var courseName = ""
    @State private var gradePercentString = ""
    @State private var gradeLevel = 9
    @State private var courseLevel = "Regular"
    @State private var credits = 3.0
    
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var alertMessage = ""
    @State private var gradeError: String? = nil
    
    let gradeLevels = [9, 10, 11, 12]
    let courseLevels = ["Regular", "Honors", "AP", "IB"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background
                Theme.backgroundGrouped.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) { // Increased spacing for breathability
                        
                        header(title: "New Course", subtitle: "Add details to track your progress", icon: "book.closed.fill", color: Theme.brandPrimary)
                        
                        FormCard(title: "COURSE DETAILS") {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(Theme.brandPrimary)
                                    .frame(width: 24)
                                TextField("Course Name (e.g. Algebra II)", text: $courseName)
                                    .autocapitalization(.words)
                                    .foregroundColor(Theme.textPrimary)
                                    .formRow()
                            }
                            Divider()
                            HStack {
                                Image(systemName: "graduationcap")
                                    .foregroundColor(Theme.brandSecondary)
                                    .frame(width: 24)
                                Text("Grade Taken")
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Picker("Grade Taken", selection: $gradeLevel) {
                                    ForEach(gradeLevels, id: \.self) { level in Text("\(level)th").tag(level) }
                                }.pickerStyle(.menu).accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 4)
                            .formRow()
                            Divider()
                            HStack {
                                Image(systemName: "chart.bar")
                                    .foregroundColor(Theme.warning)
                                    .frame(width: 24)
                                Text("Level")
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Picker("Level", selection: $courseLevel) {
                                    ForEach(courseLevels, id: \.self) { level in Text(level).tag(level) }
                                }.pickerStyle(.menu).accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 4)
                            .formRow()
                        }
                        
                        FormCard(title: "PERFORMANCE") {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Image(systemName: "percent")
                                        .foregroundColor(Theme.success)
                                        .frame(width: 24)
                                    Text("Current Grade")
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    TextField("95.0", text: $gradePercentString)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Theme.textPrimary)
                                        .frame(width: 90)
                                        .padding(8)
                                        .background(Theme.inputBackground)
                                        .cornerRadius(8)
                                        .onChange(of: gradePercentString) { _, newValue in validateGrade(newValue) }
                                }
                                .formRow()
                                if let error = gradeError {
                                    Text(error)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.danger)
                                        .padding(.top, 4)
                                }
                            }
                            Divider()
                            HStack {
                                Image(systemName: "star.circle")
                                    .foregroundColor(Theme.warning)
                                    .frame(width: 24)
                                Text("Credits")
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Stepper(value: $credits, in: 0.0...5.0, step: 0.5) {
                                    Text(String(format: "%.1f", credits))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.textPrimary)
                                        .frame(width: 40)
                                        .multilineTextAlignment(.center)
                                }
                                .labelsHidden()
                            }
                            .formRow()
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 10)
                }
                .dismissKeyboardOnTap() // <--- KEYBOARD DISMISSAL
                
                FloatingSaveButton(
                    label: "Save Course",
                    isDisabled: isSaving || courseName.isEmpty || gradePercentString.isEmpty || gradeError != nil,
                    isSaving: isSaving,
                    action: saveCourse
                )
            }
            .navigationTitle("New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { isPresented = false }.disabled(isSaving) }
            }
            .alert("Error", isPresented: $showingErrorAlert) { Button("OK", role: .cancel) { } } message: { Text(alertMessage) }
            .interactiveDismissDisabled(isSaving)
        }
    }
    
    private func validateGrade(_ value: String) {
        if value.isEmpty { gradeError = nil }
        else if Double(value) == nil { gradeError = "Invalid number" }
        else if let num = Double(value), (num < 0 || num > 110) { gradeError = "Grade must be 0-110" }
        else { gradeError = nil }
    }
    
    private func saveCourse() {
        guard !courseName.isEmpty else { return }
        guard let gradeValue = Double(gradePercentString) else { return }
        guard let userId = Auth.auth().currentUser?.uid else { alertMessage = "Not logged in"; showingErrorAlert = true; return }
        
        isSaving = true
        // Safe trimming
        let cleanName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newCourse = Course(
            id: nil, name: cleanName, gradeLevel: gradeLevel,
            courseLevel: courseLevel, credits: credits, gradePercent: gradeValue, createdAt: Timestamp(date: Date())
        )
        
        let docRef = Firestore.firestore().collection(Constants.Firestore.root).document(Constants.appId)
            .collection(Constants.Firestore.users).document(userId).collection(Constants.Firestore.courses).document()
        
        try? docRef.setData(from: newCourse) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error { alertMessage = "Save Failed: \(error.localizedDescription)"; showingErrorAlert = true }
                else { isPresented = false }
            }
        }
    }
}
