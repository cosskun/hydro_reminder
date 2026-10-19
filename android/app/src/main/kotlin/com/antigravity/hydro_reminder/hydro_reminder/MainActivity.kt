package com.antigravity.hydro_reminder.hydro_reminder

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val hapticsChannelName = "com.antigravity.hydroReminder/alarm_haptics"
    private var methodChannel: MethodChannel? = null
    private var pendingShortcutUri: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        extractShortcutUri(intent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val uriStr = extractShortcutUri(intent)
        if (uriStr != null && methodChannel != null) {
            pendingShortcutUri = null
            methodChannel?.invokeMethod("onShortcutUri", uriStr)
        }
    }

    private fun extractShortcutUri(intent: android.content.Intent?): String? {
        val data = intent?.data ?: return null
        if (data.scheme == "hydroreminder") {
            val uriStr = data.toString()
            pendingShortcutUri = uriStr
            return uriStr
        }
        return null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, hapticsChannelName)
        methodChannel = channel
        channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "vibrateAlarm" -> {
                        triggerHardwareAlarmVibration()
                        result.success(true)
                    }
                    "isSilentMode" -> {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                        val isSilent = audioManager != null &&
                            audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL
                        result.success(isSilent)
                    }
                    "openNotificationSettings" -> {
                        openAppNotificationSettings()
                        result.success(true)
                    }
                    "openHealthConnectSettings" -> {
                        val opened = openHealthConnectSettingsPage()
                        result.success(opened)
                    }
                    "pinHomeWidget" -> {
                        val providerName = call.argument<String>("provider") ?: "WaterProgressWidgetProvider"
                        val pinned = requestPinWidget(providerName)
                        result.success(pinned)
                    }
                    "pinAppShortcut" -> {
                        val shortcutId = call.argument<String>("shortcutId") ?: "shortcut_cup_200"
                        val pinned = requestPinAppShortcut(shortcutId)
                        result.success(pinned)
                    }
                    "consumeInitialShortcutUri" -> {
                        val uri = pendingShortcutUri
                        pendingShortcutUri = null
                        result.success(uri)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestPinAppShortcut(shortcutId: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        try {
            val shortcutManager = getSystemService(android.content.pm.ShortcutManager::class.java) ?: return false
            if (!shortcutManager.isRequestPinShortcutSupported) return false

            val existing = (shortcutManager.manifestShortcuts + shortcutManager.dynamicShortcuts)
                .firstOrNull { it.id == shortcutId }

            val shortcutInfo = existing ?: run {
                val (shortLabel, iconRes, dataUri) = when (shortcutId) {
                    "shortcut_bottle_330" -> Triple("+330 ml Şişe", R.drawable.ic_shortcut_bottle, "hydroreminder://log?amount=330")
                    "shortcut_bottle_500" -> Triple("+500 ml Büyük", R.drawable.ic_shortcut_wave, "hydroreminder://log?amount=500")
                    "shortcut_history_stats" -> Triple("İstatistikler", R.drawable.ic_shortcut_stats, "hydroreminder://stats")
                    else -> Triple("+200 ml Bardak", R.drawable.ic_shortcut_cup, "hydroreminder://log?amount=200")
                }
                val shortcutIntent = android.content.Intent(
                    "es.antonborri.home_widget.action.LAUNCH",
                    android.net.Uri.parse(dataUri),
                    this,
                    MainActivity::class.java
                )
                android.content.pm.ShortcutInfo.Builder(this, shortcutId)
                    .setShortLabel(shortLabel)
                    .setIcon(android.graphics.drawable.Icon.createWithResource(this, iconRes))
                    .setIntent(shortcutIntent)
                    .build()
            }

            return shortcutManager.requestPinShortcut(shortcutInfo, null)
        } catch (_: Exception) {
            return false
        }
    }

    private fun requestPinWidget(providerName: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        try {
            val appWidgetManager = android.appwidget.AppWidgetManager.getInstance(this)
            if (!appWidgetManager.isRequestPinAppWidgetSupported) return false

            val targetClass = when (providerName) {
                "WaterQuickLogWidgetProvider" -> WaterQuickLogWidgetProvider::class.java
                "WaterMiniWidgetProvider" -> WaterMiniWidgetProvider::class.java
                else -> WaterProgressWidgetProvider::class.java
            }
            val providerComponent = android.content.ComponentName(this, targetClass)
            return appWidgetManager.requestPinAppWidget(providerComponent, null, null)
        } catch (_: Exception) {
            return false
        }
    }

    private fun openAppNotificationSettings() {
        try {
            val intent = android.content.Intent().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    action = android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS
                    putExtra(android.provider.Settings.EXTRA_APP_PACKAGE, packageName)
                } else {
                    action = android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    data = android.net.Uri.fromParts("package", packageName, null)
                }
                addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {
        }
    }

    private fun openHealthConnectSettingsPage(): Boolean {
        val actions = listOf(
            "android.health.connect.action.MANAGE_HEALTH_PERMISSIONS",
            "androidx.health.ACTION_HEALTH_CONNECT_SETTINGS",
            "android.health.connect.action.HEALTH_HOME_SETTINGS"
        )
        for (actionName in actions) {
            try {
                val intent = android.content.Intent(actionName).apply {
                    putExtra(android.content.Intent.EXTRA_PACKAGE_NAME, packageName)
                    addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                return true
            } catch (_: Exception) {
            }
        }
        return false
    }

    private fun triggerHardwareAlarmVibration() {
        try {
            val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vibratorManager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }

            if (vibrator == null || !vibrator.hasVibrator()) return

            val timings = longArrayOf(0, 350, 120, 350)
            val amplitudes = intArrayOf(0, 255, 0, 255)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val effect = if (vibrator.hasAmplitudeControl()) {
                    VibrationEffect.createWaveform(timings, amplitudes, -1)
                } else {
                    VibrationEffect.createWaveform(timings, -1)
                }
                val audioAttrs = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
                @Suppress("DEPRECATION")
                vibrator.vibrate(effect, audioAttrs)
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(timings, -1)
            }
        } catch (_: Exception) {
        }
    }
}

