/**
 * Main Application Coordinator
 * Connects Profiles, 300 Catalog, Canvas Engine, Evaluation & JPG Export.
 */

import { audio } from './modules/audio.js';
import { profileManager, AVATAR_OPTIONS } from './modules/profile.js';
import { CATALOG, CATEGORIES } from './modules/catalog.js';
import { CanvasEngine } from './modules/canvasEngine.js';
import { evaluateArtwork, triggerCelebration } from './modules/evaluation.js';
import { generateFramedJpg, downloadJpgFile } from './modules/exportJpg.js';

// Vibrant 24-Color Kids Palette
const PALETTE_COLORS = [
  '#FF3B30', '#FF9500', '#FFD60A', '#34C759', '#00C7BE', '#30B0C7',
  '#32ADE6', '#007AFF', '#5856D6', '#AF52DE', '#FF2D55', '#FF70A6',
  '#FF9F1C', '#FFE066', '#70C1B3', '#247BA0', '#F25F5C', '#A0C4FF',
  '#BDB2FF', '#FFC6FF', '#795548', '#4E342E', '#9E9E9E', '#1E2022'
];

// App State
let canvasEngine = null;
let currentScreen = 'catalog'; // 'profile', 'catalog', 'studio', 'gallery'
let currentDrawing = null;
let selectedCategory = 'all';
let currentFramedJpgUrl = null;
let editingProfileId = null;
let tempSelectedAvatar = '🦁';

// Elements
const profileScreen = document.getElementById('profileScreen');
const catalogScreen = document.getElementById('catalogScreen');
const studioScreen = document.getElementById('studioScreen');
const galleryScreen = document.getElementById('galleryScreen');

const profileCardsContainer = document.getElementById('profileCardsContainer');
const categoryChips = document.getElementById('categoryChips');
const catalogGrid = document.getElementById('catalogGrid');
const searchInput = document.getElementById('searchInput');

const headerAvatar = document.getElementById('headerAvatar');
const headerKidName = document.getElementById('headerKidName');
const headerStars = document.getElementById('headerStars');
const activeKidCapsule = document.getElementById('activeKidCapsule');
const soundToggleBtn = document.getElementById('soundToggleBtn');
const galleryNavBtn = document.getElementById('galleryNavBtn');
const brandBtn = document.getElementById('brandBtn');

const currentDrawingTitle = document.getElementById('currentDrawingTitle');
const backToCatalogBtn = document.getElementById('backToCatalogBtn');
const undoBtn = document.getElementById('undoBtn');
const redoBtn = document.getElementById('redoBtn');
const clearBtn = document.getElementById('clearBtn');
const saveAndGradeBtn = document.getElementById('saveAndGradeBtn');

const paletteGrid = document.getElementById('paletteGrid');
const customColorPicker = document.getElementById('customColorPicker');

// Modals
const evalModal = document.getElementById('evalModal');
const evalBadgeIcon = document.getElementById('evalBadgeIcon');
const evalTitle = document.getElementById('evalTitle');
const evalStarsContainer = document.getElementById('evalStarsContainer');
const evalBadgeName = document.getElementById('evalBadgeName');
const evalPraiseText = document.getElementById('evalPraiseText');
const evalPreviewImg = document.getElementById('evalPreviewImg');
const downloadJpgBtn = document.getElementById('downloadJpgBtn');
const evalViewGalleryBtn = document.getElementById('evalViewGalleryBtn');
const evalNewDrawingBtn = document.getElementById('evalNewDrawingBtn');

const editProfileModal = document.getElementById('editProfileModal');
const editNameInput = document.getElementById('editNameInput');
const editAgeInput = document.getElementById('editAgeInput');
const avatarPickerGrid = document.getElementById('avatarPickerGrid');
const cancelEditProfileBtn = document.getElementById('cancelEditProfileBtn');
const saveEditProfileBtn = document.getElementById('saveEditProfileBtn');

// Gallery
const galleryGrid = document.getElementById('galleryGrid');
const galleryTitle = document.getElementById('galleryTitle');
const galleryBackCatalogBtn = document.getElementById('galleryBackCatalogBtn');

