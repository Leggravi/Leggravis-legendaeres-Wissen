# 🎮 Wikinger Spieleabend – Überarbeitete Version

Komplette Überarbeitung des Spieleabend-Programms für 3 Teams mit modernem Buzzer-System, Soundeffekten und zwei separaten Websites.

## 🚀 Features

✅ **Zwei separate Websites:**
- **BEAMER** (beamer.html) – Publikum/Zuschauer mit großer Anzeige
- **MODERATOR** (moderator.html) – Spielleitung & Kontrolle

✅ **3 Teams fest**
- Tasten 1, 2, 3 für Buzzer

✅ **Hochfrequentes Buzzer-System**
- Unterstützt >30 Buzzer pro Sekunde
- Gleichzeitige Buzzer werden erkannt

✅ **Soundeffekte & Musik**
- Buzzer-Sound
- Punkt-Sound
- Gewinner-Sound
- Einstellbare Lautstärke

✅ **Neue & überarbeitete Spiele:**
- Die Bergung (Buzzer Race)
- Der Schmied (Counter/Schläge zählen)
- Das Ankertau (Tauziehen)
- Die eiserne Ration (Timer-Spiel)
- Rat der Ältesten (Quiz mit Buzzer)
- Der Fjordkurs (Precision Timer)
- Das Turnier (moderiert)
- Der Schildwall (Endurance/Wandsitzen)
- Der blinde Wächter (moderiert)
- **3 Joker-Spiele** (geheim, zufällig verteilt) ✨

✅ **Moderne Grafik**
- Orbitron & Fredoka Schriftarten
- Gradients & Glow-Effekte
- Responsive Design

## 📁 Dateien

```
Games/Beamer/
├── index.html                 # Startseite mit Links
├── beamer.html               # Publikums-Website
├── moderator.html            # Moderator-Website
├── js/
│   ├── buzzer-system.js      # Buzzer-Input-Handling
│   ├── sound-system.js       # Sound & Audio
│   └── games-config.js       # Spiel-Konfiguration
└── README.md                 # Diese Datei
```

## 🎯 Schnellstart

### 1. Beide Websites öffnen
```bash
# Terminal 1: Beamer-Website im Vollbild
# Terminal 2: Moderator-Website auf Laptop/Tablet
```

### 2. Im Browser
1. **Beamer** (beamer.html): 
   - Team-Namen eingeben
   - "SPIELEABEND STARTEN" klicken
   - Spiel anzeigen lassen

2. **Moderator** (moderator.html):
   - Team-Namen anpassen (optional)
   - Spiel wählen aus der Liste
   - Buzzer testen
   - Punkte vergeben
   - Timer nutzen

### 3. Tastenbedienung
- `1`, `2`, `3` = Buzzer Teams
- `Space` = Timer Start/Stop (Moderator)

## 🔊 Buzzer-System

### How It Works
```javascript
// Tasten 1, 2, 3 registrieren
// Automatische Schallplattenerkennung
// Gleichzeitige Buzzer werden erfasst
```

### High-Frequency Support
- Debounce: 50ms (verhindert Doppelerfassung)
- Queue-Verarbeitung: 10ms Fenster
- Bis zu 30+ clicks/second möglich

### Beispiel: Schmied-Spiel
```
Team 1 drückt 47 mal
Team 2 drückt 52 mal (GEWINNER!)
Team 3 drückt 41 mal

Alle Drücke werden gezählt, auch wenn gleichzeitig
```

## 🎮 Spiele-Typen

### 1. **buzzer_race** – Wer buzzert zuerst?
- Erste Buzzer gewinnt
- Z.B.: "Die Bergung"

### 2. **counter** – Buzzer-Drücke zählen
- Wer drückt am meisten in X Sekunden?
- Z.B.: "Der Schmied" (60 Sekunden, >100 Drücke)

### 3. **tug_of_war** – Tauziehen
- Team 1 vs 2, 1 vs 3, 2 vs 3
- Wer zuerst in 5-sec-Fenster?

### 4. **timer** – Countdown-Timer
- Moderator steuert Timer
- Z.B.: "Die eiserne Ration" (120 Sekunden)

### 5. **precision** – Auf Sekunde genau stoppen
- Timer läuft, auf Zielzeit stoppen
- Z.B.: "Der Fjordkurs" (30 Sekunden)

### 6. **endurance** – Durchhaltevermögen
- Spieler eliminieren sich selbst (Buzzer)
- Letzter steht, gewinnt
- Z.B.: "Der Schildwall"

### 7. **quiz** – Fragen + Buzzer
- Frage vorlesen
- Erstes Team buzzert, antwortet
- Z.B.: "Rat der Ältesten"

### 8. **moderiert** – Frei spielbar
- Keine spezielle UI
- Moderator erklärt, was passiert
- Z.B.: "Das Turnier" (Klobürsten-Spiel)

