/**
 * Interactive Coloring Canvas Engine
 * Supports high-speed Flood Fill (paint bucket), Freehand Brush, Rainbow Brush,
 * Eraser, Undo/Redo, and 2-layer line-art preservation.
 */

import { audio } from './audio.js';

export class CanvasEngine {
  constructor(canvasElement) {
    this.canvas = canvasElement;
    this.ctx = this.canvas.getContext('2d', { willReadFrequently: true });

    // Internal resolution (high-res for crisp drawings)
    this.width = 1000;
    this.height = 1000;
    this.canvas.width = this.width;
    this.canvas.height = this.height;

    // Offscreen Line-Art Outline Layer
    this.outlineCanvas = document.createElement('canvas');
    this.outlineCanvas.width = this.width;
    this.outlineCanvas.height = this.height;
    this.outlineCtx = this.outlineCanvas.getContext('2d');

    // Offscreen Coloring Layer (where colors and fills live)
    this.colorCanvas = document.createElement('canvas');
    this.colorCanvas.width = this.width;
    this.colorCanvas.height = this.height;
    this.colorCtx = this.colorCanvas.getContext('2d', { willReadFrequently: true });

    // Current State
    this.currentTool = 'bucket'; // 'bucket', 'brush', 'rainbow', 'eraser'
    this.currentColor = '#FF5E7E';
    this.brushSize = 16;
    this.rainbowHue = 0;
    this.isDrawing = false;
    this.lastX = 0;
    this.lastY = 0;

    // History stack for Undo / Redo
    this.undoStack = [];
    this.redoStack = [];
    this.maxHistory = 15;

    // Attach interaction listeners
    this.initEvents();
  }

  // Load an SVG outline into the engine
  loadSvg(svgString) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const blob = new Blob([svgString], { type: 'image/svg+xml;charset=utf-8' });
      const url = URL.createObjectURL(blob);

      img.onload = () => {
        // Clear outline and color canvases
        this.outlineCtx.clearRect(0, 0, this.width, this.height);
        this.outlineCtx.drawImage(img, 0, 0, this.width, this.height);

        // Reset color canvas with clean white background
        this.colorCtx.fillStyle = '#FFFFFF';
        this.colorCtx.fillRect(0, 0, this.width, this.height);

        // Reset history
        this.undoStack = [];
        this.redoStack = [];
        this.saveHistory();

        this.composite();
        URL.revokeObjectURL(url);
        resolve();
      };

      img.onerror = (err) => {
        URL.revokeObjectURL(url);
        reject(err);
      };

