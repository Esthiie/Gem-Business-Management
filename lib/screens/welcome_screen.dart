import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// First screen the owner sees on a new phone.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoAvatar(size: 132),
                  const SizedBox(height: 20),
                  Text('Welcome', style: AppText.heading(30)),
                  const SizedBox(height: 8),
                  Text(
                    'Everything for Queens.Trinket in one place, at home and at the booth.',
                    textAlign: TextAlign.center,
                    style: AppText.body(15, color: AppColors.muted)
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton('Get started',
                  height: 54,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.setupAccount)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.login),
              child: Text.rich(TextSpan(
                text: 'Already set up? ',
                style: AppText.body(14,
                    color: AppColors.muted, weight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: 'Log in',
                    style: AppText.body(14, weight: FontWeight.w600)
                        .copyWith(decoration: TextDecoration.underline),
                  ),
                ],
              )),
            ),
          ]),
        ),
      ),
    );
  }
}
