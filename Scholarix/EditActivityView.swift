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
                            HStack(spacing: 12) {
                                Image(systemName: "star")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Activity Name", text: $title)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Role / Position", text: $position)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                Image(systemName: "tag")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                Text("Type")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Picker("Type", selection: $type) {
                                    ForEach(types, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                                .accentColor(Theme.brandPrimary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        FormCard(title: "TIMELINE") {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .font(.system(.body, design: .rounded))
                                .padding(.vertical, 8)
                            
                            Divider()
                            
                            Toggle("Currently Ongoing", isOn: $isOngoing)
                                .font(.system(.body, design: .rounded))
                                .padding(.vertical, 8)
                            
                            if !isOngoing {
                                Divider()
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .font(.system(.body, design: .rounded))
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        FormCard(title: "IMPACT") {
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 28, alignment: .center)
                                TextField("Total Hours (Optional)", text: $hoursString)
                                    .keyboardType(.decimalPad)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 28, alignment: .center)
                                    Text("Description / Achievements")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .padding(.top, 4)
                                
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Theme.inputBackground)
                                    .cornerRadius(10)
                                    .font(.system(.body, design: .rounded))
                            }
                            .padding(.bottom, 4)
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
