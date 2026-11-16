import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// Booth sale (offline-friendly POS).
class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final Map<String, int> _cart = {};
  int _mode = 0; // 0 Collection, 1 Enter total only
  String _cat = 'All';
  late String _eventId;
  final _total = TextEditingController();
  final _note = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _eventId = context.read<AppState>().liveEvent.id;
  }

  @override
  void dispose() {
    _total.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickEvent(AppState s) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Text('Which event?', style: AppText.heading(18)),
          const SizedBox(height: 8),
          for (final e in s.events)
            ListTile(
              title: Text(e.name, style: AppText.body(15, weight: FontWeight.w600)),
              subtitle: Text(longDate(e.date), style: AppText.body(13, color: AppColors.muted)),
              trailing: e.id == _eventId ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(ctx, e.id),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (picked != null) setState(() => _eventId = picked);
  }

  void _record(AppState s) {
    if (_mode == 0) {
      if (_cart.isEmpty) {
        showToast(context, 'Tap the items you sold first.');
        return;
      }
      s.recordSale(_eventId, Map.of(_cart));
      setState(() {
        _cart.clear();
        _saved = true;
      });
    } else {
      final v = double.tryParse(_total.text);
      if (v == null || v <= 0) {
        showToast(context, 'Key in the total collected.');
        return;
      }
      s.recordTotalOnly(_eventId, v, _note.text.trim());
      _total.clear();
      _note.clear();
      setState(() => _saved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final event = s.events.firstWhere((e) => e.id == _eventId);
    double total = 0;
    int count = 0;
    _cart.forEach((id, q) {
      total += q * (s.designById(id)?.price ?? 0);
      count += q;
    });

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const AppHeader(title: 'Booth sale', backLabel: 'Home'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              CardBox(
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () => _pickEvent(s),
                child: Row(children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('Event ', style: AppText.body(14, color: AppColors.muted)),
                  Expanded(
                      child: Text(event.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(14, weight: FontWeight.w700))),
                  const Icon(Icons.expand_more_rounded, color: AppColors.muted),
                ]),
              ),
              const SizedBox(height: 12),
              Segmented(
                options: const ['Collection', 'Enter total only'],
                index: _mode,
                onChanged: (i) => setState(() {
                  _mode = i;
                  _saved = false;
                }),
              ),
            ]),
          ),
          Expanded(child: _mode == 0 ? _collection(s) : _totalOnly()),
          // Summary bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14121212),
                    blurRadius: 14,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Row(children: [
              Expanded(
                child: _saved
                    ? Row(children: [
                        const Icon(Icons.check_rounded,
                            color: AppColors.purple, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                              s.online
                                  ? 'Sale saved · stock updated'
                                  : 'Saved on this phone · syncs later',
                              style: AppText.body(14,
                                  color: AppColors.purple,
                                  weight: FontWeight.w700)),
                        ),
                      ])
                    : _mode == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text('$count ${count == 1 ? 'item' : 'items'}',
                                    style: AppText.body(12,
                                        color: AppColors.muted)),
                                Text(rm(total), style: AppText.heading(22)),
                              ])
                        : Text('Saved on this phone, syncs when online',
                            style:
                                AppText.body(13, color: AppColors.muted)),
              ),
              PrimaryButton('Record sale',
                  height: 50, onPressed: () => _record(s)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _collection(AppState s) {
    final cats = _cat == 'All' ? Categories.all : [_cat];
    return Column(children: [
      ChoiceChips(
        options: ['All', ...Categories.all],
        selected: (c) => c == _cat,
        onSelected: (c) => setState(() => _cat = c),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          children: [
            for (final c in cats) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SectionLabel(c),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  for (final d in s.designsIn(c)) _tile(d),
                ],
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _tile(Design d) {
    final q = _cart[d.id] ?? 0;
    final out = d.qty == 0;
    final left = d.qty - q;
    void setQty(int n) => setState(() {
          _saved = false;
          if (n <= 0) {
            _cart.remove(d.id);
          } else {
            _cart[d.id] = n;
          }
        });

    return Opacity(
      opacity: out ? 0.45 : 1,
      child: Stack(children: [
        Positioned.fill(
          child: Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: q > 0 ? AppColors.ink : AppColors.line, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: out || q >= d.qty ? null : () => setQty(q + 1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BeadRing(colour: d.colour, size: 30),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(d.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(14, weight: FontWeight.w700)
                                .copyWith(height: 1.2)),
                      ),
                      Row(children: [
                        Text(rm(d.price),
                            style: AppText.body(12, color: AppColors.muted)),
                        const Spacer(),
                        Text(out ? 'Sold out' : '$left left',
                            style: AppText.body(12, color: AppColors.muted)),
                      ]),
                    ]),
              ),
            ),
          ),
        ),
        if (q > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Row(children: [
              RoundIconButton(
                  icon: Icons.remove_rounded,
                  size: 30,
                  tooltip: 'Remove one',
                  onTap: () => setQty(q - 1)),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 30),
                height: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(15)),
                child: Text('$q',
                    style: AppText.body(14,
                        color: AppColors.white, weight: FontWeight.w700)),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _totalOnly() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        Text('For a busy rush: key in the takings now, match items to stock later.',
            style: AppText.body(14, color: AppColors.muted)),
        const SizedBox(height: 14),
        FieldLabel('Total collected (RM)',
            child: TextField(
              controller: _total,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppText.heading(30),
              decoration: const InputDecoration(hintText: '0.00'),
            )),
        const SizedBox(height: 14),
        LabeledField(
            label: 'Note (optional)',
            controller: _note,
            hint: 'e.g. 3 charms, 2 bracelets'),
      ],
    );
  }
}
