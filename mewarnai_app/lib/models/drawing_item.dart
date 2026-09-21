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
    DrawingCategory(id: '3d_expert', name: '⭐ 3D & Expert', icon: '⭐'),
    DrawingCategory(id: 'sketches', name: '✏️ Model Sketsa', icon: '✏️'),
    DrawingCategory(id: 'animals', name: '🦁 Hewan Lucu', icon: '🦁'),
    DrawingCategory(id: 'dinos', name: '🦖 Dinosaurus', icon: '🦖'),
    DrawingCategory(id: 'vehicles', name: '🚗 Kendaraan', icon: '🚗'),
    DrawingCategory(id: 'ocean', name: '🌊 Bawah Laut', icon: '🌊'),
    DrawingCategory(id: 'space', name: '🚀 Antariksa', icon: '🚀'),
    DrawingCategory(id: 'food', name: '🍓 Buah & Kue', icon: '🍓'),
    DrawingCategory(id: 'fairytale', name: '🏰 Dongeng', icon: '🏰'),
    DrawingCategory(id: 'nature', name: '🌸 Alam Bebas', icon: '🌸'),
    DrawingCategory(id: 'custom', name: '📁 Gambar Sendiri', icon: '📁'),
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
  final String? sketchReferenceGuide; // Reference color hint for sketch mode
  final bool isBlankSketchpad;
  final String paperType; // 'white', 'grid', 'kraft'

  DrawingItem({
    required this.id,
    required this.num,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.svgData,
    this.localCustomImagePath,
    this.sketchReferenceGuide,
    this.isBlankSketchpad = false,
    this.paperType = 'white',
  });

  bool get isCustom => localCustomImagePath != null;
  bool get is3D => category == '3d_expert';
  bool get isSketch => category == 'sketches' || isBlankSketchpad;

  static DrawingItem createBlankSketchpad(String paper) {
    return DrawingItem(
      id: 'blank-${DateTime.now().millisecondsSinceEpoch}',
      num: 0,
      title: 'Kanvas Sketsa Bebas (${paper == 'grid' ? 'Grid Kotak' : paper == 'kraft' ? 'Kertas Kraft' : 'Kertas Putih'})',
      category: 'sketches',
      difficulty: 'Kreatif Bebas ✏️',
      svgData: '',
      isBlankSketchpad: true,
      paperType: paper,
    );
  }

  static List<DrawingItem> generate300Catalog() {
    final List<DrawingItem> items = [];

    // Map each category to its REAL, AUTHENTIC, category-specific SVGs
    final Map<String, List<Map<String, String>>> categoryDatabase = {
      // 1. ⭐ 3D & EXPERT (Detailed, 3D perspective, shading lines, intricate segments)
      '3d_expert': [
        {
          'title': 'Mobil Balap Super 3D Perspektif',
          'svg': _svg3dSportsCar,
          'diff': 'Expert 3D ⭐⭐⭐',
          'ref': 'Bodi merah menyala dengan bayangan hitam di kolong dan kaca gelap!',
        },
        {
          'title': 'Robot Mecha Tempur 3D Berdimensi',
          'svg': _svg3dRobotMecha,
          'diff': 'Expert 3D ⭐⭐⭐',
          'ref': 'Lapisan pelindung baja biru-perak dengan inti dada bercahaya kuning!',
        },
        {
          'title': 'Naga Legendaris 3D Sayap Megah',
          'svg': _svg3dDragon,
          'diff': 'Expert 3D ⭐⭐⭐',
          'ref': 'Sisik naga hijau zamrud dengan sayap bergradasi merah emas!',
        },
        {
          'title': 'Kastil 3D Isometrik Benteng Pertahanan',
          'svg': _svg3dIsometricCastle,
          'diff': 'Expert 3D ⭐⭐⭐',
          'ref': 'Dinding batu abu-abu berarsir dengan atap menara biru kerajaan!',
        },
        {
          'title': 'Mandala Geometris 3D Bunga Kaca',
          'svg': _svg3dMandala,
          'diff': 'Expert 3D ⭐⭐⭐',
          'ref': 'Pola simetris warna pelangi bergantian dari tengah ke luar!',
        },
      ],

      // 2. ✏️ MODEL SKETSA (Pencil sketch outlines with shading guides)
      'sketches': [
        {
          'title': 'Sketsa Burung Hantu Panduan Arsir 3D',
          'svg': _svgSketchOwl,
          'diff': 'Model Sketsa ✏️',
          'ref': 'Gunakan pensil coklat muda dan arsir bagian sayap dengan tekanan lembut!',
        },
        {
          'title': 'Sketsa Kuda Berlari Anatomi Dinamis',
          'svg': _svgSketchHorse,
          'diff': 'Model Sketsa ✏️',
          'ref': 'Warna coklat tua dengan gradasi bayangan di bagian perut dan kaki!',
        },
        {
          'title': 'Sketsa Mobil Klasik Garis Perspektif',
          'svg': _svgSketchVintageCar,
          'diff': 'Model Sketsa ✏️',
          'ref': 'Warna biru vintage dengan sorotan cahaya putih di kap mesin!',
        },
        {
          'title': 'Sketsa Mawar 3D Bayangan Kelopak',
          'svg': _svgSketchRose,
          'diff': 'Model Sketsa ✏️',
          'ref': 'Kelopak merah tua di dalam, merah muda di luar dengan arsir bayangan hijau di daun!',
        },
      ],

      // 3. 🦁 HEWAN LUCU (Actual authentic animals)
      'animals': [
        {'title': 'Singa Rimba Ceria', 'svg': _svgLion, 'diff': 'Mudah ⭐'},
        {'title': 'Gajah Belalai Panjang', 'svg': _svgElephant, 'diff': 'Mudah ⭐'},
        {'title': 'Kucing Belang Lucu', 'svg': _svgCat, 'diff': 'Mudah ⭐'},
        {'title': 'Panda Pemakan Bambu', 'svg': _svgPanda, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Kelinci Ceria Melompat', 'svg': _svgRabbit, 'diff': 'Mudah ⭐'},
        {'title': 'Jerapah Leher Panjang', 'svg': _svgGiraffe, 'diff': 'Sedang ⭐⭐'},
      ],

      // 4. 🦖 DINOSAURUS (Actual authentic dinos)
      'dinos': [
        {'title': 'T-Rex Sang Raja Rimba', 'svg': _svgTrex, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Triceratops Tanduk Tiga', 'svg': _svgTriceratops, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Brontosaurus Leher Tinggi', 'svg': _svgBronto, 'diff': 'Mudah ⭐'},
        {'title': 'Stegosaurus Sisik Emas', 'svg': _svgStego, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Pterodactyl Sayap Gagah', 'svg': _svgPterodactyl, 'diff': 'Sedang ⭐⭐'},
      ],

      // 5. 🚗 KENDARAAN (Actual authentic vehicles)
      'vehicles': [
        {'title': 'Mobil Balap Formula 1', 'svg': _svgRaceCar, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Truk Pemadam Penyelamat', 'svg': _svgFireTruck, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Kereta Api Uap Klasik', 'svg': _svgSteamTrain, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Pesawat Jet Penembus Awan', 'svg': _svgAirplane, 'diff': 'Mudah ⭐'},
        {'title': 'Kapal Layar Samudra', 'svg': _svgSailBoat, 'diff': 'Mudah ⭐'},
      ],

      // 6. 🌊 BAWAH LAUT (Actual authentic sea life)
      'ocean': [
        {'title': 'Ikan Badut Nemo Ceria', 'svg': _svgClownFish, 'diff': 'Mudah ⭐'},
        {'title': 'Lumba-Lumba Cerdas Melompat', 'svg': _svgDolphin, 'diff': 'Mudah ⭐'},
        {'title': 'Paus Biru Raksasa Lembut', 'svg': _svgWhale, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Kura-Kura Laut Berenang', 'svg': _svgSeaTurtle, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Gurita Delapan Lengan', 'svg': _svgOctopus, 'diff': 'Sedang ⭐⭐'},
      ],

      // 7. 🚀 ANTARIKSA (Actual authentic space)
      'space': [
        {'title': 'Astronot Cilik Menjelajah', 'svg': _svgAstronaut, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Roket Melesat ke Bintang', 'svg': _svgRocketSpace, 'diff': 'Mudah ⭐'},
        {'title': 'Planet Saturnus Cincin Indah', 'svg': _svgSaturnPlanet, 'diff': 'Mudah ⭐'},
        {'title': 'UFO Piring Terbang Ramah', 'svg': _svgUfo, 'diff': 'Mudah ⭐'},
      ],

      // 8. 🍓 BUAH & KUE (Actual authentic treats)
      'food': [
        {'title': 'Kue Ulang Tahun Bertingkat', 'svg': _svgBirthdayCake, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Kue Cupcake Krim Stroberi', 'svg': _svgCupcakeTreat, 'diff': 'Mudah ⭐'},
        {'title': 'Es Krim Tiga Rasa Pelangi', 'svg': _svgIceCreamSundae, 'diff': 'Mudah ⭐'},
        {'title': 'Donat Ceria Tabur Coklat', 'svg': _svgDonut, 'diff': 'Mudah ⭐'},
        {'title': 'Pizza Mini Segitiga Lezat', 'svg': _svgPizzaSlice, 'diff': 'Mudah ⭐'},
      ],

      // 9. 🏰 DONGENG (Actual authentic fantasy)
      'fairytale': [
        {'title': 'Istana Megah Sang Putri', 'svg': _svgFairytaleCastle, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Kuda Unicorn Ajaib Bertanduk', 'svg': _svgUnicornPegasus, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Naga Baik Penjaga Harta', 'svg': _svgFriendlyDragon, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Mahkota Emas Bertabur Permata', 'svg': _svgCrown, 'diff': 'Mudah ⭐'},
      ],

      // 10. 🌸 ALAM BEBAS (Actual authentic nature)
      'nature': [
        {'title': 'Bunga Matahari Penuh Senyum', 'svg': _svgSunflowerNature, 'diff': 'Mudah ⭐'},
        {'title': 'Pelangi Indah Seusai Hujan', 'svg': _svgRainbowNature, 'diff': 'Mudah ⭐'},
        {'title': 'Kupu-Kupu Sayap Bidadari', 'svg': _svgButterfly, 'diff': 'Sedang ⭐⭐'},
        {'title': 'Pohon Apel Rindang Ceria', 'svg': _svgAppleTree, 'diff': 'Mudah ⭐'},
      ],
    };

    int globalNum = 1;
    final catKeys = categoryDatabase.keys.toList();

    // Fill the 300 catalog proportionally, ensuring 100% CATEGORY ACCURACY
    for (int i = 0; i < 300; i++) {
      final catKey = catKeys[i % catKeys.length];
      final templates = categoryDatabase[catKey]!;
      final baseData = templates[i % templates.length];
      final cycle = (i ~/ catKeys.length) > 0 ? ' Seri #${(i ~/ catKeys.length) + 1}' : '';

      items.add(DrawingItem(
        id: 'item-$globalNum',
        num: globalNum,
        title: '${baseData['title']}$cycle',
        category: catKey,
        difficulty: baseData['diff'] ?? 'Sedang ⭐⭐',
        svgData: baseData['svg']!,
        sketchReferenceGuide: baseData['ref'],
      ));
      globalNum++;
    }

    return items;
  }

  // =========================================================================
  // AUTHENTIC SVG DEFINITIONS
  // =========================================================================

  // 1. ⭐ 3D & EXPERT (Perspective, Shaded Facets, Depth)
  static const String _svg3dSportsCar = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- 3D Angular Hood & Bumper with perspective -->
    <polygon points="50,320 120,270 380,270 450,320 440,370 60,370" stroke-width="7"/>
    <polygon points="120,270 160,200 340,200 380,270"/>
    <!-- 3D Windshield & Roof -->
    <polygon points="170,200 210,130 290,130 330,200"/>
    <line x1="250" y1="130" x2="250" y2="200" stroke-width="4"/>
    <!-- Headlights 3D angled -->
    <polygon points="80,310 130,290 140,330 90,340" fill="#f8f9fa"/>
    <polygon points="420,310 370,290 360,330 410,340" fill="#f8f9fa"/>
    <!-- Front Grill 3D Depth -->
    <polygon points="180,310 320,310 310,360 190,360" stroke-width="5"/>
    <line x1="200" y1="330" x2="300" y2="330" stroke-width="4"/>
    <line x1="205" y1="345" x2="295" y2="345" stroke-width="4"/>
    <!-- 3D Wheels with Rim Depth -->
    <ellipse cx="100" cy="380" rx="45" ry="50" stroke-width="8"/>
    <ellipse cx="100" cy="380" rx="26" ry="30" stroke-width="5" fill="#1a1a1a"/>
    <ellipse cx="400" cy="380" rx="45" ry="50" stroke-width="8"/>
    <ellipse cx="400" cy="380" rx="26" ry="30" stroke-width="5" fill="#1a1a1a"/>
    <!-- Aerodynamic Side Mirrors -->
    <polygon points="145,210 120,195 130,225" stroke-width="5"/>
    <polygon points="355,210 380,195 370,225" stroke-width="5"/>
    <!-- Shading Hatching lines for 3D depth -->
    <line x1="70" y1="355" x2="90" y2="365" stroke-width="3"/>
    <line x1="410" y1="365" x2="430" y2="355" stroke-width="3"/>
  </g>
</svg>''';

  static const String _svg3dRobotMecha = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Mecha Head with Angular Helmet & Visor -->
    <polygon points="210,130 250,90 290,130 275,170 225,170" stroke-width="7"/>
    <polygon points="225,135 275,135 270,150 230,150" fill="#1a1a1a"/>
    <!-- Chest Armor Plates with 3D Core -->
    <polygon points="180,170 320,170 300,280 200,280" stroke-width="7"/>
    <circle cx="250" cy="225" r="28" stroke-width="6"/>
    <polygon points="250,205 265,225 250,245 235,225" fill="#1a1a1a"/>
    <!-- Angular Shoulder Guards -->
    <polygon points="180,170 110,150 130,230 180,210" stroke-width="7"/>
    <polygon points="320,170 390,150 370,230 320,210" stroke-width="7"/>
    <!-- Forearm Cannons -->
    <rect x="95" y="230" width="45" height="110" rx="10" stroke-width="6"/>
    <rect x="360" y="230" width="45" height="110" rx="10" stroke-width="6"/>
    <!-- Waist & Heavy Legs -->
    <polygon points="210,280 290,280 280,330 220,330" stroke-width="6"/>
    <polygon points="190,330 235,330 225,450 160,450" stroke-width="7"/>
    <polygon points="310,330 265,330 275,450 340,450" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svg3dDragon = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Dragon Head & Horns -->
    <path d="M 230,150 L 210,80 L 250,110 L 290,80 L 270,150 Z" stroke-width="7"/>
    <path d="M 215,150 Q 250,200 285,150 Z" stroke-width="6"/>
    <circle cx="235" cy="135" r="8" fill="#1a1a1a"/>
    <circle cx="265" cy="135" r="8" fill="#1a1a1a"/>
    <!-- Giant Wings with 3D Ribs -->
    <path d="M 210,190 Q 90,80 50,180 Q 120,230 190,240 Z" stroke-width="7"/>
    <line x1="140" y1="140" x2="110" y2="210" stroke-width="5"/>
    <path d="M 290,190 Q 410,80 450,180 Q 380,230 310,240 Z" stroke-width="7"/>
    <line x1="360" y1="140" x2="390" y2="210" stroke-width="5"/>
    <!-- Muscular Scaled Body -->
    <path d="M 220,200 Q 200,320 230,420 Q 270,420 280,320 Q 270,200 220,200 Z" stroke-width="7"/>
    <!-- Dragon Claws & Tail -->
    <path d="M 200,420 L 170,460 M 230,420 L 220,465 M 270,420 L 280,465 M 300,420 L 330,460" stroke-width="7"/>
    <path d="M 250,420 Q 340,460 380,380 Q 420,320 450,340" stroke-width="7" fill="none"/>
  </g>
</svg>''';

  static const String _svg3dIsometricCastle = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Isometric Central Tower -->
    <polygon points="250,100 320,140 250,180 180,140" stroke-width="7"/>
    <polygon points="180,140 250,180 250,320 180,270"/>
    <polygon points="250,180 320,140 320,270 250,320"/>
    <!-- Conical 3D Roof -->
    <polygon points="250,20 320,100 180,100" stroke-width="7"/>
    <!-- Left Bastion Tower -->
    <polygon points="120,210 170,240 120,270 70,240" stroke-width="6"/>
    <polygon points="70,240 120,270 120,380 70,340"/>
    <polygon points="120,270 170,240 170,340 120,380"/>
    <polygon points="120,150 170,210 70,210" stroke-width="6"/>
    <!-- Right Bastion Tower -->
    <polygon points="380,210 430,240 380,270 330,240" stroke-width="6"/>
    <polygon points="330,240 380,270 380,380 330,340"/>
    <polygon points="380,270 430,240 430,340 380,380"/>
    <polygon points="380,150 430,210 330,210" stroke-width="6"/>
    <!-- Castle Gate 3D -->
    <path d="M 220,320 L 220,270 Q 250,250 280,270 L 280,320 Z" stroke-width="6" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svg3dMandala = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="250" r="210" stroke-width="8"/>
    <circle cx="250" cy="250" r="160" stroke-width="6"/>
    <circle cx="250" cy="250" r="110" stroke-width="6"/>
    <circle cx="250" cy="250" r="60" stroke-width="6"/>
    <circle cx="250" cy="250" r="20" stroke-width="5" fill="#1a1a1a"/>
    <!-- 8 Symmetrical Petal Rays -->
    <polygon points="250,40 270,110 250,140 230,110"/>
    <polygon points="250,460 270,390 250,360 230,390"/>
    <polygon points="40,250 110,270 140,250 110,230"/>
    <polygon points="460,250 390,270 360,250 390,230"/>
    <polygon points="100,100 160,130 150,170 110,150"/>
    <polygon points="400,100 340,130 350,170 390,150"/>
    <polygon points="100,400 160,370 150,330 110,350"/>
    <polygon points="400,400 340,370 350,330 390,350"/>
  </g>
</svg>''';

  // 2. ✏️ MODEL SKETSA (Pencil sketch with shading hatching lines)
  static const String _svgSketchOwl = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#2c3437" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Owl Outline -->
    <ellipse cx="250" cy="260" rx="120" ry="150" stroke-width="7"/>
    <!-- Big Expressive Eyes -->
    <circle cx="195" cy="190" r="42" stroke-width="6"/>
    <circle cx="195" cy="190" r="20" fill="#2c3437"/>
    <circle cx="305" cy="190" r="42" stroke-width="6"/>
    <circle cx="305" cy="190" r="20" fill="#2c3437"/>
    <!-- Beak -->
    <polygon points="250,215 238,245 262,245" fill="#2c3437"/>
    <!-- Ear Tufts -->
    <polygon points="140,160 170,90 205,140"/>
    <polygon points="360,160 330,90 295,140"/>
    <!-- Shading Hatching Guides for 3D Feathers -->
    <line x1="210" y1="280" x2="230" y2="295" stroke-dasharray="4 4"/>
    <line x1="240" y1="280" x2="260" y2="295" stroke-dasharray="4 4"/>
    <line x1="270" y1="280" x2="290" y2="295" stroke-dasharray="4 4"/>
    <line x1="220" y1="310" x2="240" y2="325" stroke-dasharray="4 4"/>
    <line x1="250" y1="310" x2="270" y2="325" stroke-dasharray="4 4"/>
    <!-- Tree Branch -->
    <rect x="80" y="400" width="340" height="30" rx="10" stroke-width="6"/>
    <!-- Claws -->
    <circle cx="190" cy="405" r="10"/><circle cx="210" cy="405" r="10"/>
    <circle cx="290" cy="405" r="10"/><circle cx="310" cy="405" r="10"/>
  </g>
</svg>''';

  static const String _svgSketchHorse = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#2c3437" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Running Horse Muscular Form -->
    <path d="M 120,260 C 160,200 240,210 320,240 C 370,250 420,210 440,160 L 410,130 L 370,160 C 350,140 330,110 320,80 L 300,120 C 270,140 240,180 200,220 Z" stroke-width="7"/>
    <!-- Legs in Motion -->
    <path d="M 210,240 L 160,370 L 140,430 M 230,240 L 260,360 L 280,440" stroke-width="6"/>
    <path d="M 330,250 L 350,380 L 380,430 M 350,250 L 390,350 L 430,410" stroke-width="6"/>
    <!-- Flowing Mane & Tail -->
    <path d="M 340,90 Q 300,110 310,160 Q 260,160 270,210" stroke-width="6"/>
    <path d="M 130,260 Q 80,300 70,380 Q 90,340 120,310" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgSketchVintageCar = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#2c3437" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Classic Rounded Fenders & Body -->
    <path d="M 70,340 C 70,270 140,260 170,260 L 200,180 L 340,180 L 370,260 C 400,260 450,280 450,350 L 50,350 Z" stroke-width="7"/>
    <!-- Split Windshield -->
    <rect x="210" y="195" width="55" height="55" rx="6"/>
    <rect x="275" y="195" width="55" height="55" rx="6"/>
    <!-- Big Vintage Spoke Wheels -->
    <circle cx="130" cy="360" r="45" stroke-width="8"/>
    <circle cx="130" cy="360" r="18" fill="#2c3437"/>
    <circle cx="380" cy="360" r="45" stroke-width="8"/>
    <circle cx="380" cy="360" r="18" fill="#2c3437"/>
    <!-- Chrome Bumper & Headlight -->
    <circle cx="70" cy="300" r="16" stroke-width="5"/>
    <circle cx="450" cy="300" r="16" stroke-width="5"/>
  </g>
</svg>''';

  static const String _svgSketchRose = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#2c3437" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <!-- Rose Spiral Center with Layered Shading Petals -->
    <path d="M 250,180 C 230,130 290,130 270,180 C 310,150 330,220 280,240 C 310,280 230,300 210,260 C 160,280 160,200 210,190 Z" stroke-width="7"/>
    <circle cx="250" cy="200" r="22" stroke-width="5"/>
    <!-- Outer Petals with Contour Lines -->
    <path d="M 180,180 C 120,130 190,90 250,110 C 320,90 380,140 330,190" stroke-width="6"/>
    <path d="M 150,230 C 100,270 170,350 250,330 C 340,350 390,270 350,230" stroke-width="6"/>
    <!-- Stem & Detailed Leaves with Veins -->
    <path d="M 250,330 L 250,470" stroke-width="8"/>
    <path d="M 250,390 Q 170,360 140,410 Q 200,430 250,410" stroke-width="6"/>
    <line x1="250" y1="400" x2="160" y2="400" stroke-dasharray="3 3"/>
    <path d="M 250,410 Q 330,380 360,430 Q 300,450 250,430" stroke-width="6"/>
    <line x1="250" y1="420" x2="340" y2="420" stroke-dasharray="3 3"/>
  </g>
</svg>''';

  // 3. 🦁 ANIMALS (Authentic)
  static const String _svgLion = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="240" r="140" stroke-dasharray="25 15" stroke-width="12" />
    <ellipse cx="250" cy="245" rx="85" ry="80" stroke-width="7"/>
    <circle cx="175" cy="180" r="28"/><circle cx="325" cy="180" r="28"/>
    <circle cx="215" cy="230" r="12" fill="#1a1a1a"/><circle cx="285" cy="230" r="12" fill="#1a1a1a"/>
    <polygon points="250,255 235,275 265,275" fill="#1a1a1a"/>
    <path d="M 250,275 Q 235,300 215,290" fill="none"/><path d="M 250,275 Q 265,300 285,290" fill="none"/>
    <line x1="160" y1="260" x2="210" y2="265"/><line x1="160" y1="280" x2="210" y2="278"/>
    <line x1="340" y1="260" x2="290" y2="265"/><line x1="340" y1="280" x2="290" y2="278"/>
    <path d="M 190,320 Q 160,430 180,450 Q 250,460 320,450 Q 340,430 310,320"/>
  </g>
</svg>''';

  static const String _svgElephant = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="220" rx="100" ry="90" stroke-width="7"/>
    <path d="M 155,200 C 60,140 60,300 155,280 Z" stroke-width="7"/>
    <path d="M 345,200 C 440,140 440,300 345,280 Z" stroke-width="7"/>
    <path d="M 230,260 C 220,350 290,370 290,340 C 290,310 270,300 265,260" stroke-width="7"/>
    <circle cx="205" cy="195" r="10" fill="#1a1a1a"/><circle cx="295" cy="195" r="10" fill="#1a1a1a"/>
    <path d="M 175,300 L 160,450 L 220,450 L 230,370 L 270,370 L 280,450 L 340,450 L 325,300" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgCat = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="230" r="95" stroke-width="7"/>
    <polygon points="170,165 195,95 230,145"/><polygon points="270,145 305,95 330,165"/>
    <ellipse cx="210" cy="215" rx="14" ry="20" fill="#1a1a1a"/><ellipse cx="290" cy="215" rx="14" ry="20" fill="#1a1a1a"/>
    <polygon points="250,245 240,235 260,235" fill="#1a1a1a"/>
    <path d="M 250,245 Q 235,265 220,255" fill="none"/><path d="M 250,245 Q 265,265 280,255" fill="none"/>
    <line x1="140" y1="230" x2="200" y2="240"/><line x1="360" y1="230" x2="300" y2="240"/>
    <path d="M 180,315 C 160,430 200,450 250,450 C 300,450 340,430 320,315 Z" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgPanda = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="160" cy="140" r="30" fill="#1a1a1a"/><circle cx="340" cy="140" r="30" fill="#1a1a1a"/>
    <ellipse cx="250" cy="220" rx="105" ry="95" stroke-width="7"/>
    <ellipse cx="205" cy="205" rx="20" ry="26" fill="#1a1a1a"/><ellipse cx="295" cy="205" rx="20" ry="26" fill="#1a1a1a"/>
    <circle cx="205" cy="200" r="6" fill="white"/><circle cx="295" cy="200" r="6" fill="white"/>
    <polygon points="250,235 238,248 262,248" fill="#1a1a1a"/>
    <path d="M 250,248 Q 250,265 235,265 M 250,248 Q 250,265 265,265" fill="none"/>
    <path d="M 170,300 Q 150,440 250,440 Q 350,440 330,300" stroke-width="7"/>
    <ellipse cx="140" cy="340" rx="25" ry="40" fill="#1a1a1a"/><ellipse cx="360" cy="340" rx="25" ry="40" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgRabbit = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="210" cy="120" rx="24" ry="75" stroke-width="7"/><ellipse cx="290" cy="120" rx="24" ry="75" stroke-width="7"/>
    <circle cx="250" cy="240" r="85" stroke-width="7"/>
    <circle cx="215" cy="225" r="12" fill="#1a1a1a"/><circle cx="285" cy="225" r="12" fill="#1a1a1a"/>
    <polygon points="250,250 240,262 260,262" fill="#1a1a1a"/>
    <line x1="150" y1="245" x2="200" y2="250"/><line x1="350" y1="245" x2="300" y2="250"/>
    <path d="M 180,320 Q 150,440 250,440 Q 350,440 320,320" stroke-width="7"/>
    <ellipse cx="190" cy="440" rx="35" ry="18"/><ellipse cx="310" cy="440" rx="35" ry="18"/>
  </g>
</svg>''';

  static const String _svgGiraffe = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="120" rx="45" ry="35" stroke-width="6"/>
    <line x1="230" y1="85" x2="230" y2="60" stroke-width="6"/><circle cx="230" cy="55" r="7" fill="#1a1a1a"/>
    <line x1="270" y1="85" x2="270" y2="60" stroke-width="6"/><circle cx="270" cy="55" r="7" fill="#1a1a1a"/>
    <circle cx="235" cy="115" r="6" fill="#1a1a1a"/><circle cx="265" cy="115" r="6" fill="#1a1a1a"/>
    <path d="M 230,150 L 220,330 L 160,450 M 270,150 L 280,330 L 340,450" stroke-width="7"/>
    <circle cx="245" cy="200" r="14" stroke-dasharray="4 4"/><circle cx="255" cy="260" r="16" stroke-dasharray="4 4"/>
  </g>
</svg>''';

  // 4. 🦖 DINOSAURS (Authentic)
  static const String _svgTrex = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 160,180 C 160,100 280,100 310,130 C 340,160 330,220 280,220 L 260,220 L 270,260 L 210,240 L 190,260 Z" stroke-width="7"/>
    <circle cx="230" cy="150" r="10" fill="#1a1a1a"/>
    <polygon points="270,220 275,235 280,220" fill="white"/><polygon points="255,220 260,235 265,220" fill="white"/>
    <path d="M 170,240 C 150,300 130,350 70,360 C 120,400 200,410 260,390" stroke-width="7"/>
    <path d="M 210,240 C 260,280 270,360 250,390" fill="none"/>
    <path d="M 190,370 L 160,455 L 200,455 L 215,370" stroke-width="7"/>
    <path d="M 240,370 L 230,455 L 270,455 L 265,370" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgTriceratops = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 260,130 C 340,90 380,180 340,240 L 240,240 Z" stroke-width="7"/>
    <ellipse cx="220" cy="220" rx="60" ry="50" stroke-width="6"/>
    <polygon points="200,160 170,100 190,160" fill="#1a1a1a"/>
    <polygon points="250,160 270,100 240,160" fill="#1a1a1a"/>
    <polygon points="160,220 120,205 160,230" fill="#1a1a1a"/>
    <path d="M 280,230 Q 380,210 440,300 Q 380,380 280,360 Z" stroke-width="7"/>
    <rect x="230" y="330" width="35" height="110" rx="8"/><rect x="340" y="330" width="35" height="110" rx="8"/>
  </g>
</svg>''';

  static const String _svgBronto = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="140" cy="110" rx="25" ry="18" stroke-width="6"/><circle cx="145" cy="105" r="5" fill="#1a1a1a"/>
    <path d="M 155,120 Q 210,180 220,280 C 180,310 160,380 260,390 C 360,400 420,320 450,290" stroke-width="7"/>
    <rect x="200" y="360" width="35" height="95" rx="8"/><rect x="290" y="360" width="35" height="95" rx="8"/>
  </g>
</svg>''';

  static const String _svgStego = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 110,320 Q 230,220 370,300 L 450,330 L 370,370 Q 230,400 110,360 Z" stroke-width="7"/>
    <!-- Back Plates -->
    <polygon points="180,250 200,200 220,240"/><polygon points="240,230 265,170 285,230"/>
    <polygon points="300,240 325,190 345,250"/>
    <rect x="170" y="360" width="30" height="90" rx="6"/><rect x="300" y="360" width="30" height="90" rx="6"/>
  </g>
</svg>''';

  static const String _svgPterodactyl = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="220" rx="25" ry="50" stroke-width="6"/>
    <polygon points="250,170 300,120 250,190 200,120" stroke-width="6"/>
    <path d="M 230,200 Q 110,130 50,190 Q 140,250 230,230 Z" stroke-width="7"/>
    <path d="M 270,200 Q 390,130 450,190 Q 360,250 270,230 Z" stroke-width="7"/>
  </g>
</svg>''';

  // 5. 🚗 VEHICLES (Authentic)
  static const String _svgRaceCar = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 70,310 L 140,310 L 180,220 L 310,220 L 360,310 L 440,310 L 440,370 L 60,370 Z" stroke-width="7"/>
    <polygon points="190,230 240,230 240,290 160,290"/>
    <polygon points="255,230 300,230 330,290 255,290"/>
    <circle cx="140" cy="370" r="42" stroke-width="8"/><circle cx="140" cy="370" r="18" fill="#1a1a1a"/>
    <circle cx="360" cy="370" r="42" stroke-width="8"/><circle cx="360" cy="370" r="18" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgFireTruck = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="80" y="210" width="340" height="150" rx="10" stroke-width="7"/>
    <rect x="330" y="230" width="70" height="60" rx="4"/>
    <!-- Ladder on top -->
    <line x1="100" y1="180" x2="350" y2="180" stroke-width="6"/>
    <line x1="100" y1="195" x2="350" y2="195" stroke-width="6"/>
    <line x1="130" y1="180" x2="130" y2="195" stroke-width="4"/><line x1="180" y1="180" x2="180" y2="195" stroke-width="4"/>
    <line x1="230" y1="180" x2="230" y2="195" stroke-width="4"/><line x1="280" y1="180" x2="280" y2="195" stroke-width="4"/>
    <circle cx="150" cy="360" r="38" stroke-width="8"/><circle cx="330" cy="360" r="38" stroke-width="8"/>
  </g>
</svg>''';

  static const String _svgSteamTrain = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="80" y="200" width="140" height="170" rx="8" stroke-width="7"/>
    <rect x="220" y="250" width="180" height="120" rx="8" stroke-width="7"/>
    <rect x="300" y="190" width="40" height="60" stroke-width="6"/>
    <circle cx="130" cy="370" r="48" stroke-width="8"/><circle cx="260" cy="390" r="28" stroke-width="7"/>
    <circle cx="340" cy="390" r="28" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgAirplane = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="250" rx="180" ry="40" stroke-width="7"/>
    <polygon points="210,240 160,110 260,240"/>
    <polygon points="210,260 160,390 260,260"/>
    <polygon points="80,230 50,160 110,230"/>
    <circle cx="380" cy="250" r="10" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgSailBoat = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="80,310 420,310 360,390 140,390" stroke-width="7"/>
    <line x1="250" y1="100" x2="250" y2="310" stroke-width="8"/>
    <polygon points="250,110 380,280 250,280"/>
    <polygon points="240,130 130,280 240,280"/>
  </g>
</svg>''';

  // 6. 🌊 OCEAN (Authentic)
  static const String _svgClownFish = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 120,250 C 180,140 330,150 370,250 C 330,350 180,360 120,250 Z" stroke-width="7"/>
    <path d="M 130,250 L 60,170 Q 90,250 60,330 Z" stroke-width="7"/>
    <circle cx="325" cy="225" r="14" fill="#1a1a1a"/>
    <!-- Nemo White Stripes with Black Borders -->
    <path d="M 280,170 Q 260,250 280,330 L 305,320 Q 290,250 305,180 Z" fill="#f8f9fa"/>
    <path d="M 200,195 Q 185,250 200,305 L 220,300 Q 210,250 220,200 Z" fill="#f8f9fa"/>
  </g>
</svg>''';

  static const String _svgDolphin = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 90,320 C 140,160 310,130 420,230 L 390,250 C 300,220 180,280 130,360 Z" stroke-width="7"/>
    <polygon points="250,170 280,110 290,180"/>
    <polygon points="90,320 50,290 60,350 90,360"/>
    <circle cx="370" cy="225" r="8" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgWhale = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 110,290 C 160,180 340,180 390,270 C 370,360 200,380 110,290 Z" stroke-width="7"/>
    <polygon points="120,290 50,220 70,340"/>
    <circle cx="340" cy="250" r="10" fill="#1a1a1a"/>
    <!-- Water Spout -->
    <path d="M 280,190 Q 250,120 230,140 M 280,190 Q 280,100 290,120 M 280,190 Q 320,120 340,140" stroke-width="5" fill="none"/>
  </g>
</svg>''';

  static const String _svgSeaTurtle = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="260" rx="100" ry="120" stroke-width="7"/>
    <!-- Shell Pattern -->
    <polygon points="250,190 285,225 285,285 250,320 215,285 215,225"/>
    <circle cx="250" cy="115" r="28" stroke-width="6"/>
    <!-- Flippers -->
    <ellipse cx="140" cy="200" rx="45" ry="25" stroke-width="6"/>
    <ellipse cx="360" cy="200" rx="45" ry="25" stroke-width="6"/>
    <ellipse cx="170" cy="350" rx="30" ry="18" stroke-width="6"/>
    <ellipse cx="330" cy="350" rx="30" ry="18" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgOctopus = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="200" rx="90" ry="80" stroke-width="7"/>
    <circle cx="220" cy="190" r="12" fill="#1a1a1a"/><circle cx="280" cy="190" r="12" fill="#1a1a1a"/>
    <path d="M 235,225 Q 250,245 265,225" fill="none"/>
    <!-- 8 Tentacles -->
    <path d="M 180,260 Q 140,360 170,420 M 210,270 Q 190,370 220,430 M 250,280 Q 250,380 260,430 M 290,270 Q 310,370 290,430 M 320,260 Q 360,360 330,420" stroke-width="8" fill="none"/>
  </g>
</svg>''';

  // 7. 🚀 SPACE (Authentic)
  static const String _svgAstronaut = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="190" r="70" stroke-width="7"/>
    <ellipse cx="250" cy="190" rx="48" ry="38" fill="#1a1a1a"/>
    <rect x="190" y="270" width="120" height="120" rx="20" stroke-width="7"/>
    <rect x="130" y="280" width="50" height="90" rx="14"/>
    <rect x="320" y="280" width="50" height="90" rx="14"/>
    <rect x="200" y="390" width="40" height="60" rx="10"/>
    <rect x="260" y="390" width="40" height="60" rx="10"/>
  </g>
</svg>''';

  static const String _svgRocketSpace = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 250,70 C 200,160 190,280 190,360 L 310,360 C 310,280 300,160 250,70 Z" stroke-width="7"/>
    <circle cx="250" cy="230" r="36" stroke-width="6"/><circle cx="250" cy="230" r="22"/>
    <polygon points="190,300 130,370 190,370"/>
    <polygon points="310,300 370,370 310,370"/>
    <path d="M 225,385 Q 210,445 235,465 Q 250,420 265,465 Q 290,445 275,385 Z" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgSaturnPlanet = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="250" r="100" stroke-width="8"/>
    <ellipse cx="250" cy="250" rx="210" ry="45" stroke-width="8" transform="rotate(-20 250 250)" fill="none"/>
  </g>
</svg>''';

  static const String _svgUfo = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="260" rx="160" ry="50" stroke-width="8"/>
    <ellipse cx="250" cy="230" rx="80" ry="55" stroke-width="7"/>
    <circle cx="230" cy="225" r="8" fill="#1a1a1a"/><circle cx="270" cy="225" r="8" fill="#1a1a1a"/>
    <circle cx="150" cy="275" r="12"/><circle cx="210" cy="285" r="12"/>
    <circle cx="290" cy="285" r="12"/><circle cx="350" cy="275" r="12"/>
  </g>
</svg>''';

  // 8. 🍓 FOOD & TREATS (Authentic)
  static const String _svgBirthdayCake = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="120" y="290" width="260" height="120" rx="10" stroke-width="7"/>
    <rect x="160" y="190" width="180" height="100" rx="10" stroke-width="7"/>
    <!-- Candles -->
    <line x1="200" y1="190" x2="200" y2="140" stroke-width="5"/>
    <line x1="250" y1="190" x2="250" y2="140" stroke-width="5"/>
    <line x1="300" y1="190" x2="300" y2="140" stroke-width="5"/>
    <circle cx="200" cy="130" r="8" fill="#1a1a1a"/><circle cx="250" cy="130" r="8" fill="#1a1a1a"/><circle cx="300" cy="130" r="8" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgCupcakeTreat = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="160,260 185,420 315,420 340,260" stroke-width="7"/>
    <path d="M 140,260 C 130,220 170,210 190,230 C 210,190 260,190 280,220 C 300,190 350,210 360,260 Z" stroke-width="7"/>
    <path d="M 175,220 C 180,165 240,150 260,180 C 290,160 325,185 320,220 Z" stroke-width="7"/>
    <circle cx="250" cy="115" r="22" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgIceCreamSundae = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="190,270 250,440 310,270" stroke-width="7"/>
    <circle cx="250" cy="230" r="55" stroke-width="7"/>
    <circle cx="205" cy="250" r="45" stroke-width="7"/>
    <circle cx="295" cy="250" r="45" stroke-width="7"/>
    <circle cx="250" cy="150" r="20" stroke-width="5" fill="#1a1a1a"/>
  </g>
</svg>''';

  static const String _svgDonut = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="250" r="140" stroke-width="8"/>
    <circle cx="250" cy="250" r="50" stroke-width="7"/>
    <line x1="200" y1="160" x2="220" y2="150" stroke-width="5"/>
    <line x1="280" y1="160" x2="295" y2="175" stroke-width="5"/>
    <line x1="330" y1="240" x2="350" y2="255" stroke-width="5"/>
  </g>
</svg>''';

  static const String _svgPizzaSlice = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="250,90 120,410 380,410" stroke-width="8"/>
    <circle cx="230" cy="220" r="18" fill="#1a1a1a"/><circle cx="280" cy="290" r="18" fill="#1a1a1a"/>
    <circle cx="200" cy="340" r="18" fill="#1a1a1a"/>
  </g>
</svg>''';

  // 9. 🏰 FAIRYTALE (Authentic)
  static const String _svgFairytaleCastle = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="150" y="260" width="200" height="170" stroke-width="7"/>
    <path d="M 215,430 L 215,350 C 215,315 285,315 285,350 L 285,430 Z" stroke-width="7"/>
    <rect x="90" y="210" width="60" height="220" stroke-width="6"/>
    <polygon points="80,210 120,110 160,210" stroke-width="6"/>
    <rect x="350" y="210" width="60" height="220" stroke-width="6"/>
    <polygon points="340,210 380,110 420,210" stroke-width="6"/>
    <polygon points="195,160 250,60 305,160" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgUnicornPegasus = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="260,110 240,40 280,100" fill="#1a1a1a"/>
    <ellipse cx="230" cy="160" rx="45" ry="35" stroke-width="6"/>
    <circle cx="215" cy="150" r="7" fill="#1a1a1a"/>
    <path d="M 180,260 Q 230,220 310,260 Q 270,390 180,350 Z" stroke-width="7"/>
    <!-- Wings -->
    <path d="M 250,230 Q 340,140 370,220 Q 300,260 250,250 Z" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgFriendlyDragon = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="170" rx="60" ry="50" stroke-width="6"/>
    <circle cx="230" cy="160" r="9" fill="#1a1a1a"/><circle cx="270" cy="160" r="9" fill="#1a1a1a"/>
    <polygon points="200,135 180,95 215,125"/><polygon points="300,135 320,95 285,125"/>
    <path d="M 190,220 Q 150,380 250,420 Q 350,380 310,220" stroke-width="7"/>
  </g>
</svg>''';

  static const String _svgCrown = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <polygon points="100,340 400,340 370,180 300,260 250,140 200,260 130,180" stroke-width="8"/>
    <circle cx="130" cy="170" r="14"/><circle cx="250" cy="130" r="16"/><circle cx="370" cy="170" r="14"/>
  </g>
</svg>''';

  // 10. 🌸 NATURE (Authentic)
  static const String _svgSunflowerNature = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <circle cx="250" cy="210" r="60" stroke-width="7"/>
    <circle cx="230" cy="200" r="7" fill="#1a1a1a"/><circle cx="270" cy="200" r="7" fill="#1a1a1a"/>
    <path d="M 230,225 Q 250,245 270,225" fill="none"/>
    <path d="M 250,270 L 250,460" stroke-width="9"/>
    <path d="M 250,350 Q 180,330 160,380 Q 210,400 250,370"/>
    <path d="M 250,380 Q 320,360 340,410 Q 290,430 250,400"/>
  </g>
</svg>''';

  static const String _svgRainbowNature = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <path d="M 120,320 A 130,130 0 0,1 380,320" stroke-width="14" fill="none"/>
    <path d="M 140,320 A 110,110 0 0,1 360,320" stroke-width="14" fill="none"/>
    <path d="M 160,320 A 90,90 0 0,1 340,320" stroke-width="14" fill="none"/>
    <ellipse cx="120" cy="330" rx="45" ry="30"/><ellipse cx="380" cy="330" rx="45" ry="30"/>
  </g>
</svg>''';

  static const String _svgButterfly = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <ellipse cx="250" cy="250" rx="14" ry="70" stroke-width="6"/>
    <circle cx="250" cy="165" r="16" stroke-width="5"/>
    <line x1="242" y1="150" x2="220" y2="110" stroke-width="4"/><line x1="258" y1="150" x2="280" y2="110" stroke-width="4"/>
    <path d="M 240,210 C 130,130 80,220 180,270 Z" stroke-width="7"/>
    <path d="M 240,270 C 140,270 120,370 200,350 Z" stroke-width="6"/>
    <path d="M 260,210 C 370,130 420,220 320,270 Z" stroke-width="7"/>
    <path d="M 260,270 C 360,270 380,370 300,350 Z" stroke-width="6"/>
  </g>
</svg>''';

  static const String _svgAppleTree = '''
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#1a1a1a" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="white">
    <rect x="220" y="320" width="60" height="130" rx="8" stroke-width="7"/>
    <circle cx="250" cy="220" r="110" stroke-width="8"/>
    <circle cx="190" cy="190" r="16"/><circle cx="290" cy="180" r="16"/>
    <circle cx="230" cy="270" r="16"/><circle cx="280" cy="250" r="16"/>
  </g>
</svg>''';
}
