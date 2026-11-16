import 'package:flutter/material.dart';

import '../models/models.dart';

/// Demo data for the prototype. Step 2 replaces this with Firestore.
class DemoData {
  /// The prototype pretends today is Sat 24 Oct 2026 (convention day).
  static final today = DateTime(2026, 10, 24);

  static List<Design> designs() => [
        Design(id: 'd1', category: Categories.phoneCharms, name: 'Coquette Bow Phone Charm', detail: 'Pink bow', lengthCm: 18, price: 15, qty: 2, colour: const Color(0xFFE0577A)),
        Design(id: 'd2', category: Categories.phoneCharms, name: 'Cherry charm', detail: '', lengthCm: 16, price: 15, qty: 10, colour: const Color(0xFFC0283D)),
        Design(id: 'd3', category: Categories.phoneCharms, name: 'Strawberry charm', detail: '', lengthCm: 12, price: 10, qty: 1, colour: const Color(0xFFE8778E)),
        Design(id: 'd4', category: Categories.bracelets, name: 'Lilac Butterfly Bracelet', detail: '', lengthCm: 16, price: 18, qty: 8, colour: const Color(0xFF9B7BC8)),
        Design(id: 'd5', category: Categories.bracelets, name: 'Ocean bracelet', detail: '', lengthCm: 17, price: 10, qty: 7, colour: const Color(0xFF2F7FB5)),
        Design(id: 'd6', category: Categories.bracelets, name: 'Sunset bracelet', detail: '', lengthCm: 16, price: 15, qty: 6, colour: const Color(0xFFE8833A)),
        Design(id: 'd7', category: Categories.necklaces, name: 'Pearl Daisy Choker', detail: 'Pearl and daisy', lengthCm: 35, price: 25, qty: 2, colour: const Color(0xFFD8C9B0)),
        Design(id: 'd8', category: Categories.necklaces, name: 'Moonlit necklace', detail: 'Deep blue', lengthCm: 40, price: 35, qty: 1, colour: const Color(0xFF4B3F72), oneOfAKind: true),
        Design(id: 'd9', category: Categories.hairClips, name: 'Pearl hair clip', detail: '', lengthCm: 6, price: 8, qty: 0, colour: const Color(0xFFCDBBA0)),
        Design(id: 'd10', category: Categories.hairClips, name: 'Daisy clip', detail: '', lengthCm: 5, price: 8, qty: 9, colour: const Color(0xFFE2B04A)),
      ];

  static List<MaterialItem> materials() => [
        MaterialItem(id: 'm1', type: 'Beads', name: 'Seed beads · pastel pink', usedIn: 'Used in Coquette Bow, Strawberry', qty: 2, unit: 'packs', reorderBelow: 3, colour: const Color(0xFFF2B9C6)),
        MaterialItem(id: 'm2', type: 'Beads', name: 'Glass pearls 6 mm', usedIn: 'Used in Pearl Daisy, Pearl clip', qty: 150, unit: 'pcs', reorderBelow: 50, colour: const Color(0xFFF3EBDD)),
        MaterialItem(id: 'm3', type: 'Beads', name: 'Letter beads (A–Z)', usedIn: 'Used in name bracelets', qty: 1, unit: 'packs', reorderBelow: 2, colour: const Color(0xFF2F7FB5)),
        MaterialItem(id: 'm4', type: 'Strings & cords', name: 'Elastic cord 0.8 mm', usedIn: 'Bracelets', qty: 1, unit: 'rolls', reorderBelow: 2, colour: const Color(0xFF9DB89A)),
        MaterialItem(id: 'm5', type: 'Strings & cords', name: 'Nylon thread', usedIn: 'Phone charms, necklaces', qty: 3, unit: 'spools', reorderBelow: 2, colour: const Color(0xFFB8B8C0)),
        MaterialItem(id: 'm6', type: 'Charms', name: 'Bow charms (gold)', usedIn: 'Coquette Bow', qty: 12, unit: 'pcs', reorderBelow: 10, colour: const Color(0xFFD3A741)),
        MaterialItem(id: 'm7', type: 'Clips & findings', name: 'Hair clip blanks', usedIn: 'Hair clips', qty: 0, unit: 'pcs', reorderBelow: 10, colour: const Color(0xFF8E8E99)),
        MaterialItem(id: 'm8', type: 'Clips & findings', name: 'Phone strap loops', usedIn: 'Phone charms', qty: 25, unit: 'pcs', reorderBelow: 15, colour: const Color(0xFF636369)),
      ];

