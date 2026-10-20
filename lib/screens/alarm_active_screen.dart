import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../config/app_constants.dart';
import '../services/sound_service.dart';
import '../widgets/alarms/alarm_cheat_warning_view.dart';

class AlarmActiveScreen extends StatefulWidget {
  const AlarmActiveScreen({super.key});

  @override
  State<AlarmActiveScreen> createState() => _AlarmActiveScreenState();
}

class _AlarmActiveScreenState extends State<AlarmActiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late final DateTime _openedAt;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  int _selectedAmount = PresetConstants.dismissAmountMl;
  bool _showCheatWarning = false;
  int _cheatRemainingSeconds = AlarmConstants.minDrinkDurationSeconds;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _currentTime = DateTime.now();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 12, end: 32).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        if (provider.isVibrationEnabled) {
          SoundService().triggerAlarmVibration();
        }
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);
    final alarmLabel = provider.activeAlarm?.label ?? 'Su Zamanı';

    if (_showCheatWarning) {
      return AlarmCheatWarningView(
        initialRemainingSeconds: _cheatRemainingSeconds,
        onConfirmed: () {
          provider.dismissAlarm(_selectedAmount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Harika! $_selectedAmount ml su başarıyla kaydedildi. 💧😎'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF0288D1),
            ),
          );
        },
        onReturn: () {
          setState(() {
            _showCheatWarning = false;
          });
        },
      );
    }

    final timeStr = DateFormat('HH:mm').format(_currentTime);
    final dateStr = DateFormat('d MMMM EEEE', 'tr_TR').format(_currentTime);
    final presets = provider.quickPresets.isNotEmpty
        ? provider.quickPresets.take(3).toList()
        : [200, 250, 330];

    return PopScope(
      canPop: false, // Disables standard Android back button
      child: Scaffold(
        backgroundColor: const Color(0xFF070E1E),
        body: Stack(
          children: [
            // 1. Deep Oceanic Aurora Glow Background
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -60,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.22),
                ),
              ),
            ),
            Positioned(
              top: 240,
              right: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                ),
              ),
            ),

            // Backdrop filter for subtle ambient blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),

            // 2. Foreground Glass Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top: Digital Clock & Alarm Pill
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontSize: 68,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -2.5,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Frosted Capsule Alarm Label
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.22),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.alarm_on_rounded,
                                            size: 16,
                                            color: Color(0xFF38BDF8),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            alarmLabel,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Center: Frosted Glassmorphism Radar Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 28,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Pulsating Water Droplet Radar Ring
                                      AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          return ScaleTransition(
                                            scale: _scaleAnimation,
                                            child: Container(
                                              width: 104,
                                              height: 104,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                                    const Color(0xFF0284C7).withValues(alpha: 0.35),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                                  width: 2.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                                    blurRadius: _glowAnimation.value,
                                                    spreadRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '💧',
                                                  style: TextStyle(fontSize: 48),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 20),

                                      const Text(
                                        'Su Zamanı Geldi!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.4,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        'Vücudunun nem dengesini tazelemek için bir bardak su içelim.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.white.withValues(alpha: 0.8),
                                          height: 1.35,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Daily hydration indicator pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Bugün: ${provider.todayConsumed} / ${provider.dailyGoal} ml',
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF38BDF8),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '(Kalan: ${provider.dailyRemainingMl} ml)',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.white.withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Bottom: Preset Selector & Glass Pill Confirmation Button
                            Column(
                              children: [
                                // Quick Preset Amount Selector
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: presets.map((amount) {
                                    final isSelected = _selectedAmount == amount;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedAmount = amount;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF38BDF8)
                                                : Colors.white.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white.withValues(alpha: 0.2),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Text(
                                            '+$amount ml',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected ? const Color(0xFF0C2444) : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                                const SizedBox(height: 14),

                                // Giant Glowing iOS Glass Pill Action Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final triggeredAt = provider.alarmTriggeredAt ?? _openedAt;
                                      final elapsedSeconds =
                                          DateTime.now().difference(triggeredAt).inSeconds;

                                      if (elapsedSeconds < AlarmConstants.minDrinkDurationSeconds) {
                                        final remaining =
                                            AlarmConstants.minDrinkDurationSeconds - elapsedSeconds;
                                        setState(() {
                                          _showCheatWarning = true;
                                          _cheatRemainingSeconds = remaining > 0 ? remaining : 1;
                                        });
                                        return;
                                      }

                                      provider.dismissAlarm(_selectedAmount);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Harika! $_selectedAmount ml su başarıyla kaydedildi. 💧😎'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(0xFF0288D1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF38BDF8),
                                      foregroundColor: const Color(0xFF071930),
                                      elevation: 8,
                                      shadowColor: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(29),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 24, color: Color(0xFF071930)),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Su İçtim',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF071930),
                                                  height: 1.1,
                                                ),
                                              ),
                                              Text(
                                                '+$_selectedAmount ml',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF071930).withValues(alpha: 0.8),
                                                  height: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  '🛡️ 5 saniyelik içim doğrulaması aktiftir',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
