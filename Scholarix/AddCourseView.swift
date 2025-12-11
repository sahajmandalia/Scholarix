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
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing
                        
                        header(title: "New Course", subtitle: "Add details to track your progress", icon: "book.closed.fill", color: .blue)
                        
                        FormCard(title: "COURSE DETAILS") {
                            HStack {
                                Image(systemName: "pencil").foregroundColor(.gray)
                                TextField("Course Name (e.g. Algebra II)", text: $courseName)
                                    .autocapitalization(.words)
                                    .formRow()
                            }
                            Divider()
                            HStack {
                                Image(systemName: "graduationcap").foregroundColor(.gray)
                                Text("Grade Taken")
                                Spacer()
                                Picker("Grade Taken", selection: $gradeLevel) {
                                    ForEach(gradeLevels, id: \.self) { level in Text("\(level)th").tag(level) }
                                }.pickerStyle(.menu).accentColor(.blue)
                            }
                            .padding(.vertical, 2)
                            .formRow()
                            Divider()
                            HStack {
                                Image(systemName: "chart.bar").foregroundColor(.gray)
                                Text("Level")
                                Spacer()
                                Picker("Level", selection: $courseLevel) {
                                    ForEach(courseLevels, id: \.self) { level in Text(level).tag(level) }
                                }.pickerStyle(.menu).accentColor(.blue)
                            }
                            .padding(.vertical, 2)
                            .formRow()
                        }
                        
                        FormCard(title: "PERFORMANCE") {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Image(systemName: "percent").foregroundColor(.gray)
                                    Text("Current Grade")
                                    Spacer()
                                    TextField("95.0", text: $gradePercentString)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 80).padding(8).background(Color(.systemGray6)).cornerRadius(8)
                                        .onChange(of: gradePercentString) { _, newValue in validateGrade(newValue) }
                                }
                                .formRow()
                                if let error = gradeError {
                                    Text(error).font(.caption).foregroundColor(.red).padding(.top, 4)
                                }
                            }
                            Divider()
                            HStack {
                                Image(systemName: "star.circle").foregroundColor(.gray)
                                Text("Credits")
                                Spacer()
                                Stepper(value: $credits, in: 0.0...5.0, step: 0.5) {
                                    Text(String(format: "%.1f", credits)).frame(width: 40).multilineTextAlignment(.center)
                                }.labelsHidden()
                            }
                            .formRow()
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 1)
                }
                
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
            .disabled(isSaving)
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
        let newCourse = Course(
            id: nil, name: courseName.trimmingCharacters(in: .whitespacesAndNewlines), gradeLevel: gradeLevel,
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

