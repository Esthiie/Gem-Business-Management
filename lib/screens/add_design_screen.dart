import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/colour_picker.dart';
import '../widgets/common.dart';

/// Add a design to the collection.
class AddDesignScreen extends StatefulWidget {
  const AddDesignScreen({super.key});

  @override
  State<AddDesignScreen> createState() => _AddDesignScreenState();
}

class _AddDesignScreenState extends State<AddDesignScreen> {
  String _cat = Categories.phoneCharms;
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _length = TextEditingController(); // shows "0" as the hint
  bool _one = false;
  int _qty = 10;
  int _alert = 2;
  List<Color> _colours = [];
  final _desc = TextEditingController();
  bool _hasDesc = false;

  bool get _isNecklace => _cat == Categories.necklaces;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _length.dispose();
    _desc.dispose();
    super.dispose();
  }

  /// Demo AI description (FR-AI-01). Step 3 calls the AI service instead.
  /// Faith can edit the text afterwards.
  void _writeDescription() {
    final name = _name.text.trim().isEmpty ? 'This piece' : _name.text.trim();
    const lines = {
      Categories.phoneCharms:
          'a cute beaded phone charm that adds a pop of colour to your phone or bag.',
      Categories.bracelets:
          'a soft, stretchy beaded bracelet that stacks well with your favourites.',
      Categories.necklaces:
          'a one-of-a-kind beaded necklace with a little sparkle for every day.',
      Categories.lanyards:
          'a sturdy beaded lanyard for your keys, ID or camera.',
      Categories.hairClips:
          'a sweet beaded hair clip that holds well and looks lovely in photos.',
      Categories.earrings:
          'light beaded dangle earrings that are comfy to wear all day.',
    };
    final len = _length.text.trim();
    _desc.text = '$name is ${lines[_cat]}'
        '${_isNecklace && len.isNotEmpty && len != '0' ? ' Length: $len cm.' : ''}'
        ' Made in small batches by Queens.Trinket.';
    setState(() => _hasDesc = true);
  }

  void _save() {
    final s = context.read<AppState>();
    if (_name.text.trim().isEmpty) {
      showToast(context, 'Give the design a name first.');
      return;
    }
    s.addDesign(Design(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      category: _cat,
      name: _name.text.trim(),
      detail: '',
      price: double.tryParse(_price.text) ?? 0,
      qty: _one ? 1 : _qty,
      colour: _colours.isNotEmpty ? _colours.first : AppColors.lavender,
      colours: _colours,
      lengthCm: _isNecklace ? double.tryParse(_length.text) : null,
      oneOfAKind: _one,
      lowAlert: _alert,
      description: _desc.text,
    ));
    showToast(context, 'Design saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const AppHeader(title: 'Add design', backLabel: 'Stock'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PhotoBox(
                            onTap: () => showToast(context,
                                'Camera / gallery comes with the backend step.')),
                        const SizedBox(height: 16),
                        FieldLabel('Category',
                            child: ChoiceChips(
                              options: Categories.all,
                              scroll: false,
                              selected: (c) => c == _cat,
                              onSelected: (c) => setState(() => _cat = c),
                            )),
                        const SizedBox(height: 8),
                        LabeledField(
                            label: 'Design name',
                            controller: _name,
                            hint: 'e.g. Strawberry charm'),
                        const SizedBox(height: 14),
                        FieldLabel('Description (Optional)',
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _desc,
                                    maxLines: 4,
                                    minLines: 3,
                                    style: AppText.body(14),
                                    decoration: const InputDecoration(
                                        hintText:
                                            'What makes this piece special?'),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Expanded(
                                      child: Text(
                                          _hasDesc
                                              ? 'AI draft · edit it as you like'
                                              : 'Type your own or let AI write one',
                                          style: AppText.body(12,
                                              color: _hasDesc
                                                  ? AppColors.purple
                                                  : AppColors.muted,
                                              weight: FontWeight.w600)),
                                    ),
                                    SecondaryButton(
                                        _hasDesc
                                            ? 'Rewrite with AI'
                                            : 'Write it with AI',
                                        height: 40,
                                        icon: Icons.auto_awesome_outlined,
                                        onPressed: _writeDescription),
                                  ]),
                                ])),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                              child: LabeledField(
                                  label: 'Price',
                                  controller: _price,
                                  hint: '0.00',
                                  suffix: 'RM',
                                  number: true)),
                          if (_isNecklace) ...[
                            const SizedBox(width: 10),
                            Expanded(
                                child: LabeledField(
                                    label: 'Length (Optional)',
                                    controller: _length,
                                    hint: '0',
                                    suffix: 'cm',
                                    number: true)),
                          ],
                        ]),
                        const SizedBox(height: 14),
                        CardBox(
                          child: SwitchRow(
                            title: 'One-of-a-kind piece',
                            subtitle:
                                'Only 1 made. Marked sold out after it sells.',
                            value: _one,
                            onChanged: (v) => setState(() => _one = v),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CardBox(
                          child: ColourChooser(
                            colours: _colours,
                            onChanged: (c) => setState(() => _colours = c),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CardBox(
                          child: Column(children: [
                            Row(children: [
                              Expanded(
                                  child: Text('Quantity in stock',
                                      style: AppText.body(15,
                                          weight: FontWeight.w600))),
                              _one
                                  ? Text('1 (one-of-a-kind)',
                                      style: AppText.body(14,
                                          weight: FontWeight.w700))
                                  : QtyStepper(
                                      text: '$_qty',
                                      onLess: () => setState(() =>
                                          _qty = (_qty - 1).clamp(0, 999)),
                                      onMore: () =>
                                          setState(() => _qty = _qty + 1)),
                            ]),
                            const Divider(height: 24),
                            Row(children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Low-stock alert at',
                                          style: AppText.body(15,
                                              weight: FontWeight.w600)),
                                      Text(
                                          'Shows on Home and Stock when it drops to this',
                                          style: AppText.body(12,
                                              color: AppColors.muted)),
                                    ]),
                              ),
                              QtyStepper(
                                  text: '$_alert',
                                  onLess: () => setState(
                                      () => _alert = (_alert - 1).clamp(0, 99)),
                                  onMore: () =>
                                      setState(() => _alert = _alert + 1)),
                            ]),
                          ]),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          FormActions(saveLabel: 'Save design', onSave: _save),
        ]),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.lavenderTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lavender, width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.photo_camera_outlined, size: 28),
          const SizedBox(height: 6),
          Text('Add photo', style: AppText.body(14, weight: FontWeight.w700)),
          Text('Take or choose one',
              style: AppText.body(12, color: AppColors.muted)),
        ]),
      ),
    );
  }
}
