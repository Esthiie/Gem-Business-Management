import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/colour_picker.dart';
import '../widgets/common.dart';

/// New custom order form with a live "ready" checklist.
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  String _via = 'Instagram';
  String _type = 'Bracelet';
  final _customer = TextEditingController();
  final _contact = TextEditingController();
  final _item = TextEditingController();
  final _palette = TextEditingController();
  final _length = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  List<Color> _colours = [];
  DateTime? _due;
  int _pictures = 0;

  static const _quick = [
    Color(0xFFE8B4B8), Color(0xFFF3EBDD), Color(0xFF8C8C96), Color(0xFFF2B9C6),
    Color(0xFFC0283D), Color(0xFFE2B04A), Color(0xFF9DB89A), Color(0xFF2F7FB5),
    Color(0xFF9B7BC8), Color(0xFF121212),
  ];

  @override
  void dispose() {
    for (final c in [
      _customer, _contact, _item, _palette, _length, _price, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDue(AppState s) async {
    final d = await showDatePicker(
      context: context,
      initialDate: _due ?? s.today.add(const Duration(days: 7)),
      firstDate: s.today,
      lastDate: s.today.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _due = d);
  }

  void _create(AppState s) {
    s.addOrder((id) => CustomOrder(
          id: id,
          customer: _customer.text.trim(),
          contact: _contact.text.trim(),
          via: _via,
          type: _type,
          item: _item.text.trim(),
          palette: _palette.text.trim(),
          lengthCm: double.tryParse(_length.text),
          price: double.tryParse(_price.text) ?? 0,
          due: _due ?? s.today.add(const Duration(days: 7)),
          stage: 0,
          notes: _notes.text.trim(),
          pictures: _pictures,
          colours: _colours,
        ));
    showToast(context, 'Order created · deadline added to Calendar');
    Navigator.pop(context);
  }

  bool _has(TextEditingController c) => c.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final checks = [
      ('Customer', _has(_customer)),
      ('Item', _has(_item)),
      ('Colours', _has(_palette) || _colours.isNotEmpty),
      ('Length', _has(_length)),
      ('Deadline', _due != null),
    ];
    final ready = checks.where((c) => c.$2).length;
    final canCreate = _has(_customer) && _has(_item);
    void refresh(String _) => setState(() {});

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const AppHeader(
                    title: 'New custom order',
                    subtitle: 'Starts as New',
                    backLabel: 'Orders'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionLabel('Customer'),
                        const SizedBox(height: 8),
                        LabeledField(
                            label: 'Name',
                            controller: _customer,
                            hint: 'e.g. Aina Rahman',
                            onChanged: refresh),
                        const SizedBox(height: 12),
                        FieldLabel('Ordered through',
                            child: ChoiceChips(
                                options: const ['Instagram', 'WhatsApp', 'At booth'],
                                scroll: false,
                                selected: (v) => v == _via,
                                onSelected: (v) => setState(() => _via = v))),
                        LabeledField(
                            label: 'Contact (optional)',
                            controller: _contact,
                            hint: '@username or phone number'),
                        const SizedBox(height: 20),
                        const SectionLabel('Item'),
                        const SizedBox(height: 8),
                        FieldLabel('Type',
                            child: ChoiceChips(
                                options: const [
                                  'Phone charm', 'Bracelet', 'Necklace',
                                  'Lanyard', 'Hair clip', 'Earrings', 'Other',
                                ],
                                scroll: false,
                                selected: (v) => v == _type,
                                onSelected: (v) => setState(() => _type = v))),
                        LabeledField(
                            label: 'What they want',
                            controller: _item,
                            hint: 'e.g. Rose bracelet with silver clasp',
                            onChanged: refresh),
                        const SizedBox(height: 12),
                        LabeledField(
                            label: 'Colour palette',
                            controller: _palette,
                            hint: 'e.g. Blush / pearl / smoke',
                            onChanged: refresh),
                        const SizedBox(height: 10),
                        ColourChooser(
                          colours: _colours,
                          quickPicks: _quick,
                          onChanged: (c) => setState(() => _colours = c),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: LabeledField(
                                  label: 'Length',
                                  controller: _length,
                                  hint: '0',
                                  suffix: 'cm',
                                  number: true,
                                  onChanged: refresh)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FieldLabel('Deadline',
                                child: InkWell(
                                  onTap: () => _pickDue(s),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: AppColors.line),
                                    ),
                                    child: Text(
                                        _due == null
                                            ? 'Pick a date'
                                            : longDate(_due!),
                                        style: AppText.body(15,
                                            color: _due == null
                                                ? AppColors.muted
                                                : AppColors.ink)),
                                  ),
                                )),
                          ),
                        ]),
                        if (_due != null) ...[
                          const SizedBox(height: 6),
                          Text(
                              '${_due!.difference(s.today).inDays} days from today · added to Calendar',
                              style: AppText.body(12,
                                  color: AppColors.purple,
                                  weight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 12),
                        FieldLabel('Reference pictures (optional)',
                            child: Row(children: [
                              for (var i = 0; i < _pictures; i++)
                                Container(
                                  width: 64,
                                  height: 64,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.lavenderTint,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.image_outlined,
                                      color: AppColors.purple),
                                ),
                              if (_pictures < 3)
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  // Step 2: image_picker + Firebase Storage.
                                  onTap: () =>
                                      setState(() => _pictures++),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.lavender,
                                          width: 1.5),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_rounded),
                                          Text('Add',
                                              style: AppText.body(11,
                                                  weight: FontWeight.w600)),
                                        ]),
                                  ),
                                ),
                            ])),
                        const SizedBox(height: 20),
                        LabeledField(
                            label: 'Price',
                            controller: _price,
                            hint: '0.00',
                            suffix: 'RM',
                            number: true,
                            onChanged: refresh),
                        const SizedBox(height: 12),
                        LabeledField(
                            label: 'Notes (optional)',
                            controller: _notes,
                            hint: 'Anything else the customer asked for',
                            maxLines: 3),
                        const SizedBox(height: 16),
                        CardBox(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$ready of ${checks.length} details filled in',
                                    style: AppText.body(14,
                                        weight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Wrap(spacing: 6, runSpacing: 6, children: [
                                  for (final c in checks)
                                    Pill('${c.$2 ? '✓' : '○'} ${c.$1}',
                                        fg: c.$2
                                            ? AppColors.greenText
                                            : AppColors.muted,
                                        bg: c.$2
                                            ? AppColors.greenSoft
                                            : const Color(0xFFF1F1F4),
                                        fontSize: 12),
                                ]),
                              ]),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          FormActions(
            saveLabel: canCreate ? 'Create order' : 'Add name and item',
            onSave: canCreate ? () => _create(s) : null,
          ),
        ]),
      ),
    );
  }
}
