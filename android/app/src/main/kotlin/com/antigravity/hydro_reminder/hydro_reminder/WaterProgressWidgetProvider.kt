package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterProgressWidgetProvider : HomeWidgetProvider() {

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
            val views = RemoteViews(context.packageName, R.layout.water_progress_widget)

        val consumed = widgetData.getInt("todayConsumed", 0)
        val goal = widgetData.getInt("dailyGoal", 2500)
        val percent = widgetData.getInt("percentage", 0)
        val p1 = widgetData.getInt("preset1", 200)
        val p2 = widgetData.getInt("preset2", 330)
        val streak = widgetData.getInt("streakDays", if (consumed > 0) 1 else 0)

        val defaultEmoji = when {
            percent >= 100 -> "🥳"
            percent >= 70 -> "😎"
            percent >= 35 -> "😊"
            percent > 0 -> "🙂"
            else -> "🥱"
        }
        val defaultSub = when {
            percent >= 100 -> "Tebrikler! Günlük su hedefini tamamladın!"
            percent >= 70 -> "Neredeyse tamamladın! Enerjin tam yerinde."
            percent >= 35 -> "Harika gidiyorsun! Vücudun sana teşekkür ediyor."
            percent > 0 -> "İlk adımı attın! Yavaş yavaş hedefe ilerliyorsun."
            else -> "Güne susuz başladın! Hemen bir bardak su al."
        }

        val syncedEmoji = widgetData.getString("mascotEmoji", defaultEmoji) ?: defaultEmoji
        val mascotEmoji = if (syncedEmoji.isNotBlank()) syncedEmoji else defaultEmoji
        val mascotSub = widgetData.getString("mascotSubtitle", defaultSub)?.takeIf { it.isNotBlank() } ?: defaultSub
        val p1Emoji = widgetData.getString("preset1Emoji", "🥛") ?: "🥛"
        val p2Emoji = widgetData.getString("preset2Emoji", "🥤") ?: "🥤"
        val widgetTheme = widgetData.getString("widgetTheme", "ocean") ?: "ocean"
        val mascotType = widgetData.getString("mascotType", "cat") ?: "cat"

        // Mascot-aware & Theme-aware background gradient
        val bgRes = WidgetThemeHelper.resolveBackground(widgetTheme, mascotType, percent)
        views.setInt(R.id.widget_progress_root, "setBackgroundResource", bgRes)

        val primaryTextColor = WidgetThemeHelper.resolvePrimaryTextColor(widgetTheme, mascotType)

        views.setTextViewText(R.id.tv_streak_title, "🔥 $streak gün")
        views.setTextViewText(R.id.tv_progress_percent, "💧 %$percent")
        views.setTextViewText(R.id.tv_progress_message, mascotSub)
        views.setProgressBar(R.id.pb_water_progress, 100, percent.coerceIn(0, 100), false)

        val base64Str = widgetData.getString("mascotBase64", null)
        var bitmapLoaded = false

        if (!base64Str.isNullOrBlank()) {
            try {
                val imageBytes = android.util.Base64.decode(base64Str, android.util.Base64.DEFAULT)
                val original = android.graphics.BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                if (original != null) {
                    val roundedBitmap = WidgetThemeHelper.createRoundedCardBitmap(
                        original,
                        cornerRadiusRatio = 0.12f,
                        strokeWidthRatio = 0.012f,
                        strokeColor = Color.argb(68, 255, 255, 255)
                    )
                    views.setImageViewBitmap(R.id.iv_mascot_image, roundedBitmap)
                    views.setViewVisibility(R.id.iv_mascot_image, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.tv_mascot_emoji, android.view.View.GONE)
                    bitmapLoaded = true
                }
            } catch (_: Exception) {}
        }

        if (!bitmapLoaded) {
            views.setViewVisibility(R.id.iv_mascot_image, android.view.View.GONE)
            views.setViewVisibility(R.id.tv_mascot_emoji, android.view.View.VISIBLE)
            views.setTextViewText(R.id.tv_mascot_emoji, mascotEmoji)
        }

        views.setTextViewText(R.id.tv_progress_consumed, "$consumed / $goal ml")

        views.setTextViewText(R.id.btn_progress_preset1, "$p1Emoji +$p1 ml")
        views.setTextColor(R.id.btn_progress_preset1, primaryTextColor)

        views.setTextViewText(R.id.btn_progress_preset2, "$p2Emoji +$p2 ml")

        // 5-Day Streak Checkmark Tracker
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
                if (isDone) primaryTextColor else Color.parseColor("#94A3B8")
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
        } catch (e: Exception) {
            android.util.Log.e("WaterProgressWidget", "Error updating progress widget", e)
        }
    }
}
