import 'dart:math';

import 'package:flutter/material.dart';

import 'colors.dart';

/// Subtle paper-grain overlay. Renders a deterministic field of faint dots,
/// layered over the cream background at low opacity so it never competes
/// with content but gives the surface a tactile weight.
class PaperGrain extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double density;

  const PaperGrain({
    super.key,
    required this.child,
    this.opacity = 0.035,
    this.density = 0.0012,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.paper, child: child)),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GrainPainter(opacity: opacity, density: density),
            ),
          ),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  final double density;

  const _GrainPainter({required this.opacity, required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    // Deterministic seed so the grain doesn't jitter across rebuilds.
    final rand = Random(42);
    final paint = Paint()
      ..color = AppColors.ink.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final count = (size.width * size.height * density).round();
    for (var i = 0; i < count; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 0.7 + 0.1;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) =>
      old.opacity != opacity || old.density != density;
}
