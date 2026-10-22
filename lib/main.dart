import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'providers/water_provider.dart';
import 'services/alarm_service.dart';
import 'services/widget_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom graceful error handling
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'Bir arayÃ¼z yÃ¼kleme sorunu oluÅŸtu.',
          style: TextStyle(color: Colors.blueGrey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  };

  // Set system status bar to transparent with dark icons for light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize locale formatting for Turkish date representations
  await initializeDateFormatting('tr_TR', null);

  final waterProvider = WaterProvider();
  await waterProvider.init();

  // Initialize and run our background alarm checking and notification service
  await AlarmService().initialize(waterProvider);

  // Initialize home screen and lock screen widget & shortcut listener
  await WidgetService().initialize(
    onWaterLogged: (amount) async {
      await waterProvider.addWater(amount);
      void showConfirmation() {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('ğŸ’§ ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    '$amount ml su baÅŸarÄ±yla kaydedildi!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getTheme(waterProvider.customThemePreset, isDark: false).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (rootScaffoldMessengerKey.currentState != null) {
        showConfirmation();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 250), showConfirmation);
        });
      }
    },
    onNavigate: (tabIndex) {
      if (mainNavigationKey.currentState != null) {
        mainNavigationKey.currentState?.setTabIndex(tabIndex);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 250), () {
            mainNavigationKey.currentState?.setTabIndex(tabIndex);
          });
        });
      }
    },
  );

  await waterProvider.syncWidgetsNow();

  runApp(
    ChangeNotifierProvider.value(
      value: waterProvider,
      child: const HydroReminderApp(),
    ),
  );
}

class HydroReminderApp extends StatelessWidget {
  const HydroReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);

    return MaterialApp(
      title: 'HydroSoft',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: AppTheme.getTheme(provider.effectiveThemePreset, isDark: false),
      darkTheme: AppTheme.getTheme(provider.effectiveThemePreset, isDark: true),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppRouter(),
    );
  }
}