### 9. **joker** – Geheim!
- Team gewinnt einfach automatisch
- Zufällig im Spiel verteilt
- 3 Joker insgesamt

## 📋 Spiel-Liste

| Spiel | Rune | Typ | Dauer | Besonderheit |
|-------|------|-----|-------|--------------|
| Die Bergung | ⚔ | buzzer_race | 2 min | Einfach, schnell |
| Der Schmied | 🔨 | counter | 2 min | High-Frequency! |
| Das Ankertau | 🪢 | tug_of_war | 5 min | 3x gegeneinander |
| Die eiserne Ration | 🍪 | timer | 3 min | Mit Keks |
| Rat der Ältesten | 🧠 | quiz | 3 min | 5 Fragen |
| Der Fjordkurs | ⌛ | precision | 2 min | 3 Runden à 30s |
| Das Turnier | 🎯 | moderiert | 5 min | Klobürsten-Spiel |
| Der Schildwall | 🛡️ | endurance | 5 min | Wandsitzen |
| Der blinde Wächter | 👁️ | moderiert | 3 min | Mit Schwimmnudel |
| Wahl der Götter | ✨ | joker | 0 min | GEHEIM! |
| Wahl des Schicksals | ✨ | joker | 0 min | GEHEIM! |
| Odin's Gnade | ✨ | joker | 0 min | GEHEIM! |

## 🔧 Konfiguration

### Team-Namen ändern (Beamer)
1. Team-Namen eingeben vor Start
2. "SPIELEABEND STARTEN"

### Spiel-Reihenfolge
- Joker werden zufällig verteilt
- Keine feste Reihenfolge
- Spiele können wiederholt werden (aktivieren)

### Soundeffekte
- Moderator: Lautstärke-Slider rechts oben
- Beeper testen: "Beep testen" Button
- Alle Sounds sind synthetisch (kein Download nötig)

## 🎨 Design-Features

### Schriftarten
- **Orbitron** – Futuristisch, für Titel
- **Fredoka** – Modern, gut lesbar

### Farben
- Blau: #00d4ff (Accent)
- Lila: #c084fc (Primary)
- Pink: #f472b6 (Highlight)
- Gold: #fbbf24 (Winner)

### Animationen
- Gradient Shimmer
- Pulse Effects
- Glow/Neon Style
- Smooth Transitions

## 🐛 Troubleshooting

### Buzzer funktioniert nicht?
1. Moderator-Website: "Buzzer testen" Button klicken
2. Browser-Konsole öffnen (F12)
3. Taste 1, 2, 3 drücken
4. Sollte im Log erscheinen: "Team X buzzed!"

### Sound-Problem?
1. Browser-Lautsprecher testen
2. Moderator: Lautstärke-Slider erhöhen
3. "Beep testen" Button drücken
4. Falls immer noch stumm: Browser möchte Permission für Audio

### Beamer & Moderator nicht synchron?
- Aktuell: Manuelle Synchronisation
- Beide Browser-Fenster sollten die gleichen Team-Namen haben
- Punkte müssen manuell eingegeben werden

### Tasten-Inputs funktionieren?
- Nur wenn Focus auf Browser ist (nicht im Input-Feld)
- F11 = Vollbild-Modus
- In Beamer: Klick auf Fenster, dann Tasten

## 🚀 Zukünftige Features

- WebSocket-Synchronisation zwischen Beamer & Moderator
- Mehr Soundeffekte & Musik
- Score-Statistiken
- Spiel-Wiederholungen
- Mobile Buzzer-App
- Dark/Light Theme

## 📝 Änderungen zur Originalversion

✅ **Raus:**
- Ehrenwache-Spiel
- Lange Erklärungen

✅ **Neu:**
- Buzzer-System für 3 Teams
- 3 Joker-Spiele
- Soundeffekte & Audio
- Zwei separate Websites
- Moderne UI mit Orbitron/Fredoka
- High-Frequency Buzzer Support
- Quiz-Verwaltung im Moderator

✅ **Überarbeitet:**
- Alle Spiele für 3 Teams optimiert
- Buzzer-Integration
- Moderne Schriftarten & Farben

## 💡 Tipps für erfolgreiche Nutzung

1. **Test vor dem Event:** Buzzer testen, Sound checken
2. **Beide Fenster sichtbar:** Beamer groß, Moderator auf Tablet
3. **Vorlesen:** Regeln beim Spiel erklären
4. **Punkte schnell:** Right-Click = -1 Punkt (in Zukunft)
5. **Pausen:** Nach 4-5 Spielen kurze Pause
6. **Spannung:** Joker-Spiele unerwartet halten!

## 📧 Support

- Fehler? Browser-Konsole checken (F12 → Console)
- Sound-Problem? Lautstärke-Slider testen
- Buzzer funktioniert nicht? Taste 1-3 auf Moderator testen

---

**Version:** 2.0 (Überarbeitet)  
**Letzte Änderung:** Mai 2026  
**Creator:** Wikinger Spieleabend Team 🏰
