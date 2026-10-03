package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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
            val remaining = widgetData.getInt("dailyRemaining", 2500)
            val percent = widgetData.getInt("percentage", 0)

            views.setTextViewText(R.id.tv_progress_percent, "%$percent")
            views.setTextViewText(R.id.tv_progress_consumed, "$consumed ml")
            views.setTextViewText(R.id.tv_progress_goal, "/ $goal ml")
            views.setTextViewText(R.id.tv_progress_remaining, "Kalan: $remaining ml")
            views.setProgressBar(R.id.pb_water_progress, 100, percent.coerceIn(0, 100), false)

            val message = when {
                percent >= 100 -> "Harikasın! Günlük su hedefine ulaştın 🎉💧"
                percent >= 75 -> "Harika gidiyorsun, hedefe çok az kaldı! 🌊"
                percent >= 50 -> "Günün yarısı tamamlandı, devam et! 🥤"
                percent >= 25 -> "İyi bir başlangıç, su içmeyi unutma! 🥛"
                else -> "Bugün vücudunu susuz bırakma! 💧"
            }
            views.setTextViewText(R.id.tv_progress_message, message)

            // Open app on click
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
