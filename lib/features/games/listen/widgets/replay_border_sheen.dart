import 'package:flutter/material.dart';

class ReplayBorderSheen extends CustomPainter {
  const ReplayBorderSheen({
    required this.progress,
    required this.borderRadius,
    required this.color,
  });

  final double progress;
  final double borderRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final length = metric.length;

    final segmentLength = length * 0.20;
    final start = (length + progress * length) % length;
    final end = start + segmentLength;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (end <= length) {
      canvas.drawPath(metric.extractPath(start, end), paint);
    } else {
      canvas.drawPath(metric.extractPath(start, length), paint);
      canvas.drawPath(metric.extractPath(0, end - length), paint);
    }
  }

  @override
  bool shouldRepaint(ReplayBorderSheen oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.color != color;
  }
}
