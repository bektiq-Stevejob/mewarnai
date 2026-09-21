class DrawingCategory {
  final String id;
  final String name;
  final String icon;

  const DrawingCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static const List<DrawingCategory> allCategories = [
    DrawingCategory(id: 'all', name: 'Semua Gambar', icon: '🎨'),
    DrawingCategory(id: 'custom', name: '📁 Gambar Sendiri', icon: '📁'),
    DrawingCategory(id: 'animals', name: '🦁 Hewan Lucu', icon: '🦁'),
    DrawingCategory(id: 'dinos', name: '🦖 Dinosaurus', icon: '🦖'),
    DrawingCategory(id: 'vehicles', name: '🚗 Kendaraan', icon: '🚗'),
    DrawingCategory(id: 'ocean', name: '🌊 Bawah Laut', icon: '🌊'),
    DrawingCategory(id: 'space', name: '🚀 Antariksa', icon: '🚀'),
    DrawingCategory(id: 'food', name: '🍓 Buah & Kue', icon: '🍓'),
    DrawingCategory(id: 'fairytale', name: '🏰 Dongeng', icon: '🏰'),
    DrawingCategory(id: 'nature', name: '🌸 Alam Bebas', icon: '🌸'),
  ];
}

class DrawingItem {
  final String id;
  final int num;
  final String title;
  final String category;
  final String difficulty;
  final String svgData;
  final String? localCustomImagePath;

  DrawingItem({
    required this.id,
    required this.num,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.svgData,
    this.localCustomImagePath,
  });

  bool get isCustom => localCustomImagePath != null;

  static List<DrawingItem> generate300Catalog() {
    final List<DrawingItem> items = [];

    final Map<String, List<String>> categoryTitles = {
      'animals': [
        'Singa Rimba Ceria', 'Gajah Baik Hati', 'Kucing Belang Lucu',
        'Kelinci Putih Melompat', 'Panda Pemakan Bambu', 'Jerapah Leher Panjang',
        'Kuda Poni Berlari', 'Monyet Cerdik', 'Koala Santai', 'Beruang Madu Gemoy',
        'Rubah Cerdik Oren', 'Serigala Malam', 'Sapi Susu Segar', 'Bebek Kuning Berenang'
      ],
      'dinos': [
        'T-Rex Sang Raja Rimba', 'Triceratops Tanduk Tiga', 'Brontosaurus Leher Tinggi',
        'Pterodactyl Sayap Gagah', 'Stegosaurus Sisik Emas', 'Ankylosaurus Perisai Baja',
        'Dino Bayi Menetas', 'Spinosaurus Sirip Emas'
      ],
      'vehicles': [
        'Mobil Balap Formula', 'Mobil Polisi Cepat', 'Truk Pemadam Penyelamat',
        'Bus Sekolah Ceria', 'Kereta Api Uap', 'Pesawat Jet Cepat',
        'Helikopter Penolong', 'Kapal Layar Samudra'
      ],
      'ocean': [
        'Ikan Nemo Ceria', 'Lumba-Lumba Cerdas', 'Paus Biru Raksasa',
        'Kura-Kura Laut', 'Gurita Delapan Lengan', 'Kuda Laut Mungil'
      ],
      'space': [
        'Roket Menembus Bintang', 'Astronot Cilik Menjelajah', 'Planet Saturnus Cincin',
        'Alien Ramah Bintang', 'UFO Piring Terbang'
      ],
      'food': [
        'Kue Cupcake Stroberi', 'Es Krim Pelangi Tiga Rasa', 'Donat Coklat Manis',
        'Apel Segar Merah', 'Semangka Manis Berbiji'
      ],
      'fairytale': [
        'Istana Megah Sang Putri', 'Unicorn Ajaib Bertanduk', 'Naga Baik Hati',
        'Peri Bunga Bersayap', 'Mahkota Emas Permata'
      ],
      'nature': [
        'Bunga Matahari Tersenyum', 'Pelangi Seusai Hujan', 'Pohon Apel Rindang',
        'Kupu-Kupu Pelangi'
      ],
    };

    final List<String> vectorTemplates = [
      _svgLion,
      _svgCar,
      _svgRocket,
      _svgFish,
      _svgCupcake,
      _svgCastle,
      _svgSunFlower,
      _svgDino,
    ];

    final difficulties = ['Mudah ⭐', 'Sedang ⭐⭐', 'Seru ⭐⭐⭐'];
    final categoryKeys = categoryTitles.keys.toList();

    for (int i = 0; i < 300; i++) {
      final catKey = categoryKeys[i % categoryKeys.length];
      final titles = categoryTitles[catKey]!;
      final title = titles[i % titles.length];
      final svg = vectorTemplates[i % vectorTemplates.length];
      final diff = difficulties[i % difficulties.length];
      final series = (i ~/ categoryKeys.length) > 0 ? ' #${(i ~/ categoryKeys.length) + 1}' : '';

      items.add(DrawingItem(
        id: 'drawing-${i + 1}',
        num: i + 1,
        title: '$title$series',
        category: catKey,
        difficulty: diff,
        svgData: svg,
      ));
    }

    return items;
  }

