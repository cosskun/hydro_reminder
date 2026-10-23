import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const MethodChannel _platformChannel =
      MethodChannel('com.antigravity.hydroReminder/alarm_haptics');

  static const String appGroupId = 'group.com.antigravity.hydroReminder';
  static const String androidProgressWidget = 'WaterProgressWidgetProvider';
  static const String androidQuickLogWidget = 'WaterQuickLogWidgetProvider';
  static const String androidMiniWidget = 'WaterMiniWidgetProvider';

  static const String iosProgressWidget = 'WaterProgressWidget';
  static const String iosQuickLogWidget = 'WaterQuickLogWidget';
  static const String iosMiniWidget = 'WaterMiniWidget';

  // Request Android 8.0+ Launcher to pin a specific widget directly to the Home Screen
  Future<bool> pinAndroidWidget(String providerName) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final pinned = await _platformChannel.invokeMethod<bool>(
        'pinHomeWidget',
        {'provider': providerName},
      );
      return pinned ?? false;
    } catch (_) {
      return false;
    }
  }

  // Request Android 8.0+ Launcher to pin a specific App Shortcut directly to the Home Screen
  Future<bool> pinAndroidShortcut(String shortcutId) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final pinned = await _platformChannel.invokeMethod<bool>(
        'pinAppShortcut',
        {'shortcutId': shortcutId},
      );
      return pinned ?? false;
    } catch (_) {
      return false;
    }
  }

  // Request Android 13+ (API 33+) to add the Quick Settings Tile via native system dialog
  Future<Map<String, dynamic>> requestAddQuickTile() async {
    if (kIsWeb || !Platform.isAndroid) {
      return {'supported': false, 'success': false, 'alreadyAdded': false};
    }
    try {
      final res = await _platformChannel.invokeMethod<Map<dynamic, dynamic>>('requestAddQuickTile');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
      return {'supported': false, 'success': false, 'alreadyAdded': false};
    } catch (_) {
      return {'supported': false, 'success': false, 'alreadyAdded': false};
    }
  }

  StreamSubscription<Uri?>? _widgetClickSubscription;
  Function(int amount)? _onWaterLogged;
  Function(int tabIndex)? _onNavigate;
  String? _lastHandledUri;
  DateTime? _lastHandledTime;
  String? _cachedImageAsset;
  String? _cachedMascotBase64;

  // Initialize widget service, app groups, and deep link listeners
  Future<void> initialize({
    required Function(int amount) onWaterLogged,
    Function(int tabIndex)? onNavigate,
  }) async {
    _onWaterLogged = onWaterLogged;
    _onNavigate = onNavigate;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Listen for runtime Android App Shortcut intents forwarded from MainActivity.onNewIntent
      _platformChannel.setMethodCallHandler((call) async {
        if (call.method == 'onShortcutUri') {
          final uriStr = call.arguments as String?;
          if (uriStr != null && uriStr.isNotEmpty) {
            final parsed = Uri.tryParse(uriStr);
            if (parsed != null) {
              _handleWidgetUri(parsed);
            }
          }
        }
      });

      try {
        await HomeWidget.setAppGroupId(appGroupId);
      } catch (e) {
        debugPrint('HomeWidget setAppGroupId error: $e');
      }

      // Handle cold start from native App Shortcut or iOS Widget URL Scheme
      try {
        final initialShortcutStr =
            await _platformChannel.invokeMethod<String>('consumeInitialShortcutUri');
        if (initialShortcutStr != null && initialShortcutStr.isNotEmpty) {
          final parsed = Uri.tryParse(initialShortcutStr);
          if (parsed != null) {
            _handleWidgetUri(parsed);
          }
        }
      } catch (e) {
        debugPrint('consumeInitialShortcutUri error: $e');
      }

      // Handle cold start from widget click
      try {
        final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
        if (initialUri != null) {
          _handleWidgetUri(initialUri);
        }
      } catch (e) {
        debugPrint('HomeWidget initialUri error: $e');
      }

      // Handle foreground/background clicks
      _widgetClickSubscription?.cancel();
      _widgetClickSubscription = HomeWidget.widgetClicked.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleWidgetUri(uri);
          }
        },
        onError: (err) {
          debugPrint('HomeWidget widgetClicked stream error: $err');
        },
      );
    }
  }

  // Handle incoming deep link from widget or app shortcuts (with deduplication)
  void _handleWidgetUri(Uri uri) {
    final now = DateTime.now();
    final uriString = uri.toString();
    if (_lastHandledUri == uriString &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!).inMilliseconds < 1500) {
      return;
    }
    _lastHandledUri = uriString;
    _lastHandledTime = now;

    debugPrint('Widget / Shortcut deep link received: $uri');
    if (uri.scheme == 'hydroreminder') {
      if (uri.host == 'log' || uri.path.contains('log')) {
        final amountStr = uri.queryParameters['amount'];
        if (amountStr != null) {
          final amount = int.tryParse(amountStr);
          if (amount != null && amount > 0) {
            _onWaterLogged?.call(amount);
          }
        }
      } else if (uri.host == 'stats' || uri.path.contains('stats') || uri.host == 'history') {
        _onNavigate?.call(1); // 1 = History / İstatistikler tab
      }
    }
  }

  Future<Uint8List> _resizeAssetBytes(Uint8List bytes, {int targetSize = 512}) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize,
      targetHeight: targetSize,
    );
    try {
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  // Sync latest hydration data across all widgets (including streak & 5-day tracker)
  Future<void> updateWidgets({
    required int todayConsumed,
    required int dailyGoal,
    required int dailyRemaining,
    required int percentage,
    required int preset1,
    required int preset2,
    required int preset3,
    int streakDays = 0,
    String dayLabels = 'Çr,Pe,Cu,Ct,Pa',
    String dayStatuses = '0,0,0,0,0',
    String mascotEmoji = '🥱',
    String mascotTitle = 'Durumunuz',
    String mascotSubtitle = 'Güne susuz başladın! Hemen bir bardak su al.',
    String preset1Emoji = '🥛',
    String preset2Emoji = '🥤',
    String preset3Emoji = '🫙',
    String widgetTheme = 'ocean',
    String mascotType = 'cat',
    String? imageAsset,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      try {
        await HomeWidget.setAppGroupId(appGroupId);
      } catch (_) {}

      String? mascotBase64;
      if (imageAsset != null && imageAsset.isNotEmpty) {
        if (imageAsset == _cachedImageAsset && _cachedMascotBase64 != null) {
          mascotBase64 = _cachedMascotBase64;
        } else {
          try {
            final ByteData byteData = await rootBundle.load(imageAsset);
            final rawBytes = byteData.buffer.asUint8List();
            final resizedBytes = await _resizeAssetBytes(rawBytes, targetSize: 512);
            mascotBase64 = base64Encode(resizedBytes);
            _cachedImageAsset = imageAsset;
            _cachedMascotBase64 = mascotBase64;
          } catch (e) {
            debugPrint('Error preparing widget mascot image: $e');
          }
        }
      }

      await HomeWidget.saveWidgetData<int>('todayConsumed', todayConsumed);
      await HomeWidget.saveWidgetData<int>('dailyGoal', dailyGoal);
      await HomeWidget.saveWidgetData<int>('dailyRemaining', dailyRemaining);
      await HomeWidget.saveWidgetData<int>('percentage', percentage);
      await HomeWidget.saveWidgetData<int>('preset1', preset1);
      await HomeWidget.saveWidgetData<int>('preset2', preset2);
      await HomeWidget.saveWidgetData<int>('preset3', preset3);
      await HomeWidget.saveWidgetData<int>('streakDays', streakDays);
      await HomeWidget.saveWidgetData<String>('dayLabels', dayLabels);
      await HomeWidget.saveWidgetData<String>('dayStatuses', dayStatuses);
      await HomeWidget.saveWidgetData<String>('mascotEmoji', mascotEmoji);
      await HomeWidget.saveWidgetData<String>('mascotTitle', mascotTitle);
      await HomeWidget.saveWidgetData<String>('mascotSubtitle', mascotSubtitle);
      await HomeWidget.saveWidgetData<String>('preset1Emoji', preset1Emoji);
      await HomeWidget.saveWidgetData<String>('preset2Emoji', preset2Emoji);
      await HomeWidget.saveWidgetData<String>('preset3Emoji', preset3Emoji);
      await HomeWidget.saveWidgetData<String>('widgetTheme', widgetTheme);
      await HomeWidget.saveWidgetData<String>('mascotType', mascotType);
      await HomeWidget.saveWidgetData<String>('mascotBase64', mascotBase64 ?? '');

      if (Platform.isIOS) {
        try {
          await _platformChannel.invokeMethod('syncIosWidgetData', {
            'todayConsumed': todayConsumed,
            'dailyGoal': dailyGoal,
            'dailyRemaining': dailyRemaining,
            'percentage': percentage,
            'preset1': preset1,
            'preset2': preset2,
            'preset3': preset3,
            'streakDays': streakDays,
            'dayLabels': dayLabels,
            'dayStatuses': dayStatuses,
            'mascotEmoji': mascotEmoji,
            'mascotTitle': mascotTitle,
            'mascotSubtitle': mascotSubtitle,
            'preset1Emoji': preset1Emoji,
            'preset2Emoji': preset2Emoji,
            'preset3Emoji': preset3Emoji,
            'widgetTheme': widgetTheme,
            'mascotType': mascotType,
            'mascotBase64': mascotBase64 ?? '',
          });
        } catch (e) {
          debugPrint('syncIosWidgetData error: $e');
        }
      }

      // Trigger update for all 3 Android & iOS widgets
      await HomeWidget.updateWidget(
        name: androidProgressWidget,
        androidName: androidProgressWidget,
        iOSName: iosProgressWidget,
      );

      await HomeWidget.updateWidget(
        name: androidQuickLogWidget,
        androidName: androidQuickLogWidget,
        iOSName: iosQuickLogWidget,
      );

      await HomeWidget.updateWidget(
        name: androidMiniWidget,
        androidName: androidMiniWidget,
        iOSName: iosMiniWidget,
      );
    } catch (e) {
      debugPrint('Error updating home widgets: $e');
    }
  }

  void dispose() {
    _widgetClickSubscription?.cancel();
  }
}
