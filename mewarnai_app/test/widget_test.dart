import 'package:flutter_test/flutter_test.dart';
import 'package:mewarnai_app/models/drawing_item.dart';
import 'package:mewarnai_app/services/svg_parser_service.dart';

void main() {
  test('Catalog generates 300 drawings successfully with 3D and sketch categories', () {
    final catalog = DrawingItem.generate300Catalog();
    expect(catalog.length, equals(300));
    
    // Check 3D Expert drawings
    final d3Drawings = catalog.where((item) => item.category == '3d_expert').toList();
    expect(d3Drawings.isNotEmpty, isTrue);
    expect(d3Drawings.first.is3D, isTrue);
    expect(d3Drawings.first.title, contains('3D'));

    // Check Sketch models
    final sketchDrawings = catalog.where((item) => item.category == 'sketches').toList();
    expect(sketchDrawings.isNotEmpty, isTrue);
    expect(sketchDrawings.first.isSketch, isTrue);

    // Check Animal drawings
    final animalDrawings = catalog.where((item) => item.category == 'animals').toList();
    expect(animalDrawings.isNotEmpty, isTrue);
    expect(animalDrawings.any((item) => item.title.contains('Singa')), isTrue);
  });

  test('SvgParserService successfully parses 3D and animal SVGs into interactive parts', () {
    final catalog = DrawingItem.generate300Catalog();
    final carItem = catalog.firstWhere((item) => item.title.contains('Mobil Balap Super 3D'));
    final parts = SvgParserService.parseSvg(carItem.svgData);
    
    expect(parts.isNotEmpty, isTrue);
    expect(parts.any((p) => p.isFillable), isTrue);
    
    // Test hit testing on a parsed part
    final fillable = parts.firstWhere((p) => p.isFillable);
    expect(fillable.bounds.width > 0, isTrue);
    expect(fillable.bounds.height > 0, isTrue);
  });
}
