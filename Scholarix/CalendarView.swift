import SwiftUI

// --- UI HELPER ---
struct ColorHelper {
    static func colorForType(_ type: String) -> Color {
        switch type {
        case "Test": return .red
        case "Project": return .purple
        case "Essay": return .orange
        case "Application": return .pink
        case "Event": return .yellow
        case "Club": return .mint
        case "Sport": return .green
        default: return .blue
        }
    }
}

// --- MAIN VIEW ---
struct CalendarView: View {
    let deadlines: [Deadline]
    @Binding var selectedDeadline: Deadline?
    
    var onDelete: ((Deadline) -> Void)? = nil
    var onToggle: ((Deadline) -> Void)? = nil
    
    @State private var currentMonth = Date()
    @State private var selectedDate = Date()
    @State private var showDayView = false
    @Namespace var animation
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        ZStack {
            // Main Calendar Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. Calendar Card
                    VStack(spacing: 16) {
                        MonthNavigation(currentMonth: $currentMonth)
                        
                        // Days of Week Header
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(daysOfWeek(), id: \.self) { day in
                                Text(day)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Calendar Grid
                        LazyVGrid(columns: columns, spacing: 10) {
                            let days = daysInMonth()
                            ForEach(days.indices, id: \.self) { index in
                                if let date = days[index] {
                                    DayCell(
                                        date: date,
                                        deadlines: deadlines.filter { calendar.isDate($0.dueDate, inSameDayAs: date) },
                                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                        isToday: calendar.isDateInToday(date)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedDate = date
                                        }
                                    }
                                    .onTapGesture(count: 2) {
                                        selectedDate = date
                                        withAnimation(.spring()) { showDayView = true }
                                    }
                                } else {
                                    Text("").frame(height: 40)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 2. Schedule List (Summary)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Schedule")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                Text(selectedDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // Expand Button
                            Button {
                                withAnimation(.spring()) { showDayView = true }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Hourly")
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                }
                                .font(.system(.caption, design: .rounded).weight(.bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                        
                        let dailyTasks = deadlines.filter { calendar.isDate($0.dueDate, inSameDayAs: selectedDate) }
                        
                        if dailyTasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "mug.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary.opacity(0.3))
                                Text("No tasks for today")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color(.secondarySystemGroupedBackground).opacity(0.5))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(dailyTasks.sorted(by: { $0.dueDate < $1.dueDate })) { task in
                                    ScheduleRow(item: task, onEdit: { selectedDeadline = $0 }, onDelete: onDelete, onToggle: onToggle)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .blur(radius: showDayView ? 5 : 0) // Blur background when overlay is active
            
            // Full Screen Day View Overlay
            if showDayView {
                HourlyScheduleView(
                    date: selectedDate,
                    deadlines: deadlines.filter { calendar.isDate($0.dueDate, inSameDayAs: selectedDate) },
                    namespace: animation,
                    onToggle: onToggle,
                    onDismiss: { withAnimation(.spring()) { showDayView = false } }
                )
                .zIndex(2)
                .transition(.move(edge: .bottom))
            }
        }
    }
    
    // --- Helpers ---
    private func daysOfWeek() -> [String] { ["S", "M", "T", "W", "T", "F", "S"] }
    
    private func daysInMonth() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth),
              let start = interval.start as Date? else { return [] }
        
        let count = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        let firstWeekday = calendar.component(.weekday, from: start)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 1...count {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: start) { days.append(d) }
        }
        return days
    }
}

// --- SUBVIEWS ---

struct MonthNavigation: View {
    @Binding var currentMonth: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            Text(monthTitle(from: currentMonth))
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func changeMonth(by value: Int) {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else { return }
        if let new = calendar.date(byAdding: .month, value: value, to: start) { currentMonth = new }
    }
    
    private func monthTitle(from date: Date) -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "MMMM yyyy"; return formatter.string(from: date)
    }
}

struct DayCell: View {
    let date: Date, deadlines: [Deadline], isSelected: Bool, isToday: Bool
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isSelected || isToday ? .bold : .medium)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                .frame(width: 34, height: 34)
                .background(
                    Group {
                        if isSelected {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        } else if isToday {
                            Circle().fill(Color.blue.opacity(0.1))
                        }
                    }
                )
            
