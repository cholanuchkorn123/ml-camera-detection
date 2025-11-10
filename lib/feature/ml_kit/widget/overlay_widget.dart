


import 'package:flutter/material.dart';

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final background = Path()..addRect(rect);
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: size.width * 0.7,
      height: size.height * 0.4,
    );
    final cutout = Path()..addOval(ovalRect);
    final overlay = Path.combine(
      PathOperation.difference,
      background,
      cutout,
    );

    canvas.drawPath(overlay, paint);
    final dashedPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final dashedPath = Path();
    final pathMetrics = cutout.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 12.0;
      const gapLength = 8.0;

      while (distance < metric.length) {
        final next = distance + dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + gapLength;
      }
    }

    canvas.drawPath(dashedPath, dashedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
