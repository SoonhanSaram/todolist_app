import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressBar extends CustomPainter {
  final BuildContext context;
  final int totalSlices; // 전체 조각의 개수
  final int drawSlices; // 그리고자 하는 조각의 개수

  ProgressBar({
    required this.context,
    this.totalSlices = 0,
    this.drawSlices = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double ratio = drawSlices / totalSlices;
    final paint = Paint()..color = Colors.orangeAccent.withOpacity(ratio);

    const center = Offset(0, 0);

    final sliceAngle = 360 / totalSlices;

    const radius = 18.0; // 원의 반지름
    const startAngle = -math.pi / 2; // -90도 (12시 방향에서 시작)

    for (int i = 0; i < drawSlices; i++) {
      final startRadian = startAngle + i * sliceAngle * (math.pi / 180);
      final endRadian = startAngle + (i + 1) * sliceAngle * (math.pi / 180);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startRadian, endRadian - startRadian, true, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
