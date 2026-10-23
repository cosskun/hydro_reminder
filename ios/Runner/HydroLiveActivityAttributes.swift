import Foundation
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
public struct HydroLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var todayConsumed: Int
        public var dailyGoal: Int
        public var dailyRemaining: Int
        public var percentage: Int
        public var streakDays: Int
        public var mascotType: String
        public var mascotEmoji: String
        public var mascotTitle: String
        public var mascotSubtitle: String
        public var widgetTheme: String

        public init(
            todayConsumed: Int = 0,
            dailyGoal: Int = 2000,
            dailyRemaining: Int = 2000,
            percentage: Int = 0,
            streakDays: Int = 0,
            mascotType: String = "cat",
            mascotEmoji: String = "🐱",
            mascotTitle: String = "HydroSoft",
            mascotSubtitle: String = "Güne taze bir bardak su ile başla!",
            widgetTheme: String = "ocean"
        ) {
            self.todayConsumed = todayConsumed
            self.dailyGoal = dailyGoal
            self.dailyRemaining = dailyRemaining
            self.percentage = percentage
            self.streakDays = streakDays
            self.mascotType = mascotType
            self.mascotEmoji = mascotEmoji
            self.mascotTitle = mascotTitle
            self.mascotSubtitle = mascotSubtitle
            self.widgetTheme = widgetTheme
        }
    }

    public var activityTitle: String

    public init(activityTitle: String = "HydroSoft Canlı Su Takibi") {
        self.activityTitle = activityTitle
    }
}
#endif
