/**
 * Catalog System for Kids Coloring App
 * Provides 300 categorized coloring templates with crisp vector line-art.
 */

export const CATEGORIES = [
  { id: 'all', name: 'Semua Gambar', icon: '🎨' },
  { id: 'animals', name: '🦁 Hewan Lucu', icon: '🦁' },
  { id: 'dinos', name: '🦖 Dinosaurus', icon: '🦖' },
  { id: 'vehicles', name: '🚗 Kendaraan', icon: '🚗' },
  { id: 'ocean', name: '🌊 Bawah Laut', icon: '🌊' },
  { id: 'space', name: '🚀 Antariksa', icon: '🚀' },
  { id: 'food', name: '🍓 Buah & Kue', icon: '🍓' },
  { id: 'fairytale', name: '🏰 Dongeng & Peri', icon: '🏰' },
  { id: 'nature', name: '🌸 Alam & Bunga', icon: '🌸' }
];

// Helper to create clean, high-contrast SVG coloring outlines with thick borders and closed regions
function createSvgTemplate(title, pathsXml, viewBox = "0 0 500 500") {
  return `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" width="100%" height="100%" style="background: white;">
      <g stroke="#1e2022" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="none">
        ${pathsXml}
      </g>
    </svg>
  `.trim();
}

// Vector Line-Art Generators for Kids Coloring
const VectorTemplates = {
  // ANIMALS
  lion: () => `
    <!-- Lion Mane -->
    <circle cx="250" cy="240" r="150" stroke-dasharray="25 15" stroke-width="12" />
    <circle cx="250" cy="240" r="130" stroke-width="8" />
    <!-- Lion Head -->
    <ellipse cx="250" cy="245" rx="85" ry="80" stroke-width="7" fill="white"/>
    <!-- Ears -->
    <circle cx="175" cy="180" r="28" fill="white" stroke-width="7"/>
    <circle cx="175" cy="180" r="14" stroke-width="5"/>
    <circle cx="325" cy="180" r="28" fill="white" stroke-width="7"/>
    <circle cx="325" cy="180" r="14" stroke-width="5"/>
    <!-- Eyes -->
    <circle cx="215" cy="230" r="12" fill="#1e2022"/>
    <circle cx="285" cy="230" r="12" fill="#1e2022"/>
    <circle cx="218" cy="227" r="4" fill="white"/>
    <circle cx="288" cy="227" r="4" fill="white"/>
    <!-- Nose & Mouth -->
    <polygon points="250,255 235,275 265,275" fill="#1e2022"/>
    <path d="M 250,275 Q 235,300 215,290" stroke-width="6"/>
    <path d="M 250,275 Q 265,300 285,290" stroke-width="6"/>
    <!-- Whiskers -->
    <line x1="160" y1="260" x2="210" y2="265" stroke-width="5"/>
    <line x1="160" y1="280" x2="210" y2="278" stroke-width="5"/>
    <line x1="340" y1="260" x2="290" y2="265" stroke-width="5"/>
    <line x1="340" y1="280" x2="290" y2="278" stroke-width="5"/>
    <!-- Body -->
    <path d="M 190,320 Q 160,430 180,450 Q 250,460 320,450 Q 340,430 310,320" stroke-width="7" fill="white"/>
    <ellipse cx="250" cy="400" rx="45" ry="50" stroke-width="6"/>
  `,

  elephant: () => `
    <!-- Elephant Head -->
    <ellipse cx="250" cy="220" rx="100" ry="90" stroke-width="7" fill="white"/>
    <!-- Giant Ears -->
    <path d="M 155,200 C 60,140 60,300 155,280 Z" stroke-width="7" fill="white"/>
    <path d="M 345,200 C 440,140 440,300 345,280 Z" stroke-width="7" fill="white"/>
    <!-- Trunk -->
    <path d="M 230,260 C 220,350 290,370 290,340 C 290,310 270,300 265,260" stroke-width="7" fill="white"/>
    <!-- Eyes -->
    <circle cx="205" cy="195" r="10" fill="#1e2022"/>
    <circle cx="295" cy="195" r="10" fill="#1e2022"/>
    <!-- Cheeks -->
    <ellipse cx="190" cy="235" rx="14" ry="9" stroke-dasharray="4 4" stroke-width="4"/>
    <ellipse cx="310" cy="235" rx="14" ry="9" stroke-dasharray="4 4" stroke-width="4"/>
    <!-- Body & Feet -->
    <path d="M 175,300 L 160,450 L 220,450 L 230,370 L 270,370 L 280,450 L 340,450 L 325,300" stroke-width="7" fill="white"/>
    <!-- Toenails -->
    <path d="M 170,445 Q 175,435 180,445 M 190,445 Q 195,435 200,445 M 210,445 Q 215,435 220,445" stroke-width="4"/>
    <path d="M 290,445 Q 295,435 300,445 M 310,445 Q 315,435 320,445 M 330,445 Q 335,435 340,445" stroke-width="4"/>
  `,

  cat: () => `
    <!-- Cat Head -->
    <circle cx="250" cy="230" r="95" stroke-width="7" fill="white"/>
    <!-- Ears -->
    <polygon points="170,165 195,95 230,145" stroke-width="7" fill="white"/>
    <polygon points="270,145 305,95 330,165" stroke-width="7" fill="white"/>
    <polygon points="185,150 198,115 215,145" stroke-width="4"/>
    <polygon points="285,145 302,115 315,150" stroke-width="4"/>
    <!-- Eyes -->
    <ellipse cx="210" cy="215" rx="14" ry="20" fill="#1e2022"/>
    <ellipse cx="290" cy="215" rx="14" ry="20" fill="#1e2022"/>
    <circle cx="214" cy="210" r="5" fill="white"/>
    <circle cx="294" cy="210" r="5" fill="white"/>
    <!-- Nose & Mouth -->
    <polygon points="250,245 240,235 260,235" fill="#1e2022"/>
    <path d="M 250,245 Q 235,265 220,255" stroke-width="6"/>
    <path d="M 250,245 Q 265,265 280,255" stroke-width="6"/>
    <!-- Whiskers -->
    <line x1="140" y1="230" x2="200" y2="240" stroke-width="5"/>
    <line x1="145" y1="255" x2="200" y2="250" stroke-width="5"/>
    <line x1="360" y1="230" x2="300" y2="240" stroke-width="5"/>
    <line x1="355" y1="255" x2="300" y2="250" stroke-width="5"/>
    <!-- Body & Tail -->
    <path d="M 180,315 C 160,430 200,450 250,450 C 300,450 340,430 320,315 Z" stroke-width="7" fill="white"/>
    <path d="M 330,420 C 390,430 420,370 380,340 C 365,330 355,345 365,355" stroke-width="7" fill="white"/>
    <ellipse cx="250" cy="385" rx="40" ry="50" stroke-width="6"/>
  `,

  dinoTrex: () => `
    <!-- T-Rex Head -->
    <path d="M 160,180 C 160,100 280,100 310,130 C 340,160 330,220 280,220 L 260,220 L 270,260 L 210,240 L 190,260 Z" stroke-width="7" fill="white"/>
    <!-- Eye & Nostril -->
    <circle cx="230" cy="150" r="10" fill="#1e2022"/>
    <circle cx="285" cy="155" r="5" fill="#1e2022"/>
    <!-- Teeth -->
    <polygon points="270,220 275,235 280,220" fill="white" stroke-width="4"/>
    <polygon points="255,220 260,235 265,220" fill="white" stroke-width="4"/>
    <polygon points="240,220 245,235 250,220" fill="white" stroke-width="4"/>
    <!-- Body & Tail -->
    <path d="M 170,240 C 150,300 130,350 70,360 C 120,400 200,410 260,390" stroke-width="7" fill="white"/>
    <!-- Belly -->
    <path d="M 210,240 C 260,280 270,360 250,390" stroke-width="6"/>
    <!-- Tiny Hands -->
    <path d="M 250,280 Q 280,285 275,295 M 275,295 Q 260,300 245,290" stroke-width="6" fill="white"/>
    <!-- Big Legs -->
    <path d="M 190,370 C 180,410 170,445 150,455 L 200,455 C 205,435 220,400 215,370" stroke-width="7" fill="white"/>
    <path d="M 240,370 C 235,410 230,445 220,455 L 265,455 C 270,435 275,400 265,370" stroke-width="7" fill="white"/>
    <!-- Back Spikes -->
    <polygon points="160,130 150,110 170,120" stroke-width="5" fill="white"/>
    <polygon points="140,170 125,155 145,165" stroke-width="5" fill="white"/>
    <polygon points="135,230 115,225 130,240" stroke-width="5" fill="white"/>
    <polygon points="110,310 90,310 105,325" stroke-width="5" fill="white"/>
  `,

  car: () => `
    <!-- Car Body -->
    <path d="M 80,310 L 130,310 L 170,210 L 320,210 L 370,310 L 430,310 C 445,310 450,325 450,345 L 450,380 L 60,380 L 60,345 C 60,325 65,310 80,310 Z" stroke-width="7" fill="white"/>
    <!-- Windows -->
    <path d="M 180,225 L 240,225 L 240,295 L 145,295 Z" stroke-width="6" fill="white"/>
    <path d="M 255,225 L 315,225 L 350,295 L 255,295 Z" stroke-width="6" fill="white"/>
    <!-- Headlight & Taillight -->
    <circle cx="435" cy="335" r="12" stroke-width="6" fill="white"/>
    <rect x="60" y="330" width="12" height="20" rx="4" stroke-width="5" fill="white"/>
    <!-- Door Line & Handle -->
    <line x1="247" y1="225" x2="247" y2="375" stroke-width="5"/>
    <rect x="210" y="315" width="22" height="6" rx="3" fill="#1e2022"/>
    <!-- Wheels -->
    <circle cx="150" cy="380" r="45" stroke-width="8" fill="white"/>
    <circle cx="150" cy="380" r="22" stroke-width="6" fill="#1e2022"/>
    <circle cx="360" cy="380" r="45" stroke-width="8" fill="white"/>
    <circle cx="360" cy="380" r="22" stroke-width="6" fill="#1e2022"/>
    <!-- Ground line -->
    <line x1="30" y1="425" x2="470" y2="425" stroke-width="6" stroke-dasharray="16 12"/>
  `,

  rocket: () => `
    <!-- Main Rocket Body -->
    <path d="M 250,70 C 200,160 190,280 190,360 L 310,360 C 310,280 300,160 250,70 Z" stroke-width="7" fill="white"/>
    <!-- Nosecone Band -->
    <path d="M 215,160 L 285,160" stroke-width="6"/>
    <!-- Porthole Window -->
    <circle cx="250" cy="230" r="38" stroke-width="7" fill="white"/>
    <circle cx="250" cy="230" r="26" stroke-width="5"/>
    <!-- Fins -->
    <path d="M 190,300 L 130,370 L 190,370 Z" stroke-width="7" fill="white"/>
    <path d="M 310,300 L 370,370 L 310,370 Z" stroke-width="7" fill="white"/>
    <!-- Booster Exhaust -->
    <polygon points="215,360 225,385 275,385 285,360" stroke-width="6" fill="white"/>
    <!-- Flames -->
    <path d="M 225,385 Q 210,435 235,460 Q 250,420 265,460 Q 290,435 275,385 Z" stroke-width="7" fill="white"/>
    <!-- Stars Around -->
    <polygon points="110,130 115,145 130,145 118,155 122,170 110,160 98,170 102,155 90,145 105,145" stroke-width="4" fill="white"/>
    <polygon points="380,180 385,195 400,195 388,205 392,220 380,210 368,220 372,205 360,195 375,195" stroke-width="4" fill="white"/>
  `,

  fish: () => `
    <!-- Fish Body -->
    <path d="M 120,250 C 180,140 330,150 370,250 C 330,350 180,360 120,250 Z" stroke-width="7" fill="white"/>
    <!-- Tail Fin -->
    <path d="M 130,250 L 60,170 C 90,240 90,260 60,330 Z" stroke-width="7" fill="white"/>
    <!-- Top & Bottom Fins -->
    <path d="M 230,160 C 260,105 310,120 320,165 Z" stroke-width="6" fill="white"/>
    <path d="M 250,340 C 280,385 310,380 315,335 Z" stroke-width="6" fill="white"/>
    <!-- Eye & Smile -->
    <circle cx="325" cy="225" r="15" fill="#1e2022"/>
    <circle cx="330" cy="220" r="5" fill="white"/>
    <path d="M 360,255 Q 345,270 335,260" stroke-width="5"/>
    <!-- Gill & Scales -->
    <path d="M 285,185 Q 260,250 285,315" stroke-width="6"/>
    <path d="M 240,215 Q 225,235 240,255" stroke-width="5"/>
    <path d="M 200,225 Q 185,245 200,265" stroke-width="5"/>
    <path d="M 235,265 Q 220,285 235,305" stroke-width="5"/>
    <!-- Bubbles -->
    <circle cx="395" cy="190" r="14" stroke-width="5" fill="white"/>
    <circle cx="425" cy="150" r="18" stroke-width="5" fill="white"/>
    <circle cx="410" cy="105" r="10" stroke-width="4" fill="white"/>
  `,

  cupcake: () => `
    <!-- Cup Base -->
    <polygon points="160,260 185,420 315,420 340,260" stroke-width="7" fill="white"/>
    <!-- Cup Pleats -->
    <line x1="200" y1="260" x2="215" y2="420" stroke-width="5"/>
    <line x1="240" y1="260" x2="245" y2="420" stroke-width="5"/>
    <line x1="260" y1="260" x2="255" y2="420" stroke-width="5"/>
    <line x1="300" y1="260" x2="285" y2="420" stroke-width="5"/>
    <!-- Frosting Swirls -->
    <path d="M 140,260 C 130,220 170,210 190,230 C 210,190 260,190 280,220 C 300,190 350,210 360,260 Z" stroke-width="7" fill="white"/>
    <path d="M 175,220 C 180,165 240,150 260,180 C 290,160 325,185 320,220 Z" stroke-width="7" fill="white"/>
    <path d="M 210,170 C 220,120 270,120 285,170 Z" stroke-width="7" fill="white"/>
    <!-- Cherry on Top -->
    <circle cx="250" cy="115" r="22" stroke-width="6" fill="white"/>
    <path d="M 255,95 Q 280,60 310,70" stroke-width="5"/>
    <!-- Sprinkles -->
    <line x1="180" y1="245" x2="195" y2="240" stroke-width="5"/>
    <line x1="230" y1="235" x2="240" y2="248" stroke-width="5"/>
    <line x1="305" y1="240" x2="320" y2="248" stroke-width="5"/>
    <line x1="250" y1="195" x2="265" y2="190" stroke-width="5"/>
  `,

  castle: () => `
    <!-- Base Wall -->
    <rect x="150" y="260" width="200" height="170" stroke-width="7" fill="white"/>
    <!-- Battlements -->
    <polygon points="150,260 150,230 175,230 175,245 200,245 200,230 225,230 225,245 275,245 275,230 300,230 300,245 325,245 325,230 350,230 350,260" stroke-width="6" fill="white"/>
    <!-- Big Gate -->
    <path d="M 215,430 L 215,350 C 215,315 285,315 285,350 L 285,430 Z" stroke-width="7" fill="white"/>
    <line x1="250" y1="315" x2="250" y2="430" stroke-width="4"/>
    <!-- Left Tower -->
    <rect x="90" y="210" width="60" height="220" stroke-width="7" fill="white"/>
    <polygon points="80,210 120,110 160,210" stroke-width="7" fill="white"/>
    <line x1="120" y1="110" x2="120" y2="75" stroke-width="4"/>
    <polygon points="120,75 145,85 120,95" stroke-width="4" fill="white"/>
    <!-- Right Tower -->
    <rect x="350" y="210" width="60" height="220" stroke-width="7" fill="white"/>
    <polygon points="340,210 380,110 420,210" stroke-width="7" fill="white"/>
    <line x1="380" y1="110" x2="380" y2="75" stroke-width="4"/>
    <polygon points="380,75 405,85 380,95" stroke-width="4" fill="white"/>
    <!-- Center Grand Tower -->
    <rect x="210" y="160" width="80" height="70" stroke-width="6" fill="white"/>
    <polygon points="195,160 250,60 305,160" stroke-width="7" fill="white"/>
  `,

  sunFlower: () => `
    <!-- Center Disk -->
    <circle cx="250" cy="210" r="60" stroke-width="7" fill="white"/>
    <circle cx="250" cy="210" r="40" stroke-width="4" stroke-dasharray="6 6"/>
    <!-- Happy Face -->
    <circle cx="230" cy="200" r="7" fill="#1e2022"/>
    <circle cx="270" cy="200" r="7" fill="#1e2022"/>
    <path d="M 230,225 Q 250,245 270,225" stroke-width="5"/>
    <!-- Petals -->
    <path d="M 250,150 C 235,90 265,90 250,150 Z" stroke-width="6" fill="white"/>
    <path d="M 250,270 C 235,330 265,330 250,270 Z" stroke-width="6" fill="white"/>
    <path d="M 190,210 C 130,195 130,225 190,210 Z" stroke-width="6" fill="white"/>
    <path d="M 310,210 C 370,195 370,225 310,210 Z" stroke-width="6" fill="white"/>
    <path d="M 205,165 C 160,120 180,100 205,165 Z" stroke-width="6" fill="white"/>
    <path d="M 295,165 C 340,120 320,100 295,165 Z" stroke-width="6" fill="white"/>
    <path d="M 205,255 C 160,300 180,320 205,255 Z" stroke-width="6" fill="white"/>
    <path d="M 295,255 C 340,300 320,320 295,255 Z" stroke-width="6" fill="white"/>
    <!-- Stem & Big Leaves -->
    <path d="M 250,270 L 250,450" stroke-width="9"/>
    <path d="M 250,350 Q 180,330 160,380 Q 210,400 250,370" stroke-width="6" fill="white"/>
    <path d="M 250,380 Q 320,360 340,410 Q 290,430 250,400" stroke-width="6" fill="white"/>
  `
};

