import SwiftUI
import FirebaseCore

struct CourseDetailView: View {
    @ObservedObject var viewModel: AcademicViewModel
    let courseId: String
    
    // Live lookup ensures changes show immediately after editing
    var course: Course? {
        viewModel.courses.first(where: { $0.id == courseId })
    }
    
    func gradeColor(for grade: Double) -> Color {
        switch grade {
        case 90...: return .green
        case 80..<90: return .blue
        default: return .orange
        }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            if let course = course {
                ScrollView {
                    VStack(spacing: 24) {
                        // --- Header Card ---
                        VStack(spacing: 16) {
                            ZStack {
                                Circle().fill(gradeColor(for: course.gradePercent ?? 0).opacity(0.1))
                                    .frame(width: 120, height: 120)
                                Circle().stroke(gradeColor(for: course.gradePercent ?? 0), lineWidth: 4)
                                    .frame(width: 120, height: 120)
                                VStack(spacing: 4) {
                                    if let grade = course.gradePercent {
                                        Text("\(grade, specifier: "%.1f")%")
                                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                                            .foregroundColor(gradeColor(for: grade))
                                    } else {
                                        Text("--").font(.system(size: 32, weight: .heavy, design: .rounded)).foregroundColor(.secondary)
                                    }
                                    Text("Current Grade").font(.caption).fontWeight(.bold).foregroundColor(.secondary).textCase(.uppercase)
                                }
                            }
                            .padding(.top, 20)
                            
                            Text(course.name)
                                .font(.system(.title2, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Theme.cardBackground).cornerRadius(24)
                        .shadow(color: Theme.shadowLight, radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // --- Details Grid ---
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            DetailInfoCard(icon: "graduationcap.fill", title: "Level", value: course.courseLevel, color: .purple)
                            DetailInfoCard(icon: "star.fill", title: "Credits", value: String(format: "%.1f", course.credits), color: .orange)
                            DetailInfoCard(icon: "number.square.fill", title: "Grade Taken", value: "\(course.gradeLevel)th", color: .blue)
                            DetailInfoCard(icon: "calendar", title: "Added", value: course.createdAt?.dateValue().formatted(date: .abbreviated, time: .omitted) ?? "Unknown", color: .gray)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Direct Push to Edit Screen
                        NavigationLink("Edit") {
                            EditCourseView(viewModel: viewModel, courseToEdit: course)
                        }
                    }
                }
            } else {
                Text("Course not found").foregroundColor(.secondary)
            }
        }
    }
}

// Reusable Sub-component
struct DetailInfoCard: View {
    let icon: String, title: String, value: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(color).padding(8).background(color.opacity(0.1)).clipShape(Circle())
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.system(.title3, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                Text(title).font(.system(.caption, design: .rounded)).foregroundColor(Theme.textSecondary)
            }
        }
        .padding(16).background(Theme.cardBackground).cornerRadius(16).shadow(color: Theme.shadowLight, radius: 5, x: 0, y: 2)
    }
}
