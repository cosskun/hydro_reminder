import WidgetKit
import SwiftUI
import Security

// App Group & Shared Keychain identifiers for sharing data with iOS widgets
let appGroupId = "group.com.antigravity.hydroReminder"
let keychainAccessGroup = "BHYTLHA722.com.antigravity.hydroreminder.shared"
let keychainService = "com.antigravity.hydroreminder.widgetsync"
let keychainAccount = "hydro_widget_state_v1"

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
    let preset1Emoji: String
    let preset2Emoji: String
    let preset3Emoji: String
}

private func loadKeychainPayload() -> [String: Any]? {
    let groupedQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: keychainService,
        kSecAttrAccount as String: keychainAccount,
        kSecAttrAccessGroup as String: keychainAccessGroup,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(groupedQuery as CFDictionary, &item)
    if status == errSecSuccess,
       let data = item as? Data,
       let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        return dict
    }

    let fallbackQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: keychainService,
        kSecAttrAccount as String: keychainAccount,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var fallbackItem: CFTypeRef?
    let fallbackStatus = SecItemCopyMatching(fallbackQuery as CFDictionary, &fallbackItem)
    if fallbackStatus == errSecSuccess,
       let data = fallbackItem as? Data,
       let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        return dict
    }
    return nil
}

private func intValue(from dict: [String: Any]?, prefs: UserDefaults?, key: String, defaultVal: Int) -> Int {
    if let val = dict?[key] as? Int {
        return val
    }
    if let num = dict?[key] as? NSNumber {
        return num.intValue
    }
    if let prefs = prefs, prefs.object(forKey: key) != nil {
        return prefs.integer(forKey: key)
    }
    return defaultVal
}

private func stringValue(from dict: [String: Any]?, prefs: UserDefaults?, key: String, defaultVal: String) -> String {
    if let val = dict?[key] as? String, !val.isEmpty {
        return val
    }
    if let val = prefs?.string(forKey: key), !val.isEmpty {
        return val
    }
    return defaultVal
}