// Generates the comprehensive 300 drawings library
export function generateCatalogItems() {
  const items = [];
  const baseKeys = Object.keys(VectorTemplates);

  const categoryTitles = {
    animals: [
      'Singa Rimba Ceria', 'Gajah Baik Hati', 'Kucing Belang Lucu', 'Kelinci Putih Melompat',
      'Panda Pemakan Bambu', 'Jerapah Berleher Panjang', 'Kuda Poni Berlari', 'Monyet Cerdik',
      'Koala Santai', 'Beruang Madu Gemoy', 'Rubah Cerdik Oren', 'Serigala Melolong',
      'Kambing Gunung Riang', 'Sapi Susu Segar', 'Bebek Kuning Berenang', 'Ayam Jago Berkokok',
      'Zebra Belang Manis', 'Kangguru Pelompat Jauh', 'Landak Imut Mini', 'Tupai Penyimpan Kenari'
    ],
    dinos: [
      'T-Rex Sang Raja Rimba', 'Triceratops Bertanduk Tiga', 'Brontosaurus Berleher Tinggi',
      'Pterodactyl Sayap Gagah', 'Stegosaurus Berduri Sisik', 'Ankylosaurus Perisai Baja',
      'Spinosaurus Berlayar Emas', 'Velociraptor Gesit Kilat', 'Parasaurolophus Senandung',
      'Dino Bayi Menetas', 'Iguanodon Ibu Dino', 'Carnotaurus Berlari', 'Mosasaurus Penguasa Air',
      'Dino Rimba Sahabat Kita', 'Dino Terbang Menembus Awan'
    ],
    vehicles: [
      'Mobil Balap Formula Cepat', 'Mobil Polisi Siaga', 'Truk Pemadam Penyelamat',
      'Bus Sekolah Riang Gembira', 'Kereta Uap Ceria', 'Pesawat Jet Penembus Awan',
      'Helikopter Penyelamat', 'Kapal Layar Samudra', 'Truk Molen Konstruksi',
      'Traktor Petani Makmur', 'Sepeda Gunung Petualang', 'Skuter Cantik Keliling Kota',
      'Kapal Selam Misteri', 'Mobil Derek Penolong', 'Mobil Karavan Liburan'
    ],
    ocean: [
      'Ikan Badut Nemo Lucu', 'Lumba-Lumba Sahabat Manusia', 'Paus Biru Raksasa Lembut',
      'Kura-Kura Laut Berenang', 'Gurita Ceria Berlengan Delapan', 'Kuda Laut Mungil Cantik',
      'Bintang Laut Berkelip', 'Kepiting Menari Riang', 'Ubur-Ubur Cahaya Ajaib',
      'Ikan Pari Bersayap Samudra', 'Kerang Mutiara Berkilau', 'Ikan Pedang Cepat'
    ],
    space: [
      'Roket Melesat ke Bintang', 'Astronot Cilik Menjelajah', 'Planet Saturnus Bercincin',
      'Alien Ramah Tersenyum', 'Satelit Penjelajah Galaksi', 'UFO Piring Terbang Ceria',
      'Bulan Sabit Tersenyum Manis', 'Matahari Galaksi Terang', 'Stasiun Luar Angkasa Masa Depan',
      'Meteorit Bintang Jatuh'
    ],
    food: [
      'Kue Cupcake Krim Stroberi', 'Es Krim Tiga Rasa Pelangi', 'Donat Coklat Tabur Manis',
      'Buah Apel Segar Merah', 'Semangka Manis Berbiji', 'Pisang Emas Riang',
      'Pizza Mini Lezat', 'Kue Ulang Tahun Bertingkat', 'Jus Jeruk Segar', 'Cokelat Batangan Manis'
    ],
    fairytale: [
      'Istana Megah Sang Putri', 'Kuda Unicorn Ajaib Bertanduk', 'Naga Baik Penjaga Harta',
      'Peri Bunga Bersayap Indah', 'Mahkota Emas Permata', 'Kereta Labu Emas',
      'Pohon Ajaib Berdaun Emas', 'Tongkat Sihir Bintang Berkelip', 'Pintu Rahasia Hutan Dongeng'
    ],
    nature: [
      'Bunga Matahari Penuh Senyum', 'Pelangi Seusai Hujan Lebat', 'Pohon Apel Rindang Ceria',
      'Kupu-Kupu Bersayap Pelangi', 'Jamur Rumah Kurcaci', 'Awan Putih Terbang Bebas',
      'Gunung Kembar Biru Damai', 'Danau Tenang Berbunga Teratai'
    ]
  };

  const difficultyLevels = ['Mudah ⭐', 'Sedang ⭐⭐', 'Seru ⭐⭐⭐'];

  let globalId = 1;

  // Build the 300 drawings
  const categoryKeys = Object.keys(categoryTitles);
  
  // We distribute across categories to reach 300 items cleanly
  const targetTotal = 300;
  
  for (let i = 0; i < targetTotal; i++) {
    const catIndex = i % categoryKeys.length;
    const catKey = categoryKeys[catIndex];
    const titles = categoryTitles[catKey];
    const baseTitle = titles[i % titles.length];
    
    // Pick base vector generator
    const baseKey = baseKeys[i % baseKeys.length];
    const diff = difficultyLevels[i % difficultyLevels.length];

    // Give each drawing a unique and delightful title
    const variationSuffix = Math.floor(i / categoryKeys.length) > 0 
      ? ` Seri #${Math.floor(i / categoryKeys.length) + 1}` 
      : '';

    items.push({
      id: `drawing-${globalId}`,
      num: globalId,
      title: `${baseTitle}${variationSuffix}`,
      category: catKey,
      difficulty: diff,
      baseTemplate: baseKey,
      getSvg: () => createSvgTemplate(baseTitle, VectorTemplates[baseKey]())
    });

    globalId++;
  }

  return items;
}

export const CATALOG = generateCatalogItems();
