import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Custom orders (combined list with status filter tiles).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final counts = {'All': s.orders.length, 'New': 0, 'In progress': 0, 'Done': 0};
    for (final o in s.orders) {
      counts[o.status] = counts[o.status]! + 1;
    }
    final list = s.orders
        .where((o) => _filter == 'All' || o.status == _filter)
        .where((o) =>
            _query.isEmpty ||
            o.customer.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(children: [
      const AppHeader(title: 'Custom orders'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          Row(children: [
            for (final t in ['All', 'New', 'In progress', 'Done']) ...[
              Expanded(child: _tile(t, counts[t]!)),
              if (t != 'Done') const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              hintText: 'Search customer name',
            ),
          ),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? Center(
                child: Text('No orders here.',
                    style: AppText.body(13, color: AppColors.muted)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _OrderCard(order: list[i]),
              ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton('New custom order',
              icon: Icons.add_rounded,
              height: 50,
              onPressed: () => Navigator.pushNamed(context, Routes.newOrder)),
        ),
      ),
    ]);
  }

  Widget _tile(String t, int n) {
    final on = _filter == t;
    final dot = t == 'All' ? null : StatusColours.of(t).accent;
    return Material(
      color: on ? AppColors.ink : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: on ? BorderSide.none : const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _filter = t),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(children: [
            Text('$n',
                style: AppText.heading(20,
                    color: on ? AppColors.white : AppColors.ink)),
            const SizedBox(height: 1),
            FittedBox(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (dot != null) ...[
                  Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: dot, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                ],
                Text(t,
                    style: AppText.body(11,
                        color: on ? AppColors.white : AppColors.ink,
                        weight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final CustomOrder order;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final o = order;
    final st = StatusColours.of(o.status);
    final overdue = s.isOverdue(o);
    final soon = s.isDueSoon(o);
    return CardBox(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      borderColor: overdue ? AppColors.redBorder : AppColors.line,
      onTap: () =>
          Navigator.pushNamed(context, Routes.orderDetail, arguments: o.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.lavenderTint,
            child: Text(o.initial,
                style: AppText.body(15, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.customer, style: AppText.body(15, weight: FontWeight.w700)),
              Text(
                  '${o.type} · ${o.palette}${o.type == 'Necklace' && o.lengthCm != null ? ' · ${o.lengthCm!.toStringAsFixed(0)} cm' : ''}',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, color: AppColors.muted)),
            ]),
          ),
          Pill(o.status, fg: st.fg, bg: st.bg),
        ]),
        const SizedBox(height: 8),
        StageBar(stage: o.stage),
        const SizedBox(height: 8),
        // Due date, then the note, then the Overdue / Due soon flag on the right.
        Row(children: [
          Text(o.isDone ? 'Completed' : 'Due ${shortDate(o.due)}',
              style: AppText.body(12, weight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text('· ${OrderStage.now(o.stage)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(12, color: AppColors.muted)),
          ),
          if (overdue) ...[
            const SizedBox(width: 8),
            const Pill('Overdue',
                fg: AppColors.white, bg: AppColors.red, radius: 6),
          ] else if (soon) ...[
            const SizedBox(width: 8),
            const Pill('Due soon',
                fg: AppColors.pinkText, bg: AppColors.pinkSoft, radius: 6),
          ],
        ]),
        const SizedBox(height: 8),
        if (!o.isDone)
          SizedBox(
            height: 34,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.ink),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: AppText.body(13, weight: FontWeight.w700),
              ),
              onPressed: () => s.nextStage(o),
              icon: const Icon(Icons.chevron_right_rounded, size: 16),
              label: Text(OrderStage.nextLabels[o.stage.clamp(0, 3)]),
            ),
          )
        else
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.muted),
            onPressed: () => s.previousStage(o),
            icon: const Icon(Icons.undo_rounded, size: 16),
            label: Text('Undo', style: AppText.body(12, color: AppColors.muted, weight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

/// Four-segment progress bar coloured by status.
class StageBar extends StatelessWidget {
  const StageBar({super.key, required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    final colour = stage >= 4 ? AppColors.green : AppColors.orange;
    return Row(children: [
      for (var j = 0; j < 4; j++) ...[
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: j < stage ? colour : AppColors.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        if (j < 3) const SizedBox(width: 4),
      ],
    ]);
  }
}
