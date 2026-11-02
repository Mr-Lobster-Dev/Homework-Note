import SwiftUI
import WidgetKit

// MARK: - Data

/// One event, task or to-do, as saved by the web app. Missing fields are fine.
struct HNItem: Decodable {
    let id: String
    let type: String
    let title: String
    let color: String?
    let due: String?
    let done: Bool?
    let urgency: Int?
    let rise: Bool?
    let urgencyStart: Double?
    let createdAt: Double?
}

/// Skips an item that can't be read instead of failing the whole list.
private struct Failable: Decodable {
    let item: HNItem?
    init(from decoder: Decoder) throws { item = try? HNItem(from: decoder) }
}

enum WidgetData {
    static var groupID: String {
        Bundle.main.object(forInfoDictionaryKey: "HNAppGroup") as? String ?? ""
    }

    static func load() -> [HNItem] {
        guard let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: groupID)?
                .appendingPathComponent("items.json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Failable].self, from: data) else { return [] }
        return list.compactMap { $0.item }
    }
}

// MARK: - Choosing what to show

private let gregorian = Calendar(identifier: .gregorian)

private func dateKey(_ date: Date) -> String {
    let c = gregorian.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
}

private func shortDate(_ key: String) -> String {
    let parts = key.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3,
          let date = gregorian.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) else { return key }
    let f = DateFormatter()
    f.calendar = gregorian
    f.locale = Locale.current
    f.setLocalizedDateFormatFromTemplate("MMMd")
    return f.string(from: date)
}

/// Same rule as the app: starts at the chosen level and goes up one level every 3 days, up to High.
private func urgencyLevel(_ item: HNItem, now: Date) -> Int {
    let base = min(2, max(0, item.urgency ?? 0))
    if item.rise == false { return base }
    let startMs = item.urgencyStart ?? item.createdAt ?? now.timeIntervalSince1970 * 1000
    let days = Int(floor((now.timeIntervalSince1970 * 1000 - startMs) / 86_400_000 / 3))
    return min(2, base + max(0, days))
}

struct Row: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let color: Color
    let isOverdue: Bool
}

struct Summary {
    let rows: [Row]
    let openCount: Int
    let overdueCount: Int
    let todayCount: Int
}

func summarize(_ items: [HNItem], now: Date) -> Summary {
    let today = dateKey(now)
    let open = items.filter { $0.done != true }
    let urgencyNames = ["Low", "Medium", "High"]

    // Lower group number is shown first: 0 overdue, 1 due today, 2 high, 3 medium, 4 low, 5 upcoming.
    var ranked: [(group: Int, sort: String, row: Row)] = []
    var overdue = 0, dueToday = 0
    for item in open {
        let color = Color(hex: item.color ?? "#5856D6")
        let created = String(format: "%020.0f", item.createdAt ?? 0)
        if item.type == "todo" {
            let level = urgencyLevel(item, now: now)
            ranked.append((4 - level, created, Row(id: item.id, title: item.title,
                subtitle: "\(urgencyNames[level]) urgency", color: color, isOverdue: false)))
        } else if let due = item.due {
            if due < today {
                overdue += 1
                ranked.append((0, due + created, Row(id: item.id, title: item.title,
                    subtitle: "Overdue, due \(shortDate(due))", color: color, isOverdue: true)))
            } else if due == today {
                dueToday += 1
                ranked.append((1, created, Row(id: item.id, title: item.title,
                    subtitle: "Due today", color: color, isOverdue: false)))
            } else {
                ranked.append((5, due + created, Row(id: item.id, title: item.title,
                    subtitle: "Due \(shortDate(due))", color: color, isOverdue: false)))
            }
        }
    }
    ranked.sort { ($0.group, $0.sort) < ($1.group, $1.sort) }
    return Summary(rows: ranked.map { $0.row }, openCount: open.count, overdueCount: overdue, todayCount: dueToday)
}

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        self.init(.sRGB,
                  red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255,
                  opacity: 1)
    }
}

// MARK: - Widget

struct HNEntry: TimelineEntry {
    let date: Date
    let summary: Summary
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HNEntry {
        HNEntry(date: Date(), summary: Summary(rows: [
            Row(id: "1", title: "Math worksheet", subtitle: "Due today", color: .orange, isOverdue: false),
            Row(id: "2", title: "Science fair", subtitle: "Due Nov 12", color: .red, isOverdue: false),
            Row(id: "3", title: "Email Ms. Chen", subtitle: "Medium urgency", color: .teal, isOverdue: false)
        ], openCount: 3, overdueCount: 0, todayCount: 1))
    }

    func getSnapshot(in context: Context, completion: @escaping (HNEntry) -> Void) {
        completion(HNEntry(date: Date(), summary: summarize(WidgetData.load(), now: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HNEntry>) -> Void) {
        let now = Date()
        let entry = HNEntry(date: now, summary: summarize(WidgetData.load(), now: now))
        // Refresh every hour so "today" and rising urgency stay correct.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct RowView: View {
    let row: Row
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2).fill(row.color).frame(width: 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(row.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(row.subtitle).font(.caption)
                    .foregroundStyle(row.isOverdue ? Color.red : Color.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(height: 34)
    }
}

struct HNWidgetView: View {
    let entry: HNEntry
    @Environment(\.widgetFamily) private var family

    private var limit: Int {
        switch family {
        case .systemSmall: return 2
        case .systemMedium: return 3
        case .systemLarge: return 8
        default: return 9
        }
    }

    var body: some View {
        let s = entry.summary
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("To do").font(.headline)
                Spacer()
                if s.openCount > 0 {
                    Text("\(s.openCount)").font(.subheadline.weight(.bold))
                        .padding(.horizontal, 9).padding(.vertical, 2)
                        .background(Capsule().fill(Color.indigo)).foregroundStyle(.white)
                }
            }
            if s.rows.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.title).foregroundStyle(.green)
                        Text("All caught up").font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(s.rows.prefix(limit))) { RowView(row: $0) }
                Spacer(minLength: 0)
                if s.rows.count > limit {
                    Text("+\(s.rows.count - limit) more").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

@main
struct HomeworkNoteWidget: Widget {
    let kind = "HomeworkNoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HNWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Homework Note")
        .description("What is overdue, due today and still to do.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
