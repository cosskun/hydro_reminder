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
    let streakDays: Int
    let dayLabels: [String]
    let dayStatuses: [Int]
    let mascotEmoji: String
    let mascotSubtitle: String
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
            preset3: 500,
            streakDays: 2,
            dayLabels: ["Pe", "Cu", "Ct", "Pa", "Pt"],
            dayStatuses: [0, 0, 2, 2, 1],
            mascotEmoji: "🐳",
            mascotSubtitle: "Damla seni çağırıyor! 💦"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterWidgetEntry) -> Void) {
        let entry = loadCurrentData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterWidgetEntry>) -> Void) {
        let entry = loadCurrentData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
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
        let streak = prefs?.integer(forKey: "streakDays") ?? (consumed > 0 ? 1 : 0)

        let rawLabels = prefs?.string(forKey: "dayLabels") ?? "Pe,Cu,Ct,Pa,Pt"
        let labels = rawLabels.components(separatedBy: ",")
        let finalLabels = labels.count == 5 ? labels : ["Pe", "Cu", "Ct", "Pa", "Pt"]

        let rawStatuses = prefs?.string(forKey: "dayStatuses") ?? "0,0,1,1,0"
        let statuses = rawStatuses.components(separatedBy: ",").map { Int($0) ?? 0 }
        let finalStatuses = statuses.count == 5 ? statuses : [0, 0, 1, 1, (consumed > 0 ? 1 : 0)]

        let defaultEmoji: String
        let defaultSub: String
        if percent >= 100 {
            defaultEmoji = "👑"
            defaultSub = "Efsanesin! Günlük hedef tamam! 🏆"
        } else if percent >= 70 {
            defaultEmoji = "🐬"
            defaultSub = "Hedefe çok az kaldı, devam et! 🚀"
        } else if percent >= 30 {
            defaultEmoji = "🐳"
            defaultSub = "Harika gidiyorsun! Su içmeyi unutma! 🌊"
        } else {
            defaultEmoji = "🥵"
            defaultSub = "Damla seni çağırıyor! Su içelim! 💦"
        }

        let emoji = prefs?.string(forKey: "mascotEmoji") ?? defaultEmoji
        let subtitle = prefs?.string(forKey: "mascotSubtitle") ?? defaultSub

        return WaterWidgetEntry(
            date: Date(),
            todayConsumed: consumed,
            dailyGoal: goal > 0 ? goal : 2500,
            dailyRemaining: remaining >= 0 ? remaining : 0,
            percentage: percent,
            preset1: p1 > 0 ? p1 : 200,
            preset2: p2 > 0 ? p2 : 330,
            preset3: p3 > 0 ? p3 : 500,
            streakDays: streak,
            dayLabels: finalLabels,
            dayStatuses: finalStatuses,
            mascotEmoji: emoji,
            mascotSubtitle: subtitle
        )
    }
}

