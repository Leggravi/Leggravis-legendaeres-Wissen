# 🎯 Spiel-Entwicklungs-Guide

Dieser Guide zeigt, wie man neue Spiele hinzufügt und das System erweitert.

## 🏗️ Architektur-Überblick

```
js/games-config.js (Spiel-Definitionen)
    ↓
js/buzzer-system.js (Eingabe)
    ↓
moderator.html (Kontrolle) ← → beamer.html (Anzeige)
    ↓
js/sound-system.js (Feedback)
```

## 🎮 Neues Spiel Hinzufügen

### Schritt 1: Spiel in `js/games-config.js` definieren

```javascript
{
  id: 'my_game',
  name: 'Mein neues Spiel',
  rune: '🎯',
  color: '#00d4ff',
  type: 'buzzer_race',  // Spieltyp
  duration: 120,         // Sekunden
  description: 'Kurze Beschreibung für Beamer',
  rules: 'Ausführliche Regeln für Moderator',
  typeConfig: {
    // Typ-spezifische Einstellungen
    rounds: 3
  }
}
```

### Schritt 2: In `GAMES_CONFIG` Array einfügen

```javascript
const GAMES_CONFIG = [
  // ... existierende Spiele ...
  {
    id: 'my_game',
    // ... wie oben ...
  }
];
```

### Schritt 3: Auf Beamer & Moderator testen

## 🔨 Spieltypen Erweitern

### Beispiel: Neuer Spieltyp `reaction_time`

#### 1. In `games-config.js` verwenden:
```javascript
{
  id: 'reaction',
  name: 'Reaktions-Test',
  type: 'reaction_time',
  typeConfig: {
    rounds: 5,
    delayMs: 2000
  }
}
```

#### 2. In `beamer.html` UI hinzufügen:

```html
<div id="gameStateContent"></div>
```

Im JavaScript:
```javascript
if (game.type === 'reaction_time') {
  content.innerHTML = `
    <div class="buzzer-display" id="buzzDisplay">
      Bereit...
    </div>
  `;
  // Spiellogik
}
```

## 🔊 Soundeffekte Erweitern

### Neue Sounds in `js/sound-system.js`:

```javascript
// In initializeBasicSounds()
this.createSound('victory', {
  type: 'chord',
  frequencies: [523, 659, 784, 1047], // C E G C
  duration: 1.0,
  envelope: 'slow'
});
```

### Sound abspielen:
```javascript
window.soundSystem.playSound('victory');
```

## 📊 Daten-Struktur

### Game Object
```javascript
{
  id: string,              // Unique ID
  name: string,            // Display Name
  rune: string,            // Icon/Rune
  color: hex,              // Accent Color
  type: enum,              // buzzer_race | timer | etc.
  duration: number,        // Seconds
  description: string,     // Short desc
  rules: string,           // Full rules
  typeConfig: object,      // Type-specific config
  isJoker?: boolean        // True = Joker-Spiel
}
```

### State Object
```javascript
{
  teams: string[],         // 3 Team-Namen
  scores: number[],        // 3 Punkte
  currentGameIdx: number,  // Index in games array
  lastBuzzedTeam: number   // 0, 1, oder 2
}
```

## 🎨 UI-Komponenten

### Button
```html
<button class="btn btn-primary">Text</button>
<button class="btn btn-small">Text</button>
```

### Card
```html
<div class="panel">
  <div class="panel-title">Titel</div>
  <!-- Content -->
</div>
```

### Display
```html
<div class="buzzer-display">Anzeige Text</div>
<div class="timer-display">00:00</div>
```

## 🔄 Arbeitsablauf für neues Spiel

1. **Konzept**: Spieltyp bestimmen
   - buzzer_race? timer? moderiert?

2. **Config**: In `games-config.js` eintragen
   - ID, Name, Rune, Regeln

3. **UI**: In beamer.html & moderator.html
   - Spieltyp-spezifische UI

4. **Logik**: Buzzer/Timer Handling
   - Events registrieren
   - Punkte vergeben

5. **Sounds**: Feedback-Sounds
   - Buzzer → playSound()

6. **Test**: Beamer + Moderator testen
   - Alle Szenarien durchspielen

## 🐛 Debugging

### Browser-Konsole (F12)
```javascript
// State anschauen
window.beamerState
window.moderatorState

// Buzzer testen
window.buzzer.registerBuzz(0) // Team 0 buzzert

// Sound testen
window.soundSystem.playSound('buzzer')

// Spiele anschauen
window.Games.all()
```

### LocalStorage-Sync debuggen
```javascript
localStorage.getItem('wikinger_spieleabend_state')
window.syncSystem.loadState()
```

## 📈 Performance-Tipps

1. **Buzzer-Debounce**: Min. 50ms zwischen Events
2. **Sound-Limiting**: Max 3 Sounds gleichzeitig
3. **Display-Updates**: requestAnimationFrame nutzen
4. **Event-Listener**: Immer remove nach Game Ende

## 🔐 Best Practices

- **IDs**: `kebab-case` (z.B. `my_game_name`)
- **Farben**: CSS-Variablen nutzen
- **Sounds**: Kurz halten (<500ms)
- **Rules**: Für Beamer kurz, für Moderator lang
- **Duration**: Realistisch schätzen (±30%)

## 🚀 Integration mit externen Tools

### WebSocket (für Remote)
```javascript
class RemoteSync {
  constructor(wsUrl) {
    this.ws = new WebSocket(wsUrl);
  }
  
  sendState(state) {
    this.ws.send(JSON.stringify(state));
  }
}
```

### Mobile-App (Buzzer)
```javascript
// Über WebSocket oder Local API
// Würde Native-App oder PWA sein
```

## 📚 Weitere Spiel-Ideen

- **Memory**: Paare finden
- **Zahlenraten**: Zahl 1-100 raten
- **Schnellrechnen**: Mathe-Aufgaben
- **Wortkette**: Alphabetische Wortkette
- **Nachsprechen**: Tongue Twister
- **Balance**: Stift balancieren
- **Sehen**: Was ist anders?
- **Hören**: Sounds erraten

---

**Viel Spaß beim Entwickeln! 🎮**
