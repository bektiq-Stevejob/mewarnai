import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drawing_item.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/evaluation_service.dart';
import '../services/export_service.dart';
import '../services/svg_parser_service.dart';
import '../widgets/evaluation_dialog.dart';

enum DrawingTool {
  bucket,
  crayon,
  pencil,
  rainbow,
  glitter,
  eraser,
}

enum StudioActionType {
  stroke,
  bucketFill,
}

class StudioAction {
  final StudioActionType type;
  final DrawingStroke? stroke;
  final int? partIndex;
  final Color? oldColor;
  final Color? newColor;

  StudioAction.stroke(DrawingStroke this.stroke)
      : type = StudioActionType.stroke,
        partIndex = null,
        oldColor = null,
        newColor = null;

  StudioAction.bucketFill({
    required int this.partIndex,
    required Color this.oldColor,
    required Color this.newColor,
  })  : type = StudioActionType.bucketFill,
        stroke = null;
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
  final List<StudioAction> _undoHistory = [];
  final List<StudioAction> _redoHistory = [];

  List<SvgPart> _svgParts = [];
  Color _canvasBackgroundColor = Colors.white;

  DrawingTool _currentTool = DrawingTool.bucket;
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
    _initSvgParts();

    _transformController.addListener(() {
      final scale = _transformController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() => _currentScale = scale);
      }
    });

    // Speak initial encouragement
    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.drawing.is3D) {
        AudioService().speakPraise('Ini gambar 3D keren! Gunakan ember cat atau kuas sesukamu!');
      } else if (widget.drawing.isSketch) {
        AudioService().speakPraise('Model sketsa siap diwarnai! Ayo kreasikan warnamu!');
      }
    });
  }

  void _initSvgParts() {
    if (!widget.drawing.isBlankSketchpad && !widget.drawing.isCustom) {
      _svgParts = SvgParserService.parseSvg(widget.drawing.svgData);
    }
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
    if (_undoHistory.isEmpty) return;

    setState(() {
      final action = _undoHistory.removeLast();
      _redoHistory.add(action);

      if (action.type == StudioActionType.stroke) {
        if (_strokes.isNotEmpty) {
          _strokes.removeLast();
        }
      } else if (action.type == StudioActionType.bucketFill) {
        final partIndex = action.partIndex!;
        final part = _svgParts.firstWhere((p) => p.index == partIndex, orElse: () => _svgParts.first);
        part.fillColor = action.oldColor!;
      }
    });
  }

  void _redo() {
    if (_redoHistory.isEmpty) return;

    setState(() {
      final action = _redoHistory.removeLast();
      _undoHistory.add(action);

      if (action.type == StudioActionType.stroke) {
        _strokes.add(action.stroke!);
      } else if (action.type == StudioActionType.bucketFill) {
        final partIndex = action.partIndex!;
        final part = _svgParts.firstWhere((p) => p.index == partIndex, orElse: () => _svgParts.first);
        part.fillColor = action.newColor!;
      }
    });
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🗑️', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Bersihkan Kanvas?'),
          ],
        ),
        content: const Text('Semua warna dan coretan akan dihapus dan kamu bisa mulai mewarnai lagi dari awal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5E7E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _strokes.clear();
                _undoHistory.clear();
                _redoHistory.clear();
                _initSvgParts();
                _canvasBackgroundColor = _getCanvasDefaultBackground();
              });
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }

  Color _getCanvasDefaultBackground() {
    if (widget.drawing.isBlankSketchpad) {
      if (widget.drawing.paperType == 'kraft') return const Color(0xFFEFE2D2);
      return Colors.white;
    }
    return Colors.white;
  }

  void _handleBucketTap(Offset localPos, Size canvasSize) {
    if (_svgParts.isEmpty) {
      // For blank sketchpad or raster custom drawing, bucket fill sets canvas background
      setState(() {
        _canvasBackgroundColor = _selectedColor;
      });
      AudioService().speakPraise('Clop! Warna latar berubah!');
      return;
    }

    // Scale tap position from canvas size to SVG 500x500 viewBox
    final double scaleX = 500.0 / canvasSize.width;
    final double scaleY = 500.0 / canvasSize.height;
    final svgPoint = Offset(localPos.dx * scaleX, localPos.dy * scaleY);

    // Find the smallest / top-most matching fillable shape
    SvgPart? hitPart;
    double smallestArea = double.infinity;

    for (final part in _svgParts.reversed) {
      if (part.isFillable && part.path.contains(svgPoint)) {
        final area = part.bounds.width * part.bounds.height;
        if (area < smallestArea) {
          smallestArea = area;
          hitPart = part;
        }
      }
    }

    if (hitPart != null) {
      final oldColor = hitPart.fillColor;
      final newColor = _selectedColor;
      setState(() {
        hitPart!.fillColor = newColor;
        _undoHistory.add(StudioAction.bucketFill(
          partIndex: hitPart.index,
          oldColor: oldColor,
          newColor: newColor,
        ));
        _redoHistory.clear();
      });
      AudioService().speakPraise('Clop! Warna yang indah!');
    } else {
      // Tap was outside shapes (canvas background)
      setState(() {
        _canvasBackgroundColor = _selectedColor;
      });
      AudioService().speakPraise('Clop! Warna latar berubah!');
    }
  }

  Future<void> _handleSaveAndGrade() async {
    final activeKid = widget.storage.getActiveProfile();

    final uniqueColors = {
      ..._strokes.map((s) => s.color.toARGB32()),
      ..._svgParts.map((p) => p.fillColor.toARGB32()),
    }.where((c) => c != Colors.white.toARGB32() && c != Colors.transparent.toARGB32()).length;

    final totalActions = _strokes.length + _svgParts.where((p) => p.fillColor != Colors.white).length;

    final evaluation = EvaluationService.evaluate(
      strokeCount: totalActions,
      colorCount: max(1, uniqueColors),
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
      return _canvasBackgroundColor;
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
      return max(3.0, _strokeWidth * 0.4);
    } else if (_currentTool == DrawingTool.glitter) {
      return max(10.0, _strokeWidth * 1.2);
    }
    return _strokeWidth;
  }

  void _confirmExitToCatalog(BuildContext context) {
    if (_strokes.isEmpty && _undoHistory.isEmpty) {
      widget.onBackToCatalog();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('🏠', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text('Kembali ke Menu?'),
          ],
        ),
        content: const Text(
          'Mau kembali ke menu katalog gambar? Kamu bisa simpan dulu atau langsung kembali.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Lanjut Mewarnai 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5E7E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onBackToCatalog();
            },
            child: const Text('Ya, Menu Utama 🏠'),
          ),
        ],
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
        elevation: 1,
        leadingWidth: 130,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5E7E),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => _confirmExitToCatalog(context),
            icon: const Text('🏠', style: TextStyle(fontSize: 18)),
            label: const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.drawing.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2B2D42),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${activeKid.avatar} ${activeKid.name}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFFF5E7E), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '⭐ ${activeKid.totalStars}',
                        style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
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
            icon: const Text('↩️', style: TextStyle(fontSize: 20)),
            onPressed: _undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Text('↪️', style: TextStyle(fontSize: 20)),
            onPressed: _redo,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
            onPressed: _clearCanvas,
            tooltip: 'Bersihkan Kanvas',
          ),
          const SizedBox(width: 4),

          // Selesai & Beri Bintang Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD93D),
              foregroundColor: const Color(0xFF432800),
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _handleSaveAndGrade,
            icon: const Text('⭐', style: TextStyle(fontSize: 18)),
            label: const Text('Selesai!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // 1. Left Vertical Tool Selection Bar
          Container(
            width: 86,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildToolBtn(
                    icon: '🪣',
                    label: 'Ember Cat',
                    sublabel: 'Otomatis',
                    isSelected: _currentTool == DrawingTool.bucket,
                    onTap: () {
                      setState(() => _currentTool = DrawingTool.bucket);
                      AudioService().speakPraise('Ember cat ajaib! Ketuk bidang mana saja untuk mewarnai!');
                    },
                  ),
                  const SizedBox(height: 6),
                  _buildToolBtn(
                    icon: '🖍️',
                    label: 'Krayon',
                    sublabel: 'Tebal',
                    isSelected: _currentTool == DrawingTool.crayon,
                    onTap: () => setState(() => _currentTool = DrawingTool.crayon),
                  ),
                  const SizedBox(height: 6),
                  _buildToolBtn(
                    icon: '✏️',
                    label: 'Pensil',
                    sublabel: 'Detail',
                    isSelected: _currentTool == DrawingTool.pencil,
                    onTap: () => setState(() => _currentTool = DrawingTool.pencil),
                  ),
                  const SizedBox(height: 6),
                  _buildToolBtn(
                    icon: '🌈',
                    label: 'Pelangi',
                    sublabel: 'Ajaib',
                    isSelected: _currentTool == DrawingTool.rainbow,
                    onTap: () => setState(() => _currentTool = DrawingTool.rainbow),
                  ),
                  const SizedBox(height: 6),
                  _buildToolBtn(
                    icon: '✨',
                    label: 'Glitter',
                    sublabel: 'Bintang',
                    isSelected: _currentTool == DrawingTool.glitter,
                    onTap: () => setState(() => _currentTool = DrawingTool.glitter),
                  ),
                  const SizedBox(height: 6),
                  _buildToolBtn(
                    icon: '🧽',
                    label: 'Hapus',
                    sublabel: 'Bersih',
                    isSelected: _currentTool == DrawingTool.eraser,
                    onTap: () => setState(() => _currentTool = DrawingTool.eraser),
                  ),
                  const Divider(height: 16),
                  const Text('Ukuran', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  _buildSizeBtn(8.0, 8.0),
                  const SizedBox(height: 4),
                  _buildSizeBtn(16.0, 14.0),
                  const SizedBox(height: 4),
                  _buildSizeBtn(28.0, 20.0),
                ],
              ),
            ),
          ),

          // 2. Center Interactive Canvas with Vector Fill & Freehand Strokes
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        panEnabled: _currentScale > 1.05,
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                              return Container(
                                decoration: BoxDecoration(
                                  color: _canvasBackgroundColor,
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

                                      // Raster Custom User Image Layer (if imported image)
                                      if (widget.drawing.isCustom)
                                        Image.file(
                                          File(widget.drawing.localCustomImagePath!),
                                          fit: BoxFit.contain,
                                        ),

                                      // Master Interactive Canvas Painter (Fills + Strokes + Vector Outlines)
                                      GestureDetector(
                                        onTapUp: (details) {
                                          if (_currentTool == DrawingTool.bucket) {
                                            _handleBucketTap(details.localPosition, canvasSize);
                                          }
                                        },
                                        onPanStart: (details) {
                                          if (_currentTool == DrawingTool.bucket) {
                                            _handleBucketTap(details.localPosition, canvasSize);
                                            return;
                                          }

                                          final localPos = details.localPosition;
                                          final strokeColor = _getCurrentStrokeColor();
                                          final width = _getEffectiveStrokeWidth();

                                          final stroke = DrawingStroke(
                                            points: [localPos],
                                            color: strokeColor,
                                            strokeWidth: width,
                                            tool: _currentTool,
                                          );

                                          setState(() {
                                            _strokes.add(stroke);
                                            _undoHistory.add(StudioAction.stroke(stroke));
                                            _redoHistory.clear();
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          if (_currentTool == DrawingTool.bucket) return;

                                          setState(() {
                                            if (_strokes.isNotEmpty) {
                                              _strokes.last.points.add(details.localPosition);
                                            }
                                          });
                                        },
                                        child: CustomPaint(
                                          painter: AdvancedCanvasPainter(
                                            strokes: _strokes,
                                            svgParts: _svgParts,
                                            isCustomRaster: widget.drawing.isCustom,
                                          ),
                                          size: Size.infinite,
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
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Floating Sketch Reference Guide Box (For Sketch / 3D models)
                if (widget.drawing.sketchReferenceGuide != null && _showSketchReference)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
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
                              const Text('💡 Contoh Warna Sketsa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2B2D42))),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => setState(() => _showSketchReference = false),
                                child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
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
                    top: 14,
                    left: 14,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4D96FF),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => setState(() => _showSketchReference = true),
                      icon: const Text('💡'),
                      label: const Text('Panduan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Right Vertical Color Palette Bar
          Container(
            width: 82,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Warna', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2B2D42))),
                  const SizedBox(height: 6),
                  ..._colors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        AudioService().speakPraise('Keren!');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        width: isSelected ? 44 : 36,
                        height: isSelected ? 44 : 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFFE5E7EB),
                            width: isSelected ? 3.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.08),
                              blurRadius: isSelected ? 8 : 3,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: isSelected
                            ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 20))
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBtn({
    required String icon,
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFE5EC) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFFEAE0D5),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF5E7E).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFF2B2D42),
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFFF5E7E) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeBtn(double size, double dotSize) {
    final isSelected = _strokeWidth == size;
    return GestureDetector(
      onTap: () => setState(() => _strokeWidth = size),
      child: Container(
        width: 34,
        height: 34,
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

class AdvancedCanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<SvgPart> svgParts;
  final bool isCustomRaster;

  AdvancedCanvasPainter({
    required this.strokes,
    required this.svgParts,
    required this.isCustomRaster,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 500.0;

    // Layer 1: Draw Fills for SVG parts (Colored by Ember Cat)
    if (svgParts.isNotEmpty && !isCustomRaster) {
      canvas.save();
      canvas.scale(scale, scale);

      final fillPaint = Paint()..style = PaintingStyle.fill;
      for (final part in svgParts) {
        if (part.isFillable && part.fillColor != Colors.transparent) {
          fillPaint.color = part.fillColor;
          canvas.drawPath(part.path, fillPaint);
        }
      }
      canvas.restore();
    }

    // Layer 2: Draw User Freehand Strokes (Crayon, Pencil, Rainbow, Eraser)
    for (final stroke in strokes) {
      if (stroke.tool == DrawingTool.glitter) {
        _drawGlitterStars(canvas, stroke);
        continue;
      }

      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = stroke.tool == DrawingTool.pencil ? StrokeCap.square : StrokeCap.round
        ..strokeJoin = stroke.tool == DrawingTool.pencil ? StrokeJoin.miter : StrokeJoin.round
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

    // Layer 3: Draw Crisp Black Outlines of SVG Shapes ON TOP
    if (svgParts.isNotEmpty && !isCustomRaster) {
      canvas.save();
      canvas.scale(scale, scale);

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final part in svgParts) {
        strokePaint.color = part.strokeColor;
        strokePaint.strokeWidth = part.strokeWidth;
        canvas.drawPath(part.path, strokePaint);
      }
      canvas.restore();
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
