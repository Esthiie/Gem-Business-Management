import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// "Synced" (purple) or "Offline · n to sync" (orange).
class SyncPill extends StatelessWidget {
  const SyncPill({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final online = s.online;
    final fg = online ? AppColors.purple : AppColors.orangeText;
    final bg = online ? AppColors.purpleSoft : AppColors.orangeSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(online ? Icons.cloud_done_outlined : Icons.wifi_off_rounded,
            size: 15, color: fg),
        const SizedBox(width: 6),
        Text(
          online
              ? 'Synced'
              : (s.pendingSync > 0 ? 'Offline · ${s.pendingSync} to sync' : 'Offline'),
          style: AppText.body(12, color: fg, weight: FontWeight.w600),
        ),
      ]),
    );
  }
}

/// Round lavender icon button (settings gear in the header).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.dark = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: dark ? AppColors.ink : AppColors.lavenderTint,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon,
                size: 20, color: dark ? AppColors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Top of every screen: shop logo (tab pages) or a back link (sub pages),
/// the sync pill and the settings button, then the page title.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.backLabel,
    this.titleTrailing,
    this.onSettingsPage = false,
  });

  final String title;
  final String? subtitle;
  final String? backLabel; // null = show logo + shop name
  final Widget? titleTrailing;
  final bool onSettingsPage;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (backLabel == null)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.pushNamed(context, Routes.settings),
              child: Row(children: [
                const LogoAvatar(size: 30),
                const SizedBox(width: 8),
                Text(s.shopName, style: AppText.heading(16)),
              ]),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.maybePop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  const Icon(Icons.chevron_left_rounded, size: 22),
                  Text(backLabel!,
                      style: AppText.body(14, weight: FontWeight.w600)),
                ]),
              ),
            ),
          const Spacer(),
          const SyncPill(),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            dark: onSettingsPage,
            onTap: onSettingsPage
                ? null
                : () => Navigator.pushNamed(context, Routes.settings),
          ),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.heading(28)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: AppText.body(14, color: AppColors.muted)),
              ],
            ]),
          ),
          if (titleTrailing != null) titleTrailing!,
        ]),
      ]),
    );
  }
}

/// Faith's crown logo in a black circle.
class LogoAvatar extends StatelessWidget {
  const LogoAvatar({super.key, this.size = 30, this.full = false});
  final double size;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.ink,
        child: Image.asset(
          full ? 'assets/images/logo_full.png' : 'assets/images/logo_crown.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// White rounded card with a thin grey border.
class CardBox extends StatelessWidget {
  const CardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor = AppColors.line,
    this.color = AppColors.white,
    this.radius = 18,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: box),
    );
  }
}

/// Small rounded label, e.g. "New", "2 left", "Overdue".
class Pill extends StatelessWidget {
  const Pill(this.text,
      {super.key,
      required this.fg,
      required this.bg,
      this.radius = 999,
      this.fontSize = 11});

  final String text;
  final Color fg;
  final Color bg;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(radius)),
      child: Text(text,
          style: AppText.body(fontSize, color: fg, weight: FontWeight.w700)),
    );
  }
}

/// Colours for custom order status: New purple, In progress orange, Done green.
class StatusColours {
  const StatusColours(this.fg, this.bg, this.accent);
  final Color fg;
  final Color bg;
  final Color accent;

  static StatusColours of(String status) {
    switch (status) {
      case 'New':
        return const StatusColours(
            AppColors.purple, AppColors.lavenderTint, AppColors.purpleDot);
      case 'Done':
        return const StatusColours(
            AppColors.greenText, AppColors.greenSoft, AppColors.green);
      default:
        return const StatusColours(
            AppColors.orangeText, AppColors.orangeSoft, AppColors.orange);
    }
  }
}

/// Horizontal row of black/white choice chips.
class ChoiceChips extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scroll = true,
    this.padding = EdgeInsets.zero,
  });

  final List<String> options;
  final bool Function(String) selected;
  final ValueChanged<String> onSelected;
  final bool scroll;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final o in options)
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: SmallChip(
              label: o, on: selected(o), onTap: () => onSelected(o)),
        ),
    ];
    if (!scroll) {
      return Padding(padding: padding, child: Wrap(children: chips));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(children: chips),
    );
  }
}

