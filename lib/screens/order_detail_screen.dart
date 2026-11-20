import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// One custom order: stage tracker, auto-ticking checklist, edit.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _editing = false;
  final _c = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startEdit(CustomOrder o) {
    for (final c in _c.values) {
      c.dispose();
    }
    _c.clear();
    _c['customer'] = TextEditingController(text: o.customer);
    _c['contact'] = TextEditingController(text: o.contact);
    _c['item'] = TextEditingController(text: o.item);
    _c['palette'] = TextEditingController(text: o.palette);
    _c['length'] = TextEditingController(
        text: o.lengthCm == null ? '' : o.lengthCm!.toStringAsFixed(0));
    _c['deposit'] =
        TextEditingController(text: o.deposit == 0 ? '' : o.deposit.toStringAsFixed(0));
    _c['notes'] = TextEditingController(text: o.notes);
    setState(() => _editing = true);
  }

  void _finishEdit(AppState s, CustomOrder o) {
    o.customer = _c['customer']!.text.trim();
    o.contact = _c['contact']!.text.trim();
    o.item = _c['item']!.text.trim();
    o.palette = _c['palette']!.text.trim();
    o.lengthCm = double.tryParse(_c['length']!.text);
    o.deposit = double.tryParse(_c['deposit']!.text) ?? 0;
    o.notes = _c['notes']!.text.trim();
    s.updateOrder(o);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final o = s.orderById(widget.orderId);
    if (o == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }
    final st = StatusColours.of(o.status);
    final days = s.daysLeft(o);
    final dueNote = o.isDone
        ? 'Handed over'
        : days < 0
            ? 'Overdue by ${-days} ${days == -1 ? 'day' : 'days'}'
            : days == 0
                ? 'Due today'
                : '$days ${days == 1 ? 'day' : 'days'} left';

    final checks = [
      _Check('Colour palette', o.palette, o.palette.isNotEmpty),
      _Check('Length',
          o.lengthCm == null ? 'Not set' : '${o.lengthCm!.toStringAsFixed(0)} cm',
          o.lengthCm != null),
      _Check('Deadline', longDate(o.due), true),
      _Check('Reference picture',
          o.pictures > 0 ? '${o.pictures} photo' : 'Not added', o.pictures > 0),
      _Check(
          'Deposit',
          o.deposit <= 0
              ? 'Not received'
              : o.deposit >= o.price
                  ? 'Paid in full · ${rm(o.price)}'
                  : '${rm(o.deposit)} of ${rm(o.price)}',
          o.deposit > 0),
    ];
    final filled = checks.where((c) => c.ok).length;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                AppHeader(
                    title: o.customer,
                    subtitle: '${o.type} · due ${longDate(o.due)} · $dueNote',
                    backLabel: 'Orders'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stage tracker
                        CardBox(
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: Text(OrderStage.now(o.stage),
                                      style: AppText.body(14,
                                          weight: FontWeight.w700))),
                              Pill(o.status, fg: st.fg, bg: st.bg),
                            ]),
                            const SizedBox(height: 12),
                            _Tracker(stage: o.stage, accent: st.accent),
                          ]),
                        ),
                        if (o.stage == 2) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppColors.pinkSoft,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        size: 18, color: AppColors.pinkText),
                                    const SizedBox(width: 8),
                                    Text('Before you tap Final check done',
                                        style: AppText.body(14,
                                            color: AppColors.pinkText,
                                            weight: FontWeight.w700)),
                                  ]),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 26),
                                    child: Text(
                                      '· Count each bead colour against the palette\n'
                                      '· Measure the length: should be ${o.lengthCm == null ? 'the length' : '${o.lengthCm!.toStringAsFixed(0)} cm'}',
                                      style: AppText.body(13,
                                              color: AppColors.pinkText,
                                              weight: FontWeight.w600)
                                          .copyWith(height: 1.5),
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                        const SizedBox(height: 12),
                        CardBox(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: SectionLabel('Order details')),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                        foregroundColor: AppColors.ink,
                                        padding: EdgeInsets.zero),
                                    onPressed: () => _editing
                                        ? _finishEdit(s, o)
                                        : _startEdit(o),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 14),
                                    label: Text(
                                        _editing ? 'Done editing' : 'Edit',
                                        style: AppText.body(13,
                                            weight: FontWeight.w700)),
                                  ),
                                ]),
                                Text(
                                    '$filled of ${checks.length} filled in · ticks itself as you fill them in',
                                    style: AppText.body(12,
                                        color: AppColors.muted)),
                                const SizedBox(height: 6),
                                if (!_editing) ...[
                                  for (final c in checks) _checkRow(c),
                                  if (o.pictures == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 8),
                                      child: SecondaryButton(
                                          'Add reference picture',
                                          height: 40,
                                          icon: Icons.photo_camera_outlined,
                                          onPressed: () {
                                            o.pictures = 1;
                                            s.updateOrder(o);
                                          }),
                                    ),
                                ] else
                                  _editForm(),
                              ]),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (!o.isDone)
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(OrderStage.nextLabels[o.stage],
                      icon: Icons.check_rounded,
                      onPressed: () => s.nextStage(o)),
                )
              else
                Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, color: AppColors.greenText),
                    const SizedBox(width: 8),
                    Text('Order complete',
                        style: AppText.body(16,
                            color: AppColors.greenText,
                            weight: FontWeight.w700)),
                  ]),
                ),
              if (o.stage > 0)
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  onPressed: () => s.previousStage(o),
                  icon: const Icon(Icons.undo_rounded, size: 14),
                  label: Text('Undo last step',
                      style: AppText.body(12,
                          color: AppColors.muted, weight: FontWeight.w600)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _checkRow(_Check c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.ok ? AppColors.greenSoft : const Color(0xFFF1F1F4),
            shape: BoxShape.circle,
          ),
          child: Text(c.ok ? '✓' : '–',
              style: AppText.body(12,
                  color: c.ok ? AppColors.greenText : AppColors.muted,
                  weight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(c.label, style: AppText.body(14))),
        Flexible(
          child: Text(c.value,
              textAlign: TextAlign.right,
              style: AppText.body(13,
                  color: c.ok ? AppColors.ink : AppColors.pinkText,
                  weight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _editForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(children: [
        LabeledField(label: 'Customer', controller: _c['customer']),
        const SizedBox(height: 10),
        LabeledField(
            label: 'Contact',
            controller: _c['contact'],
            hint: 'Instagram, WhatsApp…'),
        const SizedBox(height: 10),
        LabeledField(label: 'Item', controller: _c['item']),
        const SizedBox(height: 10),
        LabeledField(label: 'Colour palette', controller: _c['palette']),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: LabeledField(
                  label: 'Length (cm)',
                  controller: _c['length'],
                  hint: '0',
                  number: true)),
          const SizedBox(width: 10),
          Expanded(
              child: LabeledField(
                  label: 'Deposit (RM)',
                  controller: _c['deposit'],
                  hint: '0',
                  number: true)),
        ]),
        const SizedBox(height: 10),
        LabeledField(label: 'Notes', controller: _c['notes'], maxLines: 3),
      ]),
    );
  }
}

