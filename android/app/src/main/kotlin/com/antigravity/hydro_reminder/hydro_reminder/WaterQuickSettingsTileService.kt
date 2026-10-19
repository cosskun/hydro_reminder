package com.antigravity.hydro_reminder.hydro_reminder

import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class WaterQuickSettingsTileService : TileService() {

    private fun getSafeInt(prefs: android.content.SharedPreferences, key: String, defaultVal: Int): Int {
        return try {
            prefs.getInt(key, defaultVal)
        } catch (_: ClassCastException) {
            try {
                prefs.getLong(key, defaultVal.toLong()).toInt()
            } catch (_: Exception) {
                defaultVal
            }
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()

        val homePrefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)

        val p1FromWidget = getSafeInt(homePrefs, "preset1", 0)
        val p1FromFlutter = getSafeInt(flutterPrefs, "flutter.preset_1", 200)
        val defaultAmount = when {
            p1FromWidget > 0 -> p1FromWidget
            p1FromFlutter > 0 -> p1FromFlutter
            else -> 200
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("hydroreminder://log?amount=$defaultAmount")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // Android 14+ (API 34)
            val pendingIntent = PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            startActivityAndCollapse(pendingIntent)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }

        updateTileState()
    }

    private fun updateTileState() {
        val tile = qsTile ?: return
        val homePrefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
        val p1 = getSafeInt(homePrefs, "preset1", 200).let { if (it > 0) it else 200 }
        val p1Emoji = homePrefs.getString("preset1Emoji", "🥛") ?: "🥛"
        val consumed = getSafeInt(homePrefs, "todayConsumed", 0)
        val goal = getSafeInt(homePrefs, "dailyGoal", 2500).let { if (it > 0) it else 2500 }
        val percent = getSafeInt(homePrefs, "percentage", 0)

        tile.state = Tile.STATE_ACTIVE
        tile.label = "$p1Emoji +$p1 ml Ekle"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = "%$percent · $consumed/$goal ml"
        }
        tile.updateTile()
    }
}
