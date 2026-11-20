import 'package:flutter_test/flutter_test.dart';
import 'package:gem_business_management/models/models.dart';
import 'package:gem_business_management/state/app_state.dart';

void main() {
  test('demo data has 32 designs in 6 categories and 19 sales', () {
    final s = AppState();
    expect(s.designs.length, 32);
    expect(Categories.all.length, 6);
    expect(s.sales.length, 19);
    final total = s.sales.fold(0.0, (a, x) => a + x.total);
    expect(total, 635);
  });

  test('recording a booth sale deducts stock and saves payment method', () {
    final s = AppState();
    final cherry = s.designById('d2')!;
    final before = cherry.qty;
    final sale = s.recordSale('xkid', {'d2': 2}, PayMethod.cash)!;
    expect(cherry.qty, before - 2);
    expect(sale.method, PayMethod.cash);
    expect(sale.customerNo, 11);
    expect(s.sales.first, sale);
    expect(s.soldFor('xkid')['d2'], 8);
  });

  test('deleting a sale puts pieces back into stock', () {
    final s = AppState();
    final sale = s.saleById('x9')!;
    final clips = s.designById('d26')!;
    final before = clips.qty;
    s.deleteSale(sale);
    expect(clips.qty, before + 2);
    expect(s.saleById('x9'), isNull);
    expect(s.sales.length, 18);
  });

  test('cash and QR filters split the sales', () {
    final s = AppState();
    final cash = s.salesFor(null, method: PayMethod.cash);
    final qr = s.salesFor(null, method: PayMethod.qr);
    expect(cash.length + qr.length, 19);
    expect(cash.fold(0.0, (a, x) => a + x.total), 273);
  });

  test('custom order stages move forward and back', () {
    final s = AppState();
    final o = s.orderById('o11')!;
    expect(o.status, 'New');
    s.nextStage(o);
    expect(o.status, 'In progress');
    s.previousStage(o);
    expect(o.status, 'New');
  });
}
