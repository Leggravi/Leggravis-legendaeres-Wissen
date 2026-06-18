/**
 * BUZZER-SYSTEM
 * Hochfrequentes Buzzer-System für 3 Teams
 * Tasten 1, 2, 3 = Team 1, 2, 3
 * Unterstützt >30 clicks/second
 */

class BuzzerSystem {
  constructor(options = {}) {
    this.teamCount = options.teamCount || 3;
    this.buzzerKeys = ['1', '2', '3'];
    this.buzzerQueue = []; // Queue für gleichzeitige Buzzer
    this.callbacks = {
      onBuzz: options.onBuzz || (() => {}),
      onMultiBuzz: options.onMultiBuzz || (() => {}),
    };
    this.enabled = false;
    this.debounceMs = options.debounceMs || 50; // Minimale Zeit zwischen Buzzer-Erkennungen
    this.lastBuzzTime = {}; // Letzte Zeit pro Team

    // Keyboard-Listener
    this.setupKeyboardListener();
  }

  setupKeyboardListener() {
    document.addEventListener('keydown', (e) => {
      if (!this.enabled) return;
      if (!this.buzzerKeys.includes(e.key)) return;
      
      e.preventDefault();
      this.registerBuzz(parseInt(e.key) - 1);
    });
  }

  registerBuzz(teamIdx) {
    if (teamIdx < 0 || teamIdx >= this.teamCount) return;

    const now = Date.now();
    const lastTime = this.lastBuzzTime[teamIdx] || 0;

    // Debounce: Verhindere doppelte Erfassung
    if (now - lastTime < this.debounceMs) return;

    this.lastBuzzTime[teamIdx] = now;
    this.buzzerQueue.push(teamIdx);

    // Callback nach kurzer Verzögerung (10ms) um andere gleichzeitige Buzzer zu erfassen
    if (this.buzzerQueue.length === 1) {
      setTimeout(() => {
        this.processBuzzerQueue();
      }, 10);
    }
  }

  processBuzzerQueue() {
    if (this.buzzerQueue.length === 0) return;

    // Eindeutige Team-IDs aus der Queue
    const uniqueTeams = [...new Set(this.buzzerQueue)];
    
    if (uniqueTeams.length === 1) {
      // Ein Team buzzert
      const teamIdx = uniqueTeams[0];
      this.callbacks.onBuzz(teamIdx);
    } else {
      // Mehrere Teams gleichzeitig (Tauziehen, etc.)
      this.callbacks.onMultiBuzz(uniqueTeams);
    }

    this.buzzerQueue = [];
  }

  enable() {
    this.enabled = true;
    this.lastBuzzTime = {};
  }

  disable() {
    this.enabled = false;
  }

  reset() {
    this.buzzerQueue = [];
    this.lastBuzzTime = {};
  }
}

// Export für Module
if (typeof module !== 'undefined' && module.exports) {
  module.exports = BuzzerSystem;
}
