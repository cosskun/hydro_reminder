package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterProgressWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.water_progress_widget)

            val consumed = widgetData.getInt("todayConsumed", 0)
            val goal = widgetData.getInt("dailyGoal", 2500)
            val percent = widgetData.getInt("percentage", 0)
            val p1 = widgetData.getInt("preset1", 200)
            val p2 = widgetData.getInt("preset2", 330)
            val streak = widgetData.getInt("streakDays", if (consumed > 0) 1 else 0)

            val defaultEmoji = when {
                percent >= 100 -> "👑"
                percent >= 70 -> "🐬"
                percent >= 30 -> "🐳"
                else -> "🥵"
            }
            val defaultSub = when {
                percent >= 100 -> "Efsanesin! Günlük hedef tamam! 🏆"
                percent >= 70 -> "Hedefe çok az kaldı, devam et! 🚀"
                percent >= 30 -> "Harika gidiyorsun! Su içmeyi unutma! 🌊"
                else -> "Damla seni çağırıyor! Su içelim! 💦"
            }

            val mascotEmoji = widgetData.getString("mascotEmoji", defaultEmoji) ?: defaultEmoji
            val mascotSub = widgetData.getString("mascotSubtitle", defaultSub) ?: defaultSub

            // Dynamic Duolingo-style background gradient based on hydration %
            val bgRes = when {
                percent >= 100 -> R.drawable.widget_card_bg_emerald
                percent >= 70 -> R.drawable.widget_card_bg_teal
                percent >= 30 -> R.drawable.widget_card_bg_ocean
                else -> R.drawable.widget_card_bg
            }
            views.setInt(R.id.widget_progress_root, "setBackgroundResource", bgRes)

            views.setTextViewText(R.id.tv_streak_title, "🔥 $streak gün")
            views.setTextViewText(R.id.tv_progress_percent, "💧 %$percent")
            views.setTextViewText(R.id.tv_progress_message, mascotSub)
            views.setTextViewText(R.id.tv_mascot_emoji, mascotEmoji)
            views.setTextViewText(R.id.tv_progress_consumed, "$consumed ml")
            views.setTextViewText(R.id.tv_progress_goal, "Hedef: $goal ml")

            views.setTextViewText(R.id.btn_progress_preset1, "🥛 +$p1 ml")
            views.setTextViewText(R.id.btn_progress_preset2, "🥤 +$p2 ml")

            // 5-Day Duolingo Checkmark Tracker
            val rawLabels = widgetData.getString("dayLabels", "Pe,Cu,Ct,Pa,Pt") ?: "Pe,Cu,Ct,Pa,Pt"
            val labels = rawLabels.split(",").let { if (it.size == 5) it else listOf("Pe", "Cu", "Ct", "Pa", "Pt") }

            val rawStatuses = widgetData.getString("dayStatuses", "0,0,1,1,0") ?: "0,0,1,1,0"
            val statuses = rawStatuses.split(",").map { it.toIntOrNull() ?: 0 }.let {
                if (it.size == 5) it else listOf(0, 0, 1, 1, if (consumed > 0) 1 else 0)
            }

            val labelIds = intArrayOf(
                R.id.tv_day_label_1,
                R.id.tv_day_label_2,
                R.id.tv_day_label_3,
                R.id.tv_day_label_4,
                R.id.tv_day_label_5
            )
            val checkIds = intArrayOf(
                R.id.tv_day_check_1,
                R.id.tv_day_check_2,
                R.id.tv_day_check_3,
                R.id.tv_day_check_4,
                R.id.tv_day_check_5
            )

            for (i in 0..4) {
                views.setTextViewText(labelIds[i], labels[i])
                val isDone = statuses[i] > 0
                views.setTextViewText(checkIds[i], if (isDone) "✓" else "•")
                views.setInt(
                    checkIds[i],
                    "setBackgroundResource",
                    if (isDone) R.drawable.widget_day_circle_done else R.drawable.widget_day_circle_empty
                )
                views.setTextColor(
                    checkIds[i],
                    if (isDone) Color.parseColor("#5B21B6") else Color.parseColor("#94A3B8")
                )
            }

            // Quick Log Intents
            val intent1 = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("hydroreminder://log?amount=$p1")
            )
            views.setOnClickPendingIntent(R.id.btn_progress_preset1, intent1)

            val intent2 = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("hydroreminder://log?amount=$p2")
            )
            views.setOnClickPendingIntent(R.id.btn_progress_preset2, intent2)

            // Open app on card click
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("hydroreminder://open")
            )
            views.setOnClickPendingIntent(R.id.widget_progress_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