  /// Past and current conventions (used by Booth sale and Best sellers).
  static List<EventInfo> pastEvents() => [
        EventInfo(id: 'kwc', name: 'Kuching Waterfront Craft Market', date: DateTime(2026, 10, 24), venue: 'Kuching Waterfront, Kuching', time: '4 pm – 10 pm'),
        EventInfo(id: 'mak', name: 'Maker Weekend', date: DateTime(2026, 9, 26), venue: 'Kuching'),
        EventInfo(id: 'art', name: 'Art Market', date: DateTime(2026, 8, 22), venue: 'Kuching'),
      ];

  /// Units sold per event per design (demo history).
  static Map<String, Map<String, int>> soldByEvent() => {
        'kwc': {'d1': 12, 'd4': 9, 'd2': 8, 'd7': 6, 'd3': 4, 'd6': 2, 'd10': 1},
        'mak': {'d1': 10, 'd4': 8, 'd7': 7, 'd5': 7, 'd2': 6, 'd6': 3, 'd10': 2},
        'art': {'d1': 9, 'd4': 7, 'd7': 6, 'd3': 6, 'd9': 6, 'd5': 5, 'd2': 4},
      };

  static List<CustomOrder> orders() => [
        CustomOrder(id: 'o11', customer: 'Mira', contact: '@mira.k (Instagram)', via: 'Instagram', type: 'Necklace', item: 'Necklace · ivory and grey beads', palette: 'Ivory / grey', lengthCm: 40, price: 35, deposit: 0, due: DateTime(2026, 10, 23), stage: 0, notes: 'Asked if the chain can be a little longer.'),
        CustomOrder(id: 'o12', customer: 'Nadia', contact: '+60 12-345 6789 (WhatsApp)', via: 'WhatsApp', type: 'Phone charm', item: 'Phone charm · pearl and smoke', palette: 'Pearl / smoke', lengthCm: 18, price: 15, deposit: 5, due: DateTime(2026, 10, 28), stage: 2, notes: 'Add a small moon charm at the end.', pictures: 1),
        CustomOrder(id: 'o14', customer: 'Aina Rahman', contact: '@aina.rhmn (Instagram)', via: 'Instagram', type: 'Bracelet', item: 'Rose bracelet · silver clasp', palette: 'Blush / pearl / smoke', lengthCm: 16, price: 18, deposit: 10, due: DateTime(2026, 10, 30), stage: 1, notes: 'Wants the clasp in silver, not gold.'),
        CustomOrder(id: 'o10', customer: 'Sara', contact: '@sara.clips (Instagram)', via: 'Instagram', type: 'Hair clip', item: 'Hair clip · ivory pearls', palette: 'Ivory pearls', lengthCm: 6, price: 12, deposit: 12, due: DateTime(2026, 10, 22), stage: 4, notes: 'Collected at Maker Weekend.', pictures: 1),
      ];

