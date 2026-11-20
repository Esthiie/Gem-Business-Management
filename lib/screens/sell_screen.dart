import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';
import '../widgets/event_picker.dart';

/// Booth sale (UI-05): tap what the customer takes, then Record sale and
/// choose how they paid (UI-06). Works offline; saved sales sync later.
class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final Map<String, int> _cart = {};
  String _cat = 'All';
  late String _eventId;
  String? _savedLabel;
  final _scroll = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    for (final c in Categories.all) c: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _eventId = context.read<AppState>().liveEvent.id;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Category chips jump to that section of the list.
  void _jumpTo(String cat) {
    setState(() => _cat = cat);
    if (cat == 'All') {
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      return;
    }
    final ctx = _sectionKeys[cat]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _setQty(String id, int n) => setState(() {
        _savedLabel = null;
        if (n <= 0) {
          _cart.remove(id);
        } else {
          _cart[id] = n;
        }
      });

  Future<void> _record(AppState s, double total, int count) async {
    if (_cart.isEmpty) {
      showToast(context, 'Tap the items the customer is taking first.');
      return;
    }
    final method = await showPaymentSheet(context, total: total, count: count);
    if (method == null || !mounted) return;
    final sale = s.recordSale(_eventId, Map.of(_cart), method);
    if (sale == null) return;
    setState(() {
      _cart.clear();
      _savedLabel =
          '${sale.customer} · ${rm(sale.total)} · ${method.short} · saved';
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    double total = 0;
    int count = 0;
    _cart.forEach((id, q) {
      total += q * (s.designById(id)?.price ?? 0);
      count += q;
    });

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          AppHeader(
            title: 'Booth sale',
            backLabel: 'Home',
            titleTrailing: LinkText('View sales',
                onTap: () => Navigator.pushNamed(context, Routes.sales)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EventPicker(
              label: 'Event',
              icon: Icons.place_outlined,
              options: [
                for (final e in s.events)
                  EventOption(e.id, e.name,
                      e.id == s.liveEvent.id ? '${e.dates} · today' : e.dates),
              ],
              selected: _eventId,
              onSelected: (id) => setState(() => _eventId = id ?? _eventId),
            ),
          ),
          ChoiceChips(
            options: ['All', ...Categories.all],
            selected: (c) => c == _cat,
            onSelected: _jumpTo,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in Categories.all) ...[
                      Padding(
                        key: _sectionKeys[c],
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
                  ]),
            ),
          ),
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
                child: _savedLabel != null
                    ? Row(children: [
                        const Icon(Icons.check_rounded,
                            color: AppColors.purple, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(_savedLabel!,
                              style: AppText.body(14,
                                  color: AppColors.purple,
                                  weight: FontWeight.w700)),
                        ),
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text('$count ${count == 1 ? 'item' : 'items'}',
                                style:
                                    AppText.body(12, color: AppColors.muted)),
                            Text(rm(total), style: AppText.heading(22)),
                          ]),
              ),
              PrimaryButton('Record sale',
                  height: 50, onPressed: () => _record(s, total, count)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tile(Design d) {
    final q = _cart[d.id] ?? 0;
    final out = d.qty == 0;
    final left = d.qty - q;

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
              onTap: out || q >= d.qty ? null : () => _setQty(d.id, q + 1),
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
                  onTap: () => _setQty(d.id, q - 1)),
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
}

/// "How did they pay?" sheet (UI-06). Returns the method, or null when
/// Faith goes back to the items.
Future<PayMethod?> showPaymentSheet(BuildContext context,
    {required double total, required int count}) {
  Widget payButton(BuildContext ctx, PayMethod m) {
    final cash = m == PayMethod.cash;
    final fg = cash ? AppColors.greenText : AppColors.purple;
    return SizedBox(
      height: 60,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: cash ? AppColors.greenSoft : AppColors.purpleSoft,
          foregroundColor: fg,
          side: const BorderSide(color: AppColors.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppText.body(17, weight: FontWeight.w700),
        ),
        icon: Icon(cash ? Icons.payments_outlined : Icons.qr_code_2_rounded,
            size: 22),
        label: Text(m.long),
        onPressed: () => Navigator.pop(ctx, m),
      ),
    );
  }

  return showModalBottomSheet<PayMethod>(
    context: context,
    backgroundColor: AppColors.white,
    barrierColor: const Color(0x73121212),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: const Color(0xFFD6D6DC),
                    borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 12),
            Text('$count ${count == 1 ? 'item' : 'items'}',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.muted)),
            Text(rm(total),
                textAlign: TextAlign.center, style: AppText.heading(40)),
            const SizedBox(height: 8),
            Text('How did they pay?',
                textAlign: TextAlign.center,
                style: AppText.body(14,
                    color: AppColors.muted, weight: FontWeight.w600)),
            const SizedBox(height: 12),
            payButton(ctx, PayMethod.cash),
            const SizedBox(height: 12),
            payButton(ctx, PayMethod.qr),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Back to items',
                  style: AppText.body(14,
                      color: AppColors.muted, weight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ),
  );
}