// Initialize App
function init() {
  // Canvas Engine
  const paintCanvas = document.getElementById('paintCanvas');
  canvasEngine = new CanvasEngine(paintCanvas);

  // Resize canvas container responsively
  setupResponsiveCanvas();
  window.addEventListener('resize', setupResponsiveCanvas);

  // Render Subsystems
  renderHeaderProfile();
  renderProfileScreen();
  renderCategoryChips();
  renderCatalog();
  renderPalette();
  renderAvatarPicker();

  // Attach Global Listeners
  attachEventListeners();

  // Set Sound Toggle State
  updateSoundBtnState();

  // Default to Catalog Screen
  switchScreen('catalog');
}

function setupResponsiveCanvas() {
  const container = document.getElementById('canvasViewport');
  if (!container) return;

  const maxWidth = Math.min(window.innerWidth - (window.innerWidth > 900 ? 360 : 40), 750);
  const maxHeight = Math.min(window.innerHeight - 220, 750);
  const size = Math.max(300, Math.min(maxWidth, maxHeight));

  container.style.width = `${size}px`;
  container.style.height = `${size}px`;

  const canvas = document.getElementById('paintCanvas');
  canvas.style.width = '100%';
  canvas.style.height = '100%';
}

// NAVIGATION STATE MACHINE
function switchScreen(screen) {
  currentScreen = screen;
  profileScreen.classList.add('hidden');
  catalogScreen.classList.add('hidden');
  studioScreen.classList.add('hidden');
  galleryScreen.classList.add('hidden');

  if (screen === 'profile') {
    renderProfileScreen();
    profileScreen.classList.remove('hidden');
  } else if (screen === 'catalog') {
    catalogScreen.classList.remove('hidden');
  } else if (screen === 'studio') {
    studioScreen.classList.remove('hidden');
    setupResponsiveCanvas();
  } else if (screen === 'gallery') {
    renderGallery();
    galleryScreen.classList.remove('hidden');
  }

  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// HEADER
function renderHeaderProfile() {
  const kid = profileManager.getActiveProfile();
  if (!kid) return;

  headerAvatar.textContent = kid.avatar || '🦁';
  headerKidName.textContent = kid.name;
  headerStars.textContent = kid.totalStars || 0;
}

function updateSoundBtnState() {
  soundToggleBtn.textContent = audio.isMuted ? '🔇' : '🔊';
}

// PROFILES SCREEN
function renderProfileScreen() {
  const profiles = profileManager.getProfiles();
  const activeId = profileManager.activeProfileId;

  profileCardsContainer.innerHTML = profiles.map(kid => `
    <div class="profile-card ${kid.id === activeId ? 'active-profile' : ''}" style="--card-color: ${kid.themeColor};" data-profile-id="${kid.id}">
      <div class="profile-avatar-wrapper" style="--avatar-bg: ${kid.avatarBg};">
        ${kid.avatar}
      </div>
      <h3 class="profile-kid-name">${kid.name}</h3>
      <p class="profile-kid-age">Usia: ${kid.age} Tahun</p>

      <div class="profile-stats-row">
        <div class="stat-item">
          <span class="stat-val">⭐ ${kid.totalStars || 0}</span>
          <span class="stat-label">Bintang</span>
        </div>
        <div class="stat-item">
          <span class="stat-val">🖼️ ${kid.gallery ? kid.gallery.length : 0}</span>
          <span class="stat-label">Karya</span>
        </div>
      </div>

      <div class="profile-actions">
        <button class="btn-cute btn-primary select-kid-btn" style="flex: 1;" data-id="${kid.id}">
          Mulai Mewarnai! 🎨
        </button>
        <button class="btn-cute btn-circle edit-kid-btn" data-id="${kid.id}" title="Ubah Nama & Karakter">
          ✏️
        </button>
      </div>
    </div>
  `).join('');

  // Attach card events
  document.querySelectorAll('.select-kid-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const id = btn.getAttribute('data-id');
      selectProfile(id);
    });
  });

  document.querySelectorAll('.profile-card').forEach(card => {
    card.addEventListener('click', () => {
      const id = card.getAttribute('data-profile-id');
      selectProfile(id);
    });
  });

  document.querySelectorAll('.edit-kid-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const id = btn.getAttribute('data-id');
      openEditProfileModal(id);
    });
  });
}

