import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/event_picker.dart';

/// Sales record (UI-07): every customer, what they bought and how they paid,
/// grouped by day. Filter by event and by Cash / QR.
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String? _eventId; // null = all events
  PayMethod? _method; // null = all

  Future<void> _open(Sale sale) async {
    final deleted = await Navigator.pushNamed(context, Routes.saleDetail,
        arguments: sale.id);
    if (!mounted || deleted is! String) return;
    showToast(context, deleted);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final all = s.salesFor(_eventId);
    double sum(Iterable<Sale> l) => l.fold(0.0, (a, x) => a + x.total);
    final cash = all.where((x) => x.method == PayMethod.cash);
    final qr = all.where((x) => x.method == PayMethod.qr);
    final shown = s.salesFor(_eventId, method: _method);

    // Group by day, newest first.
    final days = <DateTime, List<Sale>>{};
    for (final x in shown) {
      days
          .putIfAbsent(DateTime(x.time.year, x.time.month, x.time.day), () => [])
          .add(x);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const AppHeader(
              title: 'Sales',
              subtitle: 'Every customer, what they bought and how they paid',
              backLabel: 'Booth sale',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EventPicker(
                      label: 'Showing',
                      stacked: true,
                      options: [
                        EventOption(
                            null, 'All events', '${s.events.length} events'),
                        for (final e in s.events)
                          EventOption(e.id, e.name, e.dates),
                      ],
                      selected: _eventId,
                      onSelected: (id) => setState(() => _eventId = id),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _Stat('Total', rm(sum(all)),
                              customers(all.length))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _Stat(
                              'Items sold',
                              '${all.fold(0, (a, x) => a + x.items)}',
                              'pieces')),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: _Stat('Cash', rm(sum(cash)),
                              customers(cash.length),
                              accent: AppColors.greenText)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _Stat('QR (DuitNow / TNG)', rm(sum(qr)),
                              customers(qr.length),
                              accent: AppColors.purple)),
                    ]),
                    const SizedBox(height: 12),
                    ChoiceChips(
                      options: const ['All', 'Cash', 'QR (TNG / DuitNow)'],
                      selected: (o) =>
                          (o == 'All' && _method == null) ||
                          (o == 'Cash' && _method == PayMethod.cash) ||
                          (o.startsWith('QR') && _method == PayMethod.qr),
                      onSelected: (o) => setState(() => _method = o == 'All'
                          ? null
                          : (o == 'Cash' ? PayMethod.cash : PayMethod.qr)),
                    ),
                    if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text('No sales here yet.',
                            textAlign: TextAlign.center,
                            style: AppText.body(14, color: AppColors.muted)),
                      ),
                    for (final entry in days.entries) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Expanded(
                          child: Text(_dayLabel(s, entry.key),
                              style: AppText.label),
                        ),
                        Text(
                            '${customers(entry.value.length)} · ${rm(sum(entry.value))}',
                            style: AppText.body(12, color: AppColors.muted)),
                      ]),
                      Text(s.eventById(entry.value.first.eventId).name,
                          style: AppText.body(11, color: AppColors.muted)),
                      const SizedBox(height: 6),
                      CardBox(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(children: [
                          for (var i = 0; i < entry.value.length; i++)
                            _SaleRow(
                              sale: entry.value[i],
                              last: i == entry.value.length - 1,
                              onTap: () => _open(entry.value[i]),
                            ),
                        ]),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (shown.isNotEmpty)
                      Text('Tap a sale to see what the customer bought',
                          textAlign: TextAlign.center,
                          style: AppText.body(12, color: AppColors.muted)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(AppState s, DateTime d) {
    final label = '${weekday(d)} ${shortDate(d)}'.toUpperCase();
    return sameDay(d, s.today) ? 'TODAY · $label' : label;
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.sub, {this.accent});
  final String label;
  final String value;
  final String sub;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(12,
                color: accent ?? AppColors.muted, weight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: AppText.heading(22)),
        Text(sub, style: AppText.body(12, color: AppColors.muted)),
      ]),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.last, required this.onTap});
  final Sale sale;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final what = sale.lines.map((l) {
      final name = s.designById(l.designId)?.name ?? 'Item';
      return l.qty > 1 ? '$name ×${l.qty}' : name;
    }).join(', ');
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${sale.customer}  · ${clock(sale.time)}',
                  style: AppText.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${pcs(sale.items)} · $what',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, color: AppColors.muted)),
            ]),
          ),
          const SizedBox(width: 10),
          Text(rm(sale.total), style: AppText.body(15, weight: FontWeight.w700)),
          const SizedBox(width: 8),
          PayTag(sale.method),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.muted),
        ]),
      ),
    );
  }
}

/// Small green "Cash" or purple "QR" tag.
class PayTag extends StatelessWidget {
  const PayTag(this.method, {super.key, this.long = false});
  final PayMethod method;
  final bool long;

  @override
  Widget build(BuildContext context) {
    final cash = method == PayMethod.cash;
    return Pill(long ? method.long : method.short,
        fg: cash ? AppColors.greenText : AppColors.purple,
        bg: cash ? AppColors.greenSoft : AppColors.purpleSoft,
        radius: 7);
  }
}