      img.src = url;
    });
  }

  // Composite the color layer with the crisp outline layer onto main canvas
  composite() {
    this.ctx.clearRect(0, 0, this.width, this.height);
    // Draw colors
    this.ctx.drawImage(this.colorCanvas, 0, 0);
    // Draw outlines on top using multiply so lines are always crisp & visible
    this.ctx.save();
    this.ctx.globalCompositeOperation = 'multiply';
    this.ctx.drawImage(this.outlineCanvas, 0, 0);
    this.ctx.restore();
  }

  saveHistory() {
    try {
      const imageData = this.colorCtx.getImageData(0, 0, this.width, this.height);
      this.undoStack.push(imageData);
      if (this.undoStack.length > this.maxHistory) {
        this.undoStack.shift();
      }
      this.redoStack = []; // clear redo on new action
    } catch (e) {
      console.warn('Failed to save canvas history:', e);
    }
  }

  undo() {
    if (this.undoStack.length > 1) {
      const current = this.undoStack.pop();
      this.redoStack.push(current);
      const previous = this.undoStack[this.undoStack.length - 1];
      this.colorCtx.putImageData(previous, 0, 0);
      this.composite();
      audio.playPop();
      return true;
    }
    return false;
  }

  redo() {
    if (this.redoStack.length > 0) {
      const next = this.redoStack.pop();
      this.undoStack.push(next);
      this.colorCtx.putImageData(next, 0, 0);
      this.composite();
      audio.playPop();
      return true;
    }
    return false;
  }

  clearColor() {
    this.colorCtx.fillStyle = '#FFFFFF';
    this.colorCtx.fillRect(0, 0, this.width, this.height);
    this.saveHistory();
    this.composite();
    audio.playSplash();
  }

  setTool(tool) {
    this.currentTool = tool;
    audio.playPop();
  }

  setColor(hex) {
    this.currentColor = hex;
    audio.playPop();
  }

  setBrushSize(size) {
    this.brushSize = size;
    audio.playPop();
  }

  // Map mouse / touch coordinates to canvas internal coordinate space
  getPointerPos(e) {
    const rect = this.canvas.getBoundingClientRect();
    const clientX = e.touches && e.touches.length > 0 ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches && e.touches.length > 0 ? e.touches[0].clientY : e.clientY;

    const scaleX = this.width / rect.width;
    const scaleY = this.height / rect.height;

    return {
      x: Math.round((clientX - rect.left) * scaleX),
      y: Math.round((clientY - rect.top) * scaleY)
    };
  }

  initEvents() {
    const onStart = (e) => {
      e.preventDefault();
      const pos = this.getPointerPos(e);

      if (this.currentTool === 'bucket') {
        this.floodFill(pos.x, pos.y, this.currentColor);
      } else {
        this.isDrawing = true;
        this.lastX = pos.x;
        this.lastY = pos.y;
        this.drawStroke(pos.x, pos.y);
      }
    };

    const onMove = (e) => {
      if (!this.isDrawing) return;
      e.preventDefault();
      const pos = this.getPointerPos(e);
      this.drawStroke(pos.x, pos.y);
      this.lastX = pos.x;
      this.lastY = pos.y;
    };

    const onEnd = (e) => {
      if (this.isDrawing) {
        this.isDrawing = false;
        this.saveHistory();
      }
    };

    // Mouse listeners
    this.canvas.addEventListener('mousedown', onStart);
    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onEnd);

    // Touch listeners for mobile & tablet
    this.canvas.addEventListener('touchstart', onStart, { passive: false });
    window.addEventListener('touchmove', onMove, { passive: false });
    window.addEventListener('touchend', onEnd);
    window.addEventListener('touchcancel', onEnd);
  }

  drawStroke(x, y) {
    this.colorCtx.beginPath();
    this.colorCtx.lineCap = 'round';
    this.colorCtx.lineJoin = 'round';
    this.colorCtx.lineWidth = this.brushSize;

    if (this.currentTool === 'eraser') {
      this.colorCtx.strokeStyle = '#FFFFFF';
    } else if (this.currentTool === 'rainbow') {
      this.rainbowHue = (this.rainbowHue + 4) % 360;
      this.colorCtx.strokeStyle = `hsl(${this.rainbowHue}, 95%, 55%)`;
    } else {
      this.colorCtx.strokeStyle = this.currentColor;
    }

    this.colorCtx.moveTo(this.lastX, this.lastY);
    this.colorCtx.lineTo(x, y);
    this.colorCtx.stroke();

    this.composite();
    audio.playBrush();
  }

  // Fast 32-bit Queue-based Flood Fill algorithm
  floodFill(startX, startY, fillHex) {
    if (startX < 0 || startX >= this.width || startY < 0 || startY >= this.height) return;

    // Check outline pixel first - do not fill if clicking directly on a dark outline
    const outlineData = this.outlineCtx.getImageData(startX, startY, 1, 1).data;
    const outlineBrightness = (outlineData[0] + outlineData[1] + outlineData[2]) / 3;
    if (outlineData[3] > 100 && outlineBrightness < 80) {
      return; // Clicking on line art outline
    }

    // Parse target fill color
    const fillRgb = hexToRgb(fillHex);
    const fillColor = (255 << 24) | (fillRgb.b << 16) | (fillRgb.g << 8) | fillRgb.r;

    const imgData = this.colorCtx.getImageData(0, 0, this.width, this.height);
    const data32 = new Uint32Array(imgData.data.buffer);

    const outlineFull = this.outlineCtx.getImageData(0, 0, this.width, this.height);
    const outlineData32 = new Uint32Array(outlineFull.data.buffer);

    const startIndex = startY * this.width + startX;
    const startColor = data32[startIndex];

    // Already the same color
    if (startColor === fillColor) return;

    const queue = [startX, startY];
    const visited = new Uint8Array(this.width * this.height);
    const tolerance = 40;

    const targetR = startColor & 0xff;
    const targetG = (startColor >> 8) & 0xff;
    const targetB = (startColor >> 16) & 0xff;

    const matchesTarget = (idx) => {
      // If outline pixel is dark, it's a boundary
      const oPixel = outlineData32[idx];
      const oAlpha = (oPixel >> 24) & 0xff;
      if (oAlpha > 120) {
        const oR = oPixel & 0xff;
        const oG = (oPixel >> 8) & 0xff;
        const oB = (oPixel >> 16) & 0xff;
        if ((oR + oG + oB) / 3 < 100) return false;
      }

      const pixel = data32[idx];
      const r = pixel & 0xff;
      const g = (pixel >> 8) & 0xff;
      const b = (pixel >> 16) & 0xff;

      return (
        Math.abs(r - targetR) <= tolerance &&
        Math.abs(g - targetG) <= tolerance &&
        Math.abs(b - targetB) <= tolerance
      );
    };

    while (queue.length > 0) {
      const cy = queue.pop();
      const cx = queue.pop();
      const idx = cy * this.width + cx;

      if (visited[idx]) continue;
      visited[idx] = 1;

      if (!matchesTarget(idx)) continue;

      data32[idx] = fillColor;

      // Scan 4 neighbors
      if (cx > 0 && !visited[idx - 1]) queue.push(cx - 1, cy);
      if (cx < this.width - 1 && !visited[idx + 1]) queue.push(cx + 1, cy);
      if (cy > 0 && !visited[idx - this.width]) queue.push(cx, cy - 1);
      if (cy < this.height - 1 && !visited[idx + this.width]) queue.push(cx, cy + 1);
    }

    this.colorCtx.putImageData(imgData, 0, 0);
    this.saveHistory();
    this.composite();
    audio.playSplash();
  }

  // Get current merged image data as canvas for evaluation & export
  getMergedCanvas() {
    const exportCanvas = document.createElement('canvas');
    exportCanvas.width = this.width;
    exportCanvas.height = this.height;
    const expCtx = exportCanvas.getContext('2d');
    expCtx.drawImage(this.colorCanvas, 0, 0);
    expCtx.save();
    expCtx.globalCompositeOperation = 'multiply';
    expCtx.drawImage(this.outlineCanvas, 0, 0);
    expCtx.restore();
    return exportCanvas;
  }
}

function hexToRgb(hex) {
  let c = hex.replace('#', '');
  if (c.length === 3) {
    c = c.split('').map(x => x + x).join('');
  }
  const num = parseInt(c, 16);
  return {
    r: (num >> 16) & 255,
    g: (num >> 8) & 255,
    b: num & 255
  };
}
