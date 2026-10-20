import Foundation
import AppIntents
import WidgetKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct WaterPresetEntity: AppEntity {
    public static var defaultQuery = WaterPresetQuery()
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Hızlı Su Seçenekleri"

    public var id: String
    public var name: String
    public var amount: Int
    public var emoji: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(emoji) \(name) (+\(amount) ml)",
            subtitle: "\(amount) ml su kaydeder"
        )
    }

    public init(id: String, name: String, amount: Int, emoji: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.emoji = emoji
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct WaterPresetQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [String]) async throws -> [WaterPresetEntity] {
        return allPresets().filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [WaterPresetEntity] {
        return allPresets()
    }

    private func allPresets() -> [WaterPresetEntity] {
        let kcDict = loadKeychainPayload()
        let prefs = UserDefaults(suiteName: appGroupId)
        let p1 = max(intValue(from: kcDict, prefs: prefs, key: "preset1", defaultVal: 200), 50)
        let p2 = max(intValue(from: kcDict, prefs: prefs, key: "preset2", defaultVal: 330), 100)
        let p3 = max(intValue(from: kcDict, prefs: prefs, key: "preset3", defaultVal: 500), 150)
        let p1Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset1Emoji", defaultVal: "🥛")
        let p2Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset2Emoji", defaultVal: "🥤")
        let p3Emoji = stringValue(from: kcDict, prefs: prefs, key: "preset3Emoji", defaultVal: "🫙")

        return [
            WaterPresetEntity(id: "preset1", name: "Bardak", amount: p1, emoji: p1Emoji),
            WaterPresetEntity(id: "preset2", name: "Küçük Şişe", amount: p2, emoji: p2Emoji),
            WaterPresetEntity(id: "preset3", name: "Şişe", amount: p3, emoji: p3Emoji),
        ]
    }
}

