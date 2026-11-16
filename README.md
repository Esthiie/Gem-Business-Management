# Gem Business Management

Owner app for **Queens.Trinket** (TMA3084 Group 9 Comet).
Flutter + Provider. This first version is the full UI with demo data; Firebase comes in step 2.

## Run it

```bash
# 1. Generate the iOS / Android folders (only the first time; it keeps lib/ as is)
flutter create . --project-name gem_business_management --platforms ios,android

# 2. Get packages and run
flutter pub get
flutter run
```

Check the code with `flutter analyze` and `flutter test`. The GitHub Actions workflow in `.github/workflows/flutter.yml` runs both on every push.

## Folders

| Folder | What is inside |
|---|---|
| `lib/main.dart` | App start, routes |
| `lib/theme/` | Faith's colours (white, black, pastel purple, grey, pastel pink) and fonts |
| `lib/models/` | Design, MaterialItem, Sale, CustomOrder, CalendarItem, Trend |
| `lib/data/demo_data.dart` | Sample data (Sarawak events, collection, orders) |
| `lib/state/app_state.dart` | All data + actions (Provider `ChangeNotifier`) |
| `lib/widgets/` | Shared pieces: header + sync pill, bead-ring icon, chips, buttons, colour picker |
| `lib/screens/` | One file per screen |

## Screens

| Screen | File |
|---|---|
| Welcome | `welcome_screen.dart` |
| Setup 1–3 (UI-01) | `setup/setup_account_screen.dart`, `setup_profile_screen.dart`, `setup_done_screen.dart` |
| Log in (UI-02) | `login_screen.dart` |
| Home (UI-03) | `home_screen.dart` |
| Booth sale | `sell_screen.dart` |
| Stock: Collection / Materials | `stock_screen.dart` |
| Add design / Add material | `add_design_screen.dart`, `add_material_screen.dart` |
| Best sellers | `best_sellers_screen.dart` |
| Custom orders / order page / new order | `orders_screen.dart`, `order_detail_screen.dart`, `new_order_screen.dart` |
| Calendar / Add event | `calendar_screen.dart`, `add_event_screen.dart` |
| AI Assistant (events, trends, captions) | `assistant_screen.dart` |
| Settings | `settings_screen.dart` |

## What works in the demo

- Booth sale: tap items → **Record sale** lowers stock and updates Best sellers.
- Best sellers: event dropdown, **All events** by default.
- Custom orders: filter tiles, search, move stages, undo, edit details; status colours New purple, In progress orange, Done green.
- Calendar: October / November 2026, tap a day, filter, tick stock checks, deadlines come from orders.
- Settings → **Online (demo)** switch: shows "Offline · n to sync" vs "Synced" in every header.
- AI parts (captions, trends, event suggestions, description) use prepared text for now.

The iPhone status bar and home indicator from the design are drawn by the phone itself, so they are not in the code.

## Next steps

1. **Backend:** `firebase_core`, `firebase_auth`, `cloud_firestore` (offline persistence on), `firebase_storage` + `image_picker` for photos. Replace the lists in `AppState` with Firestore; screens stay the same. Look for `Step 2` comments.
2. **AI:** connect the Assistant, "Write it with AI" and event Import to the AI service (FR-AI-01 to FR-AI-04). Look for `Step 3` comments.
