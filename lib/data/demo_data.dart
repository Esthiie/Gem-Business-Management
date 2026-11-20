import 'package:flutter/material.dart';

import '../models/models.dart';

/// Demo data for the prototype. Step 2 replaces this with Firestore.
class DemoData {
  /// The prototype pretends today is Sat 24 Oct 2026 (convention day).
  static final today = DateTime(2026, 10, 24);

  static List<Design> designs() => [
        Design(id: 'd1', category: Categories.phoneCharms, name: 'Coquette Bow Phone Charm', detail: '', price: 15, qty: 2, colour: const Color(0xFFE0577A)),
        Design(id: 'd2', category: Categories.phoneCharms, name: 'Cherry charm', detail: '', price: 15, qty: 10, colour: const Color(0xFFC0283D)),
        Design(id: 'd3', category: Categories.phoneCharms, name: 'Strawberry charm', detail: '', price: 10, qty: 1, colour: const Color(0xFFE8778E)),
        Design(id: 'd4', category: Categories.phoneCharms, name: 'Pearl Heart charm', detail: '', price: 12, qty: 5, colour: const Color(0xFFD8C9B0)),
        Design(id: 'd5', category: Categories.bracelets, name: 'Violetta', detail: '', price: 15, qty: 2, colour: const Color(0xFF8E6CCB)),
        Design(id: 'd6', category: Categories.bracelets, name: 'Painted Light', detail: '', price: 15, qty: 1, colour: const Color(0xFFE8B4B8)),
        Design(id: 'd7', category: Categories.bracelets, name: 'Nightwing', detail: '', price: 15, qty: 1, colour: const Color(0xFF3A3550)),
        Design(id: 'd8', category: Categories.bracelets, name: 'Purple Monarch', detail: 'Monarch Bracelets series', price: 15, qty: 1, colour: const Color(0xFF5B4691)),
        Design(id: 'd9', category: Categories.bracelets, name: 'Black Monarch', detail: 'Monarch Bracelets series', price: 15, qty: 1, colour: const Color(0xFF2A2A30)),
        Design(id: 'd10', category: Categories.bracelets, name: 'Pink Monarch', detail: 'Monarch Bracelets series', price: 15, qty: 1, colour: const Color(0xFFE0789F)),
        Design(id: 'd11', category: Categories.bracelets, name: 'Calathea & Scabiosa', detail: '', price: 14, qty: 1, colour: const Color(0xFF9DB89A)),
        Design(id: 'd12', category: Categories.bracelets, name: 'Roseate Pearl Regent', detail: '', price: 12, qty: 1, colour: const Color(0xFFE8C4C4)),
        Design(id: 'd13', category: Categories.necklaces, name: 'Liberated Grace', detail: '', price: 24, qty: 1, colour: const Color(0xFFD8C9B0)),
        Design(id: 'd14', category: Categories.necklaces, name: 'Crowned Embellishment', detail: '', price: 25, qty: 1, colour: const Color(0xFFD3A741)),
        Design(id: 'd15', category: Categories.necklaces, name: 'Quintessa', detail: '', price: 22, qty: 1, colour: const Color(0xFF9DB8D8)),
        Design(id: 'd16', category: Categories.necklaces, name: 'Divine Reckoning', detail: '', price: 36, qty: 1, colour: const Color(0xFF4B3F72)),
        Design(id: 'd17', category: Categories.necklaces, name: 'Monarch’s Champion', detail: '', price: 20, qty: 1, colour: const Color(0xFF7A5BB5)),
        Design(id: 'd18', category: Categories.necklaces, name: 'Heart of Reverence', detail: '', price: 25, qty: 1, colour: const Color(0xFFC0283D)),
        Design(id: 'd19', category: Categories.necklaces, name: 'Sanrio Heartstrings – My Melody', detail: 'Sanrio Heartstrings series', price: 50, qty: 1, colour: const Color(0xFFF2B9C6)),
        Design(id: 'd20', category: Categories.necklaces, name: 'Sanrio Heartstrings – Kuromi', detail: 'Sanrio Heartstrings series', price: 50, qty: 1, colour: const Color(0xFF5B4691)),
        Design(id: 'd21', category: Categories.necklaces, name: 'Sanrio Heartstrings – Cinnamoroll', detail: 'Sanrio Heartstrings series', price: 50, qty: 1, colour: const Color(0xFF8FB8E0)),
        Design(id: 'd22', category: Categories.lanyards, name: 'Divina Vulpes Lanyard', detail: '', lengthCm: 75, price: 60, qty: 1, colour: const Color(0xFFC8743A)),
        Design(id: 'd23', category: Categories.lanyards, name: 'Divina Vulpes; Mix Lanyard', detail: '', lengthCm: 75, price: 60, qty: 1, colour: const Color(0xFFB5651D)),
        Design(id: 'd24', category: Categories.lanyards, name: 'Tradescantia Lanyard', detail: '', lengthCm: 75, price: 60, qty: 1, colour: const Color(0xFFA9A6D6)),
        Design(id: 'd25', category: Categories.lanyards, name: 'Her Majesty Lanyard', detail: '', lengthCm: 75, price: 60, qty: 1, colour: const Color(0xFF7A5BB5)),
        Design(id: 'd26', category: Categories.hairClips, name: 'Cinnamoroll Clips', detail: 'Sanrio Clip-It series', price: 12, qty: 6, colour: const Color(0xFF8FB8E0)),
        Design(id: 'd27', category: Categories.hairClips, name: 'Kuromi Clips', detail: 'Sanrio Clip-It series', price: 12, qty: 2, colour: const Color(0xFF2A2A30)),
        Design(id: 'd28', category: Categories.hairClips, name: 'Pompompurin Clips', detail: 'Sanrio Clip-It series', price: 12, qty: 0, colour: const Color(0xFFE2B04A)),
        Design(id: 'd29', category: Categories.earrings, name: 'Sanrio Dangles – My Melody', detail: 'Sanrio Dangles · pink and white', price: 15, qty: 3, colour: const Color(0xFFF2B9C6)),
        Design(id: 'd30', category: Categories.earrings, name: 'Sanrio Dangles – Cinnamoroll', detail: 'Sanrio Dangles · pristine white', price: 15, qty: 2, colour: const Color(0xFFC9DDF2)),
        Design(id: 'd31', category: Categories.earrings, name: 'Sanrio Dangles – Kuromi', detail: 'Sanrio Dangles · regal purple and black', price: 15, qty: 1, colour: const Color(0xFF5B4691)),
        Design(id: 'd32', category: Categories.earrings, name: 'Sanrio Dangles – Kiroppi', detail: 'Sanrio Dangles · refreshing green', price: 15, qty: 2, colour: const Color(0xFF6FB36A)),
      ];

