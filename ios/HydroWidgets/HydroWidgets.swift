import WidgetKit
import SwiftUI

// App Group identifier for sharing data with iOS widgets
let appGroupId = "group.com.antigravity.hydroReminder"

struct WaterWidgetEntry: TimelineEntry {
    let date: Date
    let todayConsumed: Int
    let dailyGoal: Int
    let dailyRemaining: Int
    let percentage: Int
    let preset1: Int
    let preset2: Int
    let preset3: Int
}

struct WaterTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterWidgetEntry {
        WaterWidgetEntry(
            date: Date(),
            todayConsumed: 1500,
            dailyGoal: 2500,
            dailyRemaining: 1000,
            percentage: 60,
            preset1: 200,
            preset2: 330,
            preset3: 500
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterWidgetEntry) -> Void) {
        let entry = loadCurrentData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterWidgetEntry>) -> Void) {
        let entry = loadCurrentData()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadCurrentData() -> WaterWidgetEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        let consumed = prefs?.integer(forKey: "todayConsumed") ?? 0
        let goal = prefs?.integer(forKey: "dailyGoal") ?? 2500
        let remaining = prefs?.integer(forKey: "dailyRemaining") ?? 2500
        let percent = prefs?.integer(forKey: "percentage") ?? 0
        let p1 = prefs?.integer(forKey: "preset1") ?? 200
        let p2 = prefs?.integer(forKey: "preset2") ?? 330
        let p3 = prefs?.integer(forKey: "preset3") ?? 500

        return WaterWidgetEntry(
            date: Date(),
            todayConsumed: consumed,
            dailyGoal: goal > 0 ? goal : 2500,
            dailyRemaining: remaining >= 0 ? remaining : 0,
            percentage: percent,
            preset1: p1 > 0 ? p1 : 200,
            preset2: p2 > 0 ? p2 : 330,
            preset3: p3 > 0 ? p3 : 500
        )
    }
}

// 1. Progress & Status Widget
struct WaterProgressWidgetEntryView: View {
    var entry: WaterWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // iOS 16+ Lock Screen Rectangular
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.cyan)
                    Text("HydroSoft (%\(entry.percentage))")
                        .font(.headline)
                }
                Text("İçilen: \(entry.todayConsumed) / \(entry.dailyGoal) ml")
                    .font(.caption2)
                ProgressView(value: Double(entry.percentage), total: 100.0)
                    .tint(.cyan)
            }
        default:
            // Home Screen Medium / Small
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("💧")
                        .font(.title3)
                    Text("HydroSoft")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.01, green: 0.52, blue: 0.78))
                    Spacer()
                    Text("%\(entry.percentage)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.88, green: 0.95, blue: 0.99))
                        .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                        .cornerRadius(8)
                }

                HStack(alignment: .lastTextBaseline) {
                    Text("\(entry.todayConsumed) ml")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 0.06, green: 0.09, blue: 0.16))
                    Text("/ \(entry.dailyGoal) ml")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Kalan: \(entry.dailyRemaining) ml")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.01, green: 0.52, blue: 0.78))
                }

                ProgressView(value: min(Double(entry.percentage), 100.0), total: 100.0)
                    .tint(Color(red: 0.29, green: 0.64, blue: 0.89))
            }
            .padding()
            .widgetURL(URL(string: "hydroreminder://open"))
        }
    }
}

// 2. Quick Log Widget
struct WaterQuickLogWidgetEntryView: View {
    var entry: WaterWidgetEntry

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("⚡ Hızlı Su Ekle")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.01, green: 0.52, blue: 0.78))
                Spacer()
                Text("Bugün: \(entry.todayConsumed) ml")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                    VStack(spacing: 2) {
                        Text("🥛").font(.title3)
                        Text("+\(entry.preset1) ml").font(.system(size: 10, weight: .bold)).foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.55))
                    .cornerRadius(12)
                }

                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset2)")!) {
                    VStack(spacing: 2) {
                        Text("🥤").font(.title3)
                        Text("+\(entry.preset2) ml").font(.system(size: 10, weight: .bold)).foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.55))
                    .cornerRadius(12)
                }

                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset3)")!) {
                    VStack(spacing: 2) {
                        Text("🌊").font(.title3)
                        Text("+\(entry.preset3) ml").font(.system(size: 10, weight: .bold)).foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.55))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

// 3. Mini / Circular Lock Screen Widget
struct WaterMiniWidgetEntryView: View {
    var entry: WaterWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(.cyan)
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(entry.percentage) / 100.0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.cyan)
                    .rotationEffect(Angle(degrees: 270.0))
                VStack(spacing: 0) {
                    Image(systemName: "drop.fill").font(.system(size: 10))
                    Text("%\(entry.percentage)").font(.system(size: 11, weight: .black))
                }
            }
        case .accessoryInline:
            Label("Su: %\(entry.percentage) (\(entry.dailyRemaining) ml kalan)", systemImage: "drop.fill")
        default:
            VStack {
                Text("💧").font(.title2)
                Text("%\(entry.percentage)")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                Text("\(entry.dailyRemaining) ml")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .widgetURL(URL(string: "hydroreminder://open"))
        }
    }
}

// Widget Configurations
struct WaterProgressWidget: Widget {
    let kind: String = "WaterProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterProgressWidgetEntryView(entry: entry)
                .containerBackground(Color.white.opacity(0.28), for: .widget)
        }
        .configurationDisplayName("HydroSoft Su Durumu")
        .description("Günlük tüketilen su, kalan hedef ve ilerleme yüzdesini gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct WaterQuickLogWidget: Widget {
    let kind: String = "WaterQuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterQuickLogWidgetEntryView(entry: entry)
                .containerBackground(Color.white.opacity(0.28), for: .widget)
        }
        .configurationDisplayName("Hızlı Su Ekle")
        .description("Bardak veya şişe sembolüne basarak tek dokunuşla su içtiğinizi kaydedin.")
        .supportedFamilies([.systemMedium])
    }
}

struct WaterMiniWidget: Widget {
    let kind: String = "WaterMiniWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterMiniWidgetEntryView(entry: entry)
                .containerBackground(Color.white.opacity(0.28), for: .widget)
        }
        .configurationDisplayName("Mini Su Sayacı")
        .description("Kilit ekranı için dairesel veya kompakt su göstergesi.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

@main
struct HydroWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WaterProgressWidget()
        WaterQuickLogWidget()
        WaterMiniWidget()
    }
}
