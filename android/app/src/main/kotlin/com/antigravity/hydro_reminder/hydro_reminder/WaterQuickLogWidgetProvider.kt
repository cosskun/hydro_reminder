package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterQuickLogWidgetProvider : HomeWidgetProvider() {

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        updateSingleWidget(context, appWidgetManager, appWidgetId, widgetData)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
    }

    private fun updateSingleWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        widgetData: SharedPreferences
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.water_quick_log_widget)

        val consumed = widgetData.getInt("todayConsumed", 0)
        val goal = widgetData.getInt("dailyGoal", 2500)
        val percent = widgetData.getInt("percentage", 0)
        val p1 = widgetData.getInt("preset1", 200)
        val p2 = widgetData.getInt("preset2", 330)
        val p3 = widgetData.getInt("preset3", 500)
        val streak = widgetData.getInt("streakDays", if (consumed > 0) 1 else 0)

        val defaultEmoji = when {
            percent >= 100 -> "🥳"
            percent >= 70 -> "😎"
            percent >= 35 -> "😊"
            percent > 0 -> "🙂"
            else -> "🥱"
        }
        val syncedEmoji = widgetData.getString("mascotEmoji", defaultEmoji) ?: defaultEmoji
        val mascotEmoji = if (syncedEmoji.isNotBlank()) syncedEmoji else defaultEmoji
        val p1Emoji = widgetData.getString("preset1Emoji", "🥛") ?: "🥛"
        val p2Emoji = widgetData.getString("preset2Emoji", "🥤") ?: "🥤"
        val p3Emoji = widgetData.getString("preset3Emoji", "🫙") ?: "🫙"
        val widgetTheme = widgetData.getString("widgetTheme", "ocean") ?: "ocean"
        val mascotType = widgetData.getString("mascotType", "cat") ?: "cat"

        // Mascot-aware & Theme-aware background gradient
        val bgRes = WidgetThemeHelper.resolveBackground(widgetTheme, mascotType, percent)
        views.setInt(R.id.widget_quick_root, "setBackgroundResource", bgRes)

        val primaryTextColor = WidgetThemeHelper.resolvePrimaryTextColor(widgetTheme, mascotType)

        views.setTextViewText(R.id.tv_quick_title, "🔥 $streak gün · ⚡ Hızlı Ekle")
        views.setTextViewText(R.id.tv_quick_status, "$mascotEmoji $consumed/$goal ml (%$percent)")
        views.setTextViewText(R.id.tv_quick_emoji1, p1Emoji)
        views.setTextViewText(R.id.tv_quick_emoji2, p2Emoji)
        views.setTextViewText(R.id.tv_quick_emoji3, p3Emoji)
        views.setTextViewText(R.id.tv_quick_preset1, "+$p1 ml")
        views.setTextViewText(R.id.tv_quick_preset2, "+$p2 ml")
        views.setTextViewText(R.id.tv_quick_preset3, "+$p3 ml")

        views.setTextColor(R.id.tv_quick_preset1, primaryTextColor)
        views.setTextColor(R.id.tv_quick_preset2, primaryTextColor)
        views.setTextColor(R.id.tv_quick_preset3, primaryTextColor)

        // Button 1 Click: Log preset1
        val intent1 = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("hydroreminder://log?amount=$p1")
        )
        views.setOnClickPendingIntent(R.id.btn_quick_preset1, intent1)

        // Button 2 Click: Log preset2
        val intent2 = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("hydroreminder://log?amount=$p2")
        )
        views.setOnClickPendingIntent(R.id.btn_quick_preset2, intent2)

        // Button 3 Click: Log preset3
        val intent3 = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("hydroreminder://log?amount=$p3")
        )
        views.setOnClickPendingIntent(R.id.btn_quick_preset3, intent3)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("WaterQuickLogWidget", "Error updating quick log widget", e)
        }
    }
}
