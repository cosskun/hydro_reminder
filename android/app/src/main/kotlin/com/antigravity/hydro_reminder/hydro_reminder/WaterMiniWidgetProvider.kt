package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterMiniWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.water_mini_widget)

            val consumed = widgetData.getInt("todayConsumed", 0)
            val percent = widgetData.getInt("percentage", 0)
            val p1 = widgetData.getInt("preset1", 200)
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
            val widgetTheme = widgetData.getString("widgetTheme", "ocean") ?: "ocean"

            val bgRes = when (widgetTheme) {
                "glass" -> R.drawable.widget_card_bg_glass
                "neon" -> R.drawable.widget_card_bg_neon
                "emerald" -> R.drawable.widget_card_bg_forest
                else -> when {
                    percent >= 100 -> R.drawable.widget_card_bg_emerald
                    percent >= 75 -> R.drawable.widget_card_bg_teal
                    percent >= 25 -> R.drawable.widget_card_bg_ocean
                    else -> R.drawable.widget_card_bg
                }
            }
            views.setInt(R.id.widget_mini_root, "setBackgroundResource", bgRes)

            views.setTextViewText(R.id.tv_mini_streak, "🔥 $streak")
            views.setTextViewText(R.id.tv_mini_percent, "%$percent")

            val base64Str = widgetData.getString("mascotBase64", null)
            val mascotType = widgetData.getString("mascotType", "cat") ?: "cat"
            var bitmapLoaded = false

            if (!base64Str.isNullOrBlank()) {
                try {
                    val imageBytes = android.util.Base64.decode(base64Str, android.util.Base64.DEFAULT)
                    val bitmap = android.graphics.BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.iv_mini_mascot, bitmap)
                        views.setViewVisibility(R.id.iv_mini_mascot, android.view.View.VISIBLE)
                        views.setViewVisibility(R.id.tv_mini_mascot, android.view.View.GONE)
                        bitmapLoaded = true
                    }
                } catch (_: Exception) {}
            }

            if (!bitmapLoaded) {
                views.setViewVisibility(R.id.iv_mini_mascot, android.view.View.GONE)
                views.setViewVisibility(R.id.tv_mini_mascot, android.view.View.VISIBLE)
                views.setTextViewText(R.id.tv_mini_mascot, mascotEmoji)
            }

            views.setTextViewText(R.id.tv_mini_subtext, "$consumed ml")
            views.setProgressBar(R.id.pb_mini_progress, 100, percent.coerceIn(0, 100), false)
            views.setTextViewText(R.id.btn_mini_quick_add, "$p1Emoji +$p1 ml")

            // Quick Add Button Click
            val quickAddIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("hydroreminder://log?amount=$p1")
            )
            views.setOnClickPendingIntent(R.id.btn_mini_quick_add, quickAddIntent)

            // Open app on root click
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("hydroreminder://open")
            )
            views.setOnClickPendingIntent(R.id.widget_mini_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
