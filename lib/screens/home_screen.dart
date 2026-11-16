import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// UI-03 Home.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categoryColour = {
    Categories.phoneCharms: Color(0xFFE0577A),
    Categories.bracelets: Color(0xFF2F7FB5),
    Categories.necklaces: Color(0xFF4B3F72),
    Categories.hairClips: Color(0xFFD8C9B0),
  };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final live = s.liveEvent;
    final low = s.lowDesigns;
    final top = s.ranking(live.id).take(3).toList();
    final dueThisWeek =
        s.activeOrders.where((o) => s.daysLeft(o) <= 7).length;

    return Stack(children: [
      ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          AppHeader(
            title: 'Hi, ${s.nickname}',
            subtitle: fullDate(s.today),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Live booth card
              Material(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, Routes.sell),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                        color: AppColors.lavender,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('LIVE AT YOUR BOOTH',
                                    style: AppText.body(11,
                                            color: AppColors.white,
                                            weight: FontWeight.w700)
                                        .copyWith(letterSpacing: 0.5)),
                              ]),
                              const SizedBox(height: 4),
                              Text(live.name,
                                  style: AppText.heading(19,
                                      color: AppColors.white)),
                            ]),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('Open booth',
                            style:
                                AppText.body(13, weight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Stats
              CardBox(
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(children: [
                    Expanded(
                      child: _Stat(
                        label: 'Sales today',
                        value: rm(s.revenueFor(live.id)),
                        note: '${s.unitsFor(live.id)} items sold',
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppColors.line),
                    Expanded(
                      child: InkWell(
                        onTap: () => s.goToTab(2),
                        child: _Stat(
                          label: 'Active orders',
                          value: '${s.activeOrders.length}',
                          note: '$dueThisWeek due this week',
                          noteColour: AppColors.pinkText,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                  title: '${s.shopName}’s collection',
                  action: 'See all',
                  onAction: () => s.goToTab(1)),
              const SizedBox(height: 12),
              Row(children: [
                for (final c in Categories.all)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => s.goToTab(1),
                      child: Column(children: [
                        BeadTile(
                            colour: _categoryColour[c]!, size: 52, radius: 16),
                        const SizedBox(height: 6),
                        Text(c,
                            textAlign: TextAlign.center,
                            style: AppText.body(12, weight: FontWeight.w600)),
                        Text('${s.designsIn(c).length} designs',
                            style: AppText.body(11, color: AppColors.muted)),
                      ]),
                    ),
                  ),
              ]),
              if (low.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionHeader(title: 'Needs restocking'),
                const SizedBox(height: 10),
                CardBox(
                  onTap: () => s.goToTab(1),
                  child: Row(children: [
                    SizedBox(
                      width: 34.0 + (low.take(3).length - 1) * 24,
                      height: 38,
                      child: Stack(children: [
                        for (var i = 0; i < low.take(3).length; i++)
                          Positioned(
                            left: i * 24.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.white, width: 2),
                              ),
                              child: BeadTile(
                                  colour: low[i].colour, size: 34),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${low.length} ${low.length == 1 ? 'design' : 'designs'} running low',
                                style: AppText.body(14,
                                    weight: FontWeight.w700)),
                            Text(low.map((d) => d.name).join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(12,
                                    color: AppColors.muted)),
                          ]),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                  ]),
                ),
              ],
              const SizedBox(height: 22),
              _SectionHeader(
                  title: 'Top sellers at this event',
                  action: 'See all',
                  onAction: () =>
                      Navigator.pushNamed(context, Routes.bestSellers)),
              const SizedBox(height: 10),
              CardBox(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  for (var i = 0; i < top.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : const Border(
                                top: BorderSide(color: AppColors.line)),
                      ),
                      child: Row(children: [
                        SizedBox(
                            width: 16,
                            child: Text('${i + 1}',
                                style: AppText.body(14,
                                    color: AppColors.muted,
                                    weight: FontWeight.w700))),
                        const SizedBox(width: 8),
                        BeadTile(
                            colour: s.designById(top[i].key)!.colour,
                            size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(s.designById(top[i].key)!.name,
                                style: AppText.body(14,
                                    weight: FontWeight.w600))),
                        Text.rich(TextSpan(
                          text: '${top[i].value}',
                          style: AppText.body(14, weight: FontWeight.w700),
                          children: [
                            TextSpan(
                                text: ' sold',
                                style: AppText.body(12,
                                    color: AppColors.muted)),
                          ],
                        )),
                      ]),
                    ),
                ]),
              ),
            ]),
          ),
        ],
      ),
      // Floating "+ Log sale" button
      Positioned(
        right: 18,
        bottom: 16,
        child: Material(
          color: AppColors.ink,
          elevation: 6,
          shadowColor: const Color(0x66121212),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => Navigator.pushNamed(context, Routes.sell),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 22, 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      color: AppColors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: AppColors.ink),
                ),
                const SizedBox(width: 10),
                Text('Log sale',
                    style: AppText.heading(17, color: AppColors.white)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label,
      required this.value,
      required this.note,
      this.noteColour = AppColors.muted});

  final String label;
  final String value;
  final String note;
  final Color noteColour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.body(12, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: AppText.heading(24)),
        const SizedBox(height: 2),
        Text(note,
            style: AppText.body(12,
                color: noteColour,
                weight: noteColour == AppColors.muted
                    ? FontWeight.w400
                    : FontWeight.w600)),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title, style: AppText.body(16, weight: FontWeight.w700))),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: AppText.body(13, weight: FontWeight.w600)),
        ),
    ]);
  }
}
