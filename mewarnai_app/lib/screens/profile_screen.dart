import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onProfileSelected;

  const ProfileScreen({
    super.key,
    required this.storage,
    required this.onProfileSelected,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late List<KidProfile> _profiles;
  late String _activeId;

  final List<String> _avatarOptions = ['🦁', '🚀', '🦄', '🦖', '🐱', '🐼', '🦊', '🐰'];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profiles = widget.storage.getProfiles();
      _activeId = widget.storage.getActiveKidId();
    });
  }

  void _editProfile(KidProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    String selectedAvatar = profile.avatar;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Atur Profil Anak 👦👧', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Panggilan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Usia (Tahun):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pilih Karakter Favorit:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _avatarOptions.map((emoji) {
                    final isChosen = emoji == selectedAvatar;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedAvatar = emoji),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChosen ? const Color(0xFFFFE5EC) : const Color(0xFFF8F9FA),
                          border: Border.all(
                            color: isChosen ? const Color(0xFFFF5E7E) : const Color(0xFFEAE0D5),
                            width: 2,
                          ),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                      ),
                    );
                  }).toList(),
                ),
              ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                profile.name = nameController.text.trim().isEmpty ? profile.name : nameController.text.trim();
                profile.age = int.tryParse(ageController.text) ?? profile.age;
                profile.avatar = selectedAvatar;
                await widget.storage.saveProfiles(_profiles);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                _loadProfiles();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Pilih Profil Anak ✨',
          style: TextStyle(color: Color(0xFF2B2D42), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Siapa yang Mau Mewarnai Sekarang? 😊',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5E7E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih akunmu agar karya dan bintangmu tersimpan rapi!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _profiles.map((profile) {
                  final isActive = profile.id == _activeId;
                  return Container(
                    width: 240,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: isActive ? 6 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isActive ? const Color(0xFFFF5E7E) : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFF0F4),
                              ),
                              child: Center(
                                child: Text(profile.avatar, style: const TextStyle(fontSize: 48)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B2D42),
                              ),
                            ),
                            Text('Usia: ${profile.age} Tahun', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('⭐ ${profile.totalStars}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const Text('Bintang', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('🖼️ ${profile.gallery.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const Text('Karya', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF5E7E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () async {
                                      await widget.storage.setActiveKidId(profile.id);
                                      widget.onProfileSelected();
                                    },
                                    child: const Text('Mulai Mewarnai 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Text('✏️', style: TextStyle(fontSize: 18)),
                                  onPressed: () => _editProfile(profile),
                                  tooltip: 'Ubah Nama & Karakter',
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
