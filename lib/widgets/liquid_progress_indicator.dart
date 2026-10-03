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
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF0F9FF),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipPath(
            clipper: _CircleClipper(),
            child: CustomPaint(
              painter: _LiquidPainter(
                progress: widget.progress,
                animationValue: _animationController.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _LiquidPainter({
    required this.progress,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.blue.shade300.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = Colors.blue.shade400.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Fluid height based on progress (capped at 100% height, but can flow up to top)
    final clampedProgress = progress.clamp(0.0, 1.0);
    final waterHeight = size.height * (1.0 - clampedProgress);

    // First wave (Back wave)
    final path1 = Path();
    path1.moveTo(0, waterHeight);
    for (double i = 0.0; i <= size.width; i++) {
      final angle = (i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi);
      final y = waterHeight + math.sin(angle) * 8; // Amplitude 8
      path1.lineTo(i, y);
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave (Front wave - offset phase and amplitude for 3D effect)
    final path2 = Path();
    path2.moveTo(0, waterHeight);
    for (double i = 0.0; i <= size.width; i++) {
      final angle = (i / size.width * 2 * math.pi) - (animationValue * 2 * math.pi) + math.pi / 2;
      final y = waterHeight + math.sin(angle) * 6; // Amplitude 6
      path2.lineTo(i, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Draw percentage text inside the bubble
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: progress > 0.45 ? Colors.white : Colors.blue.shade800,
          fontSize: (size.width * 0.18).clamp(20.0, 44.0),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: const Offset(1, 1),
              blurRadius: 2,
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
        oldDelegate.animationValue != animationValue;
  }
}
