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
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .foregroundColor(Theme.warning)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Course Name", text: $courseName)
                                    .autocapitalization(.words)
                                    .foregroundColor(Theme.textPrimary)
                                    .font(.system(.body, design: .rounded))
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "graduationcap")
                                    .foregroundColor(Theme.brandSecondary)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Grade Taken")
                                    .foregroundColor(Theme.textPrimary)
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                                Picker("Grade Taken", selection: $gradeLevel) {
                                    ForEach(gradeLevels, id: \.self) { level in 
                                        Text("\(level)th").tag(level) 
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "chart.bar")
                                    .foregroundColor(Theme.warning)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Level")
                                    .foregroundColor(Theme.textPrimary)
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                                Picker("Level", selection: $courseLevel) {
                                    ForEach(courseLevels, id: \.self) { level in 
                                        Text(level).tag(level) 
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        FormCard(title: "PERFORMANCE") {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 12) {
                                    Image(systemName: "percent")
                                        .foregroundColor(Theme.success)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 28, alignment: .center)
                                    Text("Current Grade")
                                        .foregroundColor(Theme.textPrimary)
                                        .font(.system(.body, design: .rounded))
                                    Spacer()
                                    TextField("95.0", text: $gradeString)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Theme.textPrimary)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .frame(width: 80)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Theme.inputBackground)
                                        .cornerRadius(10)
                                        .onChange(of: gradeString) { _, newValue in validateGrade(newValue) }
                                }
                                .padding(.vertical, 8)
                                
                                if let error = gradeError {
                                    Text(error)
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.danger)
                                        .padding(.top, 4)
                                        .padding(.leading, 28 + 12) // icon width + spacing
                                }
                            }
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "star.circle")
                                    .foregroundColor(Theme.warning)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Credits")
                                    .foregroundColor(Theme.textPrimary)
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                                Stepper(value: $credits, in: 0.0...5.0, step: 0.5) {
                                    Text(String(format: "%.1f", credits))
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.textPrimary)
                                        .font(.system(.body, design: .rounded))
                                        .frame(width: 50)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Theme.inputBackground)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.vertical, 8)
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

