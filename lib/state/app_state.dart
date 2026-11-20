import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/models.dart';

/// All app data lives here (Provider). Screens read it with
/// `context.watch<AppState>()` and change it through the methods below.
///
/// Step 2: swap the demo lists for Firestore collections. The method names
/// can stay the same so the screens do not need to change.
class AppState extends ChangeNotifier {
  AppState() {
    designs = DemoData.designs();
    sales = DemoData.sales();
    orders = DemoData.orders();
    calendar = DemoData.calendar();
    events = DemoData.pastEvents();
    soldByEvent = DemoData.soldByEvent();
  }

  final DateTime today = DemoData.today;

  // ---------------- bottom tabs ----------------
  /// 0 Home, 1 Stock, 2 Orders, 3 Calendar, 4 AI Assistant.
  int tab = 0;

  void goToTab(int i) {
    tab = i;
    notifyListeners();
  }

  // ---------------- profile & settings ----------------
  String shopName = 'Queens.Trinket';
  String nickname = 'Faith';
  String email = 'faith@queenstrinket.com';
  bool faceId = true;

  void updateProfile({String? shop, String? nick}) {
    if (shop != null) shopName = shop;
    if (nick != null) nickname = nick;
    notifyListeners();
  }

  void setFaceId(bool v) {
    faceId = v;
    notifyListeners();
  }

  // ---------------- offline / sync ----------------
  /// Demo switch (Settings > Data). When offline, changes queue up and the
  /// header shows "Offline · n to sync".
  bool online = false;
  int pendingSync = 3;
  String lastSynced = '2 min ago';

  void setOnline(bool v) {
    online = v;
    if (online) {
      pendingSync = 0;
      lastSynced = 'just now';
    }
    notifyListeners();
  }

  void _changed() {
    if (!online) pendingSync++;
    notifyListeners();
  }

  // ---------------- collection ----------------
  late List<Design> designs;

