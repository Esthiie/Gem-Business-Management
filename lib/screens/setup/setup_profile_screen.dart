import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'setup_widgets.dart';

/// UI-01 step 2: logo, shop name and nickname, with a live preview.
class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late final TextEditingController _shop;
  late final TextEditingController _nick;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _shop = TextEditingController(text: s.shopName);
    _nick = TextEditingController(text: s.nickname);
  }

  @override
  void dispose() {
    _shop.dispose();
    _nick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = _shop.text.trim().isEmpty ? 'Your shop' : _shop.text.trim();
    final nick = _nick.text.trim().isEmpty ? 'there' : _nick.text.trim();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SetupProgress(step: 2),
            const SizedBox(height: 28),
            Text('Make it yours', style: AppText.heading(28)),
            const SizedBox(height: 6),
            Text('Your logo and name show across the app.',
                style: AppText.body(15, color: AppColors.muted)),
            const SizedBox(height: 20),
            Row(children: [
              const LogoAvatar(size: 64),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 40,
                  child: SecondaryButton('Upload logo',
                      height: 40,
                      icon: Icons.photo_outlined,
                      // Step 2: image_picker + Firebase Storage.
                      onPressed: () => showToast(
                          context, 'Photo upload comes with the backend step.')),
                ),
                const SizedBox(height: 4),
                Text('Square image works best',
                    style: AppText.body(12, color: AppColors.muted)),
              ]),
            ]),
            const SizedBox(height: 20),
            LabeledField(
                label: 'Shop name',
                controller: _shop,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            LabeledField(
                label: 'What should the app call you?',
                controller: _nick,
                hint: 'Your nickname',
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 20),
            SectionLabel('Preview of your home screen'),
            const SizedBox(height: 8),
            CardBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const LogoAvatar(size: 26),
                  const SizedBox(width: 8),
                  Text(shop, style: AppText.heading(15)),
                ]),
                const SizedBox(height: 10),
                Text('Hi, $nick', style: AppText.heading(24)),
              ]),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: SecondaryButton('Back',
                      onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PrimaryButton('Save and continue', onPressed: () {
                  context
                      .read<AppState>()
                      .updateProfile(shop: shop, nick: _nick.text.trim());
                  Navigator.pushNamed(context, Routes.setupDone);
                }),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
