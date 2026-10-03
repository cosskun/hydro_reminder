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

            val remaining = widgetData.getInt("dailyRemaining", 2500)
            val percent = widgetData.getInt("percentage", 0)

            views.setTextViewText(R.id.tv_mini_percent, "%$percent")

            val remainingStr = if (remaining >= 1000) {
                String.format("%.1f L Kalan", remaining / 1000.0)
            } else {
                "$remaining ml Kalan"
            }
            views.setTextViewText(R.id.tv_mini_subtext, remainingStr)

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
}
