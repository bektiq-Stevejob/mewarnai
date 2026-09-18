/**
 * High-Resolution JPG Art Export Engine
 * Wraps artwork in a delightful custom frame with the child's name,
 * stars, badge, and date stamp, then downloads as a high-quality JPG.
 */

export function generateFramedJpg(artworkCanvas, options = {}) {
  const {
    childName = 'Juara Cilik',
    childAvatar = '🦁',
    drawingTitle = 'Karya Mewarnai',
    stars = 5,
    badge = 'Master Pelukis',
    dateStr = new Date().toLocaleDateString('id-ID', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    })
  } = options;

  // High-res export canvas (1400 x 1550)
  const exportCanvas = document.createElement('canvas');
  exportCanvas.width = 1400;
  exportCanvas.height = 1550;
  const ctx = exportCanvas.getContext('2d');

  // Background - Warm festive frame
  const bgGrad = ctx.createLinearGradient(0, 0, 1400, 1550);
  bgGrad.addColorStop(0, '#FFE5EC');
  bgGrad.addColorStop(0.5, '#FFF6E5');
  bgGrad.addColorStop(1, '#E8F4FD');
  ctx.fillStyle = bgGrad;
  ctx.fillRect(0, 0, 1400, 1550);

  // Decorative polka dot pattern on frame border
  ctx.fillStyle = 'rgba(255, 94, 126, 0.15)';
  for (let x = 40; x < 1400; x += 80) {
    for (let y = 40; y < 1550; y += 80) {
      if (x < 120 || x > 1280 || y < 120 || y > 1430) {
        ctx.beginPath();
        ctx.arc(x, y, 12, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  }

  // Inner White Art Mount (Matte Card)
  ctx.fillStyle = '#FFFFFF';
  ctx.shadowColor = 'rgba(0, 0, 0, 0.15)';
  ctx.shadowBlur = 30;
  ctx.shadowOffsetY = 15;
  roundRect(ctx, 100, 100, 1200, 1200, 36);
  ctx.fill();
  ctx.shadowColor = 'transparent'; // reset shadow

  // Thin golden inner border
  ctx.strokeStyle = '#FFD93D';
  ctx.lineWidth = 8;
  roundRect(ctx, 115, 115, 1170, 1170, 30);
  ctx.stroke();

  // Draw the actual Artwork into the matte
  ctx.drawImage(artworkCanvas, 140, 140, 1120, 1120);

  // Bottom Certificate Ribbon
  const ribbonY = 1330;
  ctx.fillStyle = '#FFFFFF';
  ctx.shadowColor = 'rgba(0, 0, 0, 0.12)';
  ctx.shadowBlur = 20;
  ctx.shadowOffsetY = 8;
  roundRect(ctx, 100, ribbonY, 1200, 160, 30);
  ctx.fill();
  ctx.shadowColor = 'transparent';

  // Ribbon border
  ctx.strokeStyle = '#4D96FF';
  ctx.lineWidth = 4;
  roundRect(ctx, 100, ribbonY, 1200, 160, 30);
  ctx.stroke();

  // Child Avatar & Name
  ctx.font = 'bold 48px "Fredoka", sans-serif';
  ctx.fillStyle = '#2B2D42';
  ctx.textAlign = 'left';
  ctx.textBaseline = 'middle';
  ctx.fillText(`${childAvatar}  Karya: ${childName}`, 140, ribbonY + 55);

  // Drawing Title & Badge
  ctx.font = '600 30px "Quicksand", sans-serif';
  ctx.fillStyle = '#FF5E7E';
  ctx.fillText(`"${drawingTitle}" • ${badge}`, 140, ribbonY + 110);

  // Star Rating Text
  ctx.textAlign = 'right';
  ctx.font = '48px "Fredoka", sans-serif';
  ctx.fillStyle = '#FFD93D';
  const starStr = '⭐'.repeat(stars);
  ctx.fillText(starStr, 1260, ribbonY + 55);

  // Date & App Watermark
  ctx.font = '600 24px "Quicksand", sans-serif';
  ctx.fillStyle = '#6C757D';
  ctx.fillText(`${dateStr} • Mewarnai Ceria`, 1260, ribbonY + 110);

  // Export as JPG
  const dataUrl = exportCanvas.toDataURL('image/jpeg', 0.95);
  return dataUrl;
}

export function downloadJpgFile(dataUrl, filename) {
  const link = document.createElement('a');
  link.href = dataUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function roundRect(ctx, x, y, width, height, radius) {
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + width - radius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
  ctx.lineTo(x + width, y + height - radius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
  ctx.lineTo(x + radius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
}