// 1. Top Dropdown Quick Choice Menu (Triggered via Back Tap / Action Button)
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct QuickLogMenuIntent: AppIntent {
    static var title: LocalizedStringResource = "Hızlı Su Seçim Menüsü"
    static var description = IntentDescription("Arkaya dokunulduğunda yukarıdan açılan şeffaf menüden su miktarını seçmenizi sağlar.")

    @Parameter(title: "Seçilen İçecek")
    var preset: WaterPresetEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("HydroSoft \(\.$preset) ekle")
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let prefs = UserDefaults(suiteName: appGroupId)
        let isBackTapEnabled = prefs?.bool(forKey: "ios_back_tap_enabled") ?? true

        if !isBackTapEnabled {
            return .result(value: "Özellik Kapalı", dialog: "HydroSoft ayarlarında Arkaya Dokunma özelliği kapalı.")
        }

        let selectedPreset: WaterPresetEntity
        if let preset = preset {
            selectedPreset = preset
        } else {
            // Prompt the user with the top drop-down choices banner!
            let choices = try await WaterPresetQuery().suggestedEntities()
            selectedPreset = try await $preset.requestDisambiguation(
                among: choices,
                dialog: "Ne kadar su içtiniz? 💧"
            )
        }

        let amount = selectedPreset.amount
        var kcDict = loadKeychainPayload() ?? [:]
        let consumed = intValue(from: kcDict, prefs: prefs, key: "todayConsumed", defaultVal: 0) + amount
        let goal = max(intValue(from: kcDict, prefs: prefs, key: "dailyGoal", defaultVal: 2500), 1000)
        let remaining = max(goal - consumed, 0)
        let percent = min(Int((Double(consumed) / Double(goal)) * 100.0), 100)

        let statusEmoji: String
        let statusSub: String
        if percent >= 100 {
            statusEmoji = "🥳"
            statusSub = "Tebrikler! Günlük su hedefini tamamladın!"
        } else if percent >= 75 {
            statusEmoji = "😎"
            statusSub = "Neredeyse tamamladın! Enerjin tam yerinde."
        } else if percent >= 50 {
            statusEmoji = "😊"
            statusSub = "Harika gidiyorsun! Vücudun sana teşekkür ediyor."
        } else if percent >= 25 {
            statusEmoji = "🙂"
            statusSub = "İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun."
        } else {
            statusEmoji = "🥱"
            statusSub = "Güne susuz başladın! Hemen bir bardak su al."
        }

        kcDict["todayConsumed"] = consumed
        kcDict["dailyRemaining"] = remaining
        kcDict["percentage"] = percent
        kcDict["mascotEmoji"] = statusEmoji
        kcDict["mascotSubtitle"] = statusSub
        saveKeychainPayload(kcDict)

        prefs?.set(consumed, forKey: "todayConsumed")
        prefs?.set(remaining, forKey: "dailyRemaining")
        prefs?.set(percent, forKey: "percentage")
        prefs?.set(statusEmoji, forKey: "mascotEmoji")
        prefs?.set(statusSub, forKey: "mascotSubtitle")

        // Trigger widget reload
        WidgetCenter.shared.reloadAllTimelines()

        let message = "\(selectedPreset.emoji) +\(amount) ml \(selectedPreset.name) kaydedildi! (Bugün: \(consumed)/\(goal) ml) 💧"
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

// 2. Direct Amount Voice Logging Intent (Triggered via Siri)
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct LogWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Su Ekle"
    static var description = IntentDescription("HydroSoft gününüze belirtilen miktarda su ekler.")

    @Parameter(title: "Miktar (ml)", default: 250)
    var amount: Int

    static var parameterSummary: some ParameterSummary {
        Summary("HydroSoft ile \(\.$amount) ml su ekle")
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let prefs = UserDefaults(suiteName: appGroupId)
        let isSiriEnabled = prefs?.bool(forKey: "ios_siri_shortcuts_enabled") ?? true

        if !isSiriEnabled {
            return .result(value: "Özellik Kapalı", dialog: "HydroSoft ayarlarında Siri ile Sesli Komut özelliği kapalı.")
        }

        var kcDict = loadKeychainPayload() ?? [:]
        let consumed = intValue(from: kcDict, prefs: prefs, key: "todayConsumed", defaultVal: 0) + amount
        let goal = max(intValue(from: kcDict, prefs: prefs, key: "dailyGoal", defaultVal: 2500), 1000)
        let remaining = max(goal - consumed, 0)
        let percent = min(Int((Double(consumed) / Double(goal)) * 100.0), 100)

        let statusEmoji: String
        let statusSub: String
        if percent >= 100 {
            statusEmoji = "🥳"
            statusSub = "Tebrikler! Günlük su hedefini tamamladın!"
        } else if percent >= 75 {
            statusEmoji = "😎"
            statusSub = "Neredeyse tamamladın! Enerjin tam yerinde."
        } else if percent >= 50 {
            statusEmoji = "😊"
            statusSub = "Harika gidiyorsun! Vücudun sana teşekkür ediyor."
        } else if percent >= 25 {
            statusEmoji = "🙂"
            statusSub = "İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun."
        } else {
            statusEmoji = "🥱"
            statusSub = "Güne susuz başladın! Hemen bir bardak su al."
        }

        kcDict["todayConsumed"] = consumed
        kcDict["dailyRemaining"] = remaining
        kcDict["percentage"] = percent
        kcDict["mascotEmoji"] = statusEmoji
        kcDict["mascotSubtitle"] = statusSub
        saveKeychainPayload(kcDict)

        prefs?.set(consumed, forKey: "todayConsumed")
        prefs?.set(remaining, forKey: "dailyRemaining")
        prefs?.set(percent, forKey: "percentage")
        prefs?.set(statusEmoji, forKey: "mascotEmoji")
        prefs?.set(statusSub, forKey: "mascotSubtitle")

        // Trigger widget reload
        WidgetCenter.shared.reloadAllTimelines()

        let message: String
        if percent >= 100 {
            message = "\(amount) ml su kaydedildi! 🏆 Tebrikler, bugünkü hedefine ulaştın!"
        } else {
            message = "\(amount) ml su kaydedildi! Bugün toplam \(consumed) ml içtin. Hedefe \(remaining) ml kaldı 💧"
        }

        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

// 3. Status Query Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct GetWaterStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Su Durumunu Sor"
    static var description = IntentDescription("Bugün toplam ne kadar su içtiğinizi ve hedefinizi seslendirir.")

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let kcDict = loadKeychainPayload()
        let prefs = UserDefaults(suiteName: appGroupId)
        let consumed = intValue(from: kcDict, prefs: prefs, key: "todayConsumed", defaultVal: 0)
        let goal = max(intValue(from: kcDict, prefs: prefs, key: "dailyGoal", defaultVal: 2500), 1000)
        let remaining = max(goal - consumed, 0)
        let percent = min(Int((Double(consumed) / Double(goal)) * 100.0), 100)

        let responseText = "Bugün toplam \(consumed) ml su içtin (%\(percent)). Günlük hedefine ulaşmana \(remaining) ml kaldı 💧"
        return .result(value: responseText, dialog: IntentDialog(stringLiteral: responseText))
    }
}

// 4. System App Shortcuts Provider
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct HydroAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickLogMenuIntent(),
            phrases: [
                "\(.applicationName) hızlı su menüsü",
                "\(.applicationName) su menüsü",
                "\(.applicationName) su seç"
            ],
            shortTitle: "Hızlı Su Seçimi",
            systemImageName: "drop.triangle.fill"
        )
        AppShortcut(
            intent: LogWaterIntent(),
            phrases: [
                "\(.applicationName) ile su ekle",
                "\(.applicationName) ile bir bardak su kaydet",
                "\(.applicationName) ile su içtim",
                "\(.applicationName) su içtim"
            ],
            shortTitle: "Sesle Su Ekle",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: GetWaterStatusIntent(),
            phrases: [
                "\(.applicationName) bugün ne kadar su içtim",
                "\(.applicationName) su durumum nedir",
                "\(.applicationName) su hedefim"
            ],
            shortTitle: "Su Durumu",
            systemImageName: "chart.bar.fill"
        )
    }
}
