import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../providers/water_provider.dart';
import '../models/alarm_setting.dart';

class AlarmService with WidgetsBindingObserver {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  WaterProvider? _provider;
  Timer? _checkTimer;
  String _lastTriggeredKey = '';
  final Set<String> _triggeredAlarmKeys = {};

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'hydro_reminder_alarms';
  static const String _channelName = 'HydroSoft Alarmları';
  static const String _channelDesc = 'Su zamanı hatırlatıcı alarmları';

  static const String _summaryChannelId = 'hydro_summary_channel';
  static const String _summaryChannelName = 'HydroSoft Gün Sonu Özeti';
  static const String _summaryChannelDesc = 'Günlük içilen ve kalan su miktarı özeti';

  static const String _tipsChannelId = 'hydro_tips_channel_v2';
  static const String _tipsChannelName = 'HydroSoft Sağlık İpuçları';
  static const String _tipsChannelDesc = 'Sağlıklı su tüketimi ve uyku hatırlatıcıları';

  static const String _ongoingChannelId = 'hydro_ongoing_progress';
  static const String _ongoingChannelName = 'HydroSoft Canlı İlerleme';
  static const String _ongoingChannelDesc = 'Bildirim çubuğunda sabit canlı su takip paneli';

  static const int _endOfDayNotificationId = 8888;
  static const int _sleepTipNotificationId = 7777;
  static const int _ongoingNotificationId = 9999;

