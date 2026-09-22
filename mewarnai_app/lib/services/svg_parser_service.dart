import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

class SvgPart {
  final int index;
  final Path path;
  Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isFillable;
  final Rect bounds;

  SvgPart({
    required this.index,
    required this.path,
    required this.fillColor,
    this.strokeColor = const Color(0xFF1A1A1A),
    this.strokeWidth = 5.0,
    this.isFillable = true,
  }) : bounds = path.getBounds();
}

class FlutterPathProxy implements PathProxy {
  final Path path;
  FlutterPathProxy(this.path);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

class SvgParserService {
  /// Parses SVG vector strings into a list of interactive [SvgPart] elements
  static List<SvgPart> parseSvg(String svgString) {
    final List<SvgPart> parts = [];
    int index = 0;

    // 1. Polygons: <polygon points="x1,y1 x2,y2 ..." ... />
    final polyRegex = RegExp(r'<polygon\s+[^>]*points="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in polyRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final pointsStr = match.group(1) ?? '';
      final path = _parsePolygonPoints(pointsStr);
      if (path != null) {
        final fill = _extractColor(tag, defaultColor: Colors.white);
        final stroke = _extractStroke(tag);
        final strokeW = _extractStrokeWidth(tag, defaultWidth: 5.0);
        parts.add(SvgPart(
          index: index++,
          path: path,
          fillColor: fill,
          strokeColor: stroke,
          strokeWidth: strokeW,
          isFillable: true,
        ));
      }
    }

    // 2. Circles: <circle cx="..." cy="..." r="..." ... />
    final circleRegex = RegExp(r'<circle\s+[^>]*cx="([^"]+)"\s+cy="([^"]+)"\s+r="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in circleRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final cx = double.tryParse(match.group(1) ?? '') ?? 0.0;
      final cy = double.tryParse(match.group(2) ?? '') ?? 0.0;
      final r = double.tryParse(match.group(3) ?? '') ?? 0.0;
      if (r > 0) {
        final path = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
        final fill = _extractColor(tag, defaultColor: Colors.white);
        final stroke = _extractStroke(tag);
        final strokeW = _extractStrokeWidth(tag, defaultWidth: 5.0);
        parts.add(SvgPart(
          index: index++,
          path: path,
          fillColor: fill,
          strokeColor: stroke,
          strokeWidth: strokeW,
          isFillable: true,
        ));
      }
    }

    // 3. Ellipses: <ellipse cx="..." cy="..." rx="..." ry="..." ... />
    final ellipseRegex = RegExp(r'<ellipse\s+[^>]*cx="([^"]+)"\s+cy="([^"]+)"\s+rx="([^"]+)"\s+ry="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in ellipseRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final cx = double.tryParse(match.group(1) ?? '') ?? 0.0;
      final cy = double.tryParse(match.group(2) ?? '') ?? 0.0;
      final rx = double.tryParse(match.group(3) ?? '') ?? 0.0;
      final ry = double.tryParse(match.group(4) ?? '') ?? 0.0;
      if (rx > 0 && ry > 0) {
        final path = Path()..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
        final fill = _extractColor(tag, defaultColor: Colors.white);
        final stroke = _extractStroke(tag);
        final strokeW = _extractStrokeWidth(tag, defaultWidth: 5.0);
        parts.add(SvgPart(
          index: index++,
          path: path,
          fillColor: fill,
          strokeColor: stroke,
          strokeWidth: strokeW,
          isFillable: true,
        ));
      }
    }

    // 4. Rectangles: <rect x="..." y="..." width="..." height="..." ... />
    final rectRegex = RegExp(r'<rect\s+[^>]*x="([^"]+)"\s+y="([^"]+)"\s+width="([^"]+)"\s+height="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in rectRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final x = double.tryParse(match.group(1) ?? '') ?? 0.0;
      final y = double.tryParse(match.group(2) ?? '') ?? 0.0;
      final w = double.tryParse(match.group(3) ?? '') ?? 0.0;
      final h = double.tryParse(match.group(4) ?? '') ?? 0.0;
      if (w > 0 && h > 0) {
        final path = Path()..addRect(Rect.fromLTWH(x, y, w, h));
        final fill = _extractColor(tag, defaultColor: Colors.white);
        final stroke = _extractStroke(tag);
        final strokeW = _extractStrokeWidth(tag, defaultWidth: 5.0);
        parts.add(SvgPart(
          index: index++,
          path: path,
          fillColor: fill,
          strokeColor: stroke,
          strokeWidth: strokeW,
          isFillable: true,
        ));
      }
    }

    // 5. Paths: <path d="..." ... />
    final pathRegex = RegExp(r'<path\s+[^>]*d="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in pathRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final d = match.group(1) ?? '';
      final path = Path();
      try {
        writeSvgPathDataToPath(d, FlutterPathProxy(path));
        final isClosed = d.toUpperCase().contains('Z');
        final isExplicitNone = tag.contains('fill="none"');
        final fill = isExplicitNone ? Colors.transparent : _extractColor(tag, defaultColor: Colors.white);
        final stroke = _extractStroke(tag);
        final strokeW = _extractStrokeWidth(tag, defaultWidth: 5.0);
        parts.add(SvgPart(
          index: index++,
          path: path,
          fillColor: fill,
          strokeColor: stroke,
          strokeWidth: strokeW,
          isFillable: isClosed && !isExplicitNone,
        ));
      } catch (_) {}
    }

    // 6. Lines: <line x1="..." y1="..." x2="..." y2="..." ... />
    final lineRegex = RegExp(r'<line\s+[^>]*x1="([^"]+)"\s+y1="([^"]+)"\s+x2="([^"]+)"\s+y2="([^"]+)"[^>]*>', caseSensitive: false);
    for (final match in lineRegex.allMatches(svgString)) {
      final tag = match.group(0) ?? '';
      final x1 = double.tryParse(match.group(1) ?? '') ?? 0.0;
      final y1 = double.tryParse(match.group(2) ?? '') ?? 0.0;
      final x2 = double.tryParse(match.group(3) ?? '') ?? 0.0;
      final y2 = double.tryParse(match.group(4) ?? '') ?? 0.0;
      final path = Path()..moveTo(x1, y1)..lineTo(x2, y2);
      final stroke = _extractStroke(tag);
      final strokeW = _extractStrokeWidth(tag, defaultWidth: 4.0);
      parts.add(SvgPart(
        index: index++,
        path: path,
        fillColor: Colors.transparent,
        strokeColor: stroke,
        strokeWidth: strokeW,
        isFillable: false,
      ));
    }

    return parts;
  }

