class SavedArtwork {
  final String id;
  final String title;
  final String date;
  final int stars;
  final String badge;
  final String imagePath; // Local file path or base64 data

  SavedArtwork({
    required this.id,
    required this.title,
    required this.date,
    required this.stars,
    required this.badge,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'stars': stars,
    'badge': badge,
    'imagePath': imagePath,
  };

  factory SavedArtwork.fromJson(Map<String, dynamic> json) => SavedArtwork(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Karya Ceria',
    date: json['date'] ?? '',
    stars: json['stars'] ?? 5,
    badge: json['badge'] ?? 'Artis Cilik',
    imagePath: json['imagePath'] ?? '',
  );
}

class KidProfile {
  final String id;
  String name;
  int age;
  String avatar;
  String themeColorHex;
  int totalStars;
  List<SavedArtwork> gallery;

  KidProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    required this.themeColorHex,
    required this.totalStars,
    required this.gallery,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'avatar': avatar,
    'themeColorHex': themeColorHex,
    'totalStars': totalStars,
    'gallery': gallery.map((a) => a.toJson()).toList(),
  };

  factory KidProfile.fromJson(Map<String, dynamic> json) => KidProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Anak Ceria',
    age: json['age'] ?? 5,
    avatar: json['avatar'] ?? '🦁',
    themeColorHex: json['themeColorHex'] ?? '#FF5E7E',
    totalStars: json['totalStars'] ?? 0,
    gallery: (json['gallery'] as List<dynamic>?)
            ?.map((e) => SavedArtwork.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  static List<KidProfile> get defaultProfiles => [
    KidProfile(
      id: 'kid-1',
      name: 'Kakak',
      age: 7,
      avatar: '🦁',
      themeColorHex: '#FF5E7E',
      totalStars: 15,
      gallery: [],
    ),
    KidProfile(
      id: 'kid-2',
      name: 'Abang',
      age: 5,
      avatar: '🚀',
      themeColorHex: '#4D96FF',
      totalStars: 10,
      gallery: [],
    ),
    KidProfile(
      id: 'kid-3',
      name: 'Adek',
      age: 3,
      avatar: '🦄',
      themeColorHex: '#FFD93D',
      totalStars: 8,
      gallery: [],
    ),
  ];
}
