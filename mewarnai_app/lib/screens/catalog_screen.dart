import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/drawing_item.dart';
import '../services/storage_service.dart';

class CatalogScreen extends StatefulWidget {
  final StorageService storage;
  final Function(DrawingItem) onSelectDrawing;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenGallery;

  const CatalogScreen({
    super.key,
    required this.storage,
    required this.onSelectDrawing,
    required this.onOpenProfile,
    required this.onOpenGallery,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late List<DrawingItem> _builtinDrawings;
  late List<DrawingItem> _customDrawings;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _builtinDrawings = DrawingItem.generate300Catalog();
    _customDrawings = widget.storage.getCustomDrawings();
  }

  void _reloadCustomDrawings() {
    setState(() {
      _customDrawings = widget.storage.getCustomDrawings();
    });
  }

  Future<void> _pickAndAddCustomDrawing() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final titleController = TextEditingController(text: 'Gambar Baru ${DateTime.now().day}/${DateTime.now().month}');
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Beri Nama Gambar 🎨'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Robot Super, Dinosaurus...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5E7E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = titleController.text.trim().isEmpty ? 'Gambar Sendiri' : titleController.text.trim();
              await widget.storage.addCustomDrawing(name, image.path);
              Navigator.pop(ctx);
              _reloadCustomDrawings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gambar berhasil ditambahkan ke katalog! 🚀')),
                );
              }
            },
            child: const Text('Simpan & Tambahkan'),
          ),
        ],
      ),
    );
  }

  List<DrawingItem> get _filteredDrawings {
    final all = [..._customDrawings, ..._builtinDrawings];
    return all.where((item) {
      final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeKid = widget.storage.getActiveProfile();
    final drawings = _filteredDrawings;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Text('🎨', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            const Text(
              'Mewarnai Ceria',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFFFF5E7E),
              ),
            ),
          ],
        ),
        actions: [
          // Active Kid Capsule
          GestureDetector(
            onTap: widget.onOpenProfile,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5EC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFCCD7), width: 1.5),
              ),
              child: Row(
                children: [
                  Text(activeKid.avatar, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    activeKid.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B2D42)),
                  ),
                  const SizedBox(width: 6),
                  Text('⭐ ${activeKid.totalStars}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Text('🖼️', style: TextStyle(fontSize: 22)),
            onPressed: widget.onOpenGallery,
            tooltip: 'Galeri Karya',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Scroll Bar + Import Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.white,
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BCB77),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: _pickAndAddCustomDrawing,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: const Text('Tambah Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DrawingCategory.allCategories.map((cat) {
                        final isSelected = cat.id == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Row(
                              children: [
                                Text(cat.icon),
                                const SizedBox(width: 4),
                                Text(cat.name),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() => _selectedCategory = cat.id);
                            },
                            selectedColor: const Color(0xFFFF5E7E),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF2B2D42),
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: const Color(0xFFF8F9FA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: '🔍 Cari gambar (singa, dino, roket, mobil)...',
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFEAE0D5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFEAE0D5)),
                ),
              ),
            ),
          ),

          // Drawings Grid
          Expanded(
            child: drawings.isEmpty
                ? const Center(
                    child: Text('Tidak ada gambar yang cocok 🔍', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: drawings.length,
                    itemBuilder: (ctx, index) {
                      final item = drawings[index];
                      return GestureDetector(
                        onTap: () => widget.onSelectDrawing(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1E9DF), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: item.isCustom
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            File(item.localCustomImagePath!),
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : SvgPicture.string(
                                          item.svgData,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF2B2D42),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.difficulty,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
