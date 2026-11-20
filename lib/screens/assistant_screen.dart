import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/demo_data.dart';
import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bead_ring.dart';
import '../widgets/common.dart';

/// AI Assistant: find events, spot trends, write captions.
///
/// The prototype shows prepared results. Step 3 connects these buttons to
/// the AI service from the SRS (FR-AI-01 to FR-AI-04).
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  int _tab = 0; // 0 Events, 1 Trends, 2 Captions
  int _trendView = 0; // 0 For you, 1 My ideas
  String _cat = 'All';
  final _product = TextEditingController(text: 'Cherry charm');
  String _tone = 'Cute';
  int _variant = 0;
  bool _copied = false;

  @override
  void dispose() {
    _product.dispose();
    super.dispose();
  }

  static const _tones = ['Cute', 'Elegant', 'Playful', 'Short'];

  String _caption() {
    final p = _product.text.trim().isEmpty ? 'new design' : _product.text.trim();
    final c = {
      'Cute': [
        'Sweet little $p just landed! 🍒 Hand-beaded one bead at a time, made to brighten your phone and your day. DM to grab yours 💕',
        'Meet $p 🎀 tiny, pastel and handmade with love by Queens.Trinket. Limited pieces, so come say hi at our booth!',
      ],
      'Elegant': [
        '$p. Hand-beaded in small batches with soft tones and a touch of gold. A quiet little luxury for every day.',
        'Simple, delicate and made by hand: $p is now available. Each piece is beaded with care by Queens.Trinket.',
      ],
      'Playful': [
        'Plot twist: your phone needed $p all along 😌✨ Hand-beaded, pastel and very you. Catch us at the next bazaar!',
        'POV: you found $p and now you need two 👀 Handmade by Queens.Trinket. DM or visit our booth!',
      ],
      'Short': [
        '$p 💜 handmade, limited, yours?',
        'New in: $p ✨ DM to order.',
      ],
    }[_tone]!;
    return c[_variant % c.length];
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        const AppHeader(
            title: 'Assistant',
            subtitle: 'Find events, spot trends, write captions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Segmented(
              options: const ['Events', 'Trends', 'Captions'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 14),
            if (_tab == 0) ..._events(s),
            if (_tab == 1) ..._trends(s),
            if (_tab == 2) ..._captions(),
          ]),
        ),
      ],
    );
  }

  // ---------------- Events ----------------
  List<Widget> _events(AppState s) => [
        Row(children: const [
          Expanded(child: _ReadOnlyField(label: 'Area', value: 'Kuching, Sarawak')),
          SizedBox(width: 10),
          Expanded(child: _ReadOnlyField(label: 'When', value: 'Next 2 months')),
        ]),
        const SizedBox(height: 10),
        PrimaryButton('Find craft events',
            icon: Icons.search_rounded,
            height: 46,
            onPressed: () => showToast(context,
                s.online ? 'Showing the latest results' : 'Offline: showing your last saved results')),
        const SizedBox(height: 12),
        for (final e in DemoData.eventSuggestions) ...[
          CardBox(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(e.name,
                        style: AppText.body(15, weight: FontWeight.w700))),
                Text(e.when, style: AppText.body(13, weight: FontWeight.w600)),
              ]),
              const SizedBox(height: 2),
              Text(e.where, style: AppText.body(13, color: AppColors.muted)),
              Text(e.note,
                  style: AppText.body(12,
                      color: AppColors.pinkText, weight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                if (!s.addedSuggestions.contains(e.id))
                  SizedBox(
                    height: 36,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                      onPressed: () {
                        s.addSuggestionToCalendar(e);
                        showToast(context, 'Added to your calendar');
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add to calendar'),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => s.goToTab(3),
                    icon: const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.greenText),
                    label: Text('In your calendar',
                        style: AppText.body(13,
                            color: AppColors.greenText,
                            weight: FontWeight.w700)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => showToast(context, 'Opens the organiser page'),
                  child: Text('Organiser page',
                      style: AppText.body(13, weight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        Text(
            'AI suggestions. Check dates and fees on the organiser’s page. Offline: shows your last saved results.',
            style: AppText.body(11, color: AppColors.muted)),
      ];

  // ---------------- Trends ----------------
  List<Widget> _trends(AppState s) {
    final forYou = DemoData.trends
        .where((t) => !s.hiddenTrends.contains(t.id))
        .where((t) => _cat == 'All' || t.category == _cat)
        .toList();
    final ideas =
        DemoData.trends.where((t) => s.savedTrends.contains(t.id)).toList();
    return [
      CardBox(
        color: AppColors.lavenderTint,
        borderColor: AppColors.lavenderTint,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionLabel('Based on your shop'),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: const [
            Pill('Phone charms', fg: AppColors.ink, bg: AppColors.white),
            Pill('Bracelets', fg: AppColors.ink, bg: AppColors.white),
            Pill('Pastel colours', fg: AppColors.ink, bg: AppColors.white),
            Pill('Top seller: Coquette Bow', fg: AppColors.ink, bg: AppColors.white),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      Segmented(
        options: ['For you', 'My ideas (${ideas.length})'],
        index: _trendView,
        onChanged: (i) => setState(() => _trendView = i),
      ),
      const SizedBox(height: 12),
      if (_trendView == 0) ...[
        ChoiceChips(
          options: ['All', ...Categories.all],
          selected: (c) => c == _cat,
          onSelected: (c) => setState(() => _cat = c),
        ),
        Row(children: [
          Text('Updated 2 days ago', style: AppText.body(12, color: AppColors.muted)),
          const Spacer(),
          if (s.hiddenTrends.isNotEmpty)
            TextButton(
              onPressed: s.undoHiddenTrends,
              child: Text('Show ${s.hiddenTrends.length} hidden',
                  style: AppText.body(12, weight: FontWeight.w700)),
            ),
        ]),
        for (final t in forYou) _trendCard(s, t, mine: false),
        if (forYou.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No trends for this category yet.',
                textAlign: TextAlign.center,
                style: AppText.body(13, color: AppColors.muted)),
          ),
        Text(
            'Suggestions from AI based on your stock, best sellers and custom orders. Check the sources before making a new design.',
            style: AppText.body(11, color: AppColors.muted)),
      ] else ...[
        Text('Ideas you saved to make later. They stay here offline.',
            style: AppText.body(13, color: AppColors.muted)),
        const SizedBox(height: 10),
        for (final t in ideas) _trendCard(s, t, mine: true),
        if (ideas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No saved ideas yet. Tap Save idea on a trend.',
                textAlign: TextAlign.center,
                style: AppText.body(13, color: AppColors.muted)),
          ),
      ],
    ];
  }

  Widget _trendCard(AppState s, Trend t, {required bool mine}) {
    final saved = s.savedTrends.contains(t.id);
    final (fg, bg, arrow) = switch (t.status) {
      'Rising' => (AppColors.greenText, AppColors.greenSoft, '▲'),
      'Popular' => (AppColors.purple, AppColors.lavenderTint, '●'),
      _ => (AppColors.muted, const Color(0xFFF1F1F4), '▼'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (var i = 0; i < 12; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Bead(
                    colour: t.palette[i % t.palette.length],
                    size: i % 4 == 1 ? 18 : 13),
              ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(t.name,
                    style: AppText.body(15, weight: FontWeight.w700))),
            Pill('$arrow ${t.status}', fg: fg, bg: bg),
          ]),
          const SizedBox(height: 4),
          Text(t.why, style: AppText.body(13)),
          Text(t.when, style: AppText.body(12, color: AppColors.muted)),
          const SizedBox(height: 10),
          Row(children: [
            if (!mine)
              _miniButton(saved ? 'Saved' : 'Save idea',
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  () => s.toggleSavedTrend(t.id),
                  filled: saved),
            if (mine)
              _miniButton('Add as design', Icons.add_rounded,
                  () => Navigator.pushNamed(context, Routes.addDesign),
                  filled: true),
            const SizedBox(width: 8),
            _miniButton('Write caption', Icons.edit_note_rounded, () {
              setState(() {
                _tab = 2;
                _product.text = t.name;
                _variant = 0;
                _copied = false;
              });
            }),
            const Spacer(),
            IconButton(
              tooltip: mine ? 'Remove from my ideas' : 'Not for me',
              onPressed: () {
                if (mine) {
                  s.toggleSavedTrend(t.id);
                } else {
                  s.hideTrend(t.id);
                }
              },
              icon: Icon(mine ? Icons.delete_outline_rounded : Icons.close_rounded,
                  color: AppColors.muted, size: 20),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _miniButton(String label, IconData icon, VoidCallback onTap,
      {bool filled = false}) {
    return SizedBox(
      height: 34,
      child: filled
          ? FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: AppText.body(13, weight: FontWeight.w700)),
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.line),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: AppText.body(13, weight: FontWeight.w700)),
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label),
            ),
    );
  }

  // ---------------- Captions ----------------
  List<Widget> _captions() {
    final text = _caption();
    return [
      LabeledField(
        label: 'Product or trend',
        controller: _product,
        hint: 'e.g. Cherry charm',
        onChanged: (_) => setState(() => _copied = false),
      ),
      const SizedBox(height: 12),
      FieldLabel('Tone',
          child: ChoiceChips(
            options: _tones,
            scroll: false,
            selected: (t) => t == _tone,
            onSelected: (t) => setState(() {
              _tone = t;
              _variant = 0;
              _copied = false;
            }),
          )),
      const SizedBox(height: 4),
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.purple),
            const SizedBox(width: 6),
            Text('Suggested caption',
                style: AppText.body(12, color: AppColors.purple, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(text, style: AppText.body(15).copyWith(height: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: PrimaryButton(_copied ? 'Copied' : 'Copy',
                  height: 44,
                  icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                  onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (mounted) setState(() => _copied = true);
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton('Try again',
                  height: 44,
                  icon: Icons.refresh_rounded,
                  onPressed: () => setState(() {
                        _variant++;
                        _copied = false;
                      })),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 8),
      Text('Check the caption before posting. You can edit it after copying.',
          style: AppText.body(11, color: AppColors.muted)),
    ];
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FieldLabel(label,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(value, style: AppText.body(14)),
        ));
  }
}
