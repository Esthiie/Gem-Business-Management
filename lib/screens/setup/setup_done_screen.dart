import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'setup_widgets.dart';

/// UI-01 step 3: setup finished.
class SetupDoneScreen extends StatelessWidget {
  const SetupDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SetupProgress(step: 3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                        color: AppColors.purpleSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        size: 44, color: AppColors.purple),
                  ),
                  const SizedBox(height: 16),
                  Text('You’re all set, ${s.nickname}',
                      textAlign: TextAlign.center,
                      style: AppText.heading(28)),
                  const SizedBox(height: 8),
                  Text('${s.shopName} is ready.',
                      style: AppText.body(15, color: AppColors.muted)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton('Go to Home', onPressed: () {
                s.goToTab(0);
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.home, (_) => false);
              }),
            ),
          ]),
        ),
      ),
    );
  }
}
