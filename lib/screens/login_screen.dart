import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// UI-02: owner log in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  final _pass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: context.read<AppState>().email);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() {
    // Step 2: FirebaseAuth.instance.signInWithEmailAndPassword(...)
    final s = context.read<AppState>();
    s.goToTab(0);
    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            children: [
              const Center(child: LogoAvatar(size: 100, full: true)),
              const SizedBox(height: 12),
              Text('Welcome back, ${s.nickname}',
                  textAlign: TextAlign.center, style: AppText.heading(28)),
              const SizedBox(height: 4),
              Text(s.shopName,
                  textAlign: TextAlign.center,
                  style: AppText.body(14, color: AppColors.muted)),
              const SizedBox(height: 32),
              LabeledField(label: 'Email', controller: _email),
              const SizedBox(height: 16),
              LabeledField(
                  label: 'Password',
                  controller: _pass,
                  hint: 'Enter your password',
                  obscure: true),
              const SizedBox(height: 20),
              PrimaryButton('Log in', onPressed: _login),
              if (s.faceId) ...[
                const SizedBox(height: 10),
                SecondaryButton('Use Face ID',
                    icon: Icons.face_retouching_natural_outlined,
                    onPressed: _login),
              ],
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => showToast(
                      context, 'A reset link will be sent to your email.'),
                  child: Text('Forgot password?',
                      style: AppText.body(14, weight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Owner account only.',
                  textAlign: TextAlign.center,
                  style: AppText.body(12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
