import SwiftUI

struct ActivityDetailView: View {
    @ObservedObject var viewModel: ExtracurricularsViewModel
    let activityId: String
    
    // Live lookup for instant updates
    var activity: Activity? { viewModel.activities.first(where: { $0.id == activityId }) }
    
    var themeColor: Color {
        guard let activity = activity else { return .gray }
        switch activity.type {
        case "Sport": return Theme.activitySport
        case "Club": return Theme.activityClub
        case "Service": return Color.pink
        case "Award": return Theme.warning
        default: return Theme.brandSecondary
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            if let activity = activity {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: iconForType(activity.type)).font(.system(size: 50)).foregroundColor(themeColor).padding(20).background(themeColor.opacity(0.1)).clipShape(Circle())
                            VStack(spacing: 8) {
                                Text(activity.title).font(.system(.title2, design: .rounded)).fontWeight(.heavy).foregroundColor(Theme.textPrimary).multilineTextAlignment(.center)
                                Text(activity.position).font(.headline).foregroundColor(Theme.textSecondary)
                            }
                            HStack(spacing: 12) {
                                Badge(text: activity.type, color: themeColor)
                                if let hours = activity.hours, hours > 0 { Badge(text: "\(Int(hours)) Hours", color: .gray) }
                                if activity.isOngoing { Badge(text: "Ongoing", color: .green) }
                            }
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 30).background(Theme.cardBackground).cornerRadius(24).shadow(color: Theme.shadowLight, radius: 10, x: 0, y: 5).padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("START DATE").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                                    Text(activity.startDate.formatted(date: .abbreviated, time: .omitted)).fontWeight(.medium)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("END DATE").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                                    if let end = activity.endDate { Text(end.formatted(date: .abbreviated, time: .omitted)).fontWeight(.medium) }
                                    else { Text("Present").fontWeight(.medium).foregroundColor(.green) }
                                }
                            }
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ABOUT").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                                if let desc = activity.description, !desc.isEmpty { Text(desc).font(.body).foregroundColor(Theme.textPrimary).fixedSize(horizontal: false, vertical: true) }
                                else { Text("No description provided.").italic().foregroundColor(.secondary) }
                            }
                        }.padding(24).background(Theme.cardBackground).cornerRadius(24).shadow(color: Theme.shadowLight, radius: 5, x: 0, y: 2).padding(.horizontal)
                    }.padding(.vertical)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Direct Push to Edit Screen
                        NavigationLink("Edit") {
                            EditActivityView(activity: activity, viewModel: viewModel)
                        }
                    }
                }
            } else { Text("Activity not found").foregroundColor(.secondary) }
        }
    }
    
    func iconForType(_ type: String) -> String {
        switch type {
        case "Sport": return "figure.run"; case "Club": return "person.3.fill"; case "Service": return "heart.fill"; case "Award": return "trophy.fill"; default: return "star.fill"
        }
    }
    
    struct Badge: View {
        let text: String, color: Color
        var body: some View { Text(text.uppercased()).font(.system(size: 10, weight: .bold)).padding(.horizontal, 8).padding(.vertical, 4).background(color.opacity(0.1)).foregroundColor(color).cornerRadius(8) }
    }
}