  /// Conventions Faith has joined (Booth sale, Sales record, Best sellers).
  static List<EventInfo> pastEvents() => [
        EventInfo(id: 'xkid', name: 'XKid (Vendor’s Booths)', dates: '23–24 Oct', date: DateTime(2026, 10, 23), endDate: DateTime(2026, 10, 24), venue: 'Kuching', time: '11 am – 7 pm'),
        EventInfo(id: 'tora', name: 'Torabera Fest', dates: '10–11 Oct', date: DateTime(2026, 10, 10), endDate: DateTime(2026, 10, 11), venue: 'Kuching'),
        EventInfo(id: 'aero', name: 'Aeroville', dates: 'Sat 26 Sep', date: DateTime(2026, 9, 26), venue: 'Kuching'),
        EventInfo(id: 'bcm', name: 'Borneo Culture Museum', dates: 'Sat 12 Sep', date: DateTime(2026, 9, 12), venue: 'Kuching'),
      ];

  /// Every customer at the booth, newest first.
  static List<Sale> sales() => [
        Sale(id: 'x10', eventId: 'xkid', customerNo: 10, time: DateTime(2026, 10, 24, 16, 5), method: PayMethod.cash, lines: const [SaleLine('d16', 1, 36)]),
        Sale(id: 'x9', eventId: 'xkid', customerNo: 9, time: DateTime(2026, 10, 24, 15, 51), method: PayMethod.qr, lines: const [SaleLine('d26', 2, 12), SaleLine('d31', 1, 15)]),
        Sale(id: 'x8', eventId: 'xkid', customerNo: 8, time: DateTime(2026, 10, 24, 15, 15), method: PayMethod.cash, lines: const [SaleLine('d5', 1, 15), SaleLine('d8', 1, 15)]),
        Sale(id: 'x7', eventId: 'xkid', customerNo: 7, time: DateTime(2026, 10, 24, 14, 31), method: PayMethod.qr, lines: const [SaleLine('d1', 2, 15)]),
        Sale(id: 'x6', eventId: 'xkid', customerNo: 6, time: DateTime(2026, 10, 24, 11, 20), method: PayMethod.qr, lines: const [SaleLine('d19', 1, 50)]),
        Sale(id: 'x5', eventId: 'xkid', customerNo: 5, time: DateTime(2026, 10, 23, 18, 40), method: PayMethod.qr, lines: const [SaleLine('d22', 1, 60)]),
        Sale(id: 'x4', eventId: 'xkid', customerNo: 4, time: DateTime(2026, 10, 23, 17, 12), method: PayMethod.cash, lines: const [SaleLine('d2', 1, 15), SaleLine('d3', 1, 10)]),
        Sale(id: 'x3', eventId: 'xkid', customerNo: 3, time: DateTime(2026, 10, 23, 16, 30), method: PayMethod.qr, lines: const [SaleLine('d18', 1, 25)]),
        Sale(id: 'x2', eventId: 'xkid', customerNo: 2, time: DateTime(2026, 10, 23, 15, 48), method: PayMethod.cash, lines: const [SaleLine('d27', 1, 12)]),
        Sale(id: 'x1', eventId: 'xkid', customerNo: 1, time: DateTime(2026, 10, 23, 15, 5), method: PayMethod.cash, lines: const [SaleLine('d29', 1, 15), SaleLine('d26', 1, 12)]),
        Sale(id: 't4', eventId: 'tora', customerNo: 4, time: DateTime(2026, 10, 11, 17, 30), method: PayMethod.qr, lines: const [SaleLine('d10', 1, 15), SaleLine('d15', 1, 22)]),
        Sale(id: 't3', eventId: 'tora', customerNo: 3, time: DateTime(2026, 10, 11, 14, 10), method: PayMethod.cash, lines: const [SaleLine('d24', 1, 60)]),
        Sale(id: 't2', eventId: 'tora', customerNo: 2, time: DateTime(2026, 10, 10, 16, 45), method: PayMethod.qr, lines: const [SaleLine('d1', 3, 15)]),
        Sale(id: 't1', eventId: 'tora', customerNo: 1, time: DateTime(2026, 10, 10, 13, 20), method: PayMethod.cash, lines: const [SaleLine('d6', 1, 15), SaleLine('d28', 2, 12)]),
        Sale(id: 'a3', eventId: 'aero', customerNo: 3, time: DateTime(2026, 9, 26, 18, 5), method: PayMethod.qr, lines: const [SaleLine('d14', 1, 25)]),
        Sale(id: 'a2', eventId: 'aero', customerNo: 2, time: DateTime(2026, 9, 26, 15, 40), method: PayMethod.cash, lines: const [SaleLine('d2', 2, 15)]),
        Sale(id: 'a1', eventId: 'aero', customerNo: 1, time: DateTime(2026, 9, 26, 12, 15), method: PayMethod.qr, lines: const [SaleLine('d12', 1, 12), SaleLine('d4', 1, 12)]),
        Sale(id: 'b2', eventId: 'bcm', customerNo: 2, time: DateTime(2026, 9, 12, 16, 20), method: PayMethod.cash, lines: const [SaleLine('d11', 1, 14)]),
        Sale(id: 'b1', eventId: 'bcm', customerNo: 1, time: DateTime(2026, 9, 12, 11, 50), method: PayMethod.qr, lines: const [SaleLine('d1', 1, 15), SaleLine('d27', 1, 12)]),
      ];

