import SwiftUI

struct DeadlineDetailView: View {
    @ObservedObject var viewModel: AcademicViewModel
    let deadlineId: String
    
    var deadline: Deadline? { viewModel.deadlines.first(where: { $0.id == deadlineId }) }
    
    var typeColor: Color {
        guard let deadline = deadline else { return .gray }
        switch deadline.type {
        case "Test": return Theme.activityTest
        case "Project": return Theme.activityProject
        case "Essay": return Theme.activityEssay
        default: return Theme.brandPrimary
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            if let deadline = deadline {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 20) {
                            HStack {
                                Text(deadline.type.uppercased()).font(.caption).fontWeight(.bold).padding(6).background(typeColor.opacity(0.1)).foregroundColor(typeColor).clipShape(Capsule())
                                Spacer()
                                if let priority = deadline.priority {
                                    HStack(spacing: 4) { Image(systemName: "flag.fill"); Text(priority) }
                                    .font(.caption).fontWeight(.semibold).foregroundColor(priority == "High" ? .red : .gray)
                                }
                            }
                            Text(deadline.title).font(.system(.title, design: .rounded)).fontWeight(.heavy).foregroundColor(Theme.textPrimary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Divider()
                            Button(action: { withAnimation { viewModel.toggleCompletion(deadline: deadline) } }) {
                                HStack {
                                    Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle").font(.title2)
                                    Text(deadline.isCompleted ? "Completed" : "Mark as Complete").fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding().foregroundColor(deadline.isCompleted ? .white : .primary).background(deadline.isCompleted ? Color.green : Color.clear).cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(deadline.isCompleted ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1))
                            }
                        }
                        .padding(24).background(Theme.cardBackground).cornerRadius(24).shadow(color: Theme.shadowLight, radius: 10, x: 0, y: 5).padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            detailRow(icon: "calendar", title: "Date", text: deadline.dueDate.formatted(date: .long, time: .omitted))
                            Divider().padding(.leading, 50)
                            if deadline.isAllDay { detailRow(icon: "clock", title: "Time", text: "All Day") }
                            else { detailRow(icon: "clock", title: "Time", text: deadline.dueDate.formatted(date: .omitted, time: .shortened)) }
                            if let details = deadline.details, !details.isEmpty {
                                Divider().padding(.leading, 50)
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top, spacing: 16) {
                                        Image(systemName: "text.alignleft").font(.system(size: 20)).foregroundColor(.gray).frame(width: 24)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Details").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                                            Text(details).font(.body).foregroundColor(Theme.textPrimary)
                                        }
                                    }.padding()
                                }
                            }
                        }.background(Theme.cardBackground).cornerRadius(16).padding(.horizontal).shadow(color: Theme.shadowLight, radius: 5, x: 0, y: 2)
                    }.padding(.vertical)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Direct Push to Edit Screen
                        NavigationLink("Edit") {
                            EditDeadlineView(viewModel: viewModel, deadlineToEdit: deadline)
                        }
                    }
                }
            } else { Text("Task not found").foregroundColor(.secondary) }
        }
    }
    
    func detailRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(Theme.brandPrimary).frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                Text(text).font(.body).fontWeight(.medium).foregroundColor(Theme.textPrimary)
            }
            Spacer()
        }.padding()
    }
}
