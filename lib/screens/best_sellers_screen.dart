import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// Best sellers, with an event dropdown (All events by default).
class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _BestSellersScreenState();
}

class _BestSellersScreenState extends State<BestSellersScreen> {
  String? _eventId; // null = All events
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final ranking = s.ranking(_eventId).take(5).toList();
    final topUnits = ranking.isEmpty ? 1 : ranking.first.value;
    final selectedName = _eventId == null
        ? 'All events'
        : s.events.firstWhere((e) => e.id == _eventId).name;

    // Restock tip: best seller that is running low.
    Design? tip;
    for (final r in ranking) {
      final d = s.designById(r.key);
      if (d != null && (d.isLow || d.isOut)) {
        tip = d;
        break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            AppHeader(
                title: 'Best sellers',
                subtitle: 'Ranked by units sold',
                backLabel: 'Home',
                titleTrailing: LinkText('View sales',
                    onTap: () => Navigator.pushNamed(context, Routes.sales))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown button
                    CardBox(
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      onTap: () => setState(() => _open = !_open),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Showing',
                                    style: AppText.body(11,
                                        color: AppColors.muted,
                                        weight: FontWeight.w600)),
                                Text(selectedName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.body(15,
                                        weight: FontWeight.w700)),
                              ]),
                        ),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(Icons.expand_more_rounded,
                              color: AppColors.muted),
                        ),
                      ]),
                    ),
                    if (_open) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x24121212),
                                blurRadius: 28,
                                offset: Offset(0, 12)),
                          ],
                        ),
                        child: Column(children: [
                          _option(null, 'All events',
                              '${s.rankedEvents.length} events so far'),
                          for (final e in s.rankedEvents)
                            _option(e.id, e.name, '${e.dates} ${e.date.year}'),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _StatCard(
                              label: 'Units sold',
                              value: '${s.unitsFor(_eventId)}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              label: 'Sales',
                              value: rm(s.revenueFor(_eventId)))),
                    ]),
                    const SizedBox(height: 12),
                    CardBox(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ranking.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No sales yet for this event.',
                                  style: AppText.body(13,
                                      color: AppColors.muted)),
                            )
                          : Column(children: [
                              for (var i = 0; i < ranking.length; i++)
                                _rankRow(s, i + 1, ranking[i], topUnits),
                            ]),
                    ),
                    if (tip != null) ...[
                      const SizedBox(height: 12),
                      Material(
                        color: AppColors.pinkSoft,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            s.goToTab(1);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 18, color: AppColors.pinkText),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${tip.name} sells best but only ${tip.qty} left. Make more before Community Pop-up on 31 Oct.',
                                  style: AppText.body(13,
                                      color: AppColors.pinkText,
                                      weight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.pinkText),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(String? id, String label, String sub) {
    final on = id == _eventId;
    return Material(
      color: on ? AppColors.lavenderTint : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() {
          _eventId = id;
          _open = false;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: AppText.body(14, weight: FontWeight.w600)),
                Text(sub, style: AppText.body(12, color: AppColors.muted)),
              ]),
            ),
            if (on) const Icon(Icons.check_rounded, size: 18),
          ]),
        ),
      ),
    );
  }

  Widget _rankRow(
      AppState s, int rank, MapEntry<String, int> e, int topUnits) {
    final d = s.designById(e.key)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        SizedBox(
            width: 18,
            child: Text('$rank',
                style: AppText.heading(16, color: AppColors.muted))),
        const SizedBox(width: 8),
        BeadTile(colour: d.colour, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(d.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(14, weight: FontWeight.w700))),
              Text('${e.value}', style: AppText.body(14, weight: FontWeight.w700)),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: e.value / topUnits,
                minHeight: 8,
                color: AppColors.ink,
                backgroundColor: AppColors.lavenderTint,
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              Text('${d.category} · ${rm(d.price)}',
                  style: AppText.body(12, color: AppColors.muted)),
              const Spacer(),
              Text(rm(e.value * d.price),
                  style: AppText.body(12, color: AppColors.muted)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CardBox(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppText.body(12, color: AppColors.muted, weight: FontWeight.w600)),
        Text(value, style: AppText.heading(26)),
      ]),
    );
  }
}
