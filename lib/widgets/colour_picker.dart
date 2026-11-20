import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Colour chooser used by Add design and New custom order:
/// chosen colours (tap to remove), quick picks, and a full colour grid.
class ColourChooser extends StatefulWidget {
  const ColourChooser({
    super.key,
    required this.colours,
    required this.onChanged,
    this.quickPicks = defaultQuickPicks,
  });

  final List<Color> colours;
  final ValueChanged<List<Color>> onChanged;
  final List<Color> quickPicks;

  static const defaultQuickPicks = [
    Color(0xFFF2B9C6), Color(0xFFE0577A), Color(0xFFC0283D), Color(0xFFE8833A),
    Color(0xFFE2B04A), Color(0xFFD3A741), Color(0xFF9DB89A), Color(0xFF2F7FB5),
    Color(0xFF9B7BC8), Color(0xFF4B3F72), Color(0xFFFFFFFF), Color(0xFF121212),
  ];

  @override
  State<ColourChooser> createState() => _ColourChooserState();
}

class _ColourChooserState extends State<ColourChooser> {
  bool _open = false;
  Color _current = HSLColor.fromAHSL(1, 330, 0.7, 0.72).toColor();

  late final List<Color> _grid = [
    for (var i = 0; i < 12; i++)
      HSLColor.fromAHSL(1, 0, 0, 1 - i / 11).toColor(),
    for (final l in [0.22, 0.34, 0.46, 0.58, 0.72, 0.86])
      for (var h = 0; h < 360; h += 30)
        HSLColor.fromAHSL(1, h.toDouble(), 0.7, l).toColor(),
  ];

  void _toggle(Color c) {
    final list = List<Color>.from(widget.colours);
    if (list.contains(c)) {
      list.remove(c);
    } else {
      list.add(c);
    }
    widget.onChanged(list);
  }

  Widget _dot(Color c, {bool on = false, double size = 28}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
              color: on ? AppColors.white : const Color(0x26121212),
              width: on ? 3 : 1),
          boxShadow: on
              ? const [BoxShadow(color: AppColors.purple, spreadRadius: 2)]
              : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Colours', style: AppText.body(12, color: AppColors.muted, weight: FontWeight.w600)),
        const Spacer(),
        Text(
            '${widget.colours.length} ${widget.colours.length == 1 ? 'colour' : 'colours'}',
            style: AppText.body(12, color: AppColors.muted)),
      ]),
      const SizedBox(height: 8),
      if (widget.colours.isNotEmpty) ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in widget.colours)
            GestureDetector(
              onTap: () => _toggle(c),
              child: Stack(clipBehavior: Clip.none, children: [
                _dot(c, size: 30),
                const Positioned(
                  right: -4,
                  top: -4,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.ink,
                    child: Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              ]),
            ),
        ]),
        const SizedBox(height: 10),
      ],
      Text('Quick picks', style: AppText.body(12, color: AppColors.muted)),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final c in widget.quickPicks)
          GestureDetector(
            onTap: () => _toggle(c),
            child: _dot(c, on: widget.colours.contains(c), size: 26),
          ),
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lavenderTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(_open ? 'Close picker' : 'More colours',
                style: AppText.body(12, weight: FontWeight.w700)),
          ),
        ),
      ]),
      if (_open) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            GridView.count(
              crossAxisCount: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final c in _grid)
                  GestureDetector(
                    onTap: () => setState(() => _current = c),
                    child: Container(
                      decoration: BoxDecoration(
                        color: c,
                        border: c == _current
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _current,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Selected colour',
                    style: AppText.body(13, color: Colors.white)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink),
                onPressed: () {
                  if (!widget.colours.contains(_current)) _toggle(_current);
                  setState(() => _open = false);
                },
                child: const Text('Add colour'),
              ),
            ]),
          ]),
        ),
      ],
    ]);
  }
}
