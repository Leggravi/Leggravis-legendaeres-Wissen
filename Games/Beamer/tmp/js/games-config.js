/**
 * SPIELKONFIGURATION
 * Alle Spiele und ihre Einstellungen
 * 3 Teams fest: Team 1, Team 2, Team 3
 */

const GAMES_CONFIG = [
  {
    id: 'bergung',
    name: 'Die Bergung',
    rune: '⚔',
    color: '#00d4ff',
    type: 'buzzer_race',
    duration: 120,
    description: 'Strand. Gegenstände verteilt. Wer zuerst buzzert und das richtige Objekt bringt, gewinnt!',
    rules: 'Pro Runde ein Gegenstand ausgerufen. Schnellster Buzzer (Taste 1-3) gewinnt einen Punkt. 3 Runden. Dann → Punkte vergeben.',
    typeConfig: {
      rounds: 3
    }
  },

  {
    id: 'schmied',
    name: 'Der Schmied',
    rune: '🔨',
    color: '#f472b6',
    type: 'counter',
    duration: 120,
    description: 'Das Dorf braucht Schilde! 60 Sekunden – wer am meisten auf die Trommel schlägt?',
    rules: 'Schnellste Buzzer-Drücke in 60 Sekunden zählen. Tasten 1-3 drücken! Nach 60s: Team mit den meisten Drücken gewinnt.',
    typeConfig: {
      timeSeconds: 60,
      countGoal: 100 // Optionaler Bonus
    }
  },

  {
    id: 'ankertau',
    name: 'Das Ankertau',
    rune: '🪢',
    color: '#34d399',
    type: 'tug_of_war',
    duration: 300,
    description: 'Tauziehen zwischen Teams! Wer zuerst drückt = wer überwältigt die andere Seite?',
    rules: 'Team 1 vs 2, dann 1 vs 3, dann 2 vs 3. Pro Match: Wer zuerst buzzert (5 sec Fenster), gewinnt einen Punkt.',
    typeConfig: {
      matchDuration: 5,
      matches: ['1vs2', '1vs3', '2vs3']
    }
  },

  {
    id: 'keks',
    name: 'Die eiserne Ration',
    rune: '🍪',
    color: '#fbbf24',
    type: 'timer',
    duration: 180,
    description: 'Keks auf der Stirn – ohne Hände in den Mund! Wer zuerst? Oder eine bestimmte Zeit durchhalten?',
    rules: 'Ein Spieler pro Team: Nur mit Kopfbewegungen + Gesicht. Hände zählen nicht. Fällt runter = raus. Wer schafft es zuerst?',
    typeConfig: {
      seconds: 120,
      label: 'Verbleibende Zeit'
    }
  },

  {
    id: 'quiz',
    name: 'Rat der Ältesten',
    rune: '🧠',
    color: '#c084fc',
    type: 'quiz',
    duration: 180,
    description: 'Knifflige Fragen! Team das buzzert, muss antworten. Richtig = 1 Punkt.',
    rules: 'Moderator liest Frage vor. Erstes buzzerndes Team antwortet (Taste 1-3). Moderator sagt: Richtig oder Falsch.',
    typeConfig: {
      questions: [
        { q: 'Wie viele Tier von jeder Art nahm NOAH auf die Arche?', a: 'Zwei' },
        { q: 'Du überholst den Zweiten. Welcher Platz bist du jetzt?', a: 'Zweiter' },
        { q: 'Schläger + Ball kosten 1,10€. Schläger kostet 1€ mehr. Ball kostet?', a: '0,10€' },
        { q: 'Sarahs Vater hat 5 Töchter: Lala, Lele, Lili, Lolo, und...?', a: 'Sarah' },
        { q: 'Was zündest du ZUERST an: Streichholz, Kerze, Lampe oder Kamin?', a: 'Streichholz' }
      ]
    }
  },

  {
    id: 'fjordkurs',
    name: 'Der Fjordkurs',
    rune: '⌛',
    color: '#00d4ff',
    type: 'precision',
    duration: 120,
    description: 'Timer läuft – stoppe ihn SO NAH WIE MÖGLICH an der Zielzeit!',
    rules: 'Timer läuft sichtbar. Jedes Team reißt Buzzer auf exakt 30 Sekunden. Wer am nächsten dran, gewinnt einen Punkt. 3 Runden.',
    typeConfig: {
      targetSeconds: 30,
      rounds: 3
    }
  },

  {
    id: 'wettstreit',
    name: 'Das Turnier',
    rune: '🎯',
    color: '#f472b6',
    type: 'moderiert',
    duration: 300,
    description: 'Sportlicher Wettstreit: Klobürsten-Klau-Spiel mit Tore! Wer hat am Ende noch welche?',
    rules: 'Abgegrenztes Feld. Klobürsten sind Punkte. Nur mit Bürste darf buzzern (= Tor). Team mit meisten Bürsten nach Zeit gewinnt.',
    typeConfig: {
      timeSeconds: 180
    }
  },

  {
    id: 'schildwall',
    name: 'Der Schildwall',
    rune: '🛡️',
    color: '#34d399',
    type: 'endurance',
    duration: 300,
    description: 'Wandsitzen! Beine 90°, Rücken an Wand. Wer hält am längsten durch?',
    rules: 'Jeder Spieler pro Team wandsitzt. Wenn man nicht mehr kann: Buzzer drücken (oder Moderator sagt Bescheid). Längste Zeit = Punkt.',
    typeConfig: {}
  },

  {
    id: 'waechter',
    name: 'Der blinde Wächter',
    rune: '👁️',
    color: '#fbbf24',
    type: 'moderiert',
    duration: 180,
    description: 'Ein verbundener Wächter mit Schwimmnudel. Anderes Team muss an Buzzer. Wer schafft es ohne getroffen zu werden?',
    rules: 'Ein Spieler sitzt (Augen zu/verbunden), hält Schwimmnudel. Buzzer unter dem Stuhl. Gegner müssen drücken ohne Schlag. Counts: Wie viele?',
    typeConfig: {}
  },

  // JOKER-SPIELE (geheim, zufällig verteilt)
  {
    id: 'joker_1',
    name: 'Wahl der Götter',
    rune: '✨',
    color: '#c084fc',
    type: 'joker',
    duration: 30,
    isJoker: true,
    description: '[GEHEIM]',
    rules: 'Das wählende Team gewinnt einfach diese Runde! Kein Spiel, einfach Punkte.',
    typeConfig: {}
  },

  {
    id: 'joker_2',
    name: 'Wahl des Schicksals',
    rune: '✨',
    color: '#c084fc',
    type: 'joker',
    duration: 30,
    isJoker: true,
    description: '[GEHEIM]',
    rules: 'Das wählende Team gewinnt einfach diese Runde! Kein Spiel, einfach Punkte.',
    typeConfig: {}
  },

  {
    id: 'joker_3',
    name: 'Odin\'s Gnade',
    rune: '✨',
    color: '#c084fc',
    type: 'joker',
    duration: 30,
    isJoker: true,
    description: '[GEHEIM]',
    rules: 'Das wählende Team gewinnt einfach diese Runde! Kein Spiel, einfach Punkte.',
    typeConfig: {}
  }
];

/**
 * Spiele-Objekt für einfacheren Zugriff
 */
const Games = {
  all: () => GAMES_CONFIG,
  
  byId: (id) => GAMES_CONFIG.find(g => g.id === id),
  
  byType: (type) => GAMES_CONFIG.filter(g => g.type === type),
  
  getJokers: () => GAMES_CONFIG.filter(g => g.isJoker),
  
  getNonJokers: () => GAMES_CONFIG.filter(g => !g.isJoker),
  
  shuffleWithJokers: () => {
    const nonJokers = Games.getNonJokers();
    const jokers = Games.getJokers();
    
    // Joker zufällig im Spiel verteilen
    const result = [...nonJokers];
    jokers.forEach(joker => {
      const idx = Math.floor(Math.random() * (result.length + 1));
      result.splice(idx, 0, joker);
    });
    return result;
  }
};

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { GAMES_CONFIG, Games };
}
