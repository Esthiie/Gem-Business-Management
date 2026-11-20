import 'package:flutter_test/flutter_test.dart';
import 'package:gem_business_management/state/app_state.dart';

void main() {
  test('Booth sale deducts stock and updates best sellers', () {
    final s = AppState();
    final cherry = s.designById('d2')!;
    final before = cherry.qty;
    final soldBefore = s.soldFor('kwc')['d2'] ?? 0;

    s.recordSale('kwc', {'d2': 2});

    expect(cherry.qty, before - 2);
    expect(s.soldFor('kwc')['d2'], soldBefore + 2);
  });

  test('All events adds up every event', () {
    final s = AppState();
    final total = s.unitsFor('kwc') + s.unitsFor('mak') + s.unitsFor('art');
    expect(s.unitsFor(null), total);
  });

  test('Custom order moves through the stages', () {
    final s = AppState();
    final mira = s.orderById('o11')!;
    expect(mira.status, 'New');
    s.nextStage(mira);
    expect(mira.status, 'In progress');
    for (var i = 0; i < 5; i++) {
      s.nextStage(mira);
    }
    expect(mira.status, 'Done');
    s.previousStage(mira);
    expect(mira.status, 'In progress');
  });

  test('Offline changes queue up until back online', () {
    final s = AppState();
    final start = s.pendingSync;
    s.recordTotalOnly('kwc', 30, '2 charms');
    expect(s.pendingSync, start + 1);
    s.setOnline(true);
    expect(s.pendingSync, 0);
  });
}
