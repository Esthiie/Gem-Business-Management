import 'package:flutter/material.dart';

/// The six collection categories Faith sells.
class Categories {
  static const phoneCharms = 'Phone charms';
  static const bracelets = 'Bracelets';
  static const necklaces = 'Necklaces';
  static const lanyards = 'Lanyards';
  static const hairClips = 'Hair clips';
  static const earrings = 'Earrings';
  static const all = [
    phoneCharms,
    bracelets,
    necklaces,
    lanyards,
    hairClips,
    earrings,
  ];

  /// Short label used on the Home tiles.
  static String short(String c) => const {
        phoneCharms: 'Phone charms',
        hairClips: 'Hair clips',
      }[c] ??
      c;
}

/// A finished jewellery design in the collection (Stock > Collection).
class Design {
  Design({
    required this.id,
    required this.category,
    required this.name,
    required this.detail,
    required this.price,
    required this.qty,
    required this.colour,
    this.lengthCm,
    this.oneOfAKind = false,
    this.lowAlert = 2,
    List<Color>? colours,
    this.description = '',
  }) : colours = colours ?? [colour];

  final String id;
  String category;
  String name;
  String detail; // short description shown under the name, e.g. "Pink bow"
  double price;
  int qty;
  Color colour; // main colour, used for the bead-ring icon
  double? lengthCm;
  bool oneOfAKind;
  int lowAlert;
  List<Color> colours;
  String description;

  bool get isOut => qty <= 0;
  bool get isLow => !isOut && !oneOfAKind && qty <= lowAlert;

  String get meta {
    final parts = <String>[];
    if (detail.isNotEmpty) parts.add(detail);
    if (lengthCm != null && lengthCm! > 0) parts.add('${_num(lengthCm!)} cm');
    parts.add('RM ${_num(price)}');
    return parts.join(' · ');
  }
}

/// A convention / bazaar Faith joins.
class EventInfo {
  const EventInfo({
    required this.id,
    required this.name,
    required this.date,
    required this.venue,
    required this.dates,
    this.time = '',
    this.endDate,
  });

  final String id;
  final String name;
  final DateTime date;
  final DateTime? endDate;
  final String venue;
  final String time;
  final String dates; // e.g. "23–24 Oct"
}

/// How the customer paid at the booth.
enum PayMethod { cash, qr }

extension PayMethodLabel on PayMethod {
  String get short => this == PayMethod.cash ? 'Cash' : 'QR';
  String get long => this == PayMethod.cash ? 'Cash' : 'QR (DuitNow / TNG)';
}

/// One line of a booth sale.
class SaleLine {
  const SaleLine(this.designId, this.qty, this.unitPrice);
  final String designId;
  final int qty;
  final double unitPrice;
  double get total => qty * unitPrice;
}

/// One customer at the booth: what they bought and how they paid.
class Sale {
  Sale({
    required this.id,
    required this.eventId,
    required this.customerNo,
    required this.time,
    required this.lines,
    required this.method,
  });

  final String id;
  final String eventId;
  final int customerNo; // Customer 1, 2, 3 … per event
  final DateTime time;
  final List<SaleLine> lines;
  final PayMethod method;

  double get total => lines.fold(0.0, (sum, l) => sum + l.total);
  int get items => lines.fold(0, (sum, l) => sum + l.qty);
  String get customer => 'Customer $customerNo';
}

/// Custom order stages: 0 New, 1 Details confirmed, 2 Making, 3 Final check, 4 Done.
class OrderStage {
  static const steps = ['Details confirmed', 'Making', 'Final check', 'Done'];
  static const nextLabels = [
    'Mark details confirmed',
    'Start making',
    'Final check done',
    'Mark as done',
  ];

  static String status(int stage) =>
      stage == 0 ? 'New' : (stage >= 4 ? 'Done' : 'In progress');

  static String now(int stage) {
    switch (stage) {
      case 0:
        return 'Waiting for customer to confirm';
      case 1:
        return 'Ready to start making';
      case 2:
        return 'Making';
      case 3:
        return 'Checked, ready to hand over';
      default:
        return 'Completed';
    }
  }
}

class CustomOrder {
  CustomOrder({
    required this.id,
    required this.customer,
    required this.contact,
    required this.via,
    required this.type,
    required this.item,
    required this.palette,
    required this.lengthCm,
    required this.price,
    this.deposit = 0,
    required this.due,
    required this.stage,
    this.notes = '',
    this.pictures = 0,
    List<Color>? colours,
  }) : colours = colours ?? [];

  final String id;
  String customer;
  String contact;
  String via; // Instagram, WhatsApp, At booth
  String type; // Phone charm, Bracelet, ...
  String item;
  String palette;
  double? lengthCm;
  double price;
  double deposit; // not shown in the app (client does not take deposits)
  DateTime due;
  int stage;
  String notes;
  int pictures;
  List<Color> colours;

  String get initial =>
      customer.trim().isEmpty ? '?' : customer.trim()[0].toUpperCase();
  String get status => OrderStage.status(stage);
  bool get isDone => stage >= 4;
}

enum CalendarKind { event, stock, order }

/// Something on the calendar that is not a custom order deadline
/// (those come straight from the orders list).
class CalendarItem {
  CalendarItem({
    required this.id,
    required this.kind,
    required this.date,
    required this.title,
    this.time = '',
    this.place = '',
    this.sub = '',
    this.forEventId,
    this.done = false,
    this.isTask = false,
  });

  final String id;
  final CalendarKind kind;
  final DateTime date;
  final String title;
  final String time;
  final String place;
  final String sub;
  final String? forEventId; // stock check linked to an event
  bool done;
  final bool isTask;
}

/// AI trend card (Assistant > Trends).
class Trend {
  const Trend({
    required this.id,
    required this.name,
    required this.status,
    required this.category,
    required this.palette,
    required this.why,
    required this.when,
  });

  final String id;
  final String name;
  final String status; // Rising, Popular, Fading
  final String category;
  final List<Color> palette;
  final String why;
  final String when;
}

/// AI event suggestion (Assistant > Events).
class EventSuggestion {
  const EventSuggestion({
    required this.id,
    required this.name,
    required this.when,
    required this.where,
    required this.note,
    required this.date,
  });

  final String id;
  final String name;
  final String when;
  final String where;
  final String note;
  final DateTime date;
}

// ---------- small helpers ----------

String _num(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String rm(double v) => 'RM ${_num(v)}';

String rm2(double v) => 'RM ${v.toStringAsFixed(2)}';

/// "4:05 pm"
String clock(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'am' : 'pm'}';
}

String pcs(int n) => n == 1 ? '1 pc' : '$n pcs';
String customers(int n) => n == 1 ? '1 customer' : '$n customers';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String weekday(DateTime d) => _weekdays[d.weekday - 1];
String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String longDate(DateTime d) => '${weekday(d)}, ${d.day} ${_months[d.month - 1]}';

const _fullWeekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
String fullDate(DateTime d) =>
    '${_fullWeekdays[d.weekday - 1]}, ${d.day} ${monthNames[d.month - 1]}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
