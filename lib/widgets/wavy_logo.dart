import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/shifer_theme.dart';

/// Corrugated wavy slate — visual pun on «шифер».
class WavyShiferLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const WavyShiferLogo({
    super.key,
    this.size = 88,
    this.animate = true,
  });

  @override
  State<WavyShiferLogo> createState() => _WavyShiferLogoState();
}

class _WavyShiferLogoState extends State<WavyShiferLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SlatePainter(phase: _controller.value * math.pi * 2),
          );
        },
      ),
    );
  }
}

class _SlatePainter extends CustomPainter {
  final double phase;

  _SlatePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.22),
    );
    canvas.clipRRect(r);

    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF15233A),
          Color(0xFF0B1526),
          Color(0xFF102A28),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    // Corrugated ridges
    final ridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 7; i++) {
      final t = i / 6;
      final path = Path();
      final yBase = size.height * (0.18 + t * 0.64);
      path.moveTo(-4, yBase);
      for (var x = 0.0; x <= size.width + 4; x += 2) {
        final wave = math.sin(x / size.width * math.pi * 3 + phase + i * 0.35) *
            size.height *
            0.035;
        path.lineTo(x, yBase + wave);
      }
      ridgePaint.shader = LinearGradient(
        colors: [
          Color.lerp(ShiferTheme.primaryDim, ShiferTheme.accent, t)!
              .withValues(alpha: 0.35 + t * 0.45),
          ShiferTheme.primary.withValues(alpha: 0.85),
        ],
      ).createShader(Offset.zero & size);
      canvas.drawPath(path, ridgePaint);
    }

    // Soft sheen
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(r, sheen);

    // Border glow
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ShiferTheme.primary.withValues(alpha: 0.55);
    canvas.drawRRect(r.deflate(0.7), border);
  }

  @override
  bool shouldRepaint(covariant _SlatePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
