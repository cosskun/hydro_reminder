import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_constants.dart';

class AlarmCheatWarningView extends StatefulWidget {
  final int initialRemainingSeconds;
  final VoidCallback onConfirmed;
  final VoidCallback onReturn;

  const AlarmCheatWarningView({
    super.key,
    this.initialRemainingSeconds = AlarmConstants.minDrinkDurationSeconds,
    required this.onConfirmed,
    required this.onReturn,
  });

  @override
  State<AlarmCheatWarningView> createState() => _AlarmCheatWarningViewState();
}

class _AlarmCheatWarningViewState extends State<AlarmCheatWarningView>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialRemainingSeconds > 0
        ? widget.initialRemainingSeconds
        : AlarmConstants.minDrinkDurationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initial alert vibration to signal invalid quick click
    HapticFeedback.heavyImpact();

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_remainingSeconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 1) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          setState(() {
            _remainingSeconds = 0;
          });
          timer.cancel();
          HapticFeedback.mediumImpact();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCountdownFinished = _remainingSeconds == 0;
    final totalDuration = widget.initialRemainingSeconds > 0
        ? widget.initialRemainingSeconds
        : AlarmConstants.minDrinkDurationSeconds;
    final progress = (totalDuration - _remainingSeconds) / totalDuration;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7ED),
        body: Stack(
          children: [
            // Ambient warm gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF7ED),
                      Color(0xFFFFEDD5),
                      Color(0xFFFED7AA),
                    ],
                  ),
                ),
              ),
            ),

            // Background floating warning & water droplets
            ...List.generate(6, (index) {
              final random = math.Random(index + 77);
              final left = random.nextDouble() * 300 + 20;
              final top = random.nextDouble() * 550 + 80;
              final size = random.nextDouble() * 36 + 18;
              return Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: 0.12,
                  child: Text(
                    index.isEven ? '💧' : '⏳',
                    style: TextStyle(fontSize: size),
                  ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF97316).withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('⚠️ ', style: TextStyle(fontSize: 14)),
                                  Text(
                                    'HIZLI ONAY KORUMASI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFC2410C),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Pulsing Hourglass + Water Glass Icon
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF97316).withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isCountdownFinished ? '💧🥤' : '⏳💧',
                                    style: const TextStyle(fontSize: 42),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Main Title
                            const Text(
                              AlarmConstants.cheatWarningTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7C2D12),
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Prominent Alert Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    AlarmConstants.cheatWarningMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF9A3412),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      AlarmConstants.cheatWarningAction,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Explanation Subtext
                            Text(
                              AlarmConstants.cheatWarningExplanation,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF9A3412).withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Countdown Progress Bar & Indicator
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isCountdownFinished
                                              ? 'Su içme süresi tamamlandı ✅'
                                              : 'Lütfen suyunuzu yudumlayın... 🥤',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isCountdownFinished
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFFC2410C),
                                          ),
                                        ),
                                      ),
                                      if (!isCountdownFinished)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEA580C),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$_remainingSeconds sn',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: isCountdownFinished ? 1.0 : progress,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFFED7AA),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCountdownFinished
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Actions
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: isCountdownFinished
                                        ? () {
                                            widget.onConfirmed();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0284C7),
                                      disabledBackgroundColor:
                                          Colors.blueGrey.shade200,
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor:
                                          Colors.blueGrey.shade600,
                                      elevation: isCountdownFinished ? 4 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isCountdownFinished
                                              ? Icons.check_circle_rounded
                                              : Icons.hourglass_top_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            isCountdownFinished
                                              ? 'Şimdi Suyumu İçtim (+250 ml)'
                                              : 'Suyunuzu Yudumlayın ($_remainingSeconds sn)',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: widget.onReturn,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF9A3412),
                                  ),
                                  child: const Text(
                                    'Alarm Ekranına Dön',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
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