// Dynamic HydroSoft Blue theme gradients based on hydration percentage
private func duolingoGradient(for percentage: Int) -> LinearGradient {
    if percentage >= 100 {
        // Royal Crystal Blue Gradient (100%+)
        return LinearGradient(
            colors: [
                Color(red: 0.00, green: 0.34, blue: 0.61), // #01579B
                Color(red: 0.01, green: 0.53, blue: 0.82), // #0288D1
                Color(red: 0.25, green: 0.77, blue: 1.00)  // #40C4FF
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else if percentage >= 70 {
        // Bright Aqua-Sky Blue Gradient (70-99%)
        return LinearGradient(
            colors: [
                Color(red: 0.01, green: 0.47, blue: 0.74), // #0277BD
                Color(red: 0.01, green: 0.61, blue: 0.90), // #039BE5
                Color(red: 0.22, green: 0.74, blue: 0.97)  // #38BDF8
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else if percentage >= 30 {
        // HydroSoft Signature Sky Blue Gradient (30-69%)
        return LinearGradient(
            colors: [
                Color(red: 0.01, green: 0.41, blue: 0.63), // #0369A1
                Color(red: 0.01, green: 0.53, blue: 0.82), // #0288D1
                Color(red: 0.16, green: 0.71, blue: 0.96)  // #29B6F6
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else {
        // Deep Ocean Blue Gradient (0-29%)
        return LinearGradient(
            colors: [
                Color(red: 0.03, green: 0.35, blue: 0.52), // #075985
                Color(red: 0.01, green: 0.52, blue: 0.78), // #0284C7
                Color(red: 0.22, green: 0.74, blue: 0.97)  // #38BDF8
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// 1. Duolingo-Style Streak, Mascot & 5-Day Checkmark Widget
struct WaterProgressWidgetEntryView: View {
    var entry: WaterWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // iOS 16+ Lock Screen Rectangular
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text("🔥 \(entry.streakDays) gün")
                        .font(.system(size: 12, weight: .heavy))
                    Spacer()
                    Text("%\(entry.percentage) \(entry.mascotEmoji)")
                        .font(.system(size: 11, weight: .bold))
                }
                Text("\(entry.todayConsumed) / \(entry.dailyGoal) ml")
                    .font(.caption2)
                ProgressView(value: min(Double(entry.percentage), 100.0), total: 100.0)
                    .tint(.cyan)
            }
        case .systemSmall:
            // Duolingo-style Small Card (2x2)
            ZStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("🔥 \(entry.streakDays) gün")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("%\(entry.percentage)")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.24))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Text(entry.mascotSubtitle)
                        .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.92))
                        .lineLimit(2)

                    Spacer(minLength: 0)

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(entry.todayConsumed) ml")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                                Text("🥛 +\(entry.preset1)")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white)
                                    .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                                    .cornerRadius(10)
                            }
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.22))
                                .frame(width: 46, height: 46)
                            Text(entry.mascotEmoji)
                                .font(.system(size: 28))
                        }
                    }
                }
            }
            .widgetURL(URL(string: "hydroreminder://open"))
        default:
            // Duolingo-style Medium Card (4x2) with Streak, 5-Day Checkmarks & Big Mascot Character
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    // Streak + Progress Pill
                    HStack(spacing: 8) {
                        Text("🔥 \(entry.streakDays) gün")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("💧 %\(entry.percentage)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.24))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Dynamic Mascot Callout
                    Text(entry.mascotSubtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.92))
                        .lineLimit(1)

                    Spacer(minLength: 2)

                    // 5-Day Duolingo Checkmark Row (Pe Cu Ct Pa Pt)
                    HStack(spacing: 7) {
                        ForEach(0..<5, id: \.self) { idx in
                            let isDone = entry.dayStatuses[idx] > 0
                            VStack(spacing: 3) {
                                Text(entry.dayLabels[idx])
                                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.85))
                                ZStack {
                                    Circle()
                                        .fill(isDone ? Color.white.opacity(0.95) : Color.black.opacity(0.22))
                                        .frame(width: 22, height: 22)
                                    Text(isDone ? "✓" : "•")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(
                                            isDone
                                                ? Color(red: 0.01, green: 0.41, blue: 0.63)
                                                : Color.white.opacity(0.50)
                                        )
                                }
                            }
                        }
                    }

                    // Quick 1-Tap Water Buttons
                    HStack(spacing: 6) {
                        Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                            Text("🥛 +\(entry.preset1) ml")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.95))
                                .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                                .cornerRadius(8)
                        }
                        Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset2)")!) {
                            Text("🥤 +\(entry.preset2) ml")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.24))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }

                Spacer(minLength: 0)

                // Right Side Mascot Character Stage (Duolingo Duo Style)
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.20))
                            .frame(width: 82, height: 82)
                        VStack(spacing: 0) {
                            Text(entry.mascotEmoji)
                                .font(.system(size: 42))
                            Text("\(entry.todayConsumed) ml")
                                .font(.system(size: 10.5, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    Text("Hedef: \(entry.dailyGoal) ml")
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                }
            }
            .widgetURL(URL(string: "hydroreminder://open"))
        }
    }
}

// 2. Interactive Quick Log Bar Widget (Vibrant Ocean Style)
struct WaterQuickLogWidgetEntryView: View {
    var entry: WaterWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🔥 \(entry.streakDays) gün · ⚡ Hızlı Su Ekle")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(entry.mascotEmoji) \(entry.todayConsumed)/\(entry.dailyGoal) ml")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.92))
            }

            HStack(spacing: 8) {
                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                    VStack(spacing: 3) {
                        Text("🥛").font(.title2)
                        Text("+\(entry.preset1) ml")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(14)
                }

                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset2)")!) {
                    VStack(spacing: 3) {
                        Text("🥤").font(.title2)
                        Text("+\(entry.preset2) ml")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(14)
                }

                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset3)")!) {
                    VStack(spacing: 3) {
                        Text("🌊").font(.title2)
                        Text("+\(entry.preset3) ml")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(14)
                }
            }
        }
    }
}

// 3. Mini Mascot & Circular Lock Screen Widget
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
                    Text(entry.mascotEmoji).font(.system(size: 11))
                    Text("%\(entry.percentage)").font(.system(size: 10, weight: .black))
                }
            }
        case .accessoryInline:
            Label("🔥\(entry.streakDays)g · Su %\(entry.percentage) (\(entry.dailyRemaining) ml kalan)", systemImage: "drop.fill")
        default:
            VStack(spacing: 4) {
                HStack {
                    Text("🔥 \(entry.streakDays)")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("%\(entry.percentage)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.9))
                }
                Text(entry.mascotEmoji)
                    .font(.system(size: 36))
                Text("\(entry.todayConsumed) ml")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                    Text("💧 +\(entry.preset1) ml Ekle")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.95))
                        .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                        .cornerRadius(8)
                }
            }
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
                .containerBackground(for: .widget) {
                    duolingoGradient(for: entry.percentage)
                }
        }
        .configurationDisplayName("🔥 HydroSoft Seri & Maskot")
        .description("Duolingo tarzı günlük seri, 5 günlük su takvimi, canlı maskot ve hızlı su ekleme.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct WaterQuickLogWidget: Widget {
    let kind: String = "WaterQuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterQuickLogWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    duolingoGradient(for: entry.percentage)
                }
        }
        .configurationDisplayName("⚡ Hızlı Su Ekleme Barı")
        .description("Bardak veya şişe sembolüne basarak tek dokunuşla su içtiğinizi kaydedin.")
        .supportedFamilies([.systemMedium])
    }
}

struct WaterMiniWidget: Widget {
    let kind: String = "WaterMiniWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterMiniWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    duolingoGradient(for: entry.percentage)
                }
        }
        .configurationDisplayName("🐳 Mini Maskot & Kilit Ekranı")
        .description("Ana ekran ve kilit ekranı için emojili mini maskot ve su halkası.")
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
