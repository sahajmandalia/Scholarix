import SwiftUI

struct CourseRowView: View {
    let course: Course
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var levelColor: Color {
        switch course.courseLevel {
        case "AP", "IB": return .purple
        case "Honors": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Level Indicator Strip
            RoundedRectangle(cornerRadius: 4)
                .fill(levelColor)
                .frame(width: 4)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(course.courseLevel)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(levelColor.opacity(0.1))
                        .foregroundColor(levelColor)
                        .cornerRadius(4)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(course.credits, specifier: "%.1f") Credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Grade Badge
            if let grade = course.gradePercent {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(grade, specifier: "%.1f")%")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(grade >= 90 ? .green : (grade >= 80 ? .blue : .orange))
                        // Why is this here?
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(grade >= 90 ? .green : (grade >= 80 ? .blue : .orange))
                        .baselineOffset(0)
                    
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("--")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        // Note: The List/Parent view handles the swipe actions
    }
}

