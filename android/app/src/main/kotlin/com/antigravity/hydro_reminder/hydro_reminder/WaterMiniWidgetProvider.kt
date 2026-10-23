package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterMiniWidgetProvider : HomeWidgetProvider() {

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
        val views = RemoteViews(context.packageName, R.layout.water_mini_widget)

        val consumed = widgetData.getInt("todayConsumed", 0)
        val goal = widgetData.getInt("dailyGoal", 2500)
        val percent = widgetData.getInt("percentage", 0)
        val streak = widgetData.getInt("streakDays", if (consumed > 0) 1 else 0)

        val defaultEmoji = when {
            percent >= 100 -> "🥳"
            percent >= 70 -> "😎"
            percent >= 35 -> "😊"
            percent > 0 -> "🙂"
            else -> "🥱"
        }
        val defaultSub = when {
            percent >= 100 -> "Hedef Tamam!"
            percent >= 70 -> "Zirve Yakın!"
            percent >= 35 -> "Harika Gidiyorsun!"
            percent > 0 -> "İlk Adım Atıldı!"
            else -> "Su İçmeyi Unutma!"
        }

        val syncedEmoji = widgetData.getString("mascotEmoji", defaultEmoji) ?: defaultEmoji
        val mascotEmoji = if (syncedEmoji.isNotBlank()) syncedEmoji else defaultEmoji
        val syncedTitle = widgetData.getString("mascotTitle", "")?.takeIf { it.isNotBlank() }
        val syncedSub = widgetData.getString("mascotSubtitle", defaultSub)?.takeIf { it.isNotBlank() } ?: defaultSub
        val displayTitle = syncedTitle ?: syncedSub

        val widgetTheme = widgetData.getString("widgetTheme", "ocean") ?: "ocean"
        val mascotType = widgetData.getString("mascotType", "cat") ?: "cat"

        // Mascot-aware & Theme-aware background gradient
        val bgRes = WidgetThemeHelper.resolveBackground(widgetTheme, mascotType, percent)
        views.setInt(R.id.widget_mini_root, "setBackgroundResource", bgRes)

        views.setTextViewText(R.id.tv_mini_streak, "🔥 $streak gün")
        views.setTextViewText(R.id.tv_mini_percent, "💧 %$percent")
        views.setTextViewText(R.id.tv_mini_title, displayTitle)
        views.setTextViewText(R.id.tv_mini_subtext, "$consumed / $goal ml")

        val base64Str = widgetData.getString("mascotBase64", null)
        var bitmapLoaded = false

        if (!base64Str.isNullOrBlank()) {
            try {
                val imageBytes = android.util.Base64.decode(base64Str, android.util.Base64.DEFAULT)
                val original = android.graphics.BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                if (original != null) {
                    val roundedHeroBitmap = WidgetThemeHelper.createRoundedCardBitmap(
                        original,
                        cornerRadiusRatio = 0.16f,
                        strokeWidthRatio = 0.014f,
                        strokeColor = Color.argb(68, 255, 255, 255)
                    )
                    views.setImageViewBitmap(R.id.iv_mini_hero_image, roundedHeroBitmap)
                    views.setViewVisibility(R.id.iv_mini_hero_image, View.VISIBLE)
                    views.setViewVisibility(R.id.ll_mini_fallback, View.GONE)
                    bitmapLoaded = true
                }
            } catch (_: Exception) {}
        }

        if (!bitmapLoaded) {
            views.setViewVisibility(R.id.iv_mini_hero_image, View.GONE)
            views.setViewVisibility(R.id.ll_mini_fallback, View.VISIBLE)
            views.setTextViewText(R.id.tv_mini_mascot, mascotEmoji)
        }

        // Open app on click
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("hydroreminder://open")
        )
        views.setOnClickPendingIntent(R.id.widget_mini_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
