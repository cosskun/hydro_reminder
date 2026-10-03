import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/water_provider.dart';
import 'services/alarm_service.dart';
import 'services/widget_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/alarms_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/alarm_active_screen.dart';

import 'package:flutter/services.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress yellow-black zebra stripe overflow warnings across all devices
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
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

  // Initialize home screen and lock screen widget listener
  await WidgetService().initialize(
    onWaterLogged: (amount) async {
      await waterProvider.addWater(amount);
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('💧 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  '$amount ml su başarıyla kaydedildi!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0288D1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    },
  );

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

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F9FD),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0288D1),
        onPrimary: Colors.white,
        secondary: Color(0xFF26C6DA),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1E293B),
        error: Color(0xFFE53935),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0288D1),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0288D1),
        unselectedItemColor: Color(0xFF94A3B8),
        elevation: 8,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      fontFamily: 'Roboto',
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B132B), // Deep Midnight Blue
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF38BDF8),
        onPrimary: Color(0xFF0B132B),
        secondary: Color(0xFF00E5FF),
        onSecondary: Color(0xFF0B132B),
        surface: Color(0xFF1C2541),
        onSurface: Color(0xFFF1F5F9),
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C2541),
        foregroundColor: Color(0xFF38BDF8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C2541),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3A506B), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C2541),
        selectedItemColor: Color(0xFF38BDF8),
        unselectedItemColor: Color(0xFF64748B),
        elevation: 8,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1C2541),
        surfaceTintColor: Colors.transparent,
      ),
      fontFamily: 'Roboto',
    );

    return MaterialApp(
      title: 'HydroSoft',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
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

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);

    // CRITICAL: If an alarm is currently active, hijack the entire UI
    // and show the AlarmActiveScreen which has no navigation and cannot be bypassed.
    if (provider.isAlarmActive) {
      return const AlarmActiveScreen();
    }

    // Otherwise, route based on onboarding completion
    if (!provider.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    return const MainNavigationLayout();
  }
}

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }

  Future<void> _checkAndRequestPermissions() async {
    final alarmService = AlarmService();
    final isGranted = await alarmService.checkPermissionStatus();
    if (!isGranted) {
      final result = await alarmService.requestPermission();
      if (!result) {
        if (mounted) {
          _showPermissionWarningDialog();
        }
      }
    }
  }

  void _showPermissionWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Bildirim İzni Gerekli 🔔', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Su hatırlatıcılarının ve alarmların kilit ekranında çalabilmesi için bildirim izni vermeniz gerekmektedir.\n\nİzin vermezseniz uygulama tarafından gelecek uyarılar, bilgilendirmeler ve alarmlar tarafınıza iletilemeyecektir.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anladım', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final alarmService = AlarmService();
                final result = await alarmService.requestPermission();
                if (!result) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen telefon ayarlarından HydroSoft için bildirimlere izin verin.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('İzin Ver'),
            ),
          ],
        );
      },
    );
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    AlarmsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'HydroSoft',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFF38BDF8) : Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '💧',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'HydroSoft',
                applicationVersion: '1.0.0',
                applicationIcon: const Text('💧', style: TextStyle(fontSize: 32)),
                children: [
                  const Text(
                    'HydroSoft, vücut kitle indeksiniz, yaşınız ve cinsiyetinize özel su içme hedefleri belirleyen ve sizi düzenli aralıklarla uyararak hidrasyon dengenizi korumanızı sağlayan akıllı bir hatırlatıcıdır.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.blue.shade900.withValues(alpha: 0.04),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.water_drop_outlined),
                activeIcon: Icon(Icons.water_drop),
                label: 'Panel',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_toggle_off_rounded),
                activeIcon: Icon(Icons.history_rounded),
                label: 'Günlük',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined),
                activeIcon: Icon(Icons.notifications_active_rounded),
                label: 'Alarmlar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Ayarlar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
