import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GalleryScreen extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onBackToCatalog;

  const GalleryScreen({
    super.key,
    required this.storage,
    required this.onBackToCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final activeKid = storage.getActiveProfile();
    final artworks = activeKid.gallery;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2B2D42), size: 28),
          onPressed: onBackToCatalog,
        ),
        title: Text(
          'Galeri Karya ${activeKid.name} 🌟',
          style: const TextStyle(color: Color(0xFF2B2D42), fontWeight: FontWeight.bold),
        ),
      ),
      body: artworks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎨', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada karya dari ${activeKid.name}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF5E7E)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pilih gambar di katalog dan mulailah berkreasi! ✨', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5E7E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: onBackToCatalog,
                    child: const Text('Mulai Mewarnai Sekarang 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: artworks.length,
              itemBuilder: (ctx, index) {
                final art = artworks[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1E9DF), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: File(art.imagePath).existsSync()
                              ? Image.file(File(art.imagePath), fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFFF8F9FA),
                                  child: const Center(child: Text('🖼️', style: TextStyle(fontSize: 40))),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              art.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('⭐' * art.stars, style: const TextStyle(fontSize: 12)),
                                Text(art.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
