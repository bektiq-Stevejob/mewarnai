import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  /// Captures the RepaintBoundary widget as a high-resolution PNG/JPG
  static Future<String?> captureAndSaveFramedArtwork({
    required GlobalKey boundaryKey,
    required String childName,
    required String drawingTitle,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to device storage
      final directory = await getApplicationDocumentsDirectory();
      final sanitizedTitle = drawingTitle.replaceAll(RegExp(r'\s+'), '_');
      final sanitizedName = childName.replaceAll(RegExp(r'\s+'), '_');
      final filename = 'Karya_${sanitizedName}_${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }
}