            // Dots indicator
            HStack(spacing: 3) {
                ForEach(Array(deadlines.prefix(3)), id: \.self) { deadline in
                    Circle()
                        .fill(isSelected ? .white.opacity(0.8) : ColorHelper.colorForType(deadline.type))
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 50)
        .contentShape(Rectangle())
    }
}

struct ScheduleRow: View {
    let item: Deadline
    let onEdit: (Deadline) -> Void
    var onDelete: ((Deadline) -> Void)?, onToggle: ((Deadline) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            // Accent Strip
            if !item.isCompleted {
                Rectangle()
                    .fill(ColorHelper.colorForType(item.type))
                    .frame(width: 4)
            }
            
            // Checkmark
            Button(action: { withAnimation { onToggle?(item) } }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.isCompleted ? .green : .secondary.opacity(0.6))
            }
            .padding(.leading, 12)
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        if item.isAllDay {
                            Text("All Day")
                        } else {
                            Text(formatTimeRange(start: item.dueDate, end: item.endDate))
                        }
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    
                    if !item.isCompleted {
                        Text(item.type.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ColorHelper.colorForType(item.type).opacity(0.1))
                            .foregroundColor(ColorHelper.colorForType(item.type))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            Menu {
                Button { onEdit(item) } label: { Label("Edit", systemImage: "pencil") }
                Button(role: .destructive) { onDelete?(item) } label: { Label("Delete", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .contentShape(Rectangle())
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    func formatTimeRange(start: Date, end: Date?) -> String {
        let f = DateFormatter(); f.timeStyle = .short
        if let end = end { return "\(f.string(from: start)) - \(f.string(from: end))" }
        return f.string(from: start)
    }
}

// --- HOURLY VIEW (With Correct Geometry Logic) ---
struct HourlyScheduleView: View {
    let date: Date
    let deadlines: [Deadline]
    var namespace: Namespace.ID
    var onToggle: ((Deadline) -> Void)?
    var onDismiss: () -> Void
    
    private let hours = Array(0...23)
    private let calendar = Calendar.current
    private let timeHeight: CGFloat = 80
    private let columnWidth: CGFloat = 180
    
    private var headerDateString: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEEE, MMMM d"; return formatter.string(from: date)
    }
    
    // --- Layout Logic ---
    struct PlacedItem: Identifiable {
        let id: String
        let deadline: Deadline
        let yOffset: CGFloat
        let height: CGFloat
        let colIndex: Int
        let colSpan: Int
    }
    
    private var allDayItems: [Deadline] { deadlines.filter { $0.isAllDay } }
    
    private var timedItems: [PlacedItem] {
        let sorted = deadlines.filter { !$0.isAllDay }.sorted { $0.dueDate < $1.dueDate }
        var result: [PlacedItem] = []
        var columns: [[Deadline]] = []
        
        // Arrange items into columns to handle overlaps
        for item in sorted {
            var placed = false
            for (i, column) in columns.enumerated() {
                if let last = column.last {
                    let lastEnd = last.endDate ?? last.dueDate.addingTimeInterval(isEvent(last) ? 3600 : 1800)
                    if item.dueDate >= lastEnd {
                        columns[i].append(item)
                        placed = true
                        break
                    }
                }
            }
            if !placed { columns.append([item]) }
        }
        
        for (colIndex, column) in columns.enumerated() {
            for item in column {
                if let offsets = calculateGeometry(for: item) {
                    result.append(PlacedItem(
                        id: item.id ?? UUID().uuidString,
                        deadline: item,
                        yOffset: offsets.y,
                        height: offsets.h,
                        colIndex: colIndex,
                        colSpan: columns.count
                    ))
                }
            }
        }
        return result
    }
    
    func isEvent(_ item: Deadline) -> Bool {
        return ["Event", "Club", "Sport", "Other"].contains(item.type)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(headerDateString)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "xmark.circle.fill").hidden()
            }
            .padding()
            .background(Material.regular)
            
            // All Day Section
            if !allDayItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ALL DAY")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allDayItems) { item in
                                TaskBubble(deadline: item, onToggle: onToggle)
                                    .frame(width: 160)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Divider().padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
            
            // Main Timeline with Sticky Time Column
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 0) {
                        // Sticky Time Column
                        VStack(spacing: 0) {
                            ForEach(hours, id: \.self) { hour in
                                Text(formatHour(hour))
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .frame(height: timeHeight, alignment: .top)
                                    .frame(width: 60, alignment: .trailing)
                                    .padding(.trailing, 8)
                                    .offset(y: -7)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Horizontal Scroll Area
                        ScrollView(.horizontal, showsIndicators: true) {
                            ZStack(alignment: .topLeading) {
                                // Grid Lines
                                VStack(spacing: 0) {
                                    ForEach(hours, id: \.self) { _ in
                                        Rectangle()
                                            .fill(Color(.separator))
                                            .frame(height: 1)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: timeHeight, alignment: .top)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Tasks
                                ForEach(timedItems) { item in
                                    let x = CGFloat(item.colIndex) * columnWidth
                                    
                                    TaskBubble(deadline: item.deadline, onToggle: onToggle)
                                        .frame(width: columnWidth - 8, height: item.height)
                                        .position(x: x + (columnWidth - 8)/2, y: item.yOffset + item.height/2 + 20)
                                }
                            }
                            .frame(
                                width: max(geo.size.width - 60, CGFloat(timedItems.map { $0.colIndex }.max() ?? 0 + 1) * columnWidth + 100),
                                height: CGFloat(hours.count) * timeHeight + 50
                            )
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.top, 40) // Drop down slightly from top
    }
    
    func formatHour(_ hour: Int) -> String {
        let ampm = hour >= 12 ? "PM" : "AM"
        let h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(h) \(ampm)"
    }
    
    func calculateGeometry(for item: Deadline) -> (y: CGFloat, h: CGFloat)? {
        let startHour = calendar.component(.hour, from: item.dueDate)
        let startMin = calendar.component(.minute, from: item.dueDate)
        
        let startOffset = (CGFloat(startHour) + CGFloat(startMin)/60.0) * timeHeight
        
        let height: CGFloat
        if isEvent(item) {
            let end = item.endDate ?? item.dueDate.addingTimeInterval(3600)
            let duration = end.timeIntervalSince(item.dueDate)
            height = max(CGFloat(duration / 3600.0) * timeHeight, 50)
        } else {
            height = 50 // Fixed height for simple tasks
        }
        
        return (y: startOffset, h: height)
    }
}

struct TaskBubble: View {
    let deadline: Deadline
    var onToggle: ((Deadline) -> Void)?
    
    var isEvent: Bool {
        return ["Event", "Club", "Sport", "Other"].contains(deadline.type)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(ColorHelper.colorForType(deadline.type))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .strikethrough(deadline.isCompleted)
                    .foregroundColor(deadline.isCompleted ? .secondary : .primary)
                
                if isEvent {
                    if let details = deadline.details, !details.isEmpty {
                        Text(details)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    if !deadline.isAllDay {
                        Text(formatTimeRange(start: deadline.dueDate, end: deadline.endDate))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(formatTimeRange(start: deadline.dueDate, end: nil))
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 6)
            
            Spacer(minLength: 0)
            
            if !isEvent { // Show checkmark for simple tasks
                Button(action: { onToggle?(deadline) }) {
                    Image(systemName: deadline.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundColor(deadline.isCompleted ? .green : .secondary.opacity(0.4))
                }
                .padding(.trailing, 6)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    func formatTimeRange(start: Date, end: Date?) -> String {
        let f = DateFormatter(); f.timeStyle = .short
        if let end = end { return "\(f.string(from: start)) - \(f.string(from: end))" }
        return f.string(from: start)
    }
}
