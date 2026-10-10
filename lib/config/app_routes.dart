import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/water_provider.dart';
import '../services/alarm_service.dart';
import '../screens/onboarding_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/alarms_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/alarm_active_screen.dart';

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

    return MainNavigationLayout(key: mainNavigationKey);
  }
}

final GlobalKey<MainNavigationLayoutState> mainNavigationKey =
    GlobalKey<MainNavigationLayoutState>();

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => MainNavigationLayoutState();
}

class MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _currentIndex = 0;

  void setTabIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsSilently();
    });
  }

  Future<void> _checkPermissionsSilently() async {
    final alarmService = AlarmService();
    final isGranted = await alarmService.checkPermissionStatus();
    if (!isGranted) {
      // Requests native OS permission prompt smoothly without blocking modal
      await alarmService.requestPermission();
    }
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
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
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
