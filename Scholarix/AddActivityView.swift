import SwiftUI
import FirebaseAuth

struct AddActivityView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ExtracurricularsViewModel
    
    @State private var title = ""
    @State private var position = ""
    @State private var type = "Club"
    @State private var hoursString = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isOngoing = true
    @State private var description = ""
    @State private var isSaving = false
    @State private var alertMessage = ""
    @State private var showingErrorAlert = false
    
    let types = ["Club", "Sport", "Service", "Award", "Work", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing
                        header(title: "New Activity", subtitle: "Build your experience profile", icon: "plus.circle.fill", color: .green)
                        
                        FormCard(title: "BASIC INFO") {
                            TextField("Activity Name", text: $title)
                                .formRow()
                            Divider()
                            TextField("Role / Position", text: $position)
                                .formRow()
                            Divider()
                            HStack {
                                Text("Type")
                                Spacer()
                                Picker("Type", selection: $type) {
                                    ForEach(types, id: \.self) { Text($0) }
                                }.pickerStyle(.menu)
                            }
                            .padding(.vertical, 2)
                            .formRow()
                        }
                        
                        FormCard(title: "TIMELINE") {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .formRow()
                            Divider()
                            Toggle("Currently Ongoing", isOn: $isOngoing)
                                .formRow()
                            if !isOngoing {
                                Divider()
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .formRow()
                            }
                        }
                        
                        FormCard(title: "IMPACT") {
                            TextField("Total Hours (Optional)", text: $hoursString)
                                .keyboardType(.decimalPad)
                                .formRow()
                            Divider()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Description / Achievements")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray5), lineWidth: 1))
                            }
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 1)
                }
                
                FloatingSaveButton(
                    label: "Add Activity",
                    isDisabled: title.isEmpty || isSaving,
                    isSaving: isSaving,
                    action: save
                )
            }
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.disabled(isSaving)
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) { Button("OK", role: .cancel) { } } message: { Text(alertMessage) }
        }
    }
    
    private func save() {
        guard let userId = Auth.auth().currentUser?.uid else { alertMessage = "Not logged in"; showingErrorAlert = true; return }
        
        isSaving = true
        let newActivity = Activity(
            title: title, position: position, type: type, hours: Double(hoursString),
            startDate: startDate, endDate: isOngoing ? nil : endDate, description: description.isEmpty ? nil : description
        )
        
        Task {
            do {
                try await viewModel.addActivity(newActivity)
                await MainActor.run { isPresented = false }
            } catch {
                await MainActor.run { alertMessage = error.localizedDescription; showingErrorAlert = true }
            }
            await MainActor.run { isSaving = false }
        }
    }
}
