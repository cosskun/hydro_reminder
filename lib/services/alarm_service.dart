import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../providers/water_provider.dart';
import '../models/alarm_setting.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  WaterProvider? _provider;
  Timer? _checkTimer;
  String _lastTriggeredKey = '';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'hydro_reminder_alarms';
  static const String _channelName = 'HydroSoft Alarmları';
  static const String _channelDesc = 'Su zamanı hatırlatıcı alarmları';

  static const String _summaryChannelId = 'hydro_summary_channel';
  static const String _summaryChannelName = 'HydroSoft Gün Sonu Özeti';
  static const String _summaryChannelDesc = 'Günlük içilen ve kalan su miktarı özeti';

  static const String _tipsChannelId = 'hydro_tips_channel';
  static const String _tipsChannelName = 'HydroSoft Sağlık İpuçları';
  static const String _tipsChannelDesc = 'Sağlıklı su tüketimi ve uyku hatırlatıcıları';

  static const int _endOfDayNotificationId = 8888;
  static const int _sleepTipNotificationId = 7777;

  // Initialize notifications, channel, permissions, and timezone settings
  Future<void> initialize(WaterProvider provider) async {
    _provider = provider;

    if (kIsWeb) {
      startChecking();
      return;
    }

    try {
      // Initialize timezones
      tz.initializeTimeZones();
      try {
        final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // Fallback to default timezone if timezone fetch fails
      }

      // Android Initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS (Darwin) Initialization settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Initialize the plugin with named settings parameter
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.startsWith('alarm_')) {
            final alarmId = payload.substring(6); // Remove prefix
            _triggerAlarmFromPayload(alarmId);
          }
        },
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      // Explicitly create high-priority notification channel for Android 8.0+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      const AndroidNotificationChannel summaryChannel = AndroidNotificationChannel(
        _summaryChannelId,
        _summaryChannelName,
        description: _summaryChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel tipsChannel = AndroidNotificationChannel(
        _tipsChannelId,
        _tipsChannelName,
        description: _tipsChannelDesc,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sound_water_drop'),
        enableVibration: true,
      );

      await androidImplementation?.createNotificationChannel(channel);
      await androidImplementation?.createNotificationChannel(summaryChannel);
      await androidImplementation?.createNotificationChannel(tipsChannel);

      // Request permissions on Android 13+ / 14+ and iOS
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Check if the app was launched by a notification (Cold Start)
      final NotificationAppLaunchDetails? launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.startsWith('alarm_')) {
          final alarmId = payload.substring(6);
          _triggerAlarmFromPayload(alarmId);
        }
      }

      // Initial sync of existing alarms and end-of-day summary notification
      await syncNotifications(provider.alarms);
      await scheduleEndOfDayNotification(
        isEnabled: provider.isEndOfDayEnabled,
        hour: provider.endOfDayHour,
        minute: provider.endOfDayMinute,
        remainingMl: provider.dailyRemainingMl,
        consumedMl: provider.todayConsumed,
        dailyGoalMl: provider.dailyGoal,
      );
    } catch (e) {
      debugPrint('AlarmService initialization error: $e');
    }

    // Start background timer check when app is open in foreground
    startChecking();
  }

  // Trigger alarm overlay if notification is tapped
  void _triggerAlarmFromPayload(String alarmId) {
    if (_provider == null) return;
    
    final alarmIndex = _provider!.alarms.indexWhere((a) => a.id == alarmId);
    if (alarmIndex != -1) {
      _provider!.triggerAlarm(_provider!.alarms[alarmIndex]);
    } else {
      // Fallback / Test alarm
      _provider!.triggerAlarm(
        AlarmSetting(
          id: alarmId,
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
          label: 'Su Zamanı Geldi! 💧',
        ),
      );
    }
  }

  // Foreground Timer checking (runs when app is open)
  void startChecking() {
    if (_checkTimer != null) return;

    _checkTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_provider == null) return;
      
      final now = DateTime.now();
      final currentKey = '${now.day}-${now.hour}-${now.minute}';

      // Avoid double triggering in the same minute
      if (_lastTriggeredKey == currentKey) return;

      for (final alarm in _provider!.alarms) {
        if (alarm.isEnabled && alarm.hour == now.hour && alarm.minute == now.minute) {
          _lastTriggeredKey = currentKey;
          _provider!.triggerAlarm(alarm);
          break;
        }
      }
    });
  }

  // Stop checking
  void stopChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  // Synchronize Flutter local scheduled notifications with active alarms
  Future<void> syncNotifications(List<AlarmSetting> alarms) async {
    if (kIsWeb) return;

    // Clear all previously scheduled notifications except end-of-day summary
    for (final alarm in alarms) {
      await _notificationsPlugin.cancel(id: alarm.id.hashCode);
    }

    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        final id = alarm.id.hashCode;
        final title = 'Su Zamanı Geldi! 💧';
        final body = '${alarm.label} saati geldi. Bir bardak su içelim!';

        final now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          alarm.hour,
          alarm.minute,
        );

        // If time has passed today, schedule for tomorrow
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        const androidDetails = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(''),
        );

        const darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'sound_water_drop.wav',
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        const notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        );

        try {
          // Attempt alarmClock mode (wakes up phone from deep sleep/Doze mode)
          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
            payload: 'alarm_${alarm.id}',
          );
        } catch (e) {
          try {
            // Fallback to exactAllowWhileIdle if alarmClock fails
            await _notificationsPlugin.zonedSchedule(
              id: id,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
              notificationDetails: notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.time,
              payload: 'alarm_${alarm.id}',
            );
          } catch (_) {
            // Fail silently
          }
        }
      }
    }
  }

  // Schedule daily End of Day Summary Notification
  Future<void> scheduleEndOfDayNotification({
    required bool isEnabled,
    required int hour,
    required int minute,
    required int remainingMl,
    required int consumedMl,
    required int dailyGoalMl,
  }) async {
    if (kIsWeb) return;

    // Always cancel existing end-of-day notification first
    try {
      await _notificationsPlugin.cancel(id: _endOfDayNotificationId);
    } catch (_) {}

    if (!isEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final String title = 'Gün Sonu Su Özeti 🌙💧';
    final String body;
    if (consumedMl == 0) {
      body = 'Bugün henüz hiç su kaydı girmediniz! Günlük hedefiniz: $dailyGoalMl ml. Vücudunuzu susuz bırakmayın! 💧';
    } else if (remainingMl <= 0) {
      body = 'Tebrikler! 🏆 Bugün $dailyGoalMl ml su hedefinizi başarıyla tamamladınız! Harika bir iş çıkardınız.';
    } else {
      body = 'Bugün hedefinize ulaşmak için kalan miktar: $remainingMl ml (İçilen: $consumedMl / $dailyGoalMl ml). Yatmadan önce su içmeyi unutmayın! 💧';
    }

    const androidDetails = AndroidNotificationDetails(
      _summaryChannelId,
      _summaryChannelName,
      channelDescription: _summaryChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'sound_water_drop.wav',
      interruptionLevel: InterruptionLevel.active,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: _endOfDayNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'summary_end_of_day',
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id: _endOfDayNotificationId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'summary_end_of_day',
        );
      } catch (_) {}
    }
  }

  // Schedule a test alarm with delay to test lockscreen / background wakeup
  Future<void> scheduleTestAlarm(Duration delay) async {
    if (kIsWeb) return;

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'sound_water_drop.wav',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: 999,
        title: 'Su Zamanı Geldi! 💧',
        body: 'Kapatılamayan alarm testi. Bir bardak su içelim!',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: 'alarm_test_id',
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id: 999,
          title: 'Su Zamanı Geldi! 💧',
          body: 'Kapatılamayan alarm testi. Bir bardak su içelim!',
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'alarm_test_id',
        );
      } catch (_) {
        await postTestNotification();
      }
    }
  }

  // Helper to post a direct test notification
  Future<void> postTestNotification() async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'sound_water_drop.wav',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: 999,
      title: 'Test Uyarısı 💧',
      body: 'Kapatılamayan alarm testi. Tıklayıp onaylayın.',
      notificationDetails: details,
      payload: 'alarm_test_id',
    );
  }

  // Send Sleep & Water tip notification directly to phone notification shade (not full screen)
  Future<void> sendSleepTipNotification({int? consumedMl, int? remainingMl, int? dailyGoalMl}) async {
    if (kIsWeb) return;

    final consumed = consumedMl ?? _provider?.todayConsumed ?? 0;
    final remaining = remainingMl ?? _provider?.dailyRemainingMl ?? 0;
    final goal = dailyGoalMl ?? _provider?.dailyGoal ?? 2200;

    final String body;
    if (consumed == 0) {
      body = 'Bugün henüz hiç su kaydetmediniz! Hedefiniz: $goal ml. Kaliteli bir uyku için yatmadan önce su almayı unutmayın. 🌙💤';
    } else if (remaining <= 0) {
      body = 'Tebrikler! 🏆 Bugün $goal ml hedefinizi tamamladınız! Gece rahat uyumak için yatmadan hemen önce aşırı sıvı tüketmeyin. 🌙💤';
    } else {
      body = 'Bugün $consumed ml su içtiniz ($remaining ml kaldı). Kaliteli bir uyku için yatmadan önce ihtiyacınız kadar su almayı unutmayın! 🌙💧';
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _tipsChannelId,
      _tipsChannelName,
      channelDescription: _tipsChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('sound_water_drop'),
      enableVibration: true,
      fullScreenIntent: false, // Standard heads-up notification in notification bar, not full screen
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'sound_water_drop.wav',
      interruptionLevel: InterruptionLevel.active,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: _sleepTipNotificationId,
      title: 'Sağlıklı Uyku ve Su İpucu 🌙💤',
      body: body,
      notificationDetails: details,
      payload: 'sleep_tip_notification',
    );
  }

  // Check if system notifications are enabled
  Future<bool> checkPermissionStatus() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return status ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return status?.isEnabled ?? true;
    }
    return true;
  }

  // Request notifications permission from the user
  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final notifStatus = await androidImpl?.requestNotificationsPermission();
      await androidImpl?.requestExactAlarmsPermission();
      return notifStatus ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final notifStatus = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return notifStatus ?? false;
    }
    return true;
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  // Cancel single alarm by ID
  Future<void> cancelAlarm(dynamic id) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id: id.hashCode);
    } catch (_) {}
  }

  // Schedule single alarm
  Future<void> scheduleAlarm(AlarmSetting alarm) async {
    if (kIsWeb) return;
    await syncNotifications([alarm]);
  }

  // Reschedule all alarms
  Future<void> rescheduleAllAlarms(List<AlarmSetting> alarms) async {
    if (kIsWeb) return;
    await syncNotifications(alarms);
  }
}