  Design? designById(String id) {
    for (final d in designs) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<Design> designsIn(String category) =>
      designs.where((d) => d.category == category).toList();

  List<Design> get lowDesigns => designs.where((d) => d.isLow).toList();

  void addDesign(Design d) {
    designs.add(d);
    _changed();
  }

  // ---------------- sales & best sellers ----------------
  late List<EventInfo> events;
  late Map<String, Map<String, int>> soldByEvent;
  late List<Sale> sales;
  int _nextSale = 100;

  /// Today's convention (the live booth).
  EventInfo get liveEvent => events.first;

  EventInfo eventById(String id) =>
      events.firstWhere((e) => e.id == id, orElse: () => events.first);

  Sale? saleById(String id) {
    for (final x in sales) {
      if (x.id == id) return x;
    }
    return null;
  }

  /// Sales for one event (or all when [eventId] is null), newest first.
  List<Sale> salesFor(String? eventId, {PayMethod? method}) => sales
      .where((x) =>
          (eventId == null || x.eventId == eventId) &&
          (method == null || x.method == method))
      .toList()
    ..sort((a, b) => b.time.compareTo(a.time));

  List<Sale> get salesToday =>
      sales.where((x) => sameDay(x.time, today)).toList();

  /// Booth sale: deducts stock, adds to best sellers and saves the customer
  /// with how they paid. Returns the new sale.
  Sale? recordSale(String eventId, Map<String, int> cart, PayMethod method) {
    final lines = <SaleLine>[];
    final sold = soldByEvent.putIfAbsent(eventId, () => {});
    cart.forEach((id, q) {
      final d = designById(id);
      if (d == null || q <= 0) return;
      d.qty = (d.qty - q).clamp(0, 1 << 30);
      sold[id] = (sold[id] ?? 0) + q;
      lines.add(SaleLine(id, q, d.price));
    });
    if (lines.isEmpty) return null;
    final no = sales
            .where((x) => x.eventId == eventId)
            .fold(0, (m, x) => x.customerNo > m ? x.customerNo : m) +
        1;
    final now = DateTime.now();
    final sale = Sale(
      id: 's${_nextSale++}',
      eventId: eventId,
      customerNo: no,
      time: DateTime(today.year, today.month, today.day, now.hour, now.minute),
      lines: lines,
      method: method,
    );
    sales.insert(0, sale);
    _changed();
    return sale;
  }

  /// Delete a wrong sale: the pieces go back into stock and the totals
  /// and best sellers are recalculated.
  void deleteSale(Sale sale) {
    final sold = soldByEvent[sale.eventId];
    for (final l in sale.lines) {
      final d = designById(l.designId);
      if (d != null) d.qty += l.qty;
      if (sold != null && sold.containsKey(l.designId)) {
        sold[l.designId] = (sold[l.designId]! - l.qty).clamp(0, 1 << 30);
      }
    }
    sales.remove(sale);
    _changed();
  }

  /// Units sold per design for one event, or all events when [eventId] is null.
  Map<String, int> soldFor(String? eventId) {
    if (eventId != null) return Map.of(soldByEvent[eventId] ?? {});
    final all = <String, int>{};
    for (final m in soldByEvent.values) {
      m.forEach((k, v) => all[k] = (all[k] ?? 0) + v);
    }
    return all;
  }

  double revenueFor(String? eventId) {
    double sum = 0;
    soldFor(eventId).forEach((id, q) => sum += q * (designById(id)?.price ?? 0));
    return sum;
  }

  int unitsFor(String? eventId) =>
      soldFor(eventId).values.fold(0, (a, b) => a + b);

  /// Ranked (designId, units) pairs, best first.
  List<MapEntry<String, int>> ranking(String? eventId) {
    final list = soldFor(eventId).entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Events that have best-seller history.
  List<EventInfo> get rankedEvents =>
      events.where((e) => soldByEvent.containsKey(e.id)).toList();

  // ---------------- custom orders ----------------
  late List<CustomOrder> orders;
  int _nextOrder = 15;

  CustomOrder? orderById(String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<CustomOrder> get activeOrders => orders.where((o) => !o.isDone).toList();

  int daysLeft(CustomOrder o) => o.due.difference(today).inDays;

  bool isOverdue(CustomOrder o) => !o.isDone && daysLeft(o) < 0;
  bool isDueSoon(CustomOrder o) =>
      !o.isDone && daysLeft(o) >= 0 && daysLeft(o) <= 4;

  void nextStage(CustomOrder o) {
    o.stage = (o.stage + 1).clamp(0, 4);
    _changed();
  }

  void previousStage(CustomOrder o) {
    o.stage = (o.stage - 1).clamp(0, 4);
    _changed();
  }

  void updateOrder(CustomOrder o) => _changed();

  String addOrder(CustomOrder Function(String id) build) {
    final id = 'o${_nextOrder++}';
    orders.insert(0, build(id));
    _changed();
    return id;
  }

  // ---------------- calendar ----------------
  late List<CalendarItem> calendar;
  int _nextCal = 100;

  String newCalendarId() => 'c${_nextCal++}';

  void addCalendarItem(CalendarItem item) {
    calendar.add(item);
    calendar.sort((a, b) => a.date.compareTo(b.date));
    _changed();
  }

  void toggleTask(CalendarItem item) {
    item.done = !item.done;
    _changed();
  }

  /// The stock-check task linked to an event, if any.
  CalendarItem? stockCheckFor(String eventId) {
    for (final c in calendar) {
      if (c.forEventId == eventId) return c;
    }
    return null;
  }

  // ---------------- AI assistant (demo) ----------------
  final Set<String> savedTrends = {'pearl'};
  final Set<String> hiddenTrends = {};
  final Set<String> addedSuggestions = {};

  void toggleSavedTrend(String id) {
    savedTrends.contains(id) ? savedTrends.remove(id) : savedTrends.add(id);
    notifyListeners();
  }

  void hideTrend(String id) {
    hiddenTrends.add(id);
    notifyListeners();
  }

  void undoHiddenTrends() {
    hiddenTrends.clear();
    notifyListeners();
  }

  void addSuggestionToCalendar(EventSuggestion s) {
    if (addedSuggestions.contains(s.id)) return;
    addedSuggestions.add(s.id);
    addCalendarItem(CalendarItem(
      id: newCalendarId(),
      kind: CalendarKind.event,
      date: s.date,
      title: s.name,
      time: s.when,
      place: s.where,
    ));
  }
}
