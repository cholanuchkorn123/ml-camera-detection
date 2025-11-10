import 'package:flutter/material.dart';

class ThaiIDCardOverlayPainter extends CustomPainter {
  final Rect frameRect;
  final bool isGood;
   ThaiIDCardOverlayPainter({required this.frameRect, this.isGood = false});
  @override
  void paint(Canvas canvas, Size size) {
       final paint = Paint()
      ..color = isGood ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final frameWidth = size.width * 0.95; 
    final frameHeight = size.height * 0.30;

    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;
    final rect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

    canvas.drawRect(rect, paint);

    final photoRect = Rect.fromLTWH(left +35 , top + 95, 60, 50);
    final photoRRect = RRect.fromRectAndRadius(photoRect, Radius.circular(10));
    canvas.drawRRect(photoRRect, paint);

    final logoRect = Rect.fromLTWH(left +10, top + 15, 50, 50);
    canvas.drawOval(logoRect, paint);

    final barcodeRect = Rect.fromLTWH(
     frameWidth - 75,
      top + frameHeight - 105,
      75,
      90,
    );
    canvas.drawRect(barcodeRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