struct WaterTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterWidgetEntry {
        WaterWidgetEntry(
            date: Date(),
            todayConsumed: 1250,
            dailyGoal: 2500,
            dailyRemaining: 1250,
            percentage: 50,
            preset1: 200,
            preset2: 330,
            preset3: 500,
            streakDays: 2,
            dayLabels: ["Pe", "Cu", "Ct", "Pa", "Pt"],
            dayStatuses: [0, 0, 2, 2, 1],
            mascotEmoji: "💧",
            mascotSubtitle: "Harika gidiyorsun! Vücudun sana teşekkür ediyor.",
            preset1Emoji: "🥛",
            preset2Emoji: "🥤",
            preset3Emoji: "🍶"
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
        let kcDict = loadKeychainPayload()
        let prefs = UserDefaults(suiteName: appGroupId)

        let consumed = intValue(from: kcDict, prefs: prefs, key: "todayConsumed", defaultVal: 0)
        let goal = intValue(from: kcDict, prefs: prefs, key: "dailyGoal", defaultVal: 2500)
        let remaining = intValue(from: kcDict, prefs: prefs, key: "dailyRemaining", defaultVal: max(goal - consumed, 0))
        let percent = intValue(
            from: kcDict,
            prefs: prefs,
            key: "percentage",
            defaultVal: goal > 0 ? min(Int(round(Double(consumed) * 100.0 / Double(goal))), 100) : 0
        )
        let p1 = intValue(from: kcDict, prefs: prefs, key: "preset1", defaultVal: 200)
        let p2 = intValue(from: kcDict, prefs: prefs, key: "preset2", defaultVal: 330)
        let p3 = intValue(from: kcDict, prefs: prefs, key: "preset3", defaultVal: 500)
        let streak = intValue(from: kcDict, prefs: prefs, key: "streakDays", defaultVal: consumed > 0 ? 1 : 0)

        let rawLabels = stringValue(from: kcDict, prefs: prefs, key: "dayLabels", defaultVal: "Pe,Cu,Ct,Pa,Pt")
        let labels = rawLabels.components(separatedBy: ",")
        let finalLabels = labels.count == 5 ? labels : ["Pe", "Cu", "Ct", "Pa", "Pt"]

        let rawStatuses = stringValue(from: kcDict, prefs: prefs, key: "dayStatuses", defaultVal: "0,0,0,0,0")
        let statuses = rawStatuses.components(separatedBy: ",").map { Int($0) ?? 0 }
        let finalStatuses = statuses.count == 5 ? statuses : [0, 0, 0, 0, (consumed > 0 ? 1 : 0)]

        // Synchronized with DashboardScreen & WaterProvider.getHydrationStatus
        let statusEmoji: String
        let statusSub: String
        if percent >= 100 {
            statusEmoji = "🏆"
            statusSub = "Tebrikler! Günlük su hedefini tamamladın!"
        } else if percent >= 75 {
            statusEmoji = "😎"
            statusSub = "Neredeyse tamamladın! Enerjin yerinde."
        } else if percent >= 50 {
            statusEmoji = "💧"
            statusSub = "Harika gidiyorsun! Vücudun sana teşekkür ediyor."
        } else if percent >= 25 {
            statusEmoji = "🥛"
            statusSub = "Güzel başlangıç! Yavaş yavaş hedefe ilerliyorsun."
        } else {
            statusEmoji = "🥵"
            statusSub = "Çok susuz kaldın! Hemen bir bardak su al."
        }

        let p1Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset1Emoji", defaultVal: "🥛")
        let p2Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset2Emoji", defaultVal: "🥤")
        let p3Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset3Emoji", defaultVal: "🍶")

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
            mascotEmoji: statusEmoji,
            mascotSubtitle: statusSub,
            preset1Emoji: p1Emoji,
            preset2Emoji: p2Emoji,
            preset3Emoji: p3Emoji
        )
    }
}

// Reusable Water Progress Bar (Su Barı)
struct HydroWaterProgressBar: View {
    let percentage: Int
    var height: CGFloat = 7

    var body: some View {
        GeometryReader { geo in
            let clamped = CGFloat(min(max(percentage, 0), 100)) / 100.0
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(height: height)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.73, green: 0.90, blue: 0.99),
                                Color.white
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(clamped * geo.size.width, percentage > 0 ? height : 0), height: height)
            }
        }
        .frame(height: height)
    }
}

