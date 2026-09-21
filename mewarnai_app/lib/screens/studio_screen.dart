import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/drawing_item.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/evaluation_service.dart';
import '../services/export_service.dart';
import '../widgets/evaluation_dialog.dart';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
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
  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStrokes = [];

  Color _selectedColor = const Color(0xFFFF3B30);
  double _strokeWidth = 14.0;
  bool _isEraser = false;
  bool _isRainbow = false;
  double _rainbowHue = 0.0;

  final List<Color> _colors = const [
    Color(0xFFFF3B30), Color(0xFFFF9500), Color(0xFFFFD60A), Color(0xFF34C759),
    Color(0xFF00C7BE), Color(0xFF30B0C7), Color(0xFF32ADE6), Color(0xFF007AFF),
    Color(0xFF5856D6), Color(0xFFAF52DE), Color(0xFFFF2D55), Color(0xFFFF70A6),
    Color(0xFFFF9F1C), Color(0xFFFFE066), Color(0xFF70C1B3), Color(0xFF247BA0),
    Color(0xFFF25F5C), Color(0xFFA0C4FF), Color(0xFFBDB2FF), Color(0xFFFFC6FF),
    Color(0xFF795548), Color(0xFF4E342E), Color(0xFF8E8E93), Color(0xFF1E2022),
  ];

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
        content: const Text('Semua warna akan dihapus dan kamu bisa mulai mewarnai lagi dari awal.'),
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

    // Unique colors used
    final uniqueColors = _strokes.map((s) => s.color.value).toSet().length;
    final evaluation = EvaluationService.evaluate(
      strokeCount: _strokes.length,
      colorCount: uniqueColors,
      childName: activeKid.name,
    );

    // Speak cheerful praise via Indonesian TTS
    AudioService().speakPraise(evaluation.praise);

    // Capture framed artwork image
    final savedPath = await ExportService.captureAndSaveFramedArtwork(
      boundaryKey: _repaintBoundaryKey,
      childName: activeKid.name,
      drawingTitle: widget.drawing.title,
    );

    // Save to profile gallery
    if (savedPath != null) {
      await widget.storage.saveArtworkForActiveKid(
        SavedArtwork(
          id: 'art-${DateTime.now().millisecondsSinceEpoch}',
          title: widget.drawing.title,
          date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          stars: evaluation.stars,
          badge: evaluation.badge,
          imagePath: savedPath,
        ),
      );
    }

    if (!mounted) return;

    // Show popup with celebration confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EvaluationDialog(
        evaluation: evaluation,
        childName: activeKid.name,
        onViewGallery: widget.onViewGallery,
        onNewDrawing: widget.onBackToCatalog,
      ),
    );
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
        title: Text(
          widget.drawing.title,
          style: const TextStyle(
            color: Color(0xFF2B2D42),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
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
          // Left Tool Panel
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFF1E9DF), width: 2)),
            ),
            child: Column(
              children: [
                _buildToolBtn(
                  icon: '🖍️',
                  label: 'Kuas',
                  isSelected: !_isEraser && !_isRainbow,
                  onTap: () => setState(() { _isEraser = false; _isRainbow = false; }),
                ),
                const SizedBox(height: 12),
                _buildToolBtn(
                  icon: '🌈',
                  label: 'Pelangi',
                  isSelected: _isRainbow,
                  onTap: () => setState(() { _isRainbow = true; _isEraser = false; }),
                ),
                const SizedBox(height: 12),
                _buildToolBtn(
                  icon: '🧽',
                  label: 'Hapus',
                  isSelected: _isEraser,
                  onTap: () => setState(() { _isEraser = true; _isRainbow = false; }),
                ),
                const Divider(height: 32),
                const Text('Ukuran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                _buildSizeBtn(8.0, 8.0),
                const SizedBox(height: 8),
                _buildSizeBtn(16.0, 14.0),
                const SizedBox(height: 8),
                _buildSizeBtn(28.0, 20.0),
              ],
            ),
          ),

          // Center Interactive Canvas wrapped with framed RepaintBoundary for high-res JPG export
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFD93D), width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Color Painting Gesture Layer
                            GestureDetector(
                              onPanStart: (details) {
                                final localPos = details.localPosition;
                                Color strokeColor = _selectedColor;
                                if (_isRainbow) {
                                  _rainbowHue = (_rainbowHue + 15) % 360;
                                  strokeColor = HSVColor.fromAHSV(1.0, _rainbowHue, 0.9, 0.9).toColor();
                                }
                                setState(() {
                                  _strokes.add(
                                    DrawingStroke(
                                      points: [localPos],
                                      color: strokeColor,
                                      strokeWidth: _strokeWidth,
                                      isEraser: _isEraser,
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
                                painter: CanvasPainter(strokes: _strokes),
                                size: Size.infinite,
                              ),
                            ),

                            // 2. Line-Art Outline Layer (Vector SVG or Custom Image) on top
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

                            // 3. Cute Watermark Ribbon
                            Positioned(
                              bottom: 8,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${activeKid.avatar} ${activeKid.name} • Mewarnai Ceria',
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

          // Right Color Palette
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFF1E9DF), width: 2)),
            ),
            child: Column(
              children: [
                const Text('Palet 🎨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B2D42))),
                const SizedBox(height: 8),
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
                      final isSelected = c == _selectedColor && !_isEraser;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = c;
                            _isEraser = false;
                            _isRainbow = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.white,
                              width: isSelected ? 3.5 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
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
        width: 58,
        height: 58,
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
            Text(icon, style: const TextStyle(fontSize: 22)),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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
        width: 38,
        height: 38,
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

class CanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  CanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.isEraser ? Colors.white : stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      } else {
        for (int i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
