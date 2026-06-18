/**
 * SYNCHRONISIERUNG ZWISCHEN BEAMER & MODERATOR
 * Nutzt localStorage und Polling
 */

class SyncSystem {
  constructor() {
    this.storageKey = 'wikinger_spieleabend_state';
    this.pollInterval = 500; // ms
    this.lastUpdate = 0;
    this.listeners = [];
  }

  /**
   * State speichern
   */
  saveState(state) {
    const data = {
      timestamp: Date.now(),
      teams: state.teams,
      scores: state.scores,
      currentGameIdx: state.currentGameIdx,
      lastBuzzedTeam: state.lastBuzzedTeam
    };
    localStorage.setItem(this.storageKey, JSON.stringify(data));
    this.broadcastUpdate(data);
  }

  /**
   * State abrufen
   */
  loadState() {
    const stored = localStorage.getItem(this.storageKey);
    return stored ? JSON.parse(stored) : null;
  }

  /**
   * Polling starten (für andere Fenster)
   */
  startPolling(onUpdate) {
    setInterval(() => {
      const state = this.loadState();
      if (state && state.timestamp > this.lastUpdate) {
        this.lastUpdate = state.timestamp;
        onUpdate(state);
      }
    }, this.pollInterval);
  }

  /**
   * Update-Listener hinzufügen
   */
  addEventListener(callback) {
    this.listeners.push(callback);
  }

  broadcastUpdate(state) {
    this.listeners.forEach(cb => cb(state));
  }

  clearState() {
    localStorage.removeItem(this.storageKey);
  }
}

// Globale Instanz
if (typeof window !== 'undefined') {
  window.syncSystem = new SyncSystem();
}
