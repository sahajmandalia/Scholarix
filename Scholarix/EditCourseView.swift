import SwiftUI
import FirebaseFirestore
import Combine

struct EditCourseView: View {
    @ObservedObject var viewModel: AcademicViewModel
    private var originalCourse: Course
    
    @State private var courseName: String
    @State private var gradeString: String
    @State private var gradeLevel: Int
    @State private var courseLevel: String
    @State private var credits: Double
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    @State private var gradeError: String? = nil
    
    let gradeLevels = [9, 10, 11, 12]
    let courseLevels = ["Regular", "Honors", "AP", "IB"]
    
    init(viewModel: AcademicViewModel, courseToEdit: Course) {
        self.viewModel = viewModel
        self.originalCourse = courseToEdit
        _courseName = State(initialValue: courseToEdit.name)
        _gradeLevel = State(initialValue: courseToEdit.gradeLevel)
        _courseLevel = State(initialValue: courseToEdit.courseLevel)
        _credits = State(initialValue: courseToEdit.credits)
        _gradeString = State(initialValue: courseToEdit.gradePercent != nil ? String(format: "%.1f", courseToEdit.gradePercent!) : "")
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background
                Theme.backgroundGrouped.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        header(title: "Edit Course", subtitle: "Update course details", icon: "pencil.circle.fill", color: Theme.warning)
                        
                        FormCard(title: "COURSE DETAILS") {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(Theme.warning)
                                    .frame(width: 24)
                                TextField("Course Name", text: $courseName)
                                    .autocapitalization(.words)
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .formRow()
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
                                    TextField("95.0", text: $gradeString)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Theme.textPrimary)
                                        .frame(width: 90)
                                        .padding(8)
                                        .background(Theme.inputBackground)
                                        .cornerRadius(8)
                                        .onChange(of: gradeString) { _, newValue in validateGrade(newValue) }
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
                    label: "Save Changes",
                    isDisabled: isSaving || courseName.isEmpty || gradeString.isEmpty || gradeError != nil,
                    isSaving: isSaving,
                    action: updateCourse
                )
            }
            .navigationTitle("Edit Course")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingErrorAlert) { Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK"))) }
        }
    }
    
    private func validateGrade(_ value: String) {
        if value.isEmpty { gradeError = nil }
        else if Double(value) == nil { gradeError = "Invalid number" }
        else if let num = Double(value), (num < 0 || num > 110) { gradeError = "Grade must be 0-110" }
        else { gradeError = nil }
    }
    
    private func updateCourse() {
        Task {
            await MainActor.run { self.isSaving = true }
            var updatedCourse = originalCourse
            updatedCourse.name = courseName
            updatedCourse.gradeLevel = gradeLevel
            updatedCourse.courseLevel = courseLevel
            updatedCourse.credits = credits
            updatedCourse.gradePercent = Double(gradeString)
            
            do {
                try await viewModel.updateCourse(course: updatedCourse)
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            }
        }
    }
}