  // Initialize notifications, channel, permissions, and timezone settings
  Future<void> initialize(WaterProvider provider) async {
    _provider = provider;

    try {
      WidgetsBinding.instance.removeObserver(this);
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}

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

      // iOS (Darwin) Initialization settings - do not prompt before onboarding completes
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Initialize the plugin with named settings parameter
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final actionId = response.actionId;
          if (actionId != null && actionId.startsWith('action_log_')) {
            final amount = int.tryParse(actionId.substring(11));
            if (amount != null && amount > 0) {
              _provider?.addWater(amount);
            }
            return;
          }

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
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel ongoingChannel = AndroidNotificationChannel(
        _ongoingChannelId,
        _ongoingChannelName,
        description: _ongoingChannelDesc,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      await androidImplementation?.createNotificationChannel(channel);
      await androidImplementation?.createNotificationChannel(summaryChannel);
      await androidImplementation?.createNotificationChannel(tipsChannel);
      await androidImplementation?.createNotificationChannel(ongoingChannel);

      // Only check/request permissions if onboarding was already completed
      if (provider.hasCompletedOnboarding) {
        final hasPerm = await checkPermissionStatus();
        if (!hasPerm) {
          await provider.syncNotificationPermissionFromOS(false);
        } else if (provider.isNotificationsEnabled) {
          await syncNotifications(provider.alarms);
          await scheduleEndOfDayNotification(
            isEnabled: provider.isEndOfDayEnabled,
            hour: provider.endOfDayHour,
            minute: provider.endOfDayMinute,
            remainingMl: provider.dailyRemainingMl,
            consumedMl: provider.todayConsumed,
            dailyGoalMl: provider.dailyGoal,
          );
        }
      }

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
    } catch (e) {
      debugPrint('AlarmService initialization error: $e');
    }

    // Start background timer check when app is open in foreground
    startChecking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Sync OS permissions (Notifications & Health Connect / HealthKit) when returning from system settings
      unawaited(_provider?.syncSystemPermissionsOnResume());
      // Immediately check on app resume so full-screen alarm pops up with 0ms delay!
      checkAlarmsNow(includeRecentMissed: true);
    }
  }

  void markAlarmHandledForToday(String alarmId) {
    final now = DateTime.now();
    _triggeredAlarmKeys.add('${now.year}-${now.month}-${now.day}-$alarmId');
  }

  // Trigger alarm overlay if notification is tapped
  void _triggerAlarmFromPayload(String alarmId) {
    if (_provider == null) return;

    markAlarmHandledForToday(alarmId);
    unawaited(cancelAlarmFollowUps(alarmId));

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

  // Immediate check for due or recently fired unacknowledged alarms
  void checkAlarmsNow({bool includeRecentMissed = false}) {
    if (_provider == null ||
        _provider!.isAlarmActive ||
        !_provider!.isNotificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    final currentMinuteKey =
        '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';

    for (final alarm in _provider!.alarms) {
      if (!alarm.isEnabled) continue;

      final alarmDayKey = '${now.year}-${now.month}-${now.day}-${alarm.id}';
      if (_triggeredAlarmKeys.contains(alarmDayKey)) continue;

      // 1. Exact minute match while app is open
      if (alarm.hour == now.hour && alarm.minute == now.minute) {
        if (_lastTriggeredKey != currentMinuteKey) {
          _lastTriggeredKey = currentMinuteKey;
          _triggeredAlarmKeys.add(alarmDayKey);
          unawaited(cancelAlarmFollowUps(alarm.id));
          _provider!.triggerAlarm(alarm);
          return;
        }
      }

      // 2. Recent alarm within last 15 minutes when user opens app after seeing notification
      if (includeRecentMissed) {
        final alarmTimeToday = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.hour,
          alarm.minute,
        );
        final diffSeconds = now.difference(alarmTimeToday).inSeconds;
        if (diffSeconds >= 0 && diffSeconds <= 900) {
          final hasDrankSinceAlarm = _provider!.logs.any(
            (log) => !log.timestamp.isBefore(alarmTimeToday),
          );
          if (!hasDrankSinceAlarm) {
            _lastTriggeredKey = currentMinuteKey;
            _triggeredAlarmKeys.add(alarmDayKey);
            unawaited(cancelAlarmFollowUps(alarm.id));
            _provider!.triggerAlarm(alarm);
            return;
          }
        }
      }
    }
  }

  // Foreground Timer checking (runs when app is open)
  void startChecking() {
    // Run immediately so user never sees Dashboard first when opening at alarm time
    checkAlarmsNow(includeRecentMissed: true);

    if (_checkTimer != null) return;

    // 1-second precision timer (instead of 15s) for instant full-screen trigger
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkAlarmsNow(includeRecentMissed: false);
    });
  }

  // Stop checking
  void stopChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  // Cancel follow-up burst notifications for an alarm
  Future<void> cancelAlarmFollowUps(dynamic id) async {
    if (kIsWeb) return;
    try {
      final baseId = id.hashCode;
      await _notificationsPlugin.cancel(id: baseId + 10001);
      await _notificationsPlugin.cancel(id: baseId + 20002);
      await _notificationsPlugin.cancel(id: baseId + 30003);
    } catch (_) {}
  }

  // Synchronize Flutter local scheduled notifications with active alarms
  Future<void> syncNotifications(List<AlarmSetting> alarms) async {
    if (kIsWeb) return;

    try {
      // Clear all previously scheduled notifications and follow-up rings
      for (final alarm in alarms) {
        final baseId = alarm.id.hashCode;
        await _notificationsPlugin.cancel(id: baseId);
        await _notificationsPlugin.cancel(id: baseId + 10001);
        await _notificationsPlugin.cancel(id: baseId + 20002);
        await _notificationsPlugin.cancel(id: baseId + 30003);
      }
    } catch (_) {
      // In test or unsupported environments where plugin platform instance isn't registered
      return;
    }

    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        final id = alarm.id.hashCode;
        final title = '🚨 Su Zamanı Geldi! 💧';
        final body =
            '${alarm.label} saati geldi! Tam ekran alarmı kapatmak için dokunun ve suyunuzu için.';

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
          presentBanner: true,
          presentList: true,
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

          // On iOS, schedule persistent follow-up alarm rings (+12s, +24s, +36s)
          // so if the app is closed, it continues ringing & vibrating like a real alarm until opened
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            final followUpOffsets = [12, 24, 36];
            final followUpIds = [id + 10001, id + 20002, id + 30003];
            for (int i = 0; i < followUpOffsets.length; i++) {
              final followUpDate =
                  scheduledDate.add(Duration(seconds: followUpOffsets[i]));
              await _notificationsPlugin.zonedSchedule(
                id: followUpIds[i],
                title: '⏰ Su Alarmı Çalıyor! (${alarm.label})',
                body:
                    'Henüz suyunuzu içmediniz! Tam ekran alarmı açmak ve onaylamak için dokunun. 💧',
                scheduledDate: followUpDate,
                notificationDetails: const NotificationDetails(iOS: darwinDetails),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                matchDateTimeComponents: DateTimeComponents.time,
                payload: 'alarm_${alarm.id}',
              );
            }
          }
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
  Future<bool> sendSleepTipNotification({int? consumedMl, int? remainingMl, int? dailyGoalMl}) async {
    if (kIsWeb) return true;

    bool hasPerm = await checkPermissionStatus();
    if (!hasPerm) {
      hasPerm = await requestPermission();
    }
    if (!hasPerm) {
      await openNotificationSettings();
      return false;
    }

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

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _tipsChannelId,
      _tipsChannelName,
      channelDescription: _tipsChannelDesc,
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: false,
      styleInformation: BigTextStyleInformation(body),
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: true,
      sound: 'sound_water_drop.wav',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: _sleepTipNotificationId,
        title: 'Sağlıklı Uyku ve Su İpucu 🌙💤',
        body: body,
        notificationDetails: details,
        payload: 'sleep_tip_notification',
      );
      return true;
    } catch (e) {
      debugPrint('sendSleepTipNotification error: $e');
      return false;
    }
  }

  // Check if system notifications are enabled
  Future<bool> checkPermissionStatus() async {
    if (kIsWeb) return true;
    try {
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
    } catch (_) {
      return true;
    }
    return true;
  }

  // Request notifications permission from the user
  Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    try {
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
    } catch (_) {
      return true;
    }
    return true;
  }

  // Open OS Notification Settings page when permission was previously denied
  Future<void> openNotificationSettings() async {
    if (kIsWeb) return;
    try {
      const channel = MethodChannel('com.antigravity.hydroReminder/alarm_haptics');
      await channel.invokeMethod('openNotificationSettings');
    } catch (_) {}
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
      await cancelAlarmFollowUps(id);
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

  // Show or Update Ongoing Live Hydration Panel Notification
  Future<void> updateOngoingProgressNotification({
    required bool isEnabled,
    required int todayConsumed,
    required int dailyGoal,
    required int percentage,
    required int preset1,
    required int preset2,
    required int preset3,
  }) async {
    if (kIsWeb) return;
    if (!isEnabled) {
      await cancelOngoingNotification();
      return;
    }

    try {
      final safeGoal = dailyGoal > 0 ? dailyGoal : 2500;
      final percentClamped = percentage.clamp(0, 100);
      final remaining = (safeGoal - todayConsumed).clamp(0, safeGoal);
      final status = WaterProvider.getHydrationStatus(percentage / 100.0);
      final statusEmoji = status['emoji'] ?? '💧';
      final p1Emoji = WaterProvider.getPresetMeta(preset1)['emoji'] ?? '🥛';
      final p2Emoji = WaterProvider.getPresetMeta(preset2)['emoji'] ?? '🥤';
      final p3Emoji = WaterProvider.getPresetMeta(preset3)['emoji'] ?? '🍶';

      final androidDetails = AndroidNotificationDetails(
        _ongoingChannelId,
        _ongoingChannelName,
        channelDescription: _ongoingChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: safeGoal,
        progress: todayConsumed.clamp(0, safeGoal),
        showWhen: false,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'action_log_$preset1',
            '$p1Emoji +$preset1 ml',
            showsUserInterface: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            'action_log_$preset2',
            '$p2Emoji +$preset2 ml',
            showsUserInterface: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            'action_log_$preset3',
            '$p3Emoji +$preset3 ml',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: _ongoingNotificationId,
        title: '$statusEmoji HydroSoft • Hedef: $safeGoal ml (%$percentClamped)',
        body: 'Bugün: $todayConsumed ml  |  Kalan: $remaining ml',
        notificationDetails: notificationDetails,
        payload: 'ongoing_panel',
      );
    } catch (e) {
      debugPrint('Error updating ongoing notification: $e');
    }
  }

  // Cancel Ongoing Live Notification
  Future<void> cancelOngoingNotification() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id: _ongoingNotificationId);
    } catch (_) {}
  }
}
