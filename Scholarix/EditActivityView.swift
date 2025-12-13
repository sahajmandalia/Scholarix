import SwiftUI

struct EditActivityView: View {
    @Environment(\.dismiss) var dismiss
    var activity: Activity
    @ObservedObject var viewModel: ExtracurricularsViewModel
    
    @State private var title: String
    @State private var position: String
    @State private var type: String
    @State private var hoursString: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isOngoing: Bool
    @State private var description: String
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    let types = ["Club", "Sport", "Service", "Award", "Work", "Other"]
    
    init(activity: Activity, viewModel: ExtracurricularsViewModel) {
        self.activity = activity
        self.viewModel = viewModel
        
        _title = State(initialValue: activity.title)
        _position = State(initialValue: activity.position)
        _type = State(initialValue: activity.type)
        _hoursString = State(initialValue: activity.hours != nil ? String(format: "%.0f", activity.hours!) : "")
        _startDate = State(initialValue: activity.startDate)
        _endDate = State(initialValue: activity.endDate ?? Date())
        _isOngoing = State(initialValue: activity.endDate == nil)
        _description = State(initialValue: activity.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // --- PREMIUM BACKGROUND ---
                LinearGradient(
                    colors: [Color.green.opacity(0.05), Color.orange.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        header(title: "Edit Activity", subtitle: "Update your experience profile", icon: "pencil.circle.fill", color: .orange)
                        
                        FormCard(title: "BASIC INFO") {
                            HStack {
                                Image(systemName: "star")
                                    .foregroundColor(.orange)
                                    .frame(width: 24)
                                TextField("Activity Name", text: $title)
                            }
                            .formRow()
                            Divider()
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                TextField("Role / Position", text: $position)
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
                    label: "Save Changes",
                    isDisabled: title.isEmpty || isSaving,
                    isSaving: isSaving,
                    action: update
                )
            }
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.disabled(isSaving)
                }
            }
            .alert("Error", isPresented: $showingErrorAlert) { Button("OK", role: .cancel) { } } message: { Text(errorMessage) }
        }
    }
    
    private func update() {
        isSaving = true
        var updated = activity
        updated.title = title
        updated.position = position
        updated.type = type
        updated.hours = Double(hoursString)
        updated.startDate = startDate
        updated.endDate = isOngoing ? nil : endDate
        updated.description = description.isEmpty ? nil : description
        
        Task {
            do {
                try await viewModel.updateActivity(updated)
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription; showingErrorAlert = true }
            }
            await MainActor.run { isSaving = false }
        }
    }
}
