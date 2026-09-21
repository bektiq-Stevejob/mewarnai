import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportResult {
  final bool success;
  final String internalPath;
  final String? publicPath;
  final String? errorMessage;

  ExportResult({
    required this.success,
    required this.internalPath,
    this.publicPath,
    this.errorMessage,
  });
}

class ExportService {
  /// Captures the RepaintBoundary widget as a high-resolution JPG
  /// and saves it both to the app's internal gallery and Android's public Pictures folder!
  static Future<ExportResult> captureAndSaveFramedArtwork({
    required GlobalKey boundaryKey,
    required String childName,
    required String drawingTitle,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return ExportResult(
          success: false,
          internalPath: '',
          errorMessage: 'Render object tidak ditemukan',
        );
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return ExportResult(
          success: false,
          internalPath: '',
          errorMessage: 'Gagal mengonversi gambar',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final sanitizedTitle = drawingTitle.replaceAll(RegExp(r'\s+'), '_');
      final sanitizedName = childName.replaceAll(RegExp(r'\s+'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'Karya_${sanitizedName}_${sanitizedTitle}_$timestamp.jpg';

      // 1. Save to app documents directory (internal gallery)
      final appDir = await getApplicationDocumentsDirectory();
      final internalFile = File('${appDir.path}/$filename');
      await internalFile.writeAsBytes(pngBytes);

      // 2. Save to Android Public Pictures folder so it appears in the tablet Gallery app!
      String? publicSavedPath;
      try {
        final publicPicturesDir = Directory('/storage/emulated/0/Pictures/MewarnaiCeria');
        if (!await publicPicturesDir.exists()) {
          await publicPicturesDir.create(recursive: true);
        }
        final publicFile = File('${publicPicturesDir.path}/$filename');
        await publicFile.writeAsBytes(pngBytes);
        publicSavedPath = publicFile.path;
      } catch (_) {
        // Fallback for devices with scoped storage
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final fallbackFile = File('${extDir.path}/$filename');
            await fallbackFile.writeAsBytes(pngBytes);
            publicSavedPath = fallbackFile.path;
          }
        } catch (_) {}
      }

      return ExportResult(
        success: true,
        internalPath: internalFile.path,
        publicPath: publicSavedPath,
      );
    } catch (e) {
      debugPrint('Export error: $e');
      return ExportResult(
        success: false,
        internalPath: '',
        errorMessage: e.toString(),
      );
    }
  }

  /// Share artwork directly to WhatsApp, Bluetooth, or Google Drive via system share sheet
  static Future<void> shareArtwork({
    required String filePath,
    required String childName,
    required String drawingTitle,
  }) async {
    try {
      final file = XFile(filePath);
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: 'Lihat karya indah $childName: "$drawingTitle" diwarnai dengan Aplikasi Mewarnai Ceria - Achmad Family Apps! 🎨⭐',
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }
}
