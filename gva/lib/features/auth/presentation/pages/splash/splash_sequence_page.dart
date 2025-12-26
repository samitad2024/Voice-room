import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_colors.dart';
import '../../widgets/guava_rings.dart';

class SplashSequencePage extends StatefulWidget {
  const SplashSequencePage({super.key});

  @override
  State<SplashSequencePage> createState() => _SplashSequencePageState();
}

class _SplashSequencePageState extends State<SplashSequencePage> {
  static const _firstDuration = Duration(milliseconds: 900);
  static const _secondDuration = Duration(milliseconds: 650);

  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer(_firstDuration, () {
      if (!mounted) return;
      setState(() => _step = 1);
      _timer = Timer(_secondDuration, () {
        if (!mounted) return;
        context.go('/onboarding');
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0
            ? const _SplashOne(key: ValueKey(0))
            : const _SplashTwo(key: ValueKey(1)),
      ),
    );
  }
}

class _SplashOne extends StatelessWidget {
  const _SplashOne({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            GuavaRings(diameter: 190),
            SizedBox(height: 26),
            Text(
              'Guava',
              style: TextStyle(
                fontSize: 28,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: AppColors.brandWordmark,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashTwo extends StatelessWidget {
  const _SplashTwo({super.key});

  @override
  Widget build(BuildContext context) {
    // Oversized rings that extend beyond the screen edges.
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = (constraints.biggest.shortestSide) * 2.1;

        return Center(
          child: OverflowBox(
            maxWidth: diameter,
            maxHeight: diameter,
            child: GuavaRings(diameter: diameter),
          ),
        );
      },
    );
  }
}
