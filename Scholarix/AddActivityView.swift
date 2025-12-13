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
                // --- PREMIUM BACKGROUND ---
                LinearGradient(
                    colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        header(title: "New Activity", subtitle: "Build your experience profile", icon: "plus.circle.fill", color: .green)
                        
                        FormCard(title: "BASIC INFO") {
                            HStack {
                                Image(systemName: "star")
                                    .foregroundColor(.green)
                                    .frame(width: 24)
                                TextField("Activity Name (e.g. Debate Club)", text: $title)
                            }
                            .formRow()
                            Divider()
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                TextField("Role / Position (e.g. Member)", text: $position)
                            }
                            .formRow()
                            Divider()
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.orange)
                                    .frame(width: 24)
                                Text("Type")
                                Spacer()
                                Picker("Type", selection: $type) {
                                    ForEach(types, id: \.self) { Text($0) }
                                }.pickerStyle(.menu).accentColor(.primary)
                            }
                            .padding(.vertical, 4)
                            .formRow()
                        }
                        
                        FormCard(title: "TIMELINE") {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .formRow()
                            Divider()
                            Toggle("Currently Ongoing", isOn: $isOngoing)
                                .padding(.vertical, 4)
                                .formRow()
                            if !isOngoing {
                                Divider()
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .formRow()
                            }
                        }
                        
                        FormCard(title: "IMPACT") {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                TextField("Total Hours (Optional)", text: $hoursString)
                                    .keyboardType(.decimalPad)
                            }
                            .formRow()
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description / Achievements")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .padding(4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 8)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 10)
                }
                .dismissKeyboardOnTap() // <--- KEYBOARD DISMISSAL
                
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
