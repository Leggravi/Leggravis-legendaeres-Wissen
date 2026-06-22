/**
 * SOUND & MUSIK SYSTEM
 * Verwaltet Soundeffekte, Musik und Audio-Wiedergabe
 */

class SoundSystem {
  constructor() {
    this.sounds = {};
    this.music = null;
    this.sfxVolume = 0.7;
    this.musicVolume = 0.5;
    this.enabled = true;

    // Vordefinierte Sounds (können mit createSound() hinzugefügt werden)
    this.initializeBasicSounds();
  }

  initializeBasicSounds() {
    // Buzzer-Sound
    this.createSound('buzzer', {
      type: 'sine',
      frequency: 800,
      duration: 0.15,
      envelope: 'fast'
    });

    // Punkt-Sound
    this.createSound('point', {
      type: 'sine',
      frequency: 600,
      duration: 0.3,
      envelope: 'medium'
    });

    // Gewinner-Sound
    this.createSound('winner', {
      type: 'chord',
      frequencies: [523, 659, 784], // C E G
      duration: 0.8,
      envelope: 'slow'
    });

    // Fehler-Sound
    this.createSound('error', {
      type: 'sine',
      frequency: 300,
      duration: 0.2,
      envelope: 'fast'
    });

    // Countdown-Beep
    this.createSound('beep', {
      type: 'sine',
      frequency: 1000,
      duration: 0.1,
      envelope: 'fast'
    });
  }

  createSound(name, config) {
    this.sounds[name] = config;
  }

  playSound(soundName) {
    if (!this.enabled || !this.sounds[soundName]) return;

    try {
      const audioContext = this.getAudioContext();
      const now = audioContext.currentTime;
      const config = this.sounds[soundName];

      if (config.type === 'sine' || config.type === 'chord') {
        const frequencies = config.type === 'chord' ? config.frequencies : [config.frequency];

        frequencies.forEach((freq) => {
          const osc = audioContext.createOscillator();
          const gain = audioContext.createGain();

          osc.frequency.value = freq;
          osc.connect(gain);
          gain.connect(audioContext.destination);

          // Envelope (Lautstärke-Kurve)
          gain.gain.setValueAtTime(0, now);
          
          if (config.envelope === 'fast') {
            gain.gain.linearRampToValueAtTime(this.sfxVolume, now + 0.01);
            gain.gain.exponentialRampToValueAtTime(0.01, now + config.duration);
          } else if (config.envelope === 'slow') {
            gain.gain.linearRampToValueAtTime(this.sfxVolume, now + 0.1);
            gain.gain.exponentialRampToValueAtTime(0.01, now + config.duration);
          } else {
            gain.gain.linearRampToValueAtTime(this.sfxVolume, now + 0.05);
            gain.gain.exponentialRampToValueAtTime(0.01, now + config.duration);
          }

          osc.start(now);
          osc.stop(now + config.duration);
        });
      }
    } catch (e) {
      console.warn('Sound-System Fehler:', e);
    }
  }

  getAudioContext() {
    if (!window.audioContext) {
      window.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }
    return window.audioContext;
  }

  setVolume(type, value) {
    if (type === 'sfx') this.sfxVolume = Math.max(0, Math.min(1, value));
    if (type === 'music') this.musicVolume = Math.max(0, Math.min(1, value));
  }

  toggleEnabled(enabled) {
    this.enabled = enabled;
  }
}

// Globale Sound-Instanz
if (typeof window !== 'undefined') {
  window.soundSystem = new SoundSystem();
}
