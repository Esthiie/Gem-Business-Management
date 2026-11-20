import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Add a raw material (beads, cords, charms, findings).
class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  String _type = 'Beads';
  String _unit = 'packs';
  int _amount = 5;
  int _min = 3;
  final _name = TextEditingController();
  final _size = TextEditingController();
  final _price = TextEditingController();
  final _where = TextEditingController();
  final Set<String> _usedIn = {};

  int get _step => _unit == 'pcs' ? 10 : 1;

  @override
  void dispose() {
    _name.dispose();
    _size.dispose();
    _price.dispose();
    _where.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      showToast(context, 'Give the material a name first.');
      return;
    }
    final colourFor = {
      'Beads': const Color(0xFFF2B9C6),
      'Strings & cords': const Color(0xFF9DB89A),
      'Charms': const Color(0xFFD3A741),
      'Clips & findings': const Color(0xFF8E8E99),
    };
    context.read<AppState>().addMaterial(MaterialItem(
          id: 'm${DateTime.now().millisecondsSinceEpoch}',
          type: _type,
          name: _name.text.trim(),
          sizeOrColour: _size.text.trim(),
          usedIn: _usedIn.isEmpty ? '' : 'Used in ${_usedIn.join(', ')}',
          qty: _amount,
          unit: _unit,
          reorderBelow: _min,
          colour: colourFor[_type]!,
          price: double.tryParse(_price.text),
          whereToBuy: _where.text.trim(),
        ));
    showToast(context, 'Material saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final low = _amount < _min;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const AppHeader(title: 'Add material', backLabel: 'Stock'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showToast(context,
                                'Camera / gallery comes with the backend step.'),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.lavenderTint,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add_a_photo_outlined),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                                'A photo helps you spot the right bead pack when restocking. Optional.',
                                style: AppText.body(13,
                                    color: AppColors.muted)),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        FieldLabel('Type',
                            child: ChoiceChips(
                                options: materialTypes,
                                scroll: false,
                                selected: (t) => t == _type,
                                onSelected: (t) => setState(() => _type = t))),
                        const SizedBox(height: 8),
                        LabeledField(
                            label: 'Material name',
                            controller: _name,
                            hint: 'e.g. Glass pearls'),
                        const SizedBox(height: 14),
                        LabeledField(
                            label: 'Size or colour (optional)',
                            controller: _size,
                            hint: 'e.g. 6 mm, gold'),
                        const SizedBox(height: 14),
                        FieldLabel('Counted in',
                            child: ChoiceChips(
                                options: materialUnits,
                                scroll: false,
                                selected: (u) => u == _unit,
                                onSelected: (u) => setState(() => _unit = u))),
                        const SizedBox(height: 8),
                        CardBox(
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: Text('Amount you have',
                                      style: AppText.body(15,
                                          weight: FontWeight.w600))),
                              QtyStepper(
                                  text: '$_amount $_unit',
                                  onLess: () => setState(() => _amount =
                                      (_amount - _step).clamp(0, 99999)),
                                  onMore: () =>
                                      setState(() => _amount += _step)),
                            ]),
                            const Divider(height: 24),
                            Row(children: [
                              Expanded(
                                  child: Text('Reorder when below',
                                      style: AppText.body(15,
                                          weight: FontWeight.w600))),
                              QtyStepper(
                                  text: '$_min $_unit',
                                  onLess: () => setState(() =>
                                      _min = (_min - _step).clamp(0, 99999)),
                                  onMore: () => setState(() => _min += _step)),
                            ]),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: low
                                    ? AppColors.orangeSoft
                                    : AppColors.greenSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                low
                                    ? 'Below reorder level: goes on the shopping list'
                                    : 'Stock is fine. You will get an alert below $_min $_unit.',
                                style: AppText.body(13,
                                    color: low
                                        ? AppColors.orangeText
                                        : AppColors.greenText,
                                    weight: FontWeight.w600),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                              child: LabeledField(
                                  label: 'Price (optional)',
                                  controller: _price,
                                  hint: 'RM per pack',
                                  number: true)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: LabeledField(
                                  label: 'Where to buy (optional)',
                                  controller: _where,
                                  hint: 'Shop or link')),
                        ]),
                        const SizedBox(height: 14),
                        FieldLabel('Used in designs (optional)',
                            child: ChoiceChips(
                              options: s.designs.map((d) => d.name).toList(),
                              scroll: false,
                              selected: (n) => _usedIn.contains(n),
                              onSelected: (n) => setState(() => _usedIn
                                      .contains(n)
                                  ? _usedIn.remove(n)
                                  : _usedIn.add(n)),
                            )),
                      ]),
                ),
              ],
            ),
          ),
          FormActions(saveLabel: 'Save material', onSave: _save),
        ]),
      ),
    );
  }
}
