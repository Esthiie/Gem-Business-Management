import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// UI-15 Settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editText(BuildContext context, String title, String current,
      ValueChanged<String> onSave) async {
    final c = TextEditingController(text: current);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) onSave(v);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const AppHeader(
                title: 'Settings', backLabel: 'Back', onSettingsPage: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                CardBox(
                  child: Row(children: [
                    const LogoAvatar(size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.shopName, style: AppText.heading(18)),
                        Text('Owner · ${s.nickname}',
                            style: AppText.body(13, color: AppColors.muted)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 18),
                const SectionLabel('Shop profile'),
                const SizedBox(height: 8),
                _Group(children: [
                  _Row(
                      title: 'Logo',
                      value: 'Change',
                      onTap: () => showToast(
                          context, 'Logo upload comes with the backend step.')),
                  _Row(
                      title: 'Shop name',
                      value: s.shopName,
                      onTap: () => _editText(context, 'Shop name', s.shopName,
                          (v) => s.updateProfile(shop: v))),
                  _Row(
                      title: 'Nickname',
                      value: s.nickname,
                      onTap: () => _editText(context, 'Nickname', s.nickname,
                          (v) => s.updateProfile(nick: v))),
                ]),
                const SizedBox(height: 18),
                const SectionLabel('Security'),
                const SizedBox(height: 8),
                _Group(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: SwitchRow(
                        title: 'Unlock with Face ID',
                        value: s.faceId,
                        onChanged: s.setFaceId),
                  ),
                  _Row(
                      title: 'Change password',
                      onTap: () => showToast(
                          context, 'A reset link will be sent to ${s.email}.')),
                ]),
                const SizedBox(height: 18),
                const SectionLabel('Data'),
                const SizedBox(height: 8),
                _Group(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: SwitchRow(
                      title: 'Online (demo)',
                      subtitle: s.online
                          ? 'Synced ${s.lastSynced}'
                          : 'Offline · ${s.pendingSync} changes saved on this phone',
                      value: s.online,
                      onChanged: s.setOnline,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                SecondaryButton('Log out',
                    icon: Icons.logout_rounded,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, Routes.login, (_) => false)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardBox(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.line),
          children[i],
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, this.value, required this.onTap});
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(children: [
          Expanded(child: Text(title, style: AppText.body(15, weight: FontWeight.w600))),
          if (value != null)
            Text(value!, style: AppText.body(14, color: AppColors.muted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ]),
      ),
    );
  }
}
