import 'package:flutter_test/flutter_test.dart';
import 'package:mewarnai_app/models/drawing_item.dart';

void main() {
  test('Catalog generates 300 drawings successfully', () {
    final catalog = DrawingItem.generate300Catalog();
    expect(catalog.length, equals(300));
    expect(catalog.first.title, contains('Singa'));
  });
}
