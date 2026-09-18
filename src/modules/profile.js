/**
 * Multi-Profile Management for the 3 Children
 * Stores profile names, avatars, age, star collections, and artwork galleries.
 */

const STORAGE_KEY_PROFILES = 'ceria_kids_profiles_v1';
const STORAGE_KEY_ACTIVE = 'ceria_active_kid_id_v1';

export const AVATAR_OPTIONS = [
  { id: 'lion', emoji: '🦁', label: 'Singa Berani', bg: '#FFF0F4' },
  { id: 'rocket', emoji: '🚀', label: 'Astronot Cilik', bg: '#E8F4FD' },
  { id: 'unicorn', emoji: '🦄', label: 'Unicorn Ajaib', bg: '#FFF9E6' },
  { id: 'dino', emoji: '🦖', label: 'Dino Petualang', bg: '#EAF8ED' },
  { id: 'cat', emoji: '🐱', label: 'Kucing Imut', bg: '#FDF0FF' },
  { id: 'panda', emoji: '🐼', label: 'Panda Lucu', bg: '#F0F3F6' },
  { id: 'fox', emoji: '🦊', label: 'Rubah Cerdik', bg: '#FFF1E8' },
  { id: 'rabbit', emoji: '🐰', label: 'Kelinci Ceria', bg: '#FFEBF3' }
];

const DEFAULT_PROFILES = [
  {
    id: 'kid-1',
    name: 'Kakak',
    age: 7,
    avatar: '🦁',
    avatarBg: '#FFF0F4',
    themeColor: '#FF5E7E',
    totalStars: 15,
    gallery: []
  },
  {
    id: 'kid-2',
    name: 'Abang',
    age: 5,
    avatar: '🚀',
    avatarBg: '#E8F4FD',
    themeColor: '#4D96FF',
    totalStars: 10,
    gallery: []
  },
  {
    id: 'kid-3',
    name: 'Adek',
    age: 3,
    avatar: '🦄',
    avatarBg: '#FFF9E6',
    themeColor: '#FFD93D',
    totalStars: 8,
    gallery: []
  }
];

class ProfileManager {
  constructor() {
    this.profiles = this.loadProfiles();
    this.activeProfileId = this.loadActiveId();
  }

  loadProfiles() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY_PROFILES);
      if (saved) {
        return JSON.parse(saved);
      }
    } catch (e) {
      console.warn('Failed to load profiles:', e);
    }
    return DEFAULT_PROFILES;
  }

  saveProfiles() {
    try {
      localStorage.setItem(STORAGE_KEY_PROFILES, JSON.stringify(this.profiles));
    } catch (e) {
      console.warn('Failed to save profiles:', e);
    }
  }

  loadActiveId() {
    const savedId = localStorage.getItem(STORAGE_KEY_ACTIVE);
    if (savedId && this.profiles.some(p => p.id === savedId)) {
      return savedId;
    }
    return this.profiles[0]?.id || 'kid-1';
  }

  getProfiles() {
    return this.profiles;
  }

  getActiveProfile() {
    return this.profiles.find(p => p.id === this.activeProfileId) || this.profiles[0];
  }

  setActiveProfile(id) {
    if (this.profiles.some(p => p.id === id)) {
      this.activeProfileId = id;
      localStorage.setItem(STORAGE_KEY_ACTIVE, id);
      return true;
    }
    return false;
  }

  updateProfile(id, updates) {
    const profile = this.profiles.find(p => p.id === id);
    if (profile) {
      Object.assign(profile, updates);
      this.saveProfiles();
      return profile;
    }
    return null;
  }

  saveArtwork(artworkData) {
    const active = this.getActiveProfile();
    if (!active) return false;

    const newArt = {
      id: 'art-' + Date.now(),
      title: artworkData.title || 'Karya Indah',
      category: artworkData.category || 'Mewarnai',
      stars: artworkData.stars || 5,
      badge: artworkData.badge || 'Artis Cilik',
      date: new Date().toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      }),
      preview: artworkData.previewDataUrl // base64 jpg thumbnail
    };

    active.gallery.unshift(newArt);
    active.totalStars = (active.totalStars || 0) + (artworkData.stars || 5);
    this.saveProfiles();
    return newArt;
  }
}

export const profileManager = new ProfileManager();
