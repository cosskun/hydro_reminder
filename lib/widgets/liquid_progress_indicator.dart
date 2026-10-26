import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0+
  final double size;

  const LiquidProgressIndicator({
    super.key,
    required this.progress,
    this.size = 200,
  });

  @override
  State<LiquidProgressIndicator> createState() => _LiquidProgressIndicatorState();
}

class _LiquidProgressIndicatorState extends State<LiquidProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: widget.progress),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, smoothProgress, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.65 : 0.45),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: _CircleClipper(),
                child: CustomPaint(
                  painter: _LiquidPainter(
                    progress: smoothProgress,
                    animationValue: _animationController.value,
                    isDark: isDark,
                    primaryColor: theme.colorScheme.primary,
                    secondaryColor: theme.colorScheme.secondary,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BubbleSeed {
  final double xFactor;
  final double radius;
  final double speedFactor;
  final double phase;

  const _BubbleSeed(this.xFactor, this.radius, this.speedFactor, this.phase);
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  static const List<_BubbleSeed> _bubbles = [
    _BubbleSeed(0.20, 3.2, 1.2, 0.1),
    _BubbleSeed(0.35, 4.0, 0.9, 0.4),
    _BubbleSeed(0.50, 2.5, 1.4, 0.7),
    _BubbleSeed(0.65, 3.8, 1.1, 0.2),
    _BubbleSeed(0.80, 2.8, 1.3, 0.8),
    _BubbleSeed(0.42, 2.0, 1.5, 0.55),
    _BubbleSeed(0.58, 4.5, 0.8, 0.35),
  ];

  _LiquidPainter({
    required this.progress,
    required this.animationValue,
    this.isDark = false,
    this.primaryColor = const Color(0xFF0288D1),
    this.secondaryColor = const Color(0xFF38BDF8),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final waterHeight = size.height * (1.0 - clampedProgress);

    // 1. Back Wave (Translucent Deep Fluid)
    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryColor.withValues(alpha: isDark ? 0.65 : 0.6),
          primaryColor.withValues(alpha: isDark ? 0.85 : 0.75),
        ],
      ).createShader(Rect.fromLTWH(0, waterHeight, size.width, size.height - waterHeight))
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, waterHeight);
    for (double i = 0.0; i <= size.width; i += 2.0) {
      final angle = (i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi);
      final y = waterHeight + math.sin(angle) * 7.5;
      path1.lineTo(i, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, backPaint);

    // 2. Rising Animated Micro-Air Bubbles (Only drawn inside fluid)
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    if (clampedProgress > 0.05) {
      final fluidDepth = size.height - waterHeight;
      for (final b in _bubbles) {
        final bx = size.width * b.xFactor + math.sin(animationValue * 2 * math.pi + b.phase) * 3.0;
        final cycleProgress = ((animationValue * b.speedFactor) + b.phase) % 1.0;
        final by = size.height - (fluidDepth * cycleProgress);

        if (by >= waterHeight && by <= size.height) {
          canvas.drawCircle(Offset(bx, by), b.radius, bubblePaint);
        }
      }
    }

    // 3. Front Wave (Vibrant Theme Waves)
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryColor,
          primaryColor,
        ],
      ).createShader(Rect.fromLTWH(0, waterHeight, size.width, size.height - waterHeight))
      ..style = PaintingStyle.fill;

    final path2 = Path();
    final crestPath = Path();
    path2.moveTo(0, waterHeight);
    crestPath.moveTo(0, waterHeight);

    for (double i = 0.0; i <= size.width; i += 2.0) {
      final angle = (i / size.width * 2 * math.pi) - (animationValue * 2 * math.pi) + math.pi / 2;
      final y = waterHeight + math.sin(angle) * 6.0;
      path2.lineTo(i, y);
      crestPath.lineTo(i, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, frontPaint);

    // 4. Wave Crest Foam Highlight (Subtle glowing 1.8px froth line)
    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(crestPath, crestPaint);

    // 5. Center Hydration Percentage Typography
    final percentInt = (progress * 100).toInt();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '%$percentInt',
        style: TextStyle(
          color: progress > 0.42
              ? Colors.white
              : primaryColor,
          fontSize: (size.width * 0.20).clamp(24.0, 50.0),
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.28),
              offset: const Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
