import 'package:flutter/material.dart';

import '../../../../../core/config/app_colors.dart';

class TrackingHeroBadge extends StatelessWidget {
  const TrackingHeroBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(270),
      painter: _TrackingHeroPainter(),
    );
  }
}

class AvocadoHeroIcon extends StatelessWidget {
  const AvocadoHeroIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(240),
      painter: _AvocadoPainter(),
    );
  }
}

class JournalingHeroIcon extends StatelessWidget {
  const JournalingHeroIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(240),
      painter: _JournalPainter(),
    );
  }
}

class _TrackingHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()..color = const Color(0xFFF8F6F5);
    canvas.drawCircle(center, radius, bgPaint);

    // Outer soft ring.
    final ringPaint = Paint()
      ..color = const Color(0xFFE0D2CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Dashed arc segments.
    final dashPaint = Paint()
      ..color = const Color(0xFFE0D2CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const dashCount = 18;
    final arcRect = Rect.fromCircle(center: center, radius: radius - 2);
    for (var i = 0; i < dashCount; i++) {
      final start = (i * (2 * 3.1415926535 / dashCount)) + 0.08;
      canvas.drawArc(arcRect, start, 0.12, false, dashPaint);
    }

    // Top text.
    final luteal = TextPainter(
      text: const TextSpan(
        text: 'Luteal Phase',
        style: TextStyle(
          color: Color(0xFFBFAFAA),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final day = TextPainter(
      text: const TextSpan(
        text: 'Day 15',
        style: TextStyle(
          color: Color(0xFFE0D2CB),
          fontSize: 44,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    luteal.paint(canvas, Offset(center.dx - luteal.width / 2, center.dy - 65));
    day.paint(canvas, Offset(center.dx - day.width / 2, center.dy - 40));

    // Bottom half fill.
    final bottomPaint = Paint()..color = const Color(0xFFE39CA3);
    final bottomRect = Rect.fromCircle(center: center, radius: radius - 58);
    canvas.drawArc(bottomRect, 0, 3.1415926535, true, bottomPaint);

    // Face lines.
    final facePaint = Paint()
      ..color = const Color(0xFF8A4D50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Eyes.
    canvas.drawLine(
      Offset(center.dx - 30, center.dy + 18),
      Offset(center.dx - 18, center.dy + 10),
      facePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 18, center.dy + 18),
      Offset(center.dx - 30, center.dy + 10),
      facePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 30, center.dy + 18),
      Offset(center.dx + 18, center.dy + 10),
      facePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 18, center.dy + 18),
      Offset(center.dx + 30, center.dy + 10),
      facePaint,
    );

    // Mouth.
    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 36),
      width: 62,
      height: 34,
    );
    canvas.drawArc(mouthRect, 0, 3.1415926535, false, facePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AvocadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Stylized avocado outline; meant as a placeholder until you provide the exact SVG/PNG.
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final outline = Paint()
      ..color = const Color(0xFF6E8150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(center.dx, h * 0.08);
    path.cubicTo(w * 0.78, h * 0.10, w * 0.92, h * 0.55, center.dx, h * 0.93);
    path.cubicTo(w * 0.08, h * 0.55, w * 0.22, h * 0.10, center.dx, h * 0.08);
    canvas.drawPath(path, outline);

    final seedOutline = Paint()
      ..color = const Color(0xFF6E8150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final seedPath = Path();
    seedPath.moveTo(center.dx, h * 0.30);
    seedPath.cubicTo(
      w * 0.60,
      h * 0.38,
      w * 0.60,
      h * 0.66,
      center.dx,
      h * 0.76,
    );
    seedPath.cubicTo(
      w * 0.40,
      h * 0.66,
      w * 0.40,
      h * 0.38,
      center.dx,
      h * 0.30,
    );
    canvas.drawPath(seedPath, seedOutline);

    // Inner fills.
    final outerFill = Paint()..color = const Color(0xFFCFEAA7);
    final innerFill = Paint()..color = const Color(0xFFF4B9B8);
    final coreFill = Paint()..color = const Color(0xFFF1464B);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, outerFill);

    final innerPath = Path();
    innerPath.moveTo(center.dx, h * 0.16);
    innerPath.cubicTo(
      w * 0.72,
      h * 0.18,
      w * 0.84,
      h * 0.55,
      center.dx,
      h * 0.87,
    );
    innerPath.cubicTo(
      w * 0.16,
      h * 0.55,
      w * 0.28,
      h * 0.18,
      center.dx,
      h * 0.16,
    );
    canvas.drawPath(innerPath, innerFill);

    final corePath = Path();
    corePath.moveTo(center.dx, h * 0.28);
    corePath.cubicTo(
      w * 0.58,
      h * 0.36,
      w * 0.58,
      h * 0.64,
      center.dx,
      h * 0.72,
    );
    corePath.cubicTo(
      w * 0.42,
      h * 0.64,
      w * 0.42,
      h * 0.36,
      center.dx,
      h * 0.28,
    );
    canvas.drawPath(corePath, coreFill);

    canvas.restore();

    // Stem.
    final stem = Paint()
      ..color = const Color(0xFF6E8150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, h * 0.06),
      Offset(center.dx, h * 0.02),
      stem,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JournalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final border = Paint()
      ..color = const Color(0xFF6E8150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.18, w * 0.72, h * 0.64),
      const Radius.circular(20),
    );

    final fill = Paint()..color = const Color(0xFFF8F6F5);
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, border);

    final line = Paint()
      ..color = const Color(0xFF6E8150)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Lines.
    final left = w * 0.24;
    final right = w * 0.62;
    for (var i = 0; i < 4; i++) {
      final y = h * (0.30 + i * 0.10);
      canvas.drawLine(Offset(left, y), Offset(right, y), line);
    }

    // Pencil.
    final pencilRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.66, h * 0.28, w * 0.10, h * 0.38),
      const Radius.circular(12),
    );

    final pencilBorder = Paint()
      ..color = const Color(0xFF6E8150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final pencilTop = Paint()..color = const Color(0xFFF4B9B8);
    final pencilBottom = Paint()..color = AppColors.dotActive;

    canvas.save();
    canvas.clipRRect(pencilRect);
    canvas.drawRect(
      Rect.fromLTWH(
        pencilRect.left,
        pencilRect.top,
        pencilRect.width,
        pencilRect.height / 2,
      ),
      pencilTop,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        pencilRect.left,
        pencilRect.top + pencilRect.height / 2,
        pencilRect.width,
        pencilRect.height / 2,
      ),
      pencilBottom,
    );
    canvas.restore();
    canvas.drawRRect(pencilRect, pencilBorder);

    // Pencil tip.
    final tip = Path();
    tip.moveTo(pencilRect.left, pencilRect.bottom);
    tip.lineTo(pencilRect.right, pencilRect.bottom);
    tip.lineTo(
      pencilRect.left + pencilRect.width / 2,
      pencilRect.bottom + h * 0.08,
    );
    tip.close();

    final tipFill = Paint()..color = const Color(0xFFD9D2CD);
    canvas.drawPath(tip, tipFill);
    canvas.drawPath(tip, pencilBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
