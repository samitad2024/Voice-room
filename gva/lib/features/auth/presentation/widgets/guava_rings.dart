import 'package:flutter/material.dart';

import '../../../../../core/config/app_colors.dart';

class GuavaRings extends StatelessWidget {
  const GuavaRings({super.key, required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(diameter),
      painter: _GuavaRingsPainter(),
    );
  }
}

class _GuavaRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    // From outside -> inside.
    final rings = <_RingSpec>[
      _RingSpec(color: AppColors.ringsGreenSoft, thickness: radius * 0.10),
      _RingSpec(color: AppColors.creamBackground, thickness: radius * 0.02),
      _RingSpec(color: AppColors.ringsPinkOuter, thickness: radius * 0.12),
      _RingSpec(color: AppColors.ringsPinkMid, thickness: radius * 0.15),
      _RingSpec(color: AppColors.ringsPinkInner, thickness: radius * 0.18),
    ];

    var currentRadius = radius;
    for (final ring in rings) {
      final paint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, currentRadius - ring.thickness / 2, paint);
      currentRadius -= ring.thickness;
    }

    final corePaint = Paint()..color = AppColors.ringsRedCore;
    canvas.drawCircle(center, currentRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingSpec {
  const _RingSpec({required this.color, required this.thickness});

  final Color color;
  final double thickness;
}