class _Check {
  const _Check(this.label, this.value, this.ok);
  final String label;
  final String value;
  final bool ok;
}

/// Four dots joined by a line, coloured by status.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.stage, required this.accent});
  final int stage;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final colW = box.maxWidth / 4;
      final lineW = box.maxWidth - colW; // centre of first to centre of last
      final fillW = lineW * (stage.clamp(0, 3) / 3);
      return Stack(children: [
        Positioned(
          left: colW / 2,
          top: 12,
          child: Container(width: lineW, height: 3, color: AppColors.line),
        ),
        Positioned(
          left: colW / 2,
          top: 12,
          child: Container(width: fillW, height: 3, color: accent),
        ),
        Row(children: [
          for (var j = 0; j < 4; j++)
            Expanded(
              child: Column(children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: j < stage ? accent : AppColors.white,
                    shape: BoxShape.circle,
                    border: j < stage
                        ? null
                        : Border.all(
                            color: j == stage ? accent : const Color(0xFFD6D6DC),
                            width: j == stage ? 3 : 2),
                  ),
                  child: j < stage
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: AppColors.white)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(OrderStage.steps[j],
                    textAlign: TextAlign.center,
                    style: AppText.body(11,
                        color: j <= stage ? AppColors.ink : AppColors.muted,
                        weight: j <= stage ? FontWeight.w700 : FontWeight.w500)),
              ]),
            ),
        ]),
      ]);
    });
  }
}