class SmallChip extends StatelessWidget {
  const SmallChip(
      {super.key, required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? AppColors.ink : AppColors.white,
      shape: StadiumBorder(
          side: BorderSide(color: on ? AppColors.ink : AppColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(label,
              style: AppText.body(13,
                  color: on ? AppColors.white : AppColors.ink,
                  weight: on ? FontWeight.w600 : FontWeight.w500)),
        ),
      ),
    );
  }
}

/// Lavender segmented control (Collection / Materials, etc.).
class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.lavenderTint,
          borderRadius: BorderRadius.circular(13)),
      child: Row(children: [
        for (var i = 0; i < options.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == index ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: i == index
                      ? const [
                          BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 3,
                              offset: Offset(0, 1))
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(options[i],
                      style: AppText.body(14,
                          color: i == index ? AppColors.ink : AppColors.muted,
                          weight:
                              i == index ? FontWeight.w700 : FontWeight.w600)),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Black main button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label,
      {super.key, required this.onPressed, this.icon, this.height = 52});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.line,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.body(16, weight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label),
        ]),
      ),
    );
  }
}

/// White outlined button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label,
      {super.key, required this.onPressed, this.icon, this.height = 52});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppText.body(15, weight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label),
        ]),
      ),
    );
  }
}

/// Label above a field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, required this.child});
  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text,
          style: AppText.body(12, color: AppColors.muted, weight: FontWeight.w600)),
      const SizedBox(height: 6),
      child,
    ]);
  }
}

/// Text field with a label and an optional unit suffix (RM, cm).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.suffix,
    this.number = false,
    this.maxLines = 1,
    this.obscure = false,
    this.onChanged,
    this.initialValue,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? suffix;
  final bool number;
  final int maxLines;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return FieldLabel(
      label,
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        obscureText: obscure,
        maxLines: maxLines,
        onChanged: onChanged,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        style: AppText.body(15),
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          suffixStyle: AppText.body(14, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// Grey upper-case section title.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(text.toUpperCase(), style: AppText.label)),
      if (trailing != null) trailing!,
    ]);
  }
}

/// − value + stepper.
class QtyStepper extends StatelessWidget {
  const QtyStepper(
      {super.key,
      required this.text,
      required this.onLess,
      required this.onMore});

  final String text;
  final VoidCallback onLess;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      RoundIconButton(icon: Icons.remove_rounded, onTap: onLess, tooltip: 'Less'),
      SizedBox(
        width: 84,
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppText.body(16, weight: FontWeight.w700)),
      ),
      RoundIconButton(icon: Icons.add_rounded, onTap: onMore, tooltip: 'More'),
    ]);
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.size = 34,
      this.tooltip});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: size * 0.5, color: AppColors.ink)),
        ),
      ),
    );
  }
}

/// iOS-style switch row.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.body(15, weight: FontWeight.w600)),
          if (subtitle != null)
            Text(subtitle!, style: AppText.body(12, color: AppColors.muted)),
        ]),
      ),
      Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.purple,
      ),
    ]);
  }
}

/// Bottom bar with Cancel + main action (forms).
class FormActions extends StatelessWidget {
  const FormActions({
    super.key,
    required this.saveLabel,
    required this.onSave,
    this.onCancel,
  });

  final String saveLabel;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: SecondaryButton('Cancel',
                onPressed: onCancel ?? () => Navigator.maybePop(context)),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: PrimaryButton(saveLabel, onPressed: onSave)),
        ]),
      ),
    );
  }
}

void showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Purple "View sales ›" style link.
class LinkText extends StatelessWidget {
  const LinkText(this.text, {super.key, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: AppText.body(14,
                  color: AppColors.purple, weight: FontWeight.w700)),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.purple),
        ]),
      ),
    );
  }
}
