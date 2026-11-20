import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// Stock (UI-10): Faith's collection of finished designs by category.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _cat = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final q = _query.toLowerCase();

    return Stack(children: [
      Column(children: [
        const AppHeader(title: 'Stock'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
                hintText: 'Search by name or colour',
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _collection(s, q),
        ),
      ]),
      Positioned(
        right: 20,
        bottom: 16,
        child: FloatingActionButton.extended(
          heroTag: 'stockFab',
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          onPressed: () => Navigator.pushNamed(context, Routes.addDesign),
          icon: const Icon(Icons.add_rounded),
          label: Text('Add design',
              style: AppText.body(15,
                  color: AppColors.white, weight: FontWeight.w700)),
        ),
      ),
    ]);
  }

  Widget _collection(AppState s, String q) {
    final cats = _cat == 'All' ? Categories.all : [_cat];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      children: [
        ChoiceChips(
          options: ['All', ...Categories.all],
          selected: (c) => c == _cat,
          onSelected: (c) => setState(() => _cat = c),
        ),
        for (final c in cats) ..._categorySection(s, c, q),
      ],
    );
  }

  List<Widget> _categorySection(AppState s, String c, String q) {
    final items = s
        .designsIn(c)
        .where((d) =>
            q.isEmpty ||
            d.name.toLowerCase().contains(q) ||
            d.detail.toLowerCase().contains(q))
        .toList();
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 2),
        child: SectionLabel(
            '$c · ${items.length} ${items.length == 1 ? 'design' : 'designs'}'),
      ),
      for (final d in items) _DesignRow(design: d),
    ];
  }
}

class _DesignRow extends StatelessWidget {
  const _DesignRow({required this.design});
  final Design design;

  @override
  Widget build(BuildContext context) {
    final d = design;
    Widget trailing;
    if (d.isOut) {
      trailing = const Pill('Sold out',
          fg: AppColors.white, bg: AppColors.pinkText, radius: 7);
    } else if (d.isLow) {
      trailing = Pill('${d.qty} left',
          fg: AppColors.pinkText, bg: AppColors.pinkSoft, radius: 7);
    } else {
      trailing = Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${d.qty}', style: AppText.body(15, weight: FontWeight.w700)),
        Text('in stock', style: AppText.body(11, color: AppColors.muted)),
      ]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(children: [
        BeadTile(colour: d.colour),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                  child: Text(d.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(15, weight: FontWeight.w600))),
              if (d.oneOfAKind) ...[
                const SizedBox(width: 6),
                const Pill('1 of 1',
                    fg: AppColors.ink, bg: AppColors.lavenderTint, radius: 6),
              ],
            ]),
            Text(d.meta, style: AppText.body(13, color: AppColors.muted)),
          ]),
        ),
        trailing,
      ]),
    );
  }
}
