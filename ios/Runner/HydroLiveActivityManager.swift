import Foundation
import UIKit
#if canImport(ActivityKit)
import ActivityKit
#endif

@available(iOS 16.1, *)
class HydroLiveActivityManager {
    static let shared = HydroLiveActivityManager()

    private init() {}

    // Check if Live Activities are enabled by the user in system settings
    func areActivitiesEnabled() -> Bool {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        #endif
        return false
    }

    // Start or update the Live Activity
    func startOrUpdateLiveActivity(
        todayConsumed: Int,
        dailyGoal: Int,
        dailyRemaining: Int,
        percentage: Int,
        streakDays: Int,
        mascotType: String,
        mascotEmoji: String,
        mascotTitle: String,
        mascotSubtitle: String,
        widgetTheme: String
    ) {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                print("[ActivityKit] Live activities are disabled by user in iOS settings.")
                return
            }

            let state = HydroLiveActivityAttributes.ContentState(
                todayConsumed: todayConsumed,
                dailyGoal: dailyGoal,
                dailyRemaining: dailyRemaining,
                percentage: percentage,
                streakDays: streakDays,
                mascotType: mascotType,
                mascotEmoji: mascotEmoji,
                mascotTitle: mascotTitle,
                mascotSubtitle: mascotSubtitle,
                widgetTheme: widgetTheme
            )

            let runningActivities = Activity<HydroLiveActivityAttributes>.activities

            if let active = runningActivities.first {
                Task {
                    if #available(iOS 16.2, *) {
                        let content = ActivityContent(state: state, staleDate: nil)
                        await active.update(content)
                    } else {
                        await active.update(using: state)
                    }
                    print("[ActivityKit] Updated active Live Activity: \(active.id)")
                }

                // Cleanup any excess instances if more than one exists
                if runningActivities.count > 1 {
                    Task {
                        for extra in runningActivities.dropFirst() {
                            if #available(iOS 16.2, *) {
                                await extra.end(nil, dismissalPolicy: .immediate)
                            } else {
                                await extra.end(dismissalPolicy: .immediate)
                            }
                        }
                    }
                }
            } else {
                // Request a new activity - triggers native iOS permission prompt if first time
                do {
                    let attributes = HydroLiveActivityAttributes(activityTitle: "HydroSoft Canlı Su Takibi")
                    let newActivity: Activity<HydroLiveActivityAttributes>
                    if #available(iOS 16.2, *) {
                        let content = ActivityContent(state: state, staleDate: nil)
                        newActivity = try Activity.request(attributes: attributes, content: content, pushType: nil)
                    } else {
                        newActivity = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
                    }
                    print("[ActivityKit] Successfully started Live Activity: \(newActivity.id)")
                } catch {
                    print("[ActivityKit] Error requesting Live Activity: \(error.localizedDescription)")
                }
            }
        }
        #endif
    }

    // End all active Live Activities
    func endLiveActivity() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            Task {
                for active in Activity<HydroLiveActivityAttributes>.activities {
                    if #available(iOS 16.2, *) {
                        await active.end(nil, dismissalPolicy: .immediate)
                    } else {
                        await active.end(dismissalPolicy: .immediate)
                    }
                    print("[ActivityKit] Ended Live Activity: \(active.id)")
                }
            }
        }
        #endif
    }
}
