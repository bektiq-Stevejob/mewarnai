import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/evaluation_service.dart';
import '../services/export_service.dart';

class EvaluationDialog extends StatefulWidget {
  final ArtworkEvaluation evaluation;
  final String childName;
  final String drawingTitle;
  final String savedImagePath;
  final VoidCallback onViewGallery;
  final VoidCallback onNewDrawing;

  const EvaluationDialog({
    super.key,
    required this.evaluation,
    required this.childName,
    required this.drawingTitle,
    required this.savedImagePath,
    required this.onViewGallery,
    required this.onNewDrawing,
  });

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.evaluation.icon,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 6),
                Text(
                  'Karya Luar Biasa, ${widget.childName}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5E7E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.evaluation.stars,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text('⭐', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE169), Color(0xFFFF923C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.evaluation.badge,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF432800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD93D), width: 1.5),
                  ),
                  child: Text(
                    widget.evaluation.praise,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B2D42),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Success Message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF6BCB77), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Foto berhasil disimpan ke Galeri Tablet! 📸',
                        style: TextStyle(color: Color(0xFF2C7436), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Share Button
                if (widget.savedImagePath.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp / Share green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onPressed: () {
                        ExportService.shareArtwork(
                          filePath: widget.savedImagePath,
                          childName: widget.childName,
                          drawingTitle: widget.drawingTitle,
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text('Bagikan ke WhatsApp / Keluarga 📲', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D96FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onViewGallery();
                        },
                        icon: const Text('🖼️'),
                        label: const Text('Galeri'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5E7E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onNewDrawing();
                        },
                        icon: const Text('🎨'),
                        label: const Text('Lanjut'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
        ),
      ],
    );
  }
}