  static Path? _parsePolygonPoints(String pointsStr) {
    try {
      final coords = pointsStr.trim().split(RegExp(r'[\s,]+')).map(double.parse).toList();
      if (coords.length < 4) return null;
      final path = Path();
      path.moveTo(coords[0], coords[1]);
      for (int i = 2; i < coords.length; i += 2) {
        path.lineTo(coords[i], coords[i + 1]);
      }
      path.close();
      return path;
    } catch (_) {
      return null;
    }
  }

  static Color _extractColor(String tag, {required Color defaultColor}) {
    final fillMatch = RegExp(r'fill="([^"]+)"', caseSensitive: false).firstMatch(tag);
    if (fillMatch != null) {
      final val = fillMatch.group(1)!.trim().toLowerCase();
      if (val == 'none') return Colors.transparent;
      if (val == 'white' || val == '#ffffff' || val == '#fff') return Colors.white;
      if (val == '#1a1a1a' || val == 'black' || val == '#000') return const Color(0xFF1A1A1A);
      if (val.startsWith('#') && val.length == 7) {
        final hex = int.tryParse(val.substring(1), radix: 16);
        if (hex != null) return Color(0xFF000000 | hex);
      }
    }
    return defaultColor;
  }

  static Color _extractStroke(String tag) {
    final strokeMatch = RegExp(r'stroke="([^"]+)"', caseSensitive: false).firstMatch(tag);
    if (strokeMatch != null) {
      final val = strokeMatch.group(1)!.trim().toLowerCase();
      if (val == '#1a1a1a' || val == 'black') return const Color(0xFF1A1A1A);
      if (val.startsWith('#') && val.length == 7) {
        final hex = int.tryParse(val.substring(1), radix: 16);
        if (hex != null) return Color(0xFF000000 | hex);
      }
    }
    return const Color(0xFF1A1A1A);
  }

  static double _extractStrokeWidth(String tag, {required double defaultWidth}) {
    final wMatch = RegExp(r'stroke-width="([^"]+)"', caseSensitive: false).firstMatch(tag);
    if (wMatch != null) {
      return double.tryParse(wMatch.group(1)!) ?? defaultWidth;
    }
    return defaultWidth;
  }
}
