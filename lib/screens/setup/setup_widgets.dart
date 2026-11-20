import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// "Step n of 3" progress bar at the top of the setup screens.
class SetupProgress extends StatelessWidget {
  const SetupProgress({super.key, required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (var i = 1; i <= 3; i++) ...[
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.ink : AppColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 6),
        ],
      ]),
      const SizedBox(height: 10),
      Text('Step $step of 3 · First-time setup',
          style: AppText.body(12, color: AppColors.muted, weight: FontWeight.w700)),
    ]);
  }
}
