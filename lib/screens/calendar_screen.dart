import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

const _kindColour = {
  CalendarKind.event: AppColors.ink,
  CalendarKind.stock: AppColors.stockPink,
  CalendarKind.order: AppColors.purpleDot,
};

/// One row in the calendar list (calendar items + order deadlines).
class _Entry {
  _Entry({
    required this.kind,
    required this.date,
    required this.title,
    this.time = '',
    this.place = '',
    this.sub = '',
    this.item,
    this.order,
  });

  final CalendarKind kind;
  final DateTime date;
  final String title;
  final String time;
  final String place;
  final String sub;
  final CalendarItem? item;
  final CustomOrder? order;
}

/// Calendar: conventions, stock checks and order deadlines (Sarawak events).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _month; // first day of the month on screen
  int? _selected; // selected day of month
  String _filter = 'All';

  List<_Entry> _entries(AppState s) {
    final list = <_Entry>[
      for (final c in s.calendar)
        _Entry(
            kind: c.kind,
            date: c.date,
            title: c.title,
            time: c.time,
            place: c.place,
            sub: c.sub,
            item: c),
      for (final o in s.orders.where((o) => !o.isDone))
        _Entry(
          kind: CalendarKind.order,
          date: o.due,
          title: '${o.customer} · ${o.type.toLowerCase()}',
          sub: s.isOverdue(o)
              ? 'Overdue · ${OrderStage.now(o.stage).toLowerCase()}'
              : '${OrderStage.now(o.stage)} · ${s.daysLeft(o)} days left',
          order: o,
        ),
    ];
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  bool _keep(_Entry e) {
    switch (_filter) {
      case 'Events':
        return e.kind == CalendarKind.event;
      case 'Stock':
        return e.kind == CalendarKind.stock;
      case 'Orders':
        return e.kind == CalendarKind.order;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final today = s.today;
    final month = _month ?? DateTime(today.year, today.month);
    final all = _entries(s).where(_keep).toList();
    final inMonth = all
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();

    List<_Entry> list;
    String title;
    if (_selected != null) {
      final day = DateTime(month.year, month.month, _selected!);
      list = inMonth.where((e) => sameDay(e.date, day)).toList();
      title = longDate(day);
    } else if (month.year == today.year && month.month == today.month) {
      list = inMonth
          .where((e) =>
              !e.date.isBefore(today) ||
              (e.order != null && s.isOverdue(e.order!)))
          .toList();
      title = 'Coming up';
    } else {
      list = inMonth;
      title = monthNames[month.month - 1];
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        AppHeader(
          title: 'Calendar',
          titleTrailing: SizedBox(
            height: 36,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: AppText.body(13, weight: FontWeight.w700),
              ),
              onPressed: () => Navigator.pushNamed(context, Routes.addEvent),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CardBox(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(children: [
                Row(children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _month = DateTime(month.year, month.month - 1);
                      _selected = null;
                    }),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text('${monthNames[month.month - 1]} ${month.year}',
                        textAlign: TextAlign.center,
                        style: AppText.heading(17)),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _month = DateTime(month.year, month.month + 1);
                      _selected = null;
                    }),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ]),
                _MonthGrid(
                  month: month,
                  today: today,
                  selected: _selected,
                  entries: inMonth,
                  onPick: (d) =>
                      setState(() => _selected = _selected == d ? null : d),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  for (final k in [
                    (CalendarKind.event, 'Convention'),
                    (CalendarKind.stock, 'Stock check'),
                    (CalendarKind.order, 'Order due'),
                  ]) ...[
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: _kindColour[k.$1], shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(k.$2, style: AppText.body(11, color: AppColors.muted)),
                    const SizedBox(width: 14),
                  ],
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(title, style: AppText.body(15, weight: FontWeight.w700))),
              if (_selected != null)
                GestureDetector(
                  onTap: () => setState(() => _selected = null),
                  child: Text('Show all',
                      style: AppText.body(13, weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 8),
            ChoiceChips(
              options: const ['All', 'Events', 'Stock', 'Orders'],
              selected: (f) => f == _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('Nothing planned.',
                    textAlign: TextAlign.center,
                    style: AppText.body(13, color: AppColors.muted)),
              ),
            for (final e in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EntryCard(entry: e),
              ),
          ]),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.entries,
    required this.onPick,
  });

  final DateTime month;
  final DateTime today;
  final int? selected;
  final List<_Entry> entries;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final lead = DateTime(month.year, month.month, 1).weekday - 1; // Monday first
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = <Widget>[
      for (final w in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
        Center(
            child: Text(w,
                style: AppText.body(11,
                    color: AppColors.muted, weight: FontWeight.w600))),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) _day(d),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: cells,
    );
  }

  Widget _day(int d) {
    final date = DateTime(month.year, month.month, d);
    final isToday = sameDay(date, today);
    final isSel = selected == d;
    final past = date.isBefore(today);
    final kinds = <CalendarKind>{
      for (final e in entries)
        if (sameDay(e.date, date)) e.kind,
    };
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => onPick(d),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.ink
                : isSel
                    ? AppColors.lavenderTint
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: isSel && !isToday
                ? Border.all(color: AppColors.purpleDot, width: 1.5)
                : null,
          ),
          child: Text('$d',
              style: AppText.body(13,
                  color: isToday
                      ? AppColors.white
                      : past
                          ? const Color(0xFFA5A5AC)
                          : AppColors.ink,
                  weight: isToday || isSel ? FontWeight.w700 : FontWeight.w500)),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 5,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (final k in kinds)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: (_kindColour[k]!).withAlpha(past ? 115 : 255),
                  shape: BoxShape.circle,
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final e = entry;
    final isToday = sameDay(e.date, s.today);
    final overdue = e.order != null && s.isOverdue(e.order!);
    final task = e.item != null && e.item!.isTask;
    final done = task && e.item!.done;

    // Note under an event: is its stock check done?
    String note = '';
    Color noteColour = AppColors.muted;
    if (e.kind == CalendarKind.event && e.item != null) {
      final check = s.calendar
          .where((c) =>
              c.kind == CalendarKind.stock && c.sub.contains(e.title))
          .toList();
      if (check.isNotEmpty) {
        final c = check.first;
        note = c.done
            ? '✓ Stock checked on ${shortDate(c.date)}'
            : '○ Stock check on ${shortDate(c.date)}';
        noteColour = c.done ? AppColors.greenText : AppColors.pinkText;
      }
    }

    Color tileBg;
    Color tileFg;
    switch (e.kind) {
      case CalendarKind.event:
        tileBg = AppColors.ink;
        tileFg = AppColors.white;
        break;
      case CalendarKind.stock:
        tileBg = AppColors.pinkSoft;
        tileFg = AppColors.pinkText;
        break;
      case CalendarKind.order:
        tileBg = AppColors.purpleSoft;
        tileFg = AppColors.purple;
        break;
    }

    Widget? action;
    if (task) {
      action = SizedBox(
        height: 32,
        child: done
            ? FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.greenSoft,
                    foregroundColor: AppColors.greenText,
                    padding: const EdgeInsets.symmetric(horizontal: 12)),
                onPressed: () => s.toggleTask(e.item!),
                child: const Text('Done'),
              )
            : OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pinkText,
                    side: const BorderSide(color: AppColors.stockPink),
                    padding: const EdgeInsets.symmetric(horizontal: 12)),
                onPressed: () => s.toggleTask(e.item!),
                child: const Text('To do'),
              ),
      );
    } else if (e.order != null) {
      action = _smallLink('Open', AppColors.purpleSoft, AppColors.purple,
          () => Navigator.pushNamed(context, Routes.orderDetail, arguments: e.order!.id));
    } else if (isToday && e.kind == CalendarKind.event) {
      action = _smallLink('Log sale', AppColors.ink, AppColors.white,
          () => Navigator.pushNamed(context, Routes.sell));
    }

    return CardBox(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: overdue
          ? AppColors.redBorder
          : isToday
              ? AppColors.ink
              : AppColors.line,
      child: Row(children: [
        Container(
          width: 46,
          height: 50,
          decoration: BoxDecoration(
              color: tileBg, borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(weekday(e.date).toUpperCase(),
                style: AppText.body(10, color: tileFg, weight: FontWeight.w700)),
            Text('${e.date.day}', style: AppText.heading(18, color: tileFg)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Opacity(
            opacity: done ? 0.55 : 1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(e.title,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(14, weight: FontWeight.w700)),
                ),
                if (isToday) ...[
                  const SizedBox(width: 6),
                  const Pill('TODAY',
                      fg: AppColors.white, bg: AppColors.ink, fontSize: 10),
                ],
              ]),
              if (e.time.isNotEmpty)
                _iconLine(Icons.schedule_rounded, e.time),
              if (e.place.isNotEmpty)
                _iconLine(Icons.place_outlined, e.place),
              if (e.sub.isNotEmpty)
                Text(e.sub,
                    style: AppText.body(12,
                        color: overdue ? AppColors.red : AppColors.muted)),
              if (note.isNotEmpty)
                Text(note,
                    style: AppText.body(12,
                        color: noteColour, weight: FontWeight.w600)),
            ]),
          ),
        ),
        if (action != null) ...[const SizedBox(width: 8), action],
      ]),
    );
  }

  Widget _iconLine(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(12, color: AppColors.muted)),
          ),
        ]),
      );

  Widget _smallLink(String label, Color bg, Color fg, VoidCallback onTap) =>
      Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Text(label,
                style: AppText.body(13, color: fg, weight: FontWeight.w700)),
          ),
        ),
      );
}