  /// Units sold per design per event (used by Best sellers).
  static Map<String, Map<String, int>> soldByEvent() => {
        'xkid': {'d1': 12, 'd26': 10, 'd29': 8, 'd2': 6, 'd27': 5, 'd31': 3, 'd5': 2},
        'tora': {'d1': 10, 'd26': 8, 'd2': 7, 'd29': 6, 'd3': 5, 'd28': 4, 'd31': 2},
        'aero': {'d1': 9, 'd26': 6, 'd3': 6, 'd28': 6, 'd29': 5, 'd2': 4, 'd27': 3},
      };

  static List<CustomOrder> orders() => [
        CustomOrder(id: 'o11', customer: 'Mira', contact: '@mira.k (Instagram)', via: 'Instagram', type: 'Necklace', item: 'Necklace · ivory and grey beads', palette: 'Ivory / grey', lengthCm: 40, price: 35, deposit: 0, due: DateTime(2026, 10, 23), stage: 0, notes: 'Asked if the chain can be a little longer.'),
        CustomOrder(id: 'o12', customer: 'Nadia', contact: '+60 12-345 6789 (WhatsApp)', via: 'WhatsApp', type: 'Phone charm', item: 'Phone charm · pearl and smoke', palette: 'Pearl / smoke', lengthCm: 18, price: 15, deposit: 5, due: DateTime(2026, 10, 28), stage: 2, notes: 'Add a small moon charm at the end.', pictures: 1),
        CustomOrder(id: 'o14', customer: 'Aina Rahman', contact: '@aina.rhmn (Instagram)', via: 'Instagram', type: 'Bracelet', item: 'Rose bracelet · silver clasp', palette: 'Blush / pearl / smoke', lengthCm: 16, price: 18, deposit: 10, due: DateTime(2026, 10, 30), stage: 1, notes: 'Wants the clasp in silver, not gold.'),
        CustomOrder(id: 'o10', customer: 'Sara', contact: '@sara.clips (Instagram)', via: 'Instagram', type: 'Hair clip', item: 'Hair clip · ivory pearls', palette: 'Ivory pearls', lengthCm: 6, price: 12, deposit: 12, due: DateTime(2026, 10, 22), stage: 4, notes: 'Collected at Torabera Fest.', pictures: 1),
      ];

  static List<CalendarItem> calendar() => [
        CalendarItem(id: 'c1', kind: CalendarKind.stock, date: DateTime(2026, 10, 22), title: 'Stock check', sub: 'For XKid (Vendor’s Booths)', forEventId: 'xkid', done: true, isTask: true),
        CalendarItem(id: 'c2', kind: CalendarKind.event, date: DateTime(2026, 10, 24), title: 'XKid (Vendor’s Booths)', time: '23–24 Oct · 11 am – 7 pm', place: 'Kuching'),
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