  static List<CalendarItem> calendar() => [
        CalendarItem(id: 'c1', kind: CalendarKind.stock, date: DateTime(2026, 10, 22), title: 'Stock check', sub: 'For Kuching Waterfront Craft Market', forEventId: 'kwc', done: true, isTask: true),
        CalendarItem(id: 'c2', kind: CalendarKind.event, date: DateTime(2026, 10, 24), title: 'Kuching Waterfront Craft Market', time: '4 pm – 10 pm', place: 'Kuching Waterfront, Kuching'),
        CalendarItem(id: 'c3', kind: CalendarKind.stock, date: DateTime(2026, 10, 29), title: 'Stock check', sub: 'For Community Pop-up · count and restock', forEventId: 'pop', isTask: true),
        CalendarItem(id: 'c4', kind: CalendarKind.event, date: DateTime(2026, 10, 31), title: 'Community Pop-up', time: '11 am – 6 pm', place: 'The Spring Mall, Kuching'),
        CalendarItem(id: 'c5', kind: CalendarKind.event, date: DateTime(2026, 11, 7), title: 'Satok Weekend Bazaar', time: '5 pm – 11 pm', place: 'Satok, Kuching'),
        CalendarItem(id: 'c6', kind: CalendarKind.stock, date: DateTime(2026, 11, 12), title: 'Stock check', sub: 'For Miri Makers Bazaar', isTask: true),
        CalendarItem(id: 'c7', kind: CalendarKind.event, date: DateTime(2026, 11, 14), title: 'Miri Makers Bazaar', time: '14–15 Nov · 10 am – 9 pm', place: 'Bintang Megamall, Miri'),
        CalendarItem(id: 'c8', kind: CalendarKind.event, date: DateTime(2026, 11, 21), title: 'Sibu Craft Night', time: '6 pm – 11 pm', place: 'Sibu Central Market, Sibu'),
        CalendarItem(id: 'c9', kind: CalendarKind.event, date: DateTime(2026, 11, 28), title: 'Borneo Art & Craft Fair', time: '28–29 Nov · 10 am – 8 pm', place: 'Borneo Convention Centre (BCCK), Kuching'),
      ];

  static const trends = [
    Trend(id: 'fruit', name: 'Fruit & dessert charms', status: 'Rising', category: Categories.phoneCharms, palette: [Color(0xFFC0283D), Color(0xFFF2B9C6), Color(0xFFFFF1E0), Color(0xFF9DB89A)], why: 'Close to your Cherry charm, one of your top sellers', when: 'Good for Borneo Art & Craft Fair · 28 Nov'),
    Trend(id: 'names', name: 'Name & initial beads', status: 'Popular', category: Categories.bracelets, palette: [Color(0xFF2F7FB5), Color(0xFFFFFFFF), Color(0xFFF2B9C6), Color(0xFF121212)], why: 'Asked for in 4 of your custom orders this month', when: 'Gift idea for December'),
    Trend(id: 'pearl', name: 'Pearl & gold mixes', status: 'Rising', category: Categories.bracelets, palette: [Color(0xFFF3EBDD), Color(0xFFE9DCC5), Color(0xFFD3A741), Color(0xFFFFFFFF)], why: 'Fits your RM 15–18 bracelet range', when: 'Good for Miri Makers Bazaar · 14 Nov'),
    Trend(id: 'butterfly', name: 'Butterfly charms', status: 'Fading', category: Categories.phoneCharms, palette: [Color(0xFF9B7BC8), Color(0xFFF2B9C6), Color(0xFFE2F4E7), Color(0xFFFFFFFF)], why: 'Still sells, but fewer people are searching for it', when: 'Use up what you have'),
  ];

  static final eventSuggestions = [
    EventSuggestion(id: 'xmas', name: 'Christmas Bazaar', when: '5–6 Dec', where: 'Shopping mall atrium, Kuching', note: 'Vendor sign-up closes 25 Nov', date: DateTime(2026, 12, 5)),
    EventSuggestion(id: 'ny', name: 'New Year Artisan Pop-Up', when: '2 Jan', where: 'Kuching Waterfront, Kuching', note: 'Booth fee and slots on organiser page', date: DateTime(2027, 1, 2)),
  ];
}
