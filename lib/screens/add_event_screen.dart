import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Add a convention, an order deadline or a reminder to the calendar.
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  int _type = 0; // 0 Convention, 1 Order deadline, 2 Reminder
  final _name = TextEditingController();
  final _venue = TextEditingController();
  final _booth = TextEditingController();
  final _fee = TextEditingController();
  final _notes = TextEditingController();
  final _remember = TextEditingController();
  late DateTime _start;
  late DateTime _end;
  TimeOfDay _opens = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _closes = const TimeOfDay(hour: 21, minute: 0);
  bool _remind = true;
  int _daysBefore = 2;
  String? _orderId;
  int _orderLead = 1;
  TimeOfDay _stockTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _orderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _remTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _start = s.today.add(const Duration(days: 14));
    _end = _start;
  }

  @override
  void dispose() {
    for (final c in [_name, _venue, _booth, _fee, _notes, _remember]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _date(DateTime initial) {
    final s = context.read<AppState>();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: s.today.subtract(const Duration(days: 30)),
      lastDate: s.today.add(const Duration(days: 730)),
    );
  }

  Future<TimeOfDay?> _time(TimeOfDay initial) =>
      showTimePicker(context: context, initialTime: initial);

  String _t(TimeOfDay t) => t.format(context);

  void _save(AppState s) {
    if (_type == 0) {
      if (_name.text.trim().isEmpty) {
        showToast(context, 'Add the event name first.');
        return;
      }
      final multi = !sameDay(_start, _end);
      s.addCalendarItem(CalendarItem(
        id: s.newCalendarId(),
        kind: CalendarKind.event,
        date: _start,
        title: _name.text.trim(),
        time:
            '${multi ? '${shortDate(_start)}–${shortDate(_end)} · ' : ''}${_t(_opens)} – ${_t(_closes)}',
        place: _venue.text.trim(),
      ));
      if (_remind) {
        s.addCalendarItem(CalendarItem(
          id: s.newCalendarId(),
          kind: CalendarKind.stock,
          date: _start.subtract(Duration(days: _daysBefore)),
          title: 'Stock check',
          time: _t(_stockTime),
          sub: 'For ${_name.text.trim()}',
          isTask: true,
        ));
      }
    } else if (_type == 1) {
      // Order deadlines already come from the orders list. Adding one by
      // hand just sets a reminder for the chosen order.
      showToast(context,
          'Reminder set ${_orderLead == 0 ? 'on the day' : '$_orderLead day${_orderLead == 1 ? '' : 's'} before'} at ${_t(_orderTime)}');
    } else {
      if (_remember.text.trim().isEmpty) {
        showToast(context, 'Write what to remember first.');
        return;
      }
      s.addCalendarItem(CalendarItem(
        id: s.newCalendarId(),
        kind: CalendarKind.stock,
        date: _start,
        title: _remember.text.trim(),
        time: _t(_remTime),
        sub: _notes.text.trim(),
        isTask: true,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final saveLabel = ['Save convention', 'Save deadline', 'Save reminder'][_type];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const AppHeader(title: 'Add event', backLabel: 'Calendar'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardBox(
                          color: AppColors.lavenderTint,
                          borderColor: AppColors.lavenderTint,
                          child: Row(children: [
                            const Icon(Icons.auto_awesome_outlined, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Got an event post?',
                                        style: AppText.body(14,
                                            weight: FontWeight.w700)),
                                    Text(
                                        'Paste the caption or a poster screenshot. The assistant fills in the form for you.',
                                        style: AppText.body(12,
                                            color: AppColors.muted)),
                                  ]),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 36,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.ink),
                                onPressed: () {
                                  // Demo of the AI import (FR-AI).
                                  setState(() {
                                    _type = 0;
                                    _name.text = 'Christmas Bazaar';
                                    _venue.text = 'Shopping mall atrium, Kuching';
                                    _start = DateTime(2026, 12, 5);
                                    _end = DateTime(2026, 12, 6);
                                  });
                                  showToast(context,
                                      'Filled in from the post. Check before saving.');
                                },
                                child: const Text('Import'),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        Segmented(
                          options: const ['Convention', 'Order deadline', 'Reminder'],
                          index: _type,
                          onChanged: (i) => setState(() => _type = i),
                        ),
                        const SizedBox(height: 14),
                        if (_type == 0) ..._convention(),
                        if (_type == 1) ..._orderDeadline(s),
                        if (_type == 2) ..._reminder(),
                      ]),
                ),
              ],
            ),
          ),
          FormActions(saveLabel: saveLabel, onSave: () => _save(s)),
        ]),
      ),
    );
  }

  Widget _pickerBox(String label, String value, VoidCallback onTap) {
    return FieldLabel(label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(value, style: AppText.body(15)),
          ),
        ));
  }

  List<Widget> _convention() {
    final check = _start.subtract(Duration(days: _daysBefore));
    return [
      LabeledField(label: 'Event name', controller: _name, hint: 'e.g. Christmas Bazaar'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _pickerBox('Starts', longDate(_start), () async {
          final d = await _date(_start);
          if (d != null) {
            setState(() {
              _start = d;
              if (_end.isBefore(d)) _end = d;
            });
          }
        })),
        const SizedBox(width: 10),
        Expanded(
            child: _pickerBox('Ends', longDate(_end), () async {
          final d = await _date(_end);
          if (d != null) setState(() => _end = d.isBefore(_start) ? _start : d);
        })),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _pickerBox('Opens', _t(_opens), () async {
          final t = await _time(_opens);
          if (t != null) setState(() => _opens = t);
        })),
        const SizedBox(width: 10),
        Expanded(
            child: _pickerBox('Closes', _t(_closes), () async {
          final t = await _time(_closes);
          if (t != null) setState(() => _closes = t);
        })),
      ]),
      const SizedBox(height: 12),
      LabeledField(label: 'Venue', controller: _venue, hint: 'e.g. Kuching Waterfront'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: LabeledField(
                label: 'Booth no. (optional)', controller: _booth, hint: 'e.g. B12')),
        const SizedBox(width: 10),
        Expanded(
            child: LabeledField(
                label: 'Booth fee (optional)',
                controller: _fee,
                hint: '0',
                suffix: 'RM',
                number: true)),
      ]),
      const SizedBox(height: 12),
      CardBox(
        child: Column(children: [
          SwitchRow(
            title: 'Stock check reminder',
            subtitle: 'Adds a to-do before the event',
            value: _remind,
            onChanged: (v) => setState(() => _remind = v),
          ),
          if (_remind) ...[
            const Divider(height: 20),
            Row(children: [
              Expanded(
                child: Text(
                    '$_daysBefore ${_daysBefore == 1 ? 'day' : 'days'} before',
                    style: AppText.body(15, weight: FontWeight.w600)),
              ),
              RoundIconButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Fewer days',
                  onTap: () => setState(
                      () => _daysBefore = (_daysBefore - 1).clamp(1, 7))),
              const SizedBox(width: 8),
              RoundIconButton(
                  icon: Icons.add_rounded,
                  tooltip: 'More days',
                  onTap: () => setState(
                      () => _daysBefore = (_daysBefore + 1).clamp(1, 7))),
            ]),
            const SizedBox(height: 10),
            _timeRow('Remind me at', _stockTime, (t) => _stockTime = t),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Stock check on ${longDate(check)} · reminder at ${_t(_stockTime)}',
                  style: AppText.body(12,
                      color: AppColors.pinkText, weight: FontWeight.w600)),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      LabeledField(
          label: 'Notes (optional)',
          controller: _notes,
          hint: 'e.g. bring extra phone charms and the table cloth',
          maxLines: 3),
    ];
  }

  List<Widget> _orderDeadline(AppState s) {
    final active = s.activeOrders;
    _orderId ??= active.isNotEmpty ? active.first.id : null;
    final chosen = _orderId == null ? null : s.orderById(_orderId!);
    return [
      Text('Deadlines from custom orders appear here automatically. Use this only to add one by hand.',
          style: AppText.body(13, color: AppColors.muted)),
      const SizedBox(height: 12),
      FieldLabel('Custom order',
          child: DropdownButtonFormField<String>(
            initialValue: _orderId,
            items: [
              for (final o in active)
                DropdownMenuItem(
                    value: o.id, child: Text('${o.customer} · ${o.type.toLowerCase()}')),
            ],
            onChanged: (v) => setState(() => _orderId = v),
          )),
      const SizedBox(height: 12),
      _pickerBox('Due date', chosen == null ? '-' : longDate(chosen.due), () {}),
      const SizedBox(height: 12),
      FieldLabel('Remind me',
          child: ChoiceChips(
            options: const ['On the day', '1 day before', '3 days before'],
            scroll: false,
            selected: (o) =>
                o == ['On the day', '1 day before', '3 days before'][[0, 1, 3].indexOf(_orderLead)],
            onSelected: (o) => setState(() => _orderLead =
                [0, 1, 3][['On the day', '1 day before', '3 days before'].indexOf(o)]),
          )),
      const SizedBox(height: 4),
      _timeRow('At what time', _orderTime, (t) => _orderTime = t),
      if (chosen != null) ...[
        const SizedBox(height: 6),
        Text(
            'You will be reminded on ${longDate(chosen.due.subtract(Duration(days: _orderLead)))} at ${_t(_orderTime)}',
            style: AppText.body(12,
                color: AppColors.purple, weight: FontWeight.w600)),
      ],
    ];
  }

  /// "Remind me at  [9:00 am]" row with a time picker.
  Widget _timeRow(String label, TimeOfDay value, ValueChanged<TimeOfDay> onPick) {
    return Row(children: [
      Expanded(
          child: Text(label, style: AppText.body(14, weight: FontWeight.w600))),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.schedule_rounded, size: 16),
        label: Text(_t(value), style: AppText.body(14, weight: FontWeight.w600)),
        onPressed: () async {
          final t = await _time(value);
          if (t != null) setState(() => onPick(t));
        },
      ),
    ]);
  }

  List<Widget> _reminder() {
    return [
      LabeledField(
          label: 'What to remember',
          controller: _remember,
          hint: 'e.g. Buy more pearl beads'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _pickerBox('Date', longDate(_start), () async {
          final d = await _date(_start);
          if (d != null) setState(() => _start = d);
        })),
        const SizedBox(width: 10),
        Expanded(
            child: _pickerBox('Time', _t(_remTime), () async {
          final t = await _time(_remTime);
          if (t != null) setState(() => _remTime = t);
        })),
      ]),
      const SizedBox(height: 12),
      LabeledField(
          label: 'Notes (optional)',
          controller: _notes,
          hint: 'Anything else',
          maxLines: 3),
    ];
  }
}
