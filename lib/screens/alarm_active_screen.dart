import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../config/app_constants.dart';
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

  bool _showCheatWarning = false;
  int _cheatRemainingSeconds = AlarmConstants.minDrinkDurationSeconds;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 10, end: 30).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
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
          provider.dismissAlarm(PresetConstants.dismissAmountMl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harika! Su içimi başarıyla kaydedildi. 💧😎'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blueAccent,
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

    return PopScope(
      canPop: false, // Disables standard Android back button
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Stack(
          children: [
            // Flashing soft blue background wave lines
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.blue.shade100.withValues(alpha: _pulseController.value * 0.5 + 0.3),
                          Colors.blue.shade200.withValues(alpha: 0.5),
                        ],
                        radius: 1.2,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Floating bubbles/water drops in background
            ...List.generate(6, (index) {
              final random = math.Random(index);
              final left = random.nextDouble() * 300 + 30;
              final top = random.nextDouble() * 500 + 100;
              final size = random.nextDouble() * 40 + 20;
              return Positioned(
                left: left,
                top: top,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final offset = math.sin(_pulseController.value * math.pi + index) * 15;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Opacity(
                        opacity: 0.2,
                        child: Text(
                          '💧',
                          style: TextStyle(fontSize: size),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 10),
                            // Flashing/pulsing alarm clock & drop emoji
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade300.withValues(alpha: 0.4),
                                      blurRadius: _glowAnimation.value,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '💧⏰💧',
                                  style: TextStyle(fontSize: 44),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Heading
                            Text(
                              alarmLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Prompt message
                            Text(
                              'Şimdi 1 büyük bardak (250 ml) su içme zamanı! Vücudunuzun nem dengesini korumak için onaylamadan alarmı kapatamazsınız.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.blue.shade800.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            
                            const SizedBox(height: 28),

                            // Giant pulsing approval button
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent.withValues(alpha: 0.3),
                                          blurRadius: _glowAnimation.value + 10,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final triggeredAt = provider.alarmTriggeredAt ?? _openedAt;
                                        final elapsedSeconds = DateTime.now().difference(triggeredAt).inSeconds;

                                        if (elapsedSeconds < AlarmConstants.minDrinkDurationSeconds) {
                                          final remaining = AlarmConstants.minDrinkDurationSeconds - elapsedSeconds;
                                          setState(() {
                                            _showCheatWarning = true;
                                            _cheatRemainingSeconds = remaining > 0 ? remaining : 1;
                                          });
                                          return;
                                        }

                                        // Log 250ml water intake and close alarm
                                        provider.dismissAlarm(PresetConstants.dismissAmountMl);
                                        
                                        // Show snackbar feedback in main context
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Harika! Su içimi başarıyla kaydedildi. 💧😎'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Su İçtim',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '+250 ml',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
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
