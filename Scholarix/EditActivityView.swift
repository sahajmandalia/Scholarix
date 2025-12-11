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
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing
                        header(title: "Edit Activity", subtitle: "Update your experience profile", icon: "pencil.circle.fill", color: .orange)
                        
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