// Dynamic HydroSoft Blue theme gradients based on hydration percentage
private func duolingoGradient(for percentage: Int) -> LinearGradient {
    if percentage >= 100 {
        return LinearGradient(
            colors: [
                Color(red: 0.00, green: 0.34, blue: 0.61), // #01579B
                Color(red: 0.01, green: 0.53, blue: 0.82), // #0288D1
                Color(red: 0.25, green: 0.77, blue: 1.00)  // #40C4FF
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else if percentage >= 75 {
        return LinearGradient(
            colors: [
                Color(red: 0.01, green: 0.47, blue: 0.74), // #0277BD
                Color(red: 0.01, green: 0.61, blue: 0.90), // #039BE5
                Color(red: 0.22, green: 0.74, blue: 0.97)  // #38BDF8
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else if percentage >= 25 {
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

// 1. Duolingo-Style Streak, Mascot, Water Bar & 5-Day Checkmark Widget
struct WaterProgressWidgetEntryView: View {
    var entry: WaterWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
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
            ZStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("🔥 \(entry.streakDays) gün")
                            .font(.system(size: 15, weight: .black, design: .rounded))
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
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.92))
                        .lineLimit(2)

                    HydroWaterProgressBar(percentage: entry.percentage, height: 6)

                    Spacer(minLength: 0)

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(entry.todayConsumed) ml")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                                Text("\(entry.preset1Emoji) +\(entry.preset1)")
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
                                .frame(width: 44, height: 44)
                            Text(entry.mascotEmoji)
                                .font(.system(size: 26))
                        }
                    }
                }
            }
            .widgetURL(URL(string: "hydroreminder://open"))
        default:
            // Duolingo-style Medium Card (4x2) with Streak, Water Progress Bar, 5-Day Checkmarks & Mascot Character
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    // Streak + Progress Pill
                    HStack(spacing: 8) {
                        Text("🔥 \(entry.streakDays) gün")
                            .font(.system(size: 19, weight: .black, design: .rounded))
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
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.95))
                        .lineLimit(1)

                    // Live Water Progress Bar (Su Barı)
                    HydroWaterProgressBar(percentage: entry.percentage, height: 7)

                    // 5-Day Duolingo Checkmark Row (Pe Cu Ct Pa Pt)
                    HStack(spacing: 7) {
                        ForEach(0..<5, id: \.self) { idx in
                            let isDone = entry.dayStatuses[idx] > 0
                            VStack(spacing: 2) {
                                Text(entry.dayLabels[idx])
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.85))
                                ZStack {
                                    Circle()
                                        .fill(isDone ? Color.white.opacity(0.95) : Color.black.opacity(0.22))
                                        .frame(width: 20, height: 20)
                                    Text(isDone ? "✓" : "•")
                                        .font(.system(size: 10, weight: .black))
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
                            Text("\(entry.preset1Emoji) +\(entry.preset1) ml")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.95))
                                .foregroundColor(Color(red: 0.01, green: 0.41, blue: 0.63))
                                .cornerRadius(8)
                        }
                        Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset2)")!) {
                            Text("\(entry.preset2Emoji) +\(entry.preset2) ml")
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

                // Right Side Mascot Character Stage
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.20))
                            .frame(width: 80, height: 80)
                        VStack(spacing: 1) {
                            Text(entry.mascotEmoji)
                                .font(.system(size: 40))
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
        VStack(spacing: 6) {
            HStack {
                Text("🔥 \(entry.streakDays) gün · ⚡ Hızlı Su Ekle")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(entry.mascotEmoji) \(entry.todayConsumed)/\(entry.dailyGoal) ml (%\(entry.percentage))")
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.95))
            }

            HydroWaterProgressBar(percentage: entry.percentage, height: 6)

            HStack(spacing: 8) {
                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                    VStack(spacing: 3) {
                        Text(entry.preset1Emoji).font(.title2)
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
                        Text(entry.preset2Emoji).font(.title2)
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
                        Text(entry.preset3Emoji).font(.title2)
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
                    .font(.system(size: 32))
                Text("\(entry.todayConsumed) ml")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                HydroWaterProgressBar(percentage: entry.percentage, height: 5)
                Link(destination: URL(string: "hydroreminder://log?amount=\(entry.preset1)")!) {
                    Text("\(entry.preset1Emoji) +\(entry.preset1) ml Ekle")
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

extension View {
    @ViewBuilder
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            background(backgroundView)
        }
    }
}

// Widget Configurations
struct WaterProgressWidget: Widget {
    let kind: String = "WaterProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterProgressWidgetEntryView(entry: entry)
                .widgetBackground(duolingoGradient(for: entry.percentage))
        }
        .configurationDisplayName("🔥 HydroSoft Seri & Maskot")
        .description("Duolingo tarzı günlük seri, su barı, 5 günlük su takvimi, canlı maskot ve hızlı su ekleme.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct WaterQuickLogWidget: Widget {
    let kind: String = "WaterQuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterTimelineProvider()) { entry in
            WaterQuickLogWidgetEntryView(entry: entry)
                .widgetBackground(duolingoGradient(for: entry.percentage))
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
                .widgetBackground(duolingoGradient(for: entry.percentage))
        }
        .configurationDisplayName("💧 Mini Maskot & Kilit Ekranı")
        .description("Ana ekran ve kilit ekranı için emojili mini maskot ve su barı.")
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
