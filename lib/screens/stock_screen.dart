import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// Stock: Collection (finished designs) and Materials.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int _tab = 0; // 0 collection, 1 materials
  String _cat = 'All';
  String _mcat = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final q = _query.toLowerCase();

    return Stack(children: [
      Column(children: [
        const AppHeader(title: 'Stock', subtitle: 'Your collection and materials'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            Segmented(
                options: const ['Collection', 'Materials'],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i)),
            const SizedBox(height: 10),
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
          child: _tab == 0 ? _collection(s, q) : _materials(s, q),
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
          onPressed: () => Navigator.pushNamed(
              context, _tab == 0 ? Routes.addDesign : Routes.addMaterial),
          icon: const Icon(Icons.add_rounded),
          label: Text(_tab == 0 ? 'Add design' : 'Add material',
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

  Widget _materials(AppState s, String q) {
    final lowCount = s.lowMaterials.length;
    final items = s.materials
        .where((m) => _mcat == 'All' || m.type == _mcat)
        .where((m) => q.isEmpty || m.name.toLowerCase().contains(q))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      children: [
        ChoiceChips(
          options: ['All', ...materialTypes],
          selected: (c) => c == _mcat,
          onSelected: (c) => setState(() => _mcat = c),
        ),
        if (lowCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.pinkText),
              const SizedBox(width: 10),
              Text('$lowCount materials below reorder level',
                  style: AppText.body(13,
                      color: AppColors.pinkText, weight: FontWeight.w600)),
            ]),
          ),
        for (final m in items) _MaterialRow(item: m),
        const SizedBox(height: 6),
        Text('Materials are counted by hand. Tap − when you use some, + when you restock.',
            style: AppText.body(11, color: AppColors.muted)),
      ],
    );
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

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.item});
  final MaterialItem item;

  @override
  Widget build(BuildContext context) {
    final m = item;
    final s = context.read<AppState>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: m.colour.withAlpha(34),
              borderRadius: BorderRadius.circular(12)),
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                  color: m.colour, borderRadius: BorderRadius.circular(5)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                  child: Text(m.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(15, weight: FontWeight.w600))),
              if (m.isLow) ...[
                const SizedBox(width: 6),
                m.qty == 0
                    ? const Pill('Out',
                        fg: AppColors.white, bg: AppColors.pinkText, radius: 7)
                    : const Pill('Low',
                        fg: AppColors.pinkText,
                        bg: AppColors.pinkSoft,
                        radius: 7),
              ],
            ]),
            Text(m.usedIn, style: AppText.body(12, color: AppColors.muted)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${m.qty} ${m.unit}',
              style: AppText.body(14, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            RoundIconButton(
                icon: Icons.remove_rounded,
                size: 30,
                tooltip: 'Use some',
                onTap: () => s.changeMaterialQty(m, -m.step)),
            const SizedBox(width: 6),
            RoundIconButton(
                icon: Icons.add_rounded,
                size: 30,
                tooltip: 'Add more',
                onTap: () => s.changeMaterialQty(m, m.step)),
          ]),
        ]),
      ]),
    );
  }
}
