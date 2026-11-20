import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';
import 'sales_screen.dart';

/// Sale details (UI-08): what one customer bought, the total and how they
/// paid. A wrong sale can be deleted; the pieces go back into stock.
class SaleDetailScreen extends StatelessWidget {
  const SaleDetailScreen({super.key, required this.saleId});
  final String saleId;

  Future<void> _delete(BuildContext context, AppState s, Sale sale) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Delete this sale?', style: AppText.heading(20)),
        content: Text(
            '${sale.customer} · ${rm(sale.total)} (${sale.method.short}). '
            'The ${sale.items == 1 ? 'piece goes' : '${sale.items} pieces go'} '
            'back into stock. This can’t be undone.',
            style: AppText.body(14, color: AppColors.muted)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(children: [
            Expanded(
              child: SecondaryButton('Cancel',
                  height: 46, onPressed: () => Navigator.pop(ctx, false)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: AppText.body(15, weight: FontWeight.w700),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final msg = '${sale.customer} deleted · ${rm(sale.total)} removed · '
        '${sale.items == 1 ? '1 piece' : '${sale.items} pieces'} back in stock';
    s.deleteSale(sale);
    Navigator.pop(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final sale = s.saleById(saleId);
    if (sale == null) {
      return const Scaffold(
          body: SafeArea(child: AppHeader(title: 'Sale', backLabel: 'Sales')));
    }
    final event = s.eventById(sale.eventId);
    final day = sameDay(sale.time, s.today)
        ? 'Today · ${longDate(sale.time)}'
        : longDate(sale.time);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                AppHeader(
                  title: sale.customer,
                  subtitle: '$day · ${clock(sale.time)} · ${event.name}',
                  backLabel: 'Sales',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardBox(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: Text('ITEM', style: AppText.label)),
                              SizedBox(
                                  width: 40,
                                  child: Text('QTY',
                                      textAlign: TextAlign.center,
                                      style: AppText.label)),
                              SizedBox(
                                  width: 70,
                                  child: Text('AMOUNT',
                                      textAlign: TextAlign.right,
                                      style: AppText.label)),
                            ]),
                            for (final l in sale.lines) _line(s, l),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Row(children: [
                                Expanded(
                                  child: Text('Total · ${pcs(sale.items)}',
                                      style: AppText.body(15,
                                          weight: FontWeight.w700)),
                                ),
                                Text(rm(sale.total),
                                    style: AppText.heading(24)),
                              ]),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        CardBox(
                          child: Row(children: [
                            Expanded(
                              child: Text('Paid by',
                                  style: AppText.body(14,
                                      color: AppColors.muted)),
                            ),
                            PayTag(sale.method, long: true),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            'Stock went down by these items when the sale was saved.',
                            style: AppText.body(12, color: AppColors.muted)),
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.redBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: AppText.body(15, weight: FontWeight.w700),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete sale'),
                onPressed: () => _delete(context, s, sale),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _line(AppState s, SaleLine l) {
    final d = s.designById(l.designId);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(children: [
        BeadRing(colour: d?.colour ?? AppColors.lavender, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d?.name ?? 'Item',
                style: AppText.body(14, weight: FontWeight.w600)),
            Text('${rm(l.unitPrice)} each',
                style: AppText.body(12, color: AppColors.muted)),
          ]),
        ),
        SizedBox(
            width: 40,
            child: Text('${l.qty}',
                textAlign: TextAlign.center,
                style: AppText.body(15, weight: FontWeight.w700))),
        SizedBox(
            width: 70,
            child: Text(rm(l.total),
                textAlign: TextAlign.right,
                style: AppText.body(14, weight: FontWeight.w700))),
      ]),
    );
  }
}
