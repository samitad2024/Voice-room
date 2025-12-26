import 'package:flutter/material.dart';

import '../../../../../core/config/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (i) => Container(
          width: 7,
          height: 7,
          margin: EdgeInsets.only(right: i == count - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: i == index ? AppColors.dotActive : AppColors.dotInactive,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
