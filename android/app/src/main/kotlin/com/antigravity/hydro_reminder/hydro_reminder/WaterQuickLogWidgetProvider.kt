package com.antigravity.hydro_reminder.hydro_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterQuickLogWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.water_quick_log_widget)

            val consumed = widgetData.getInt("todayConsumed", 0)
            val p1 = widgetData.getInt("preset1", 200)
            val p2 = widgetData.getInt("preset2", 330)
            val p3 = widgetData.getInt("preset3", 500)

            views.setTextViewText(R.id.tv_quick_status, "Bugün: $consumed ml")
            views.setTextViewText(R.id.tv_quick_preset1, "+$p1 ml")
            views.setTextViewText(R.id.tv_quick_preset2, "+$p2 ml")
            views.setTextViewText(R.id.tv_quick_preset3, "+$p3 ml")

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
        }
    }
}
