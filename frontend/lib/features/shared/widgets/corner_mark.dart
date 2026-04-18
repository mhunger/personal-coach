import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// The signature detail: a small oxblood L-shape in the upper-right of every
/// card, like a magazine crop mark. 8×8 by default, reading as a subtle
/// editorial stamp.
class CornerMark extends StatelessWidget {
  final double size;
  final double thickness;
  final Color color;

  const CornerMark({
    super.key,
    this.size = 8,
    this.thickness = 1.2,
    this.color = AppColors.oxblood,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerMarkPainter(color: color, thickness: thickness),
    );
  }
}

class _CornerMarkPainter extends CustomPainter {
  final Color color;
  final double thickness;

  const _CornerMarkPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    // Horizontal arm (along the top edge).
    canvas.drawLine(Offset(0, thickness / 2), Offset(size.width, thickness / 2), paint);
    // Vertical arm (down the right edge).
    canvas.drawLine(
      Offset(size.width - thickness / 2, 0),
      Offset(size.width - thickness / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerMarkPainter old) =>
      old.color != color || old.thickness != thickness;
}
