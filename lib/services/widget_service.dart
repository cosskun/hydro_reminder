import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const String appGroupId = 'group.com.antigravity.hydroReminder';
  static const String androidProgressWidget = 'WaterProgressWidgetProvider';
  static const String androidQuickLogWidget = 'WaterQuickLogWidgetProvider';
  static const String androidMiniWidget = 'WaterMiniWidgetProvider';

  static const String iosProgressWidget = 'WaterProgressWidget';
  static const String iosQuickLogWidget = 'WaterQuickLogWidget';
  static const String iosMiniWidget = 'WaterMiniWidget';

  StreamSubscription<Uri?>? _widgetClickSubscription;
  Function(int amount)? _onWaterLogged;
  Function(int tabIndex)? _onNavigate;

  // Initialize widget service, app groups, and deep link listeners
  Future<void> initialize({
    required Function(int amount) onWaterLogged,
    Function(int tabIndex)? onNavigate,
  }) async {
    _onWaterLogged = onWaterLogged;
    _onNavigate = onNavigate;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await HomeWidget.setAppGroupId(appGroupId);
      } catch (e) {
        debugPrint('HomeWidget setAppGroupId error: $e');
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

  // Handle incoming deep link from widget or app shortcuts
  void _handleWidgetUri(Uri uri) {
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

  // Sync latest hydration data across all widgets
  Future<void> updateWidgets({
    required int todayConsumed,
    required int dailyGoal,
    required int dailyRemaining,
    required int percentage,
    required int preset1,
    required int preset2,
    required int preset3,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      await HomeWidget.saveWidgetData<int>('todayConsumed', todayConsumed);
      await HomeWidget.saveWidgetData<int>('dailyGoal', dailyGoal);
      await HomeWidget.saveWidgetData<int>('dailyRemaining', dailyRemaining);
      await HomeWidget.saveWidgetData<int>('percentage', percentage);
      await HomeWidget.saveWidgetData<int>('preset1', preset1);
      await HomeWidget.saveWidgetData<int>('preset2', preset2);
      await HomeWidget.saveWidgetData<int>('preset3', preset3);

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