function selectProfile(id) {
  profileManager.setActiveProfile(id);
  renderHeaderProfile();
  audio.playPop();
  switchScreen('catalog');
}

// CATEGORY CHIPS
function renderCategoryChips() {
  categoryChips.innerHTML = CATEGORIES.map(cat => `
    <button class="category-chip ${cat.id === selectedCategory ? 'active' : ''}" data-cat="${cat.id}">
      <span>${cat.icon}</span>
      <span>${cat.name}</span>
    </button>
  `).join('');

  document.querySelectorAll('.category-chip').forEach(btn => {
    btn.addEventListener('click', () => {
      selectedCategory = btn.getAttribute('data-cat');
      document.querySelectorAll('.category-chip').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      audio.playPop();
      renderCatalog();
    });
  });
}

// 300 DRAWINGS CATALOG
function renderCatalog() {
  const query = (searchInput.value || '').toLowerCase().trim();

  const filtered = CATALOG.filter(item => {
    const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory;
    const matchesQuery = !query || item.title.toLowerCase().includes(query);
    return matchesCategory && matchesQuery;
  });

  if (filtered.length === 0) {
    catalogGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
        <div style="font-size: 3rem; margin-bottom: 8px;">🔍</div>
        <h3 style="font-family: var(--font-display); font-size: 1.4rem;">Tidak ada gambar yang cocok</h3>
        <p style="color: var(--text-muted);">Coba cari dengan kata kunci lain ya!</p>
      </div>
    `;
    return;
  }

  // Display initial batch (limit 48 for ultra smooth render, scroll/search provides the rest of 300)
  const displayItems = filtered.slice(0, 60);

  catalogGrid.innerHTML = displayItems.map(item => `
    <div class="drawing-card" data-drawing-id="${item.id}">
      <div class="drawing-thumbnail-box">
        ${item.getSvg()}
      </div>
      <div class="drawing-card-title">${item.title}</div>
      <div class="drawing-card-tag">${item.difficulty}</div>
    </div>
  `).join('');

  document.querySelectorAll('.drawing-card').forEach(card => {
    card.addEventListener('click', () => {
      const id = card.getAttribute('data-drawing-id');
      const item = CATALOG.find(d => d.id === id);
      if (item) {
        startColoring(item);
      }
    });
  });
}

// STUDIO WORKFLOW
async function startColoring(item) {
  currentDrawing = item;
  currentDrawingTitle.textContent = item.title;
  audio.playPop();

  switchScreen('studio');

  // Load SVG into Canvas Engine
  await canvasEngine.loadSvg(item.getSvg());
}

// COLOR PALETTE
function renderPalette() {
  paletteGrid.innerHTML = PALETTE_COLORS.map(color => `
    <div 
      class="color-swatch ${color === canvasEngine.currentColor ? 'active' : ''}" 
      style="background-color: ${color};" 
      data-color="${color}"
    ></div>
  `).join('');

  document.querySelectorAll('.color-swatch').forEach(swatch => {
    swatch.addEventListener('click', () => {
      const color = swatch.getAttribute('data-color');
      document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
      swatch.classList.add('active');
      canvasEngine.setColor(color);
      customColorPicker.value = color;
    });
  });

  customColorPicker.addEventListener('input', (e) => {
    const color = e.target.value;
    document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
    canvasEngine.setColor(color);
  });
}

// MODAL & EVALUATION
function handleSaveAndGrade() {
  const activeKid = profileManager.getActiveProfile();
  const mergedCanvas = canvasEngine.getMergedCanvas();

  // Run child psychology-tailored positive evaluation
  const evaluation = evaluateArtwork(mergedCanvas, activeKid.name);

  // Generate high-resolution framed JPG
  currentFramedJpgUrl = generateFramedJpg(mergedCanvas, {
    childName: activeKid.name,
    childAvatar: activeKid.avatar,
    drawingTitle: currentDrawing ? currentDrawing.title : 'Karya Mewarnai',
    stars: evaluation.stars,
    badge: evaluation.badge
  });

  // Save to kid's persistent personal gallery & add stars
  profileManager.saveArtwork({
    title: currentDrawing ? currentDrawing.title : 'Karya Ceria',
    category: currentDrawing ? currentDrawing.category : 'Mewarnai',
    stars: evaluation.stars,
    badge: evaluation.badge,
    previewDataUrl: currentFramedJpgUrl
  });

  // Update header stars badge
  renderHeaderProfile();

  // Populate Evaluation Modal
  evalBadgeIcon.textContent = evaluation.icon;
  evalTitle.textContent = `Karya Luar Biasa, ${activeKid.name}!`;
  evalStarsContainer.textContent = '⭐'.repeat(evaluation.stars);
  evalBadgeName.textContent = evaluation.badge;
  evalPraiseText.textContent = evaluation.praise;
  evalPreviewImg.src = currentFramedJpgUrl;

  // Show modal and fire celebration
  evalModal.classList.remove('hidden');
  triggerCelebration();

  // Cheerful Indonesian voice praise!
  setTimeout(() => {
    audio.speakPraise(evaluation.praise);
  }, 400);
}

// GALLERY
function renderGallery() {
  const activeKid = profileManager.getActiveProfile();
  galleryTitle.textContent = `Galeri Karya ${activeKid.name} 🌟`;

  const artworks = activeKid.gallery || [];

  if (artworks.length === 0) {
    galleryGrid.innerHTML = `
      <div style="grid-column: 1 / -1;" class="empty-gallery-state">
        <div class="empty-icon">🎨</div>
        <h3 style="font-family: var(--font-display); font-size: 1.6rem; color: var(--color-primary); margin-bottom: 8px;">
          Belum Ada Lukisan
        </h3>
        <p style="color: var(--text-muted); font-size: 1.1rem; margin-bottom: 24px;">
          Yuk, pilih gambar di katalog dan mulai warnai dengan seru!
        </p>
        <button class="btn-cute btn-primary" id="emptyStartBtn">
          Pilih Gambar Sekarang 🚀
        </button>
      </div>
    `;

    document.getElementById('emptyStartBtn')?.addEventListener('click', () => {
      audio.playPop();
      switchScreen('catalog');
    });
    return;
  }

  galleryGrid.innerHTML = artworks.map(art => `
    <div class="gallery-card">
      <img src="${art.preview}" class="gallery-card-img" alt="${art.title}">
      <div class="gallery-card-body">
        <div class="gallery-card-title">${art.title}</div>
        <div class="gallery-card-meta">
          <span style="color: #D97706; font-weight: 700;">${'⭐'.repeat(art.stars || 5)}</span>
          <span>${art.date}</span>
        </div>
        <button class="btn-cute btn-secondary redownload-art-btn" style="margin-top: 8px; padding: 8px 12px; font-size: 0.85rem;" data-img="${art.preview}" data-title="${art.title}">
          📥 Download JPG
        </button>
      </div>
    </div>
  `).join('');

  document.querySelectorAll('.redownload-art-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const url = btn.getAttribute('data-img');
      const title = btn.getAttribute('data-title');
      downloadJpgFile(url, `Karya_${activeKid.name}_${title.replace(/\s+/g, '_')}.jpg`);
      audio.playPop();
    });
  });
}

// EDIT PROFILE MODAL
function renderAvatarPicker() {
  avatarPickerGrid.innerHTML = AVATAR_OPTIONS.map(opt => `
    <button 
      type="button" 
      class="btn-cute btn-circle avatar-choice-btn ${opt.emoji === tempSelectedAvatar ? 'active' : ''}" 
      style="width: 54px; height: 54px; font-size: 1.8rem;" 
      data-emoji="${opt.emoji}"
      title="${opt.label}"
    >
      ${opt.emoji}
    </button>
  `).join('');

  document.querySelectorAll('.avatar-choice-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      tempSelectedAvatar = btn.getAttribute('data-emoji');
      document.querySelectorAll('.avatar-choice-btn').forEach(b => b.style.borderColor = '#EAE0D5');
      btn.style.borderColor = 'var(--color-primary)';
      audio.playPop();
    });
  });
}

function openEditProfileModal(profileId) {
  const profile = profileManager.getProfiles().find(p => p.id === profileId);
  if (!profile) return;

  editingProfileId = profileId;
  editNameInput.value = profile.name;
  editAgeInput.value = profile.age || 5;
  tempSelectedAvatar = profile.avatar || '🦁';

  renderAvatarPicker();
  editProfileModal.classList.remove('hidden');
}

// ATTACH EVENT LISTENERS
function attachEventListeners() {
  // Brand Logo Click -> Go to catalog
  brandBtn.addEventListener('click', () => {
    audio.playPop();
    switchScreen('catalog');
  });

  // Profile capsule click -> Go to Profile Screen
  activeKidCapsule.addEventListener('click', () => {
    audio.playPop();
    switchScreen('profile');
  });

  // Gallery Navigation button
  galleryNavBtn.addEventListener('click', () => {
    audio.playPop();
    switchScreen('gallery');
  });

  galleryBackCatalogBtn.addEventListener('click', () => {
    audio.playPop();
    switchScreen('catalog');
  });

  // Sound toggle button
  soundToggleBtn.addEventListener('click', () => {
    audio.toggleMute();
    updateSoundBtnState();
    if (!audio.isMuted) audio.playPop();
  });

  // Search input filter
  searchInput.addEventListener('input', () => {
    renderCatalog();
  });

  // Studio Back Button
  backToCatalogBtn.addEventListener('click', () => {
    audio.playPop();
    switchScreen('catalog');
  });

  // Studio Tools (Bucket, Brush, Rainbow, Eraser)
  document.querySelectorAll('.tool-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const tool = btn.getAttribute('data-tool');
      document.querySelectorAll('.tool-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      canvasEngine.setTool(tool);
    });
  });

  // Brush Size buttons
  document.querySelectorAll('.brush-size-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const size = parseInt(btn.getAttribute('data-size'), 10);
      document.querySelectorAll('.brush-size-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      canvasEngine.setBrushSize(size);
    });
  });

  // Undo / Redo / Clear
  undoBtn.addEventListener('click', () => canvasEngine.undo());
  redoBtn.addEventListener('click', () => canvasEngine.redo());
  clearBtn.addEventListener('click', () => {
    if (confirm('Yakin mau bersihkan kanvas dan warnai ulang dari awal? 😊')) {
      canvasEngine.clearColor();
    }
  });

  // Save & Grade Button
  saveAndGradeBtn.addEventListener('click', handleSaveAndGrade);

  // Evaluation Modal buttons
  downloadJpgBtn.addEventListener('click', () => {
    if (currentFramedJpgUrl) {
      const kid = profileManager.getActiveProfile();
      const filename = `Karya_${kid.name}_${(currentDrawing?.title || 'Mewarnai').replace(/\s+/g, '_')}.jpg`;
      downloadJpgFile(currentFramedJpgUrl, filename);
      audio.playPop();
    }
  });

  evalViewGalleryBtn.addEventListener('click', () => {
    evalModal.classList.add('hidden');
    audio.playPop();
    switchScreen('gallery');
  });

  evalNewDrawingBtn.addEventListener('click', () => {
    evalModal.classList.add('hidden');
    audio.playPop();
    switchScreen('catalog');
  });

  // Close modal when clicking backdrop
  evalModal.addEventListener('click', (e) => {
    if (e.target === evalModal) {
      evalModal.classList.add('hidden');
    }
  });

  // Edit Profile Modal buttons
  cancelEditProfileBtn.addEventListener('click', () => {
    editProfileModal.classList.add('hidden');
  });

  saveEditProfileBtn.addEventListener('click', () => {
    if (!editingProfileId) return;

    const newName = editNameInput.value.trim() || 'Anak Ceria';
    const newAge = parseInt(editAgeInput.value, 10) || 5;

    profileManager.updateProfile(editingProfileId, {
      name: newName,
      age: newAge,
      avatar: tempSelectedAvatar
    });

    editProfileModal.classList.add('hidden');
    renderHeaderProfile();
    renderProfileScreen();
    audio.playSparkle();
  });
}

// Start application when DOM is ready
window.addEventListener('DOMContentLoaded', init);