  // --- SVG Vector Line Arts ---
  static const String _svgLion = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="240" r="140" stroke-dasharray="25 15" stroke-width="12" />
    <circle cx="250" cy="240" r="120" stroke-width="8" />
    <ellipse cx="250" cy="245" rx="85" ry="80" stroke-width="7"/>
    <circle cx="175" cy="180" r="28"/>
    <circle cx="325" cy="180" r="28"/>
    <circle cx="215" cy="230" r="12" fill="#1e2022"/>
    <circle cx="285" cy="230" r="12" fill="#1e2022"/>
    <polygon points="250,255 235,275 265,275" fill="#1e2022"/>
    <path d="M 250,275 Q 235,300 215,290" fill="none"/>
    <path d="M 250,275 Q 265,300 285,290" fill="none"/>
    <line x1="160" y1="260" x2="210" y2="265"/>
    <line x1="160" y1="280" x2="210" y2="278"/>
    <line x1="340" y1="260" x2="290" y2="265"/>
    <line x1="340" y1="280" x2="290" y2="278"/>
    <path d="M 190,320 Q 160,430 180,450 Q 250,460 320,450 Q 340,430 310,320"/>
  </g>
</svg>''';

  static const String _svgCar = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 80,310 L 130,310 L 170,210 L 320,210 L 370,310 L 430,310 C 445,310 450,325 450,345 L 450,380 L 60,380 L 60,345 C 60,325 65,310 80,310 Z"/>
    <path d="M 180,225 L 240,225 L 240,295 L 145,295 Z"/>
    <path d="M 255,225 L 315,225 L 350,295 L 255,295 Z"/>
    <circle cx="435" cy="335" r="12"/>
    <circle cx="150" cy="380" r="45"/>
    <circle cx="150" cy="380" r="20" fill="#1e2022"/>
    <circle cx="360" cy="380" r="45"/>
    <circle cx="360" cy="380" r="20" fill="#1e2022"/>
  </g>
</svg>''';

  static const String _svgRocket = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 250,70 C 200,160 190,280 190,360 L 310,360 C 310,280 300,160 250,70 Z"/>
    <circle cx="250" cy="230" r="38"/>
    <circle cx="250" cy="230" r="26"/>
    <path d="M 190,300 L 130,370 L 190,370 Z"/>
    <path d="M 310,300 L 370,370 L 310,370 Z"/>
    <path d="M 225,385 Q 210,435 235,460 Q 250,420 265,460 Q 290,435 275,385 Z"/>
  </g>
</svg>''';

  static const String _svgFish = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 120,250 C 180,140 330,150 370,250 C 330,350 180,360 120,250 Z"/>
    <path d="M 130,250 L 60,170 C 90,240 90,260 60,330 Z"/>
    <circle cx="325" cy="225" r="14" fill="#1e2022"/>
    <path d="M 360,255 Q 345,270 335,260" fill="none"/>
    <circle cx="410" cy="150" r="16"/>
    <circle cx="430" cy="110" r="10"/>
  </g>
</svg>''';

  static const String _svgCupcake = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="160,260 185,420 315,420 340,260"/>
    <path d="M 140,260 C 130,220 170,210 190,230 C 210,190 260,190 280,220 C 300,190 350,210 360,260 Z"/>
    <path d="M 175,220 C 180,165 240,150 260,180 C 290,160 325,185 320,220 Z"/>
    <circle cx="250" cy="115" r="22"/>
  </g>
</svg>''';

  static const String _svgCastle = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="150" y="260" width="200" height="170"/>
    <path d="M 215,430 L 215,350 C 215,315 285,315 285,350 L 285,430 Z"/>
    <rect x="90" y="210" width="60" height="220"/>
    <polygon points="80,210 120,110 160,210"/>
    <rect x="350" y="210" width="60" height="220"/>
    <polygon points="340,210 380,110 420,210"/>
  </g>
</svg>''';

  static const String _svgSunFlower = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="210" r="60"/>
    <circle cx="230" cy="200" r="7" fill="#1e2022"/>
    <circle cx="270" cy="200" r="7" fill="#1e2022"/>
    <path d="M 230,225 Q 250,245 270,225" fill="none"/>
    <path d="M 250,270 L 250,450" stroke-width="9"/>
    <path d="M 250,350 Q 180,330 160,380 Q 210,400 250,370"/>
  </g>
</svg>''';

  static const String _svgDino = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1e2022" stroke-width="7" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 160,180 C 160,100 280,100 310,130 C 340,160 330,220 280,220 L 260,220 L 270,260 L 210,240 L 190,260 Z"/>
    <circle cx="230" cy="150" r="10" fill="#1e2022"/>
    <path d="M 170,240 C 150,300 130,350 70,360 C 120,400 200,410 260,390"/>
    <path d="M 210,240 C 260,280 270,360 250,390" fill="none"/>
    <path d="M 190,370 C 180,410 170,445 150,455 L 200,455"/>
    <path d="M 240,370 C 235,410 230,445 220,455 L 265,455"/>
  </g>
</svg>''';
}
