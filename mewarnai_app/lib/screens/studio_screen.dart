import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/drawing_item.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/evaluation_service.dart';
import '../services/export_service.dart';
import '../widgets/evaluation_dialog.dart';

enum DrawingTool {
  crayon,
  pencil,
  rainbow,
  glitter,
  bucket,
  eraser,
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

class StudioScreen extends StatefulWidget {
  final DrawingItem drawing;
  final StorageService storage;
  final VoidCallback onBackToCatalog;
  final VoidCallback onViewGallery;

  const StudioScreen({
    super.key,
    required this.drawing,
    required this.storage,
    required this.onBackToCatalog,
    required this.onViewGallery,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TransformationController _transformController = TransformationController();

  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStrokes = [];

  DrawingTool _currentTool = DrawingTool.crayon;
  Color _selectedColor = const Color(0xFFFF3B30);
  double _strokeWidth = 14.0;
  double _rainbowHue = 0.0;
  bool _showSketchReference = true;
  double _currentScale = 1.0;

  final List<Color> _colors = const [
    Color(0xFFFF3B30), Color(0xFFFF9500), Color(0xFFFFD60A), Color(0xFF34C759),
    Color(0xFF00C7BE), Color(0xFF30B0C7), Color(0xFF32ADE6), Color(0xFF007AFF),
    Color(0xFF5856D6), Color(0xFFAF52DE), Color(0xFFFF2D55), Color(0xFFFF70A6),
    Color(0xFFFF9F1C), Color(0xFFFFE066), Color(0xFF70C1B3), Color(0xFF247BA0),
    Color(0xFFF25F5C), Color(0xFFA0C4FF), Color(0xFFBDB2FF), Color(0xFFFFC6FF),
    Color(0xFF795548), Color(0xFF4E342E), Color(0xFF8E8E93), Color(0xFF1E2022),
    Color(0xFFFFFFFF), Color(0xFFE91E63), Color(0xFF009688), Color(0xFFFFC107),
  ];

  @override
  void initState() {
    super.initState();
    _transformController.addListener(() {
      final scale = _transformController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() => _currentScale = scale);
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoStrokes.add(_strokes.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoStrokes.isNotEmpty) {
      setState(() {
        _strokes.add(_redoStrokes.removeLast());
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bersihkan Kanvas? 🗑️'),
        content: const Text('Semua coretan warna akan dihapus dan kamu bisa mulai mewarnai lagi dari awal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5E7E)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _strokes.clear();
                _redoStrokes.clear();
              });
            },
            child: const Text('Bersihkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveAndGrade() async {
    final activeKid = widget.storage.getActiveProfile();

    final uniqueColors = _strokes.map((s) => s.color.toARGB32()).toSet().length;
    final evaluation = EvaluationService.evaluate(
      strokeCount: _strokes.length,
      colorCount: uniqueColors,
      childName: activeKid.name,
    );

    AudioService().speakPraise(evaluation.praise);

    // Reset zoom before capture to ensure full frame is captured perfectly!
    _transformController.value = Matrix4.identity();
    await Future.delayed(const Duration(milliseconds: 100));

    final exportResult = await ExportService.captureAndSaveFramedArtwork(
      boundaryKey: _repaintBoundaryKey,
      childName: activeKid.name,
      drawingTitle: widget.drawing.title,
    );

    if (exportResult.success) {
      await widget.storage.saveArtworkForActiveKid(
        SavedArtwork(
          id: 'art-${DateTime.now().millisecondsSinceEpoch}',
          title: widget.drawing.title,
          date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          stars: evaluation.stars,
          badge: evaluation.badge,
          imagePath: exportResult.internalPath,
        ),
      );
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EvaluationDialog(
        evaluation: evaluation,
        childName: activeKid.name,
        drawingTitle: widget.drawing.title,
        savedImagePath: exportResult.publicPath ?? exportResult.internalPath,
        onViewGallery: widget.onViewGallery,
        onNewDrawing: widget.onBackToCatalog,
      ),
    );
  }

  Color _getCurrentStrokeColor() {
    if (_currentTool == DrawingTool.eraser) {
      return Colors.white;
    } else if (_currentTool == DrawingTool.rainbow) {
      _rainbowHue = (_rainbowHue + 16) % 360;
      return HSVColor.fromAHSV(1.0, _rainbowHue, 0.95, 0.95).toColor();
    } else if (_currentTool == DrawingTool.glitter) {
      return const Color(0xFFFFD700); // Golden sparkle
    }
    return _selectedColor;
  }

  double _getEffectiveStrokeWidth() {
    if (_currentTool == DrawingTool.pencil) {
      return max(4.0, _strokeWidth * 0.45);
    } else if (_currentTool == DrawingTool.bucket) {
      return 60.0; // Broad tap fill patch
    }
    return _strokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    final activeKid = widget.storage.getActiveProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2B2D42), size: 28),
          onPressed: widget.onBackToCatalog,
          tooltip: 'Kembali ke Katalog',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.drawing.title,
              style: const TextStyle(
                color: Color(0xFF2B2D42),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              'Achmad Family Apps ✨ Studio Mewarnai',
              style: TextStyle(fontSize: 11, color: Color(0xFFFF5E7E), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Zoom Reset Indicator Button
          if (_currentScale > 1.1)
            TextButton.icon(
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFF0F4)),
              onPressed: _resetZoom,
              icon: const Icon(Icons.zoom_out_map_rounded, size: 16, color: Color(0xFFFF5E7E)),
              label: Text('${_currentScale.toStringAsFixed(1)}x Reset', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5E7E))),
            ),

          IconButton(
            icon: const Text('↩️', style: TextStyle(fontSize: 22)),
            onPressed: _undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Text('↪️', style: TextStyle(fontSize: 22)),
            onPressed: _redo,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Text('🗑️', style: TextStyle(fontSize: 22)),
            onPressed: _clearCanvas,
            tooltip: 'Bersihkan Kanvas',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 6.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BCB77),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
              ),
              onPressed: _handleSaveAndGrade,
              icon: const Text('⭐'),
              label: const Text('Selesai & Nilai!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Row(
        children: [
          // 1. Left Comprehensive Toolset Panel
          Container(
            width: 86,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFF1E9DF), width: 2)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildToolBtn(
                    icon: '🪣',
                    label: 'Ember Cat',
                    isSelected: _currentTool == DrawingTool.bucket,
                    onTap: () => setState(() => _currentTool = DrawingTool.bucket),
                  ),
                  const SizedBox(height: 8),
                  _buildToolBtn(
                    icon: '🖍️',
                    label: 'Krayon',
                    isSelected: _currentTool == DrawingTool.crayon,
                    onTap: () => setState(() => _currentTool = DrawingTool.crayon),
                  ),
                  const SizedBox(height: 8),
                  _buildToolBtn(
                    icon: '✏️',
                    label: 'Pensil',
                    isSelected: _currentTool == DrawingTool.pencil,
                    onTap: () => setState(() => _currentTool = DrawingTool.pencil),
                  ),
                  const SizedBox(height: 8),
                  _buildToolBtn(
                    icon: '🌈',
                    label: 'Pelangi',
                    isSelected: _currentTool == DrawingTool.rainbow,
                    onTap: () => setState(() => _currentTool = DrawingTool.rainbow),
                  ),
                  const SizedBox(height: 8),
                  _buildToolBtn(
                    icon: '✨',
                    label: 'Glitter',
                    isSelected: _currentTool == DrawingTool.glitter,
                    onTap: () => setState(() => _currentTool = DrawingTool.glitter),
                  ),
                  const SizedBox(height: 8),
                  _buildToolBtn(
                    icon: '🧽',
                    label: 'Penghapus',
                    isSelected: _currentTool == DrawingTool.eraser,
                    onTap: () => setState(() => _currentTool = DrawingTool.eraser),
                  ),
                  const Divider(height: 20),
                  const Text('Ukuran', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  _buildSizeBtn(8.0, 8.0),
                  const SizedBox(height: 6),
                  _buildSizeBtn(16.0, 14.0),
                  const SizedBox(height: 6),
                  _buildSizeBtn(28.0, 20.0),
                ],
              ),
            ),
          ),

