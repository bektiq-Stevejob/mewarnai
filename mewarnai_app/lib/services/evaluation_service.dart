import 'dart:math';

class ArtworkEvaluation {
  final int stars;
  final String badge;
  final String icon;
  final String praise;

  ArtworkEvaluation({
    required this.stars,
    required this.badge,
    required this.icon,
    required this.praise,
  });
}

class EvaluationService {
  static ArtworkEvaluation evaluate({
    required int strokeCount,
    required int colorCount,
    required String childName,
  }) {
    int stars = 3;
    if (strokeCount > 15 && colorCount >= 4) {
      stars = 5;
    } else if (strokeCount > 5 || colorCount >= 2) {
      stars = 4;
    } else {
      stars = 3;
    }

    final random = Random();
    String badge = '';
    String icon = '🎨';
    String praise = '';

    if (stars == 5) {
      icon = '🏆';
      final badges = [
        'Master Pelukis Cilik',
        'Raja Warna-Warni',
        'Kreativitas Emas',
        'Artis Bintang Galaksi',
      ];
      badge = badges[random.nextInt(badges.length)];
      praise = 'Luar biasa, $childName! Warna-warnamu sangat hidup, kaya, dan berani. Kamu adalah calon seniman hebat!';
    } else if (stars == 4) {
      icon = '🌟';
      final badges = [
        'Pelukis Cerdas Berbakat',
        'Petualang Pelangi',
        'Kombinasi Warna Keren',
        'Kreator Cilik Riang',
      ];
      badge = badges[random.nextInt(badges.length)];
      praise = 'Keren sekali, $childName! Gambarmu sangat rapi dan pilihan warnamu sangat serasi. Hasil karya yang menawan!';
    } else {
      icon = '🌸';
      final badges = [
        'Pewarna Ceria',
        'Karya Penuh Semangat',
        'Eksplorer Warna Cilik',
        'Seniman Ramah',
      ];
      badge = badges[random.nextInt(badges.length)];
      praise = 'Bagus sekali, $childName! Kamu sudah berusaha dengan hebat. Ayo terus warnai gambar-gambar seru lainnya!';
    }

    return ArtworkEvaluation(
      stars: stars,
      badge: badge,
      icon: icon,
      praise: praise,
    );
  }
}
