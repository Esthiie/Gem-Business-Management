import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EventOption {
  const EventOption(this.id, this.label, this.sub);
  final String? id; // null = "All events"
  final String label;
  final String sub;
}

/// Event dropdown used on Booth sale, Sales record and Best sellers.
/// Tapping the box opens the list of events right under it.
class EventPicker extends StatefulWidget {
  const EventPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icon = Icons.calendar_today_outlined,
    this.stacked = false,
  });

  final String label; // "Event" or "Showing"
  final List<EventOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final IconData icon;

  /// true: label above the name (Sales, Best sellers); false: one line.
  final bool stacked;

  @override
  State<EventPicker> createState() => _EventPickerState();
}

class _EventPickerState extends State<EventPicker> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final current = widget.options.firstWhere((o) => o.id == widget.selected,
        orElse: () => widget.options.first);
    final name = Text(current.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.body(widget.stacked ? 15 : 14, weight: FontWeight.w700));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _open = !_open),
          child: Container(
            height: widget.stacked ? 52 : 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Icon(widget.icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 10),
              Expanded(
                child: widget.stacked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(widget.label,
                                style: AppText.body(11,
                                    color: AppColors.muted,
                                    weight: FontWeight.w600)),
                            name,
                          ])
                    : Row(children: [
                        Text('${widget.label} ',
                            style: AppText.body(14, color: AppColors.muted)),
                        Expanded(child: name),
                      ]),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.expand_more_rounded,
                    color: AppColors.muted),
              ),
            ]),
          ),
        ),
      ),
      if (_open)
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x24121212),
                  blurRadius: 28,
                  offset: Offset(0, 12)),
            ],
          ),
          child: Column(children: [
            for (final o in widget.options)
              Material(
                color: o.id == widget.selected
                    ? AppColors.lavenderTint
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() => _open = false);
                    widget.onSelected(o.id);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.label,
                                    style: AppText.body(14,
                                        weight: FontWeight.w600)),
                                Text(o.sub,
                                    style: AppText.body(12,
                                        color: AppColors.muted)),
                              ]),
                        ),
                        if (o.id == widget.selected)
                          const Icon(Icons.check_rounded, size: 18),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
    ]);
  }
}
