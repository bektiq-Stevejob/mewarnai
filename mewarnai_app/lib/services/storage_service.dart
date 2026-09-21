import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../models/drawing_item.dart';

class StorageService {
  static const String _keyProfiles = 'ceria_kids_profiles_flutter_v1';
  static const String _keyActiveKid = 'ceria_active_kid_flutter_v1';
  static const String _keyCustomDrawings = 'ceria_custom_drawings_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<KidProfile> getProfiles() {
    final String? raw = _prefs.getString(_keyProfiles);
    if (raw == null) {
      final defaults = KidProfile.defaultProfiles;
      saveProfiles(defaults);
      return defaults;
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => KidProfile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return KidProfile.defaultProfiles;
    }
  }

  Future<void> saveProfiles(List<KidProfile> profiles) async {
    final String raw = jsonEncode(profiles.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyProfiles, raw);
  }

  String getActiveKidId() {
    return _prefs.getString(_keyActiveKid) ?? 'kid-1';
  }

  Future<void> setActiveKidId(String id) async {
    await _prefs.setString(_keyActiveKid, id);
  }

  KidProfile getActiveProfile() {
    final profiles = getProfiles();
    final activeId = getActiveKidId();
    return profiles.firstWhere((p) => p.id == activeId, orElse: () => profiles.first);
  }

  Future<void> saveArtworkForActiveKid(SavedArtwork artwork) async {
    final profiles = getProfiles();
    final activeId = getActiveKidId();
    final index = profiles.indexWhere((p) => p.id == activeId);
    if (index != -1) {
      profiles[index].gallery.insert(0, artwork);
      profiles[index].totalStars += artwork.stars;
      await saveProfiles(profiles);
    }
  }

  List<DrawingItem> getCustomDrawings() {
    final String? raw = _prefs.getString(_keyCustomDrawings);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => DrawingItem(
        id: e['id'] ?? '',
        num: 999,
        title: e['title'] ?? 'Gambar Sendiri',
        category: 'custom',
        difficulty: 'Bebas 🎨',
        svgData: '',
        localCustomImagePath: e['path'],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addCustomDrawing(String title, String imagePath) async {
    final list = getCustomDrawings();
    final newItem = {
      'id': 'custom-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'path': imagePath,
    };
    final rawList = list.map((e) => {'id': e.id, 'title': e.title, 'path': e.localCustomImagePath}).toList();
    rawList.insert(0, newItem);
    await _prefs.setString(_keyCustomDrawings, jsonEncode(rawList));
  }
}
