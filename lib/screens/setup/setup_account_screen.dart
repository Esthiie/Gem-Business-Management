import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'setup_widgets.dart';

/// UI-01 step 1: create the single owner account.
class SetupAccountScreen extends StatefulWidget {
  const SetupAccountScreen({super.key});

  @override
  State<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends State<SetupAccountScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _next() {
    // Step 2: FirebaseAuth.instance.createUserWithEmailAndPassword(...)
    final e = _email.text.trim();
    if (!e.contains('@')) {
      setState(() => _error = 'Enter a valid email.');
    } else if (_pass.text.length < 8) {
      setState(() => _error = 'Password needs at least 8 characters.');
    } else if (_pass.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
    } else {
      setState(() => _error = null);
      Navigator.pushNamed(context, Routes.setupProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const SetupProgress(step: 1),
            const SizedBox(height: 28),
            Text('Let’s set up your shop', style: AppText.heading(28)),
            const SizedBox(height: 6),
            Text('Create the owner account. You only do this once.',
                style: AppText.body(15, color: AppColors.muted)),
            const SizedBox(height: 24),
            LabeledField(
                label: 'Email', controller: _email, hint: 'you@example.com'),
            const SizedBox(height: 14),
            LabeledField(
                label: 'Password',
                controller: _pass,
                hint: 'At least 8 characters',
                obscure: true),
            const SizedBox(height: 14),
            LabeledField(
                label: 'Confirm password',
                controller: _confirm,
                hint: 'Type it again',
                obscure: true),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lavenderTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lock_outline_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is the only account for the app. Sign-up turns off after this, so nobody else can join.',
                    style: AppText.body(13).copyWith(height: 1.4),
                  ),
                ),
              ]),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppText.body(13,
                      color: AppColors.red, weight: FontWeight.w600)),
            ],
            const SizedBox(height: 24),
            PrimaryButton('Next', onPressed: _next),
          ],
        ),
      ),
    );
  }
}
