/**
 * Art Evaluation & Positive Reinforcement Engine
 * Evaluates color variety and completion, awards 3 to 5 stars,
 * provides unique badges and cheerful Indonesian spoken praise.
 */

import confetti from 'canvas-confetti';
import { audio } from './audio.js';

export function evaluateArtwork(canvas, childName = 'Juara Cilik') {
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;

  // Sample pixels to compute coverage and color entropy
  const imgData = ctx.getImageData(0, 0, width, height);
  const data = imgData.data;

  let totalSampled = 0;
  let coloredPixels = 0;
  const uniqueHues = new Set();

  const step = 4 * 12; // Sample every 12th pixel for high speed
  for (let i = 0; i < data.length; i += step) {
    const r = data[i];
    const g = data[i + 1];
    const b = data[i + 2];
    totalSampled++;

    // Check if not white or black line
    const isWhite = r > 240 && g > 240 && b > 240;
    const isDarkLine = r < 60 && g < 60 && b < 60;

    if (!isWhite && !isDarkLine) {
      coloredPixels++;
      // Quantize hue
      const hueBin = `${Math.round(r / 35)}_${Math.round(g / 35)}_${Math.round(b / 35)}`;
      uniqueHues.add(hueBin);
    }
  }

  const fillRatio = coloredPixels / Math.max(1, totalSampled);
  const colorCount = uniqueHues.size;

  // Calculate Stars (Always 3 to 5 stars - encouraging positive reinforcement)
  let stars = 3;
  if (fillRatio > 0.35 && colorCount >= 4) {
    stars = 5;
  } else if (fillRatio > 0.20 || colorCount >= 2) {
    stars = 4;
  } else {
    stars = 3;
  }

  // Badges and compliments based on score
  let badge = '';
  let praise = '';
  let icon = '🎨';

  if (stars === 5) {
    icon = '🏆';
    const badges5 = ['Master Pelukis Cilik', 'Raja Warna-Warni', 'Kreativitas Emas', 'Artis Bintang Galaksi'];
    badge = badges5[Math.floor(Math.random() * badges5.length)];
    praise = `Luar biasa, ${childName}! Warna-warnamu sangat hidup, kaya, dan berani. Kamu adalah calon seniman hebat!`;
  } else if (stars === 4) {
    icon = '🌟';
    const badges4 = ['Pelukis Cerdas Berbakat', 'Petualang Pelangi', 'Kombinasi Warna Keren', 'Kreator Cilik Riang'];
    badge = badges4[Math.floor(Math.random() * badges4.length)];
    praise = `Keren sekali, ${childName}! Gambarmu sangat rapi dan pilihan warnamu sangat serasi. Hasil karya yang menawan!`;
  } else {
    icon = '🌸';
    const badges3 = ['Pewarna Ceria', 'Karya Penuh Semangat', 'Eksplorer Warna Cilik', 'Seniman Ramah'];
    badge = badges3[Math.floor(Math.random() * badges3.length)];
    praise = `Bagus sekali, ${childName}! Kamu sudah berusaha dengan hebat. Ayo terus warnai gambar-gambar seru lainnya!`;
  }

  return {
    stars,
    badge,
    icon,
    praise,
    fillRatio: Math.round(fillRatio * 100),
    colorCount
  };
}

// Celebration particle burst
export function triggerCelebration() {
  audio.playSparkle();
  audio.playFanfare();

  // Multi-stage confetti celebration
  const count = 200;
  const defaults = {
    origin: { y: 0.7 }
  };

  function fire(particleRatio, opts) {
    confetti({
      ...defaults,
      ...opts,
      particleCount: Math.floor(count * particleRatio)
    });
  }

  fire(0.25, {
    spread: 26,
    startVelocity: 55,
    colors: ['#FF5E7E', '#FFD93D', '#4D96FF']
  });
  fire(0.2, {
    spread: 60,
    colors: ['#6BCB77', '#9D4EDD', '#FF923C']
  });
  fire(0.35, {
    spread: 100,
    decay: 0.91,
    scalar: 0.8
  });
  fire(0.1, {
    spread: 120,
    startVelocity: 25,
    decay: 0.92,
    scalar: 1.2
  });
  fire(0.1, {
    spread: 120,
    startVelocity: 45
  });
}