          // 2. Center Interactive Canvas with Pinch-to-Zoom & Pan support
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        panEnabled: _currentTool == DrawingTool.bucket ? false : false, // pan via two fingers
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getCanvasBackgroundColor(),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFFFD93D), width: 6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Paper texture background if blank sketchpad
                                  if (widget.drawing.isBlankSketchpad)
                                    CustomPaint(
                                      painter: PaperGridPainter(paperType: widget.drawing.paperType),
                                      size: Size.infinite,
                                    ),

                                  // Gesture Painting Layer
                                  GestureDetector(
                                    onPanStart: (details) {
                                      final localPos = details.localPosition;
                                      final strokeColor = _getCurrentStrokeColor();
                                      final width = _getEffectiveStrokeWidth();

                                      setState(() {
                                        _strokes.add(
                                          DrawingStroke(
                                            points: [localPos],
                                            color: strokeColor,
                                            strokeWidth: width,
                                            tool: _currentTool,
                                          ),
                                        );
                                        _redoStrokes.clear();
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      setState(() {
                                        if (_strokes.isNotEmpty) {
                                          _strokes.last.points.add(details.localPosition);
                                        }
                                      });
                                    },
                                    child: CustomPaint(
                                      painter: AdvancedCanvasPainter(strokes: _strokes),
                                      size: Size.infinite,
                                    ),
                                  ),

                                  // SVG Vector Line-Art or Custom Image Outline on Top
                                  if (!widget.drawing.isBlankSketchpad)
                                    IgnorePointer(
                                      child: widget.drawing.isCustom
                                          ? Image.file(
                                              File(widget.drawing.localCustomImagePath!),
                                              fit: BoxFit.contain,
                                            )
                                          : SvgPicture.string(
                                              widget.drawing.svgData,
                                              fit: BoxFit.contain,
                                            ),
                                    ),

                                  // Watermark Ribbon
                                  Positioned(
                                    bottom: 8,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFFCCD7)),
                                      ),
                                      child: Text(
                                        '${activeKid.avatar} ${activeKid.name} • Achmad Family Apps',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6C757D),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Floating Sketch Reference Guide Box (For Sketch / 3D models)
                if (widget.drawing.sketchReferenceGuide != null && _showSketchReference)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      constraints: const Box320Constraint(),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF4D96FF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💡 Contoh Sketsa & Warna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B2D42))),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => _showSketchReference = false),
                                child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.drawing.sketchReferenceGuide!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF4D96FF), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (widget.drawing.sketchReferenceGuide != null && !_showSketchReference)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4D96FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => setState(() => _showSketchReference = true),
                      icon: const Text('💡'),
                      label: const Text('Lihat Contekan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Right 28-Color Palette
          Container(
            width: 105,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFF1E9DF), width: 2)),
            ),
            child: Column(
              children: [
                const Text('Palet Warna 🎨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2B2D42))),
                const SizedBox(height: 6),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _colors.length,
                    itemBuilder: (ctx, index) {
                      final c = _colors[index];
                      final isSelected = c == _selectedColor && _currentTool != DrawingTool.eraser;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = c;
                            if (_currentTool == DrawingTool.eraser) {
                              _currentTool = DrawingTool.crayon;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: isSelected
                              ? Icon(Icons.check, size: 16, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCanvasBackgroundColor() {
    if (widget.drawing.isBlankSketchpad && widget.drawing.paperType == 'kraft') {
      return const Color(0xFFEFE2D2);
    }
    return Colors.white;
  }

  Widget _buildToolBtn({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 66,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE5EC) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFFEAE0D5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFF5E7E) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeBtn(double size, double dotSize) {
    final isSelected = _strokeWidth == size;
    return GestureDetector(
      onTap: () => setState(() => _strokeWidth = size),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE5EC) : const Color(0xFFF8F9FA),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFFEAE0D5),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: Color(0xFF2B2D42),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class Box320Constraint extends BoxConstraints {
  const Box320Constraint() : super(maxWidth: 320);
}

class AdvancedCanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  AdvancedCanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.tool == DrawingTool.glitter) {
        _drawGlitterStars(canvas, stroke);
        continue;
      }

      final paint = Paint()
        ..color = stroke.tool == DrawingTool.eraser ? Colors.white : stroke.color
        ..strokeCap = stroke.tool == DrawingTool.pencil ? StrokeCap.square : StrokeCap.round
        ..strokeJoin = stroke.tool == DrawingTool.pencil ? StrokeJoin.miter : StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      if (stroke.tool == DrawingTool.bucket) {
        // Broad color fill patch
        final fillPaint = Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill;
        for (final p in stroke.points) {
          canvas.drawCircle(p, stroke.strokeWidth, fillPaint);
        }
      } else if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      } else {
        for (int i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }
  }

  void _drawGlitterStars(Canvas canvas, DrawingStroke stroke) {
    final starPaint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < stroke.points.length; i += 3) {
      final p = stroke.points[i];
      _drawStar(canvas, p, stroke.strokeWidth, starPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.45;

    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? radius : innerRadius;
      final double angle = (i * pi / points) - (pi / 2);
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AdvancedCanvasPainter oldDelegate) => true;
}

class PaperGridPainter extends CustomPainter {
  final String paperType;
  PaperGridPainter({required this.paperType});

  @override
  void paint(Canvas canvas, Size size) {
    if (paperType == 'grid') {
      final gridPaint = Paint()
        ..color = const Color(0xFFD0E1FD).withValues(alpha: 0.6)
        ..strokeWidth = 1.0;
      const double step = 25.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaperGridPainter oldDelegate) => false;
}
